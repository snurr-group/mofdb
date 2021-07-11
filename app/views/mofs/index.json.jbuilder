if @convert_pressure.nil? && @convert_loading.nil?
  # Instead of generating json on the fly we store it in a pre-generated column and just concat those columns
  json.results = @mofs.pluck(:pregen_json)
else
  # In this case we need to convert pressure/Loading on the fly
  results = []
  @mofs.each do |mof|
    results << JSON.parse(mof.get_json(@convert_pressure, @convert_loading))
  end
  json.results results
end

json.pages @pages
json.page @page