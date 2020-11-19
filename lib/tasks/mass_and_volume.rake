require 'concurrent'
namespace :pregen do
  desc "Generate mass and volume A^3 for every mof"
  task mass_and_volume: :environment do
    startime = Time.now
    Rails.application.executor.wrap do
      success = Concurrent::AtomicFixnum.new
      fails = Concurrent::AtomicFixnum.new
      mofs = Mof.all.where(volumeA3: nil)
      size = mofs.size
      pool = Concurrent::FixedThreadPool.new(10, max_queue: 1000000)
      mofs.each do |mof|
        pool.post do
          result = mof.storeMassAndVol
          success.increment if result
          fails.increment if !result
          puts "suc: #{success.value}, fails: #{fails.value} total: #{size}"
        end
      end
      pool.shutdown
      pool.wait_for_termination
    end
    puts "Runtime: #{(Time.now - startime).seconds}"

  end
end