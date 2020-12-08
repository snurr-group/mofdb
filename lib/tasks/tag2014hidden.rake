namespace :tag do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task core14: :environment do
    base_names = Database.find_by(name: "CoREMOF 2019").mofs.pluck(:name).to_set
    all_names = Set.new
    base_names.each do |name|
      basename = name.gsub("_clean","").gsub("_charged","").gsub("_ion","").gsub("_clean_h","")
      all_names.add(basename)
    end
    count = 0
    Database.find_by(name: "CoREMOF 2019").mofs.each do |mof|
      if all_names.include(mof.name)
        count += 1
        #mof.hidden = true
        puts count
      end
    end
    puts count
  end
end