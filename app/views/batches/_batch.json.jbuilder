json.extract! batch, :id, :created_at, :updated_at
json.isotherms batch.isotherms.size
json.mofs batch.mofs.size
