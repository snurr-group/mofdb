
require 'oj'
mofs = []
@mofs.in_groups_of(1000) do |group|
  json.array! @mofs, partial: "mofs/mof", as: :mof
  json.merge! mofs
end

