namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task all: :environment do
    i = 0
    size = 10000
    Mof.all.take(100).each do |mof|
      i = i + 1
      puts i.to_f/size.to_f
      json = ApplicationController.render(template: 'mofs/_mof.json.jbuilder', locals: {mof: mof}, format: :json, assigns: { mof: mof })
      json = JSON.load(json)
      mof.pregen_json = json
      mof.save
    end
  end
end
