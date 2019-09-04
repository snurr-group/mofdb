namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task all: :environment do
    i = 0
    mofs = Mof.all.where(pregen_json: nil)
    size = mofs.size.to_f
    q = Queue.new
    puts "Filling queue"
    mofs.each do |mof|
      q << mof
    end
    puts "Queue filled"

    def process(mof)
      json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder', locals: {mof: mof}, format: :json, assigns: { mof: mof })
      json = JSON.load(json)
      mof.pregen_json = json
      mof.save
    end

    threads = []
    for x in 0..4
      threads << Thread.new {
        while q.size != 0
          mof = q.pop
            process(mof)
            i = i + 1
            puts i.to_f / size
        end
      }
    end

    threads.each do |thr|
      thr.join()
    end




  end
end
