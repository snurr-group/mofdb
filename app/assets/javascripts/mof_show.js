window.onbeforeunload = function () {
    let mof_page = document.getElementById('mof-page');

    if (mof_page == undefined) {
        return
    }

    let vp = document.getElementById('viewport');
    vp.parentElement.removeChild(vp);

};

$(document).on('DOMContentLoaded', function () {


    let mof_page = document.getElementById('mof-page');

    console.log("start");
    if (mof_page == undefined) {
        return
        console.log("undefined")
    }
    console.log("defined");



    var stage = new NGL.Stage("viewport");
    let vp = document.getElementById('viewport');

    console.log("stage and vp");

    var path_to_cif = vp.dataset['url'];
    stage.loadFile(path_to_cif, {defaultRepresentation: true}).then(function (o) {
        o.addRepresentation("unitcell");
        o.stage.setParameters({backgroundColor: "white"});
        o.autoView();
    });

    console.log("setup stage");

    let right = document.getElementById('right');
    let id = window.location.toString().split("/mofs/")[1].split("/")[0];
    console.log("pre fetch")
    $.get("/mofs/" + id + ".json", function (data) {
        console.log('post fetch')
        for (let i = 0; i < data['isotherms'].length; i++) {
            create_isotherm(data['isotherms'][i])
        }
    });



    function create_isotherm(json) {
        console.log('creat iso: ', json);
        let child = document.createElement('div');
        let id = 'isotherm_graph_' + json.id;
        child.setAttribute('id', id);
        child.setAttribute('class', "isotherm_graph");
        right.appendChild(child);


        let loading_label = "Loading [" + json['adsorption_units'] + "]";
        let pressure_label = "Pressure [" + json['pressure_units'] + "]";
        let adsorbates = [];

        for (let i = 0; i < json['adsorbates'].length; i++) {
            adsorbates.push(json['adsorbates'][i]['name']);
        }

        let layout = {
            showlegend: true,
            legend: {
                x: 0,
                y: 1,
                traceorder: 'normal',
                font: {
                    family: 'sans-serif',
                    size: 12,
                    color: '#000'
                },
                bgcolor: '#E2E2E2',
                bordercolor: '#FFFFFF',
                borderwidth: 2
            },
            autosize: true,
            title: json['temperature'] + "K, digitized by " + json['digitizer'],
            xaxis: {
                title: {
                    text: pressure_label,
                }
            },
            yaxis: {
                title: {
                    text: loading_label,
                }
            },
            margin: {l: 45, r: 30, b: 40, t: 30, pad: 0},

        };
        let gases = {}; // inchi: [ {x: 1, y:}, ... ]
        for (let i = 0; i < json['isotherm_data'].length; i++) {
            let pressure_pt = json['isotherm_data'][i];
            let pressure = pressure_pt['pressure'];
            for (let j = 0; j < pressure_pt['species_data'].length; j++) {
                let isodata = pressure_pt['species_data'][j];
                if (gases[isodata['name']]) {
                    gases[isodata['name']]['x'].push(pressure);
                    gases[isodata['name']]['y'].push(isodata['adsorption'])
                } else {
                    gases[isodata['name']] = {x: [], y: []};
                    gases[isodata['name']]['x'].push(pressure);
                    gases[isodata['name']]['y'].push(isodata['adsorption']);
                    gases[isodata['name']]['mode'] = 'markers';
                    gases[isodata['name']]['name'] = isodata['name']
                }
            }
        }
        let traces = [];

        Object.keys(gases).forEach(function (key_i) {
            traces.push(gases[key_i]);
        });

        Plotly.plot(child, traces, layout,
            {
                responsive: true, modeBarButtonsToRemove:
                    ['sendDataToCloud', 'hoverCompareCartesian',
                        'zoom2d', 'pan2d', 'select2d', 'orbitRotation', 'tableRotation',
                        'lasso2d', 'hoverClosestCartesian', 'hoverCompareCartesian',]
            })

    }


});