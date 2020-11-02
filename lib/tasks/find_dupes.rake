require 'base64'
require 'zip'
require 'set'
require 'digest'

require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :find do
  desc "duplicates"
  task :dupes, :environment do
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    i = 0
    isos = Isotherm.joins(:mof).where('mofs.database_id = 3').joins(:isodata).where('isodata.gas_id = 243').select('id').distinct
    total = isos.size
    puts total
    isos.find_in_batches(batch_size: 1000) do |ids|
      i += 1
      puts "batch #{i} / #{total/1000}"
      Isotherm.where(id: ids).destroy_all
    end
  end
end