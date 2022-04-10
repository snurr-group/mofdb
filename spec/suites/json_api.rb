require 'rails_helper'

describe "json api", type: :request do
  it "uses mofid param" do
    mofid = "[Fe]O[Fe].[O-]C(=O)c1cccnc1 MOFid-v1.ERROR.cat0"
    url = "/mofs.json?mofid=" + mofid
    puts url
    get url
    body = JSON.parse(response.body)
    expect(body["results"].length).to be < 10
    expect(body["results"].any? { |mof| mof["mofid"] == mofid }).to be true
  end

  it "uses mofkey param" do
    mofkey = "Fe.PVNIIMVLHYAWGP.MOFkey-v1.ERROR"
    get "/mofs.json?mofkey=" + CGI.escape(mofkey)
    body = JSON.parse(response.body)
    expect(body["results"].length).to be < 10
    expect(body["results"].any? { |mof| mof["mofkey"] == mofkey }).to be true
  end

  it "uses vf_min param" do
    get "/mofs.json?vf_min=0.9"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["void_fraction"] >= 0.9 }).to be true
    expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  end

  it "uses vf_max param" do
    get "/mofs.json?vf_max=0.9"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["void_fraction"] <= 0.9 }).to be true
    expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  end

  it "uses lcd_min param" do
    get "/mofs.json?lcd_min=35"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["lcd"] >= 35 }).to be true
    expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  end

  it "uses lcd_max param" do
    get "/mofs.json?lcd_max=35"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["lcd"] <= 35 }).to be true
    expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  end

  it "uses pld_min param" do
    get "/mofs.json?pld_min=23.7"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["pld"] >= 23.7 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(2)
  end

  it "uses pld_max param" do
    get "/mofs.json?pld_max=31"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["pld"] <= 31 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(2)
  end

  it "uses sa_m2g_min param" do
    get "/mofs.json?sa_m2g_min=2000"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["surface_area_m2g"] >= 2000 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(2)
  end

  it "uses sa_m2g_max param" do
    get "/mofs.json?sa_m2g_max=1100"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["surface_area_m2g"] <= 1100 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(1)
  end

  it "uses sa_m2cm3_min param" do
    get "/mofs.json?sa_m2cm3_min=2001"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["surface_area_m2cm3"] >= 2001 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(1)
  end

  it "uses sa_m2cm3_max param" do
    get "/mofs.json?sa_m2cm3_max=1999"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["surface_area_m2cm3"] <= 1999 }).to be true
    expect(body["results"].length + (body["pages"]-1) * ENV['PAGE_SIZE'].to_i).to eq(1)
  end

  it "uses the name param" do
    get "/mofs.json?name=test_mof3"
    body = JSON.parse(response.body)
    expect(body["results"].length).to eq(1)
    expect(body["results"].any? { |mof| mof["name"] == "test_mof3" }).to be true
  end

  it "uses the database param for 'CoREMOF 2014'" do
    get "/mofs.json?database=CoREMOF 2014"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["database"] == "CoREMOF 2014" }).to be true
  end

  it "uses the gases param properly" do
    gases = Set.new(["CO2"])
    get "/mofs.json?gases[]=CO2"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  end

  it "uses multiple gases properly" do
    gases = Set.new(["Xe", "Kr"])
    get "/mofs.json?gases[]=Xe&gases[]=Kr"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  end

  it "uses gases param improperly" do
    gases = Set.new(["CO2"])
    get "/mofs.json?gases=CO2"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  end

  it "uses gases param improperly multiple gases" do
    gases = Set.new(["Xe", "Kr"])
    get "/mofs.json?gases=Xe,Kr"
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  end

  def sometimes(a, b) end

  it "uses the doi param" do
    doi = "test_doi1"
    doi_model = Doi.find_by(doi: doi)
    get "/mofs.json?doi=" + doi_model.id.to_s
    body = JSON.parse(response.body)
    expect(body["results"].all? { |mof| mof["isotherms"].all? { |iso| iso["DOI"] == doi } }).to be true
    expect(body["results"].all? { |mof| mof["isotherms"].all? { |iso| iso["DOI"] == doi } }).to be true
    puts body["results"].map{|mof|mof["database"]}
    expect(body["results"].all? { |mof| mof["database"] == "testdb1" || mof["database"] == "testdb2" }).to be true
  end

  it "has DOI and doi_url in resonse" do
    get "/mofs.json?page=1&vf_min=0.001"
    body = JSON.parse(response.body)
    expect(body["results"].all?{|mof| mof["isotherms"].all?{|iso| iso["DOI"] && iso["doi_url"] }}).to be true
  end

  it "can query doi by id #" do
    doi = Doi.find_by(doi: "test_doi1")
    get "/mofs.json?doi=" + doi.id.to_s
    body = JSON.parse(response.body)
    puts body["results"].map { |mof| mof["isotherms"].any? { |iso| iso["DOI"] == doi.doi } }
    expect(body["results"].all? { |mof| mof["isotherms"].all? { |iso| iso["DOI"] == doi.doi } }).to be true
  end

end
