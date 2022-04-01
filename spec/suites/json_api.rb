require 'rails_helper'

describe "json api", type: :request do
  # it "uses mofid param" do
  #   mofid = "[Fe]O[Fe].[O-]C(=O)c1cccnc1 MOFid-v1.ERROR.cat0"
  #   get "/mofs.json?mofid=" + CGI.escape(mofid)
  #   body = JSON.parse(response.body)
  #   expect(body["results"].length).to be < 10
  #   expect(body["results"].any? { |mof| mof["mofid"] == mofid }).to be true
  # end
  #
  # it "uses mofkey param" do
  #   mofkey = "Fe.PVNIIMVLHYAWGP.MOFkey-v1.ERROR"
  #   get "/mofs.json?mofkey=" + CGI.escape(mofkey)
  #   body = JSON.parse(response.body)
  #   expect(body["results"].length).to be < 10
  #   expect(body["results"].any? { |mof| mof["mofkey"] == mofkey }).to be true
  # end
  #
  # it "uses vf_min param" do
  #   get "/mofs.json?vf_min=0.9"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["void_fraction"] >= 0.9 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses vf_max param" do
  #   get "/mofs.json?vf_max=0.9"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["void_fraction"] <= 0.9 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses lcd_min param" do
  #   get "/mofs.json?lcd_min=35"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["lcd"] >= 35 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses lcd_max param" do
  #   get "/mofs.json?lcd_max=35"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["lcd"] <= 35 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses pld_min param" do
  #   get "/mofs.json?pld_min=13.7"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["pld"] >= 13.7 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses pld_max param" do
  #   get "/mofs.json?pld_max=13.7"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["pld"] <= 13.7 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses sa_m2g_min param" do
  #   get "/mofs.json?sa_m2g_min=3000"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["surface_area_m2g"] >= 3000 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses sa_m2g_max param" do
  #   get "/mofs.json?sa_m2g_max=100"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["surface_area_m2g"] <= 100 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses sa_m2cm3_min param" do
  #   get "/mofs.json?sa_m2cm3_min=1000"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["surface_area_m2cm3"] >= 1000 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses sa_m2cm3_max param" do
  #   get "/mofs.json?sa_m2cm3_max=1400"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["surface_area_m2cm3"] <= 1400 }).to be true
  #   expect(body["results"].length + body["pages"] * ENV['PAGE_SIZE'].to_i).to be > 10
  # end
  #
  # it "uses the name param" do
  #   get "/mofs.json?name=RIGPEE01_clean"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].length).to eq(1)
  #   expect(body["results"].any? { |mof| mof["name"] == "RIGPEE01_clean" }).to be true
  # end
  #
  # it "uses the database param for 'CoREMOF 2014'" do
  #   get "/mofs.json?database=CoREMOF 2014"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["database"] == "CoREMOF 2014" }).to be true
  # end
  #
  # it "uses the gases param properly" do
  #   gases = Set.new(["CO2"])
  #   get "/mofs.json?gases[]=CO2"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  # end
  #
  # it "uses multiple gases properly" do
  #   gases = Set.new(["Xe", "Kr"])
  #   get "/mofs.json?gases[]=Xe&gases[]=Kr"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  # end
  #
  # it "uses gases param improperly" do
  #   gases = Set.new(["CO2"])
  #   get "/mofs.json?gases=CO2"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  # end
  #
  # it "uses gases param improperly multiple gases" do
  #   gases = Set.new(["Xe", "Kr"])
  #   get "/mofs.json?gases=Xe,Kr"
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["adsorbates"].map { |ads| ads["formula"] }.to_set == gases } }).to be true
  # end
  #
  # def sometimes(a, b) end
  #
  # it "uses the doi param" do
  #   doi = "10.1021/acs.jpcc.6b08729"
  #   get "/mofs.json?doi=" + doi
  #   body = JSON.parse(response.body)
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["DOI"] == doi } }).to be true
  #   expect(body["results"].all? { |mof| mof["isotherms"].any? { |iso| iso["DOI"] == doi } }).to be true
  #   expect(body["results"].all? { |mof| mof["database"] == "hMOF" }).to be true
  # end

  it "has DOI and doi_url in resonse" do
    get "/mofs.json?page=10&vf_min=0.001"
    body = JSON.parse(response.body)
    # body["results"].each do |mof|
    #   mof["isotherms"].each do |iso|
    #     puts "ISOOO"
    #     puts iso
    #     puts iso["DOI"]
    #     puts iso["doi_url"]
    #     expect(iso["DOI"]).to be_truthy
    #     expect(iso["doi_url"]).to be_truthy
    #   end
    # end
    expect(body["results"].all?{|mof| mof["isotherms"].all?{|iso| iso["DOI"] && iso["doi_url"] }}).to be true
  end

end
