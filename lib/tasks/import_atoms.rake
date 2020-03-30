def work(queue)
  Rails.application.executor.wrap do
    while not queue.empty?
      puts queue.size if queue.size%100 == 0
      mof = queue.pop()
      mof.write_cif_to_file
      out = `#{Rails.root.join("lib", "tasks", "atoms.py")} #{Rails.root.join("tmp", "id-" + mof.id.to_s + ".cif")}`
      atoms = out.gsub("]", "").gsub("[", "").gsub("\n", "").gsub("'", "").gsub(" ", "").split(",")
      atoms = atoms.map { |atom| Element.find_by(symbol: atom) }
      mof.elements = atoms
      mof.delete_cif
    end
  end
end


namespace :load do
  # Import all mofid/mofkey in /lib/assets/mofid/*.csv
  desc "Import all atom from cif files"
  task atoms: :environment do
    num_threads = 12
    queue = Queue.new
    Mof.all.take(100).each do |mof|
      queue << mof
    end
    puts "All mofs enqueued"
    threads = []
    num_threads.times {
      threads << Thread.new { work(queue) } }
    threads.each do |t|
      t.join
    end
    puts "Done!"
  end
end
