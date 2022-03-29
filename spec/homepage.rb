require 'rails_helper'

clipboard_text = "(async function () {
let clip = await navigator.clipboard.read();
let blob = await clip[0].getType('text/plain');
let blobText = blob.text();
return blobText;
        }).apply(this, Array.from(arguments).slice(0, -1)).then(arguments[arguments.length - 1])
"
json_content_type = "application/json"

describe 'MofDB html ui', type: :system do
  it "Loads at all" do
    visit '/'
    expect(page).to have_content 'API'
  end
  it "Loads DB page" do
    visit '/databases'
    expect(page).to have_content 'CoREMOF 2014'
    expect(page).to have_content '10.1021/acs.jpcc.6b08729'
    expect(page).to have_content 'Methane'
  end
  it "Copies mofid / mofkey" do
    page.driver.browser.execute_cdp(
      "Browser.setPermission",
      {
        origin: page.server_url,
        permission: { name: "clipboard-read" },
        setting: "granted",
      })
    visit '/mofs/1'
    expect(page).to have_content 'MOFid'
    find('button.mofid-cp').click
    mofid = page.evaluate_async_script(clipboard_text)
    expect(mofid).to eq '[Eu].[O-]C(=O)C(=O)[O-].[O-]C(=O)C1=C([N]C=N1)C(=O)[O-].[O-]C(=O)C1=NC=N[C]1C(=O)[O-].[O-]C(=O)C1=N[C]N=C1C(=O)[O-].[Zn] MOFid-v1.ERROR.cat0'

    find('button.mofkey-cp').click
    mofkey = page.evaluate_async_script(clipboard_text)
    expect(mofkey).to eq 'ZnEu.MUBZPKHOEPUJKR.WQCVMVXXCVLMAN.YCIDFVDEIMPTRS.MOFkey-v1.ERROR'
  end

  it 'Changes preferred loading unit' do
    cm3 = 'cm3(STP)/cm3'
    mg = 'mg/g'
    str = "Loading ["+cm3+"]"
    visit '/mofs/1'
    select(mg, from: 'loading-selector')
    expect(page).to have_content mg
    visit '/mofs/1'
    expect(page).to have_content mg
    select(cm3, from: 'loading-selector')
    expect(page).to have_content cm3
    expect(page).to have_content str
    expect(page).to_not have_content "Loading [cm3(STP)/g]"
  end

  it 'Changes preferred pressure unit' do
    visit '/mofs/1'
    atm = 'atm'
    bar = 'bar'
    str = "Pressure ["+bar+"]"
    select(atm, from: 'pressure-selector')
    select(bar, from: 'pressure-selector')
    expect(page).to have_content bar
    expect(page).to have_content str
    expect(page).to_not have_content "Pressure [Pa]"
  end

  it "Changes both units" do
    visit '/mofs/1'
    select('mg/g', from: 'loading-selector')
    select('atm', from: 'pressure-selector')
    loading = "Loading [mg/g]"
    pressure = "Pressure [atm]"
    expect(page).to have_content loading
    expect(page).to have_content pressure
    expect(page).to_not have_content "Loading [cm3(STP)/g]"
    expect(page).to_not have_content "Pressure [Pa]"
  end

  it "Searches for a mof by name" do
    visit '/'
    fill_in 'name', with: 'YAGHUM_clean'
    find("#name").send_keys(:enter)
    expect(page.all("#mof_table tbody tr").length).to eq(1)
    expect(page).to have_content '1983.34'

    fill_in 'name', with: 'YAGHUM_clean_NOTHING_WITH_THIS_NAME'
    find("#name").send_keys(:enter)
    expect(page).to have_content "No data available in table"
  end

  it "Searches by database" do
    visit '/'
    select 'hMOF', from: 'db_choice'
    sleep 0.5
    expect(page).to have_content "hMOF"
    rows = page.all("#mof_tbody tr")
    rows.each do |row|
      expect(row).to have_content "hMOF"
    end
    expect(rows.length).to be >= 5
  end

  it 'Opens the DB page' do
    visit '/databases'
    expect(page).to have_content 'CoREMOF 2014'
    expect(page).to have_content 'Argon'
    expect(page).to have_content 'Nitrogen'
    expect(page).to have_content 'Download ForceFields'
  end

  it 'Opens the API page' do
    visit '/api'
    expect(page).to have_content 'Units'
    expect(page).to have_content 'sa_m2cm3_max'
    expect(page).to have_content 'mofdb_client'
  end
end

def validate_units(mofs, pressure, loading)
  raise "mofs cannot be nil" if mofs.nil?
  mofs.each do |mof|
    mof["isotherms"].each do |iso|
      expect(iso["pressureUnits"]).to eq(pressure) unless pressure.nil?
      expect(iso["adsorptionUnits"]).to eq(loading) unless loading.nil?
    end
  end
end

describe 'MofDB json api', type: :request do
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
    expect(body["pages"]).to be > 100
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
    expect(body["pages"]).to be > 100
    validate_units(body["results"], "atm", nil)
  end

  it "validates loading only header with unit name" do
    units1 = { loading: "cm3(STP)/g", "ACCEPT": json_content_type }
    get '/mofs.json', headers: units1
    body = JSON.parse(response.body)
    expect(body["pages"]).to be > 100
    validate_units(body["results"], nil, "cm3(STP)/g")
  end

  it "validates pressure only using id # instead of name" do
    atm_id = 6
    units = { pressure: atm_id, "ACCEPT": json_content_type }
    get '/mofs.json', headers: units
    body = JSON.parse(response.body)
    validate_units(body["results"], "atm", nil)
  end

  it "validates loading only using id # instead of name" do
    loading_id = 12
    loading = "cm3(STP)/cm3"
    units = { loading: loading_id, "ACCEPT": json_content_type }
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

  pressures = {
    "atm": 6,
    "bar": 9,
    "kPa": 36,
    "mbar": 41,
    "mmHg": 47,
    "MPa": 82,
    "Pa": 84,
    "psi": 86,
    "Torr": 92
  }
  loadings = {
    "cm3(STP)/g": 13,
    "cm3(STP)/cm3": 12,
    "g/l": 27,
    "mg/g": 42,
    "mmol/g": 50,
    "mol/kg": 52,
  }
  loadings.each do |loading, loading_id|
    pressures.each do |pressure, pressure_id|
      it "Tests conversion between #{pressure} and #{loading}" do
        test_unit_pair(pressure, loading, pressure, loading)
        test_unit_pair(pressure_id, loading, pressure, loading)
        test_unit_pair(pressure_id, loading_id, pressure, loading)
        test_unit_pair(pressure, loading_id, pressure, loading)
      end
    end
  end

end

# Testing:
# - /mofs.json
# - /mofs.json?vf_min=0.5