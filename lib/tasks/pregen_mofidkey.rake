namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task keys: :environment do
    FileUtils.rm_rf(Rails.root.join("tmp","mofid"))
    FileUtils.rm_rf(Rails.root.join("tmp","mofid-out"))
    Dir.mkdir(Rails.root.join("tmp","mofid").to_s)
    Dir.mkdir(Rails.root.join("tmp","mofid-out").to_s)

    i = 0
    size = Mof.all.size
    Mof.all.where(mofkey: nil).find_in_batches(batch_size: 20) do |batch|
      i = i + 1000
      puts i.to_f / size.to_f

      # write cifs to delete tmp
      batch.each do |mof|
        mof.write_cif_to_file
      end

      out, err, st = IO.popen([Rails.root.join("mofid", "Scripts","run_folder.sh").to_s,
                               Rails.root.join("tmp", "mofid").to_s,
                               Rails.root.join("tmp", "mofid-out").to_s]).read

      results = File.open(Rails.root.join("tmp","mofid-out","results_part.txt"),'r')

      group = ["","",""] # 3 lines in output file, 1st line is our internal id, 2nd is mofid, 3rd is mofkey
      i = 0
      results.each_line do |line|
        i=0 if line[0] == "*"
        group[i%3] = line
        i += 1
        if i == 3
          parse_keys_and_update_mof(group)
          i=0
        end
      end

      # puts text
      results.close

      # delete tmp cif files
      # batch.each do |mof|
      #   mof.delete_cif
      # end

      raise("Done")

    end

    FileUtils.rm_rf(Rails.root.join("tmp","mofid"))
    FileUtils.rm_rf(Rails.root.join("tmp","mofid-out"))

  end
end

def parse_keys_and_update_mof(lines)
  # array of three lines of text
  puts "----"
  id = lines[0].split("tmp-")[1]
  mofid = lines[1]
  mofkey = lines[2][1..lines[2].size]
  mof = Mof.find(id)
  mof.update(mofid: mofid, mofkey: mofkey)
  puts "----"
end
