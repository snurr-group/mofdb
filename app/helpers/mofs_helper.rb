module MofsHelper
  def send_zip_file(mofs, convert_pressure, convert_loading, cifs = true, json = true)

    zip_name = "mofs-bulk-search-download.zip"
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

    begin
      ZipTricks::Streamer.open(writer) do |zip|
        mofs.find_in_batches(batch_size: 100).each do |batch|
          batch.each do |mof|
            content = mof.get_json(convert_pressure, convert_loading)
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
        Sentry.capture_message("Error while creating a zip file #{request.url.to_s}")
      else
        puts e.inspect
        puts e.backtrace.reverse.join("\n")
      end
    ensure
      response.stream.close
    end
  end
end
