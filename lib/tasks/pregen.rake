namespace :pregen do
  # Generate all json ahead of time because fuck is rendering json slow in rails...
  desc "TODO"
  task all: :environment do
    i = 0
    size = Mof.all.size
    Mof.all.includes(:gases,:isodata,:isotherms, :elements).where(pregen_json: nil).find_each do |mof|
      i = i + 1
      puts i.to_f/size.to_f
      mof.regen_json
    end
  end
end
