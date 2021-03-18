namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task json: :environment do
    i = 0
    size = Mof.all.size

    Mof.all.includes(:gases, :isodata, :isotherms, :elements).find_each do |mof|
      i = i + 1
      puts i.to_f/size.to_f
      mof.regen_json
    end
  end
end

namespace :pregen do
  desc "Regen all JSON and all ZIP files"
  task all: :environment do
    puts "Starting JSON generation"
    Rake::Task['pregen:json'].invoke
    puts "Starting ZIP generation"
    Rake::Task['pregen:databases'].invoke
  end
end

