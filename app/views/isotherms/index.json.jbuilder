json.pages @pages
json.page @page
json.results do |results|
  json.array! @isotherms, partial: "isotherms/isotherm", as: :isotherm
end
