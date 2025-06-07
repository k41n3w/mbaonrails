require_relative "./priority_queue"
require_relative "./dynamic_thread_pool"

pool = DynamicThreadPool.new(max_threads: 4)

10.times do |i|
  pool.schedule(:low) { sleep 1; puts "Tarefa baixa #{i} concluída" }
end

5.times do |i|
  pool.schedule(:high) { sleep 0.5; puts "Tarefa prioritária #{i} concluída" }
end

3.times do |i|
  pool.schedule(:medium) { sleep 0.75; puts "Tarefa média #{i} concluída" }
end

# Não precisa de sleep ou await manual – o pool garante que tudo finalize
pool.shutdown