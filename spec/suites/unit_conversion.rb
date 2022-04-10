require 'rails_helper'

def validate_units(mofs, pressure, loading)
  raise "mofs cannot be nil" if mofs.nil?
  mofs.each do |mof|
    mof["isotherms"].each do |iso|
      expect(iso["pressureUnits"]).to eq(pressure) unless pressure.nil?
      expect(iso["adsorptionUnits"]).to eq(loading) unless loading.nil?
    end
  end
end

json_content_type = "application/json"

describe 'MofDB json api unit conversion', type: :request do

  it 'Validates pressure & loading unit conversions are happening (no math check) with str headers' do
    atm = "atm"
    cm3g = "cm3(STP)/g"
    bar = "bar"
    gl = "g/l"

    units1 = { pressure: atm, loading: cm3g, "ACCEPT": json_content_type }
    units2 = { pressure: bar, loading: gl, "ACCEPT": json_content_type }

    get '/mofs.json', headers: units1
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["pages"]).to eq(1)
    expect(body["page"]).to eq(1)
    validate_units(body["results"], atm, cm3g)

    get '/mofs.json', headers: units2
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    validate_units(body["results"], bar, gl)
  end

  it "validates pressure only header with unit name" do
    units1 = { pressure: "atm", "ACCEPT": json_content_type }
    get '/mofs.json', headers: units1
    body = JSON.parse(response.body)
    expect(body["pages"]).to eq 1
    validate_units(body["results"], "atm", nil)
  end

  it "validates loading only header with unit name" do
    units1 = { loading: "cm3(STP)/g", "ACCEPT": json_content_type }
    get '/mofs.json', headers: units1
    body = JSON.parse(response.body)
    expect(body["pages"]).to eq 1
    validate_units(body["results"], nil, "cm3(STP)/g")
  end

  it "validates pressure only using id # instead of name" do
    atm_id = Classification.find_by(name: "atm").id
    units = { pressure: atm_id, "ACCEPT": json_content_type }
    get '/mofs.json', headers: units
    body = JSON.parse(response.body)
    validate_units(body["results"], "atm", nil)
  end

  it "validates loading only using id # instead of name" do
    model = Classification.find_by(name: "cm3(STP)/cm3")
    loading = model.name
    units = { loading: model.id, "ACCEPT": json_content_type }
    get '/mofs.json', headers: units
    body = JSON.parse(response.body)
    validate_units(body["results"], nil, loading)
  end

  # pressure_to_send and loading_to_send may be a str or a #
  # pressure/loading_in_json are a str to be checked for in the resulting json
  def test_unit_pair(pressure_to_send, loading_to_send, pressure_in_json, loading_in_json)
    json_content_type = "application/json"
    units = { pressure: pressure_to_send.to_s, loading: loading_to_send.to_s, "ACCEPT": json_content_type }
    get '/mofs.json', headers: units
    body = JSON.parse(response.body)
    validate_units(body["results"], pressure_in_json.to_s, loading_in_json.to_s)
  end

  pressure_names = %w[ atm bar kPa mbar mmHg MPa Pa psi Torr ]
  loading_names = %w[ cm3(STP)/g cm3(STP)/cm3 g/l mg/g mmol/g mmol/kg ]
  pressures = {}
  loadings = {}
  pressure_names.each do |pres|
    puts pres
    pressures[pres] = Classification.find_by(name: pres).id
  end
  loading_names.each do |load|
    puts load
    loadings[load] = Classification.find_by(name: load).id
  end

  loadings.each do |loading, loading_id|
    pressures.each do |pressure, pressure_id|
      it "Tests conversion between #{pressure} and #{loading}" do
        puts "Testing #{pressure} and #{loading}"
        puts "With ids #{pressure_id} and #{loading_id}"
        test_unit_pair(pressure, loading, pressure, loading)
        test_unit_pair(pressure_id, loading, pressure, loading)
        test_unit_pair(pressure_id, loading_id, pressure, loading)
        test_unit_pair(pressure, loading_id, pressure, loading)
      end
    end
  end
end
