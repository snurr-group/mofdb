if @convert_pressure.nil? && @convert_loading.nil?
  # Instead of generating json on the fly we store it in a pre-generated column and just concat those columns
  json.results = @mofs.pluck(:pregen_json)
else
  json.result do
    # In this case we need to convert pressure/Loading on the fly
    json.array! @mofs do |mof|
      mof.get_json(@convert_pressure, @convert_loading)
    end
  end
end

json.pages @pages
json.page @page