require_relative "priority_queue"

class DynamicThreadPool
  def initialize(min_threads: 2, max_threads: 10)
    @min_threads = min_threads
    @max_threads = max_threads
    @queue = PriorityQueue.new
    @threads = []
    @running = true
    @mutex = Mutex.new
    start_threads(@min_threads)
    monitor_threads
  end

  def schedule(priority = :medium, &block)
    raise ArgumentError, "Forneça um bloco para a tarefa" unless block_given?

    @queue.push(block, priority)
    maybe_spawn_thread
  end

  def shutdown
    # Aguarda até que todas as tarefas da fila sejam processadas
    sleep 0.1 while !queue_empty?

    # Agora pode parar o loop das threads
    @running = false

    # Aguarda todas as threads ativas terminarem
    @threads.each(&:join)
  end

  private

  def start_threads(count)
    count.times { spawn_worker }
  end

  def spawn_worker
    thread = Thread.new do
      while @running || !@queue.empty?
        task = @queue.pop
        begin
          task.call
        rescue => e
          puts "Erro ao executar tarefa: #{e.message}"
        end
      end
    end
    @threads << thread
  end

  def maybe_spawn_thread
    @mutex.synchronize do
      alive = @threads.select(&:alive?)
      if alive.size < @max_threads
        spawn_worker
      end
      @threads = alive
    end
  end

  def monitor_threads
    Thread.new do
      loop do
        break unless @running
        @mutex.synchronize do
          @threads.reject! { |t| !t.alive? }
        end
        sleep 0.5
      end
    end
  end

  def queue_empty?
    @queue.empty?
  end

end

