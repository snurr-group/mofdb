window.onbeforeunload = function () {
    let mof_page = document.getElementById('mof-page');

    if (mof_page == undefined) {
        console.log('wrong page');
        return
    }

    let vp = document.getElementById('viewport');
    vp.parentElement.removeChild(vp);

};

$(document).on('DOMContentLoaded', function () {


    let mof_page = document.getElementById('mof-page');

    if (mof_page == undefined) {
        console.log('wrong page');
        return
    }


    console.log('added');

    var stage = new NGL.Stage("viewport");
    let vp = document.getElementById('viewport');

    if (vp == undefined) {

    }

    var path_to_cif = vp.dataset['url'];
    stage.loadFile(path_to_cif, {defaultRepresentation: true}).then(function (o) {
        o.addRepresentation("unitcell");
        console.log(o);
        o.stage.setParameters({backgroundColor: "white"});
        o.autoView();
    });

    let right = document.getElementById('right');
    let id = window.location.toString().split("/mofs/")[1].split("/")[0];
    $.get("/mofs/" + id + ".json", function (data) {
        for (let i = 0; i < data['isotherms'].length; i++) {
            create_isotherm(data['isotherms'][i])
        }
    });


    function create_isotherm(json) {
        let child = document.createElement('div');
        let id = 'isotherm_graph_' + json.id;
        child.setAttribute('id', id);
        child.setAttribute('class', "isotherm_graph");
        right.appendChild(child);

        console.log(json);

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
                console.log(isodata, "ASDFASDF");
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

        console.log('traces:',traces)
        Plotly.plot(child, traces, layout,
            {
                responsive: true, modeBarButtonsToRemove:
                    ['sendDataToCloud', 'hoverCompareCartesian',
                        'zoom2d', 'pan2d', 'select2d', 'orbitRotation', 'tableRotation',
                        'lasso2d', 'hoverClosestCartesian', 'hoverCompareCartesian',]
            })

    }


});