namespace :import do
  desc "This script import mofids from a .smi file"
  task mofid: :environment do
    mof_not_found = 0
    parse_err = 0
    success = 0
    total = 0
    file = ARGV[1]
    if File.file?(file)
      puts "Parsing input file #{file}"
    else
      puts "#{file} is not a valid path call this script with the path to a .smi file"
    end

    translate = nil
    if ARGV.size > 2
      translate = build_translation(ARGV[2])
    end

    File.open(ARGV[1]).each_line do |line|
      if (total % 100 == 0)
        puts "success: #{success}, mof_not_found: #{mof_not_found}, parse_err: #{parse_err}"
      end
      total += 1
      begin
        mofid = line.split(";")[0].gsub("\r","").gsub("\n","")
        mof_name = line.split(";")[1].gsub("\r","").gsub("\n","")
        mof_name = translate[mof_name] if !translate.nil?

        if mofid.size == 0
          parse_err += 1
          next
        end

        mof = Mof.find_by(name: mof_name)
        if mof.nil?
          mof_not_found += 1
          next
        end
        mof.mofid = mofid
        mof.save
        success += 1
      rescue
        parse_err += 1
      end
    end
  end

  task mofkey: :environment do
    mof_not_found = 0
    parse_err = 0
    success = 0
    count = 0
    file = ARGV[1]

    translate = nil
    if ARGV.size > 2
      puts "Generating translation dict from csv"
      translate = build_translation(ARGV[2])
    end

    if File.file?(file)
      puts "Parsing input file #{file}"
    else
      puts "#{file} is not a valid path call this script with the path to a .smi file"
    end

    File.open(file).each_line do |line|
      if (count % 100 == 0)
        puts "success: #{success}, mof_not_found: #{mof_not_found}, parse_err: #{parse_err}"
      end
      count += 1
      next if (count == 1)
      begin
        mofname = line.split("\t")[0].gsub("\r","").gsub("\n","")
        mofname = mofname[0..mofname.size-5]
        mofkey = line.split("\t")[1].gsub("\r","").gsub("\n","")
        mofname = translate[mofname] if translate

        if mofkey.size == 0
          parse_err += 1
          next
        end

        mof = Mof.find_by(name: mofname)
        if mof.nil?
          mof_not_found += 1
          next
        end
        mof.mofkey = mofkey
        mof.save
        success += 1
      rescue
        parse_err += 1
      end
    end
  end

end

def build_translation(path)
  translate = {}
  num = 0
  File.open(path).each_line do |line|
    num += 1
    next if num == 1
    from = line.split(",")[0].gsub("\r","").gsub("\n","").gsub(".cif","")
    to = line.split(",")[1].gsub("\r","").gsub("\n","").gsub(".cif","")
    translate[from] = to
  end
  return translate
end