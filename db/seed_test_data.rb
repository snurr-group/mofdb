def load_cif(num)
  file = open(Rails.root.join("test", "#{num}.cif"))
  r = file.read
  file.close
  r
end

def seed_test_mofs

  if Rails.env.test?
    Isodatum.destroy_all
    Mof.destroy_all
    Database.destroy_all
    Batch.destroy_all
    Doi.destroy_all
    Isotherm.destroy_all
    b = Batch.create!
    d1 = Database.create!(name: "testdb1")
    d2 = Database.create!(name: "testdb2")
    m1 = Mof.create!(database: d1, batch: b, surface_area_m2cm3: 1000, surface_area_m2g: 1000, mofid: "[Fe]O[Fe].[O-]C(=O)c1cccnc1 MOFid-v1.ERROR.cat0", name: "test_mof1", void_fraction: 0.5, pld: 20, lcd: 30, database: d1, cif: load_cif(1))
    m2 = Mof.create!(database: d1, batch: b, surface_area_m2cm3: 2000, surface_area_m2g: 2000, mofid: "[Eu].[O-]C(=O)C(=O)[O-].[O-]C(=O)C1=C([N]C=N1)C(=O)[O-].[O-]C(=O)C1=NC=N[C]1C(=O)[O-].[O-]C(=O)C1=N[C]N=C1C(=O)[O-].[Zn] MOFid-v1.ERROR.cat0",
                     mofkey: "Fe.PVNIIMVLHYAWGP.MOFkey-v1.ERROR", name: "test_mof2", void_fraction: 0.9, pld: 30, lcd: 40, cif: load_cif(2))
    m3 = Mof.create!(database: d2, batch: b, surface_area_m2cm3: 3001, surface_area_m2g: 3000, name: "test_mof3", void_fraction: 0.99, pld: 40, lcd: 50, cif: load_cif(3))
    doi1 = Doi.create!(doi: "test_doi1", url: "https://doi1.org")
    doi2 = Doi.create!(doi: "test_doi2", url: "https://doi2.org")

    i1 = Isotherm.create!(doi: doi1, mof: m1,
                          adsorbate_forcefield: Forcefield.find_by(name: "UFF"),
                          molecule_forcefield: Forcefield.find_by(name: "UFF"),
                          adsorption_units: Classification.find_by(name: "mg/g"),
                          pressure_units: Classification.find_by(name: "atm"),
                          composition_type: Classification.find_by(name: "wt%")
    )
    i2 = Isotherm.create!(doi: doi1, mof: m2,
                          adsorbate_forcefield: Forcefield.find_by(name: "UFF"),
                          molecule_forcefield: Forcefield.find_by(name: "UFF"),
                          adsorption_units: Classification.find_by(name: "mg/g"),
                          pressure_units: Classification.find_by(name: "atm"),
                          composition_type: Classification.find_by(name: "wt%")
    )
    i3 = Isotherm.create!(doi: doi2, mof: m3,
                          adsorbate_forcefield: Forcefield.find_by(name: "UFF"),
                          molecule_forcefield: Forcefield.find_by(name: "UFF"),
                          adsorption_units: Classification.find_by(name: "mg/g"),
                          pressure_units: Classification.find_by(name: "atm"),
                          composition_type: Classification.find_by(name: "wt%")
    )

    isodata1 = Isodatum.create!(isotherm: i1, gas: Gas.find_by(formula: "N2"), pressure: 1.0, loading: 2.0, bulk_composition: 1.0)

    isodata2 = Isodatum.create!(isotherm: i1, gas: Gas.find_by(formula: "Ar"), pressure: 1.0, loading: 2.0, bulk_composition: 1.0)

    isodata3 = Isodatum.create!(isotherm: i1, gas: Gas.find_by(formula: "Kr"), pressure: 13.0, loading: 203.0, bulk_composition: 1.0)
    isodata33 = Isodatum.create!(isotherm: i1, gas: Gas.find_by(formula: "Kr"), pressure: 1.0, loading: 2.0, bulk_composition: 1.0)
  end

end