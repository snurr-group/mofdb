require 'set'
require 'csv'

namespace :hide do
  desc "Hide all coremofs except those in the CSV"
  task :mofs, :environment do
    csv = CSV.read(Rails.root.join('lib','tasks','allowed.csv'))
    i = 0
    names = Set[]
    csv.each do |row|
      i += 1
      next if i == 1
      names << row[0]
    end
    puts "Hidden all mofs in coremof except these #{names.size}"
    names = names.to_a
    coremof = Database.find_by(name: "CoREMOF")
    Mof.all.where(database: coremof).where("name not in (?)", names).update_all(hidden: true)
  end
end