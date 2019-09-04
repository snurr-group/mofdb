namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task all: :environment do
    i = 0
    mofs = Mof.all.where(pregen_json: nil)
    puts "Mofs fetched"
    size = mofs.size
    mofs.each do |mof|
      i = i + 1
      puts i.to_f/size.to_f + " " + i.to_s + "/" + size.to_s
      json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder', locals: {mof: mof}, format: :json, assigns: { mof: mof })
      json = JSON.load(json)
      mof.pregen_json = json
      mof.save
    end
  end
end
