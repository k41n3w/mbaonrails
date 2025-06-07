require "thread"

class PriorityQueue
  PRIORITY_LEVELS = [:high, :medium, :low]

  def initialize
    @queues = PRIORITY_LEVELS.map { |p| [p, Queue.new] }.to_h
    @mutex = Mutex.new
  end

  def push(task, priority = :medium)
    raise ArgumentError, "Prioridade inválida" unless @queues.key?(priority)
    @queues[priority] << task
  end

  def pop
    loop do
      @mutex.synchronize do
        PRIORITY_LEVELS.each do |priority|
          return @queues[priority].pop(true) if !@queues[priority].empty?
        end
      end
      sleep 0.01
    end
  rescue ThreadError
    retry
  end

  def empty?
    @queues.values.all?(&:empty?)
  end
end
