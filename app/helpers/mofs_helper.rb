module MofsHelper
  def symbol_to_id(elems)
    elems.map { |symbol| Element.find_by(symbol: symbol).id }
  end

  def parse_element_ids(elements)
    # elements is a string like "H, Cu"
    # or an array like ["H", "Cu"]
    # or a string like "H"
    if elements.is_a?(Array)
      symbol_to_id(elements)
    elsif elements.is_a?(String) && elements.include?(",")
      symbol_to_id(elements.split(","))
    elsif elements.is_a?(String)
      symbol_to_id([elements])
    else
      raise Exception("#{elements} could not parsed")
    end
  end

  def send_zip_file(mofs, convert_pressure, convert_loading, version, cifs = true, json = true)
    zip_name = "bulk-dl-mofdb-version-#{version}.zip"
    send_file_headers!(
      type: "application/zip",
      disposition: "attachment",
      filename: zip_name
    )
    response.headers["Last-Modified"] = Time.now.httpdate.to_s
    response.headers["X-Accel-Buffering"] = "no"

    writer = ZipTricks::BlockWrite.new do |chunk|
      response.stream.write(chunk)
    end

    if convert_loading == nil && convert_pressure == nil
      mofs = mofs.select(:id,:pregen_json,:cif,:name, :batch_id, :database_id)
    else
      mofs = mofs.convertable
                 .includes(:batch)
                 .includes(:database)
                 .includes(:gases)
                 .includes({ isotherms: [:batch,
                                         :adsorbate_forcefield,
                                         :molecule_forcefield,
                                         :adsorption_units,
                                         :pressure_units,
                                         :composition_type] })

    end
    begin
      ZipTricks::Streamer.open(writer) do |zip|
        mofs.find_in_batches(batch_size: 100).each do |batch|
          batch.each do |mof|
            content = mof.get_json(convert_pressure, convert_loading, version)
            cif = mof.cif
            if json
              zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).json") do |file_writer|
                file_writer << content
              end
            end
            if cifs
              zip.write_deflated_file("#{mof.name}-(id:#{mof.id}).cif") do |file_writer|
                file_writer << cif
              end
            end
          end
        end
      end
    rescue ActionController::Live::ClientDisconnected
      return
    rescue Exception => e
      if Rails.env.production?
        Sentry.capture_exception(e)
        # /    #   else
        puts e.inspect
        puts e.backtrace.reverse.join("\n")
      end
      if Rails.env.development?
        raise e
      end
    ensure
      response.stream.close
    end
  end
end
