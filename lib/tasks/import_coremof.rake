namespace :load do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task core2: :environment do
    data = Hash.new
    data[:mofkey_failures] = 0
    data[:mofkey_successes] = 0
    data[:mofid_failures] = 0
    data[:mofid_successes] = 0

    def print_results(data)
      puts "Mofkey: succeeded: #{data[:mofkey_successes]} failed: #{data[:mofkey_failures]}"
      puts "Mofid: succeeded: #{data[:mofid_successes]} failed: #{data[:mofid_failures]}"
    end

    results = File.open(Rails.root.join("lib", "assets", "core_mofid.smi"), 'r')
    results.each_with_index do |line,line_number|
      print_results(data) if line_number % 100 == 0
      begin
        update_mofid(line)
        data[:mofid_successes] += 1
      rescue
        data[:mofid_failures] += 1
      end
    end
    results.close

    # results = File.open(Rails.root.join("lib", "assets", "core_mofkey.tsv"), 'r')
    # results.each_with_index do |line, line_number|
    #   next if line_number == 0
    #   print_results(data) if line_number % 100 == 0
    #   begin
    #     update_mofkey(line)
    #     data[:mofkey_successes] += 1
    #   rescue
    #     data[:mofkey_failures] += 1
    #   end
    # end
    # results.close


  end
end

def update_mofid(line)
  line = line.split(";")
  mof = Mof.find_by(name: line[1].chomp!)
  # puts line.inspect
  # puts mof.inspect
  # puts "Setting mofid to : #{line[0].to_s} for more: #{mof.id.to_s}"
  mof.update(mofid: line[0])
end

def update_mofkey(line)
  line = line.split("\t")
  name = line[0]
  mofkey = line[1].chomp!
  mof = Mof.find_by(name: name.gsub(".cif",""))
  mof.update(mofkey: mofkey)
end