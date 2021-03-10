namespace :pregen do
  desc "Generate mass and volume A^3 for every mof"
  task number: :environment do
    lowest = 1
    count = 0
    while count < 20000 do
      puts "Lowest: #{lowest}" if lowest % 100 == 0
      mof = Mof.find_by(name: "tobmof-#{count}")
      if mof.nil?
      else
        puts "Renaming #{mof.name} to tobmof-#{lowest}"
        mof.name = "tobmof-#{lowest}"
        lowest += 1
        mof.save
      end
      count += 1
    end
  end
end
