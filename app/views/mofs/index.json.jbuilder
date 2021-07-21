if @convert_pressure.nil? && @convert_loading.nil?
  # Instead of generating json on the fly we store it in a pre-generated column and just concat those columns
  json.results @mofs.pluck(:pregen_json)
elsif
  # In this case we need to convert pressure/Loading on the fly
  json.results do |_|
    json.array!(@mofs, partial: 'mofs/mof', as: :mof,
                locals: { convert_pressure: @convert_pressure,
                          convert_loading: @convert_loading })
  end
end

json.pages @pages
json.page @page