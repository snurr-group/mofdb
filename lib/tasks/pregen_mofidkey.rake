namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task keys: :environment do
    mofkey_failures = 0
    mofkey_successes = 0
    mofid_failures = 0
    mofid_successes = 0

    FileUtils.rm_rf(Rails.root.join("tmp","mofid"))
    FileUtils.rm_rf(Rails.root.join("tmp","mofid-out"))
    Dir.mkdir(Rails.root.join("tmp","mofid").to_s)
    Dir.mkdir(Rails.root.join("tmp","mofid-out").to_s)

    i = 0
    size = Mof.all.size
    batch_size = 20
    Mof.all.where(mofkey: nil).find_in_batches(batch_size: batch_size) do |batch|
      i = i + batch_size

      # write cifs to delete tmp
      batch.each do |mof|
        mof.write_cif_to_file
      end

      out, err, st = IO.popen([Rails.root.join("mofid", "Scripts","run_folder.sh").to_s,
                               Rails.root.join("tmp", "mofid").to_s,
                               Rails.root.join("tmp", "mofid-out").to_s]).read

      # Parse MOFids
      results = File.open(Rails.root.join("tmp", "mofid-out", "folder_mofid.smi"), 'r')
      results.each_line do |line|
        begin
          update_mofid(line)
          mofid_successes += 1
        rescue
          mofid_failures += 1
        end
      end
      results

      # Parse MOFkeys
      results = File.open(Rails.root.join("tmp", "mofid-out", "folder_mofkey.tsv"), 'r')
      results.each_with_index do |line, line_number|
        next if line_number == 0
        begin
          update_mofkey(line)
          mofkey_successes += 1
        rescue
          mofkey_failures += 1
        end
      end
      results.close
      puts "---- % Complete: #{puts i.to_f / size.to_f}%"
      puts "Mofkey: succeeded: #{mofkey_successes} failed: #{mofkey_failures}"
      puts "Mofid: succeeded: #{mofid_successes} failed: #{mofid_failures}"
    end
    puts "%%%%%%%% FINISHED %%%%%%%%"
    puts "Mofkey: succeeded: #{mofkey_successes} failed: #{mofkey_failures}"
    puts "Mofid: succeeded: #{mofid_successes} failed: #{mofid_failures}"

    FileUtils.rm_rf(Rails.root.join("tmp", "mofid"))
    FileUtils.rm_rf(Rails.root.join("tmp", "mofid-out"))

  end
end
#
# def update_mofid(line)
#   line = line.split(";tmp-")
#   mof = Mof.find line[1]
#   mof.update(mofid: line[0])
# end
#
# def update_mofkey(line)
#   line = line.split("\t")
#   return if line[1] == "\n"
#   mof = Mof.find line[0][4..line[0].size - 5] # tmp-32.cif --> 32
#   mofkey = line[1].chomp! # Remove trailing \n
#   mof.update(mofkey: mofkey)
# end