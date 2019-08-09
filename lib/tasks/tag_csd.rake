require 'mysql2'
namespace :import do
  desc "Download regions from herpmapper"
  task csd: :environment do
    @csd = Database.find_by(name: "CSD")
    client = Mysql2::Client.new(:host => "localhost", :username => ENV['LEGACY_DB_USER'], :database => "mofdb", :password => ENV["LEGACY_DB_PASS"])
    result = client.query("SELECT name FROM materials where db_source = 'CSD'")
    successful = 0
    failed = 0
    result.each do |row|
      begin
        mof = Mof.find_by(name: row['name'])
        mof.database = @csd
        mof.save!
        successful += 1
      rescue
        failed += 1
      end
    end
    puts "suc: "+successful.to_s
    puts "failed: "+ failed.to_s


  end
end
