require 'rails_helper'

clipboard_text = "(async function () {
let clip = await navigator.clipboard.read();
let blob = await clip[0].getType('text/plain');
let blobText = blob.text();
return blobText;
        }).apply(this, Array.from(arguments).slice(0, -1)).then(arguments[arguments.length - 1])
"

def wait_until(&block)
  0.upto(10) do
    return if block.call
    sleep 1
  end
end

describe 'MofDB html ui', type: :system do
  before do
    driven_by(:headless_chrome_custom)
  end
  it "Loads at all" do
    visit '/'
    expect(page).to have_content 'API'
  end
  it "Loads DB page" do
    visit '/databases'
    expect(page).to have_content 'testdb1'
    expect(page).to have_content 'test_doi'
    expect(page).to have_content 'Nitrogen'
  end
  # it "Copies mofid / mofkey" do
  #   page.driver.browser.execute_cdp(
  #     "Browser.setPermission",
  #     {
  #       origin: page.server_url,
  #       permission: { name: "clipboard-read" },
  #       setting: "granted",
  #     })
  #   m = Mof.find_by(name: "test_mof2")
  #   visit '/mofs/' + m.id.to_s
  #   expect(page).to have_content 'MOFid'
  #   find('button.mofid-cp').click
  #   mofid = page.evaluate_async_script(clipboard_text)
  #   expect(mofid).to eq '[Eu].[O-]C(=O)C(=O)[O-].[O-]C(=O)C1=C([N]C=N1)C(=O)[O-].[O-]C(=O)C1=NC=N[C]1C(=O)[O-].[O-]C(=O)C1=N[C]N=C1C(=O)[O-].[Zn] MOFid-v1.ERROR.cat0'
  #
  #   find('button.mofkey-cp').click
  #   mofkey = page.evaluate_async_script(clipboard_text)
  #   expect(mofkey).to eq 'Fe.PVNIIMVLHYAWGP.MOFkey-v1.ERROR'
  # end

  it 'Changes preferred loading unit' do
    m = Mof.find_by(name: "test_mof2")
    cm3 = 'cm3(STP)/cm3'
    mg = 'mg/g'
    str = "Loading ["+cm3+"]"
    visit '/mofs/' + m.id.to_s
    select(mg, from: 'loading-selector')
    expect(page).to have_content mg
    visit '/mofs/' + m.id.to_s
    expect(page).to have_content mg
    select(cm3, from: 'loading-selector')
    expect(page).to have_content cm3
    expect(page).to have_content str
    expect(page).to_not have_content "Loading [cm3(STP)/g]"
  end

  it 'Changes preferred pressure unit' do
    m = Mof.find_by(name: "test_mof2")
    visit '/mofs/'+m.id.to_s
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
    m = Mof.find_by(name: "test_mof2")
    visit '/mofs/'+m.id.to_s
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
    fill_in 'name', with: 'test_mof3'
    find("#name").send_keys(:enter)
    sleep 2
    expect(page.all("#mof_table tbody tr").length).to eq(1)
    expect(page).to have_content '3001'

    fill_in 'name', with: 'test_mof3_NOTHING_WITH_THIS_NAME'
    find("#name").send_keys(:enter)
    expect(page).to have_content "No data available in table"
  end

  it "Searches by database" do
    visit '/'
    select 'testdb2', from: 'db_choice'
    expect(page).to have_content "testdb2"
    wait_until do
      page.all("#mof_tbody tr").length == 1
    end
    rows = page.all("#mof_tbody tr")
    expect(rows.length).to eq(1)
    page.find("#mof_tbody tr:nth-child(1) td:nth-child(1)").click(x: 5, y: 5)
    wait_until do
      page.find("#mof_tbody tr:nth-child(1)").text(:all).include?("testdb2")
    end
    expect(page.find("#mof_tbody tr:nth-child(1)").text(:all).include?("testdb2")).to eq(true)
  end

  it 'Opens the DB page' do
    visit '/databases'
    expect(page).to have_content 'testdb1'
    expect(page).to have_content 'testdb1'
    expect(page).to have_content 'Nitrogen'
    expect(page).to have_content 'Krypton'
  end

  it 'Opens the API page' do
    visit '/api'
    expect(page).to have_content 'Units'
    expect(page).to have_content 'sa_m2cm3_max'
    expect(page).to have_content 'mofdb_client'
  end
end