namespace :load do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "Import all csv files from mofid/mofkey"
  suc = 0
  fail = 0
  csvs = Dir.entries(Rails.root.join("lib", "assets", "mofid"))
  len = csvs.size
  task csv: :environment do
    csvs.each do |file|
      next if file[file.size - 4, file.size] != ".csv"
      results = File.open(Rails.root.join("lib", "assets", "mofid", file), 'r')

      results.each_with_index do |line, line_number|
        begin
          line = line.split(",")
          mofid = line[1]
          mofkey = line[2]
          mof = Mof.find(line[0])
          mof.update(mofid: mofid, mofkey: mofkey)
          suc += 1
        rescue
          fail += 1
        end
      end
      results.close
    end
    puts "suc: #{suc}, fail: #{fail}, out of: #{len}"
  end
end
end
