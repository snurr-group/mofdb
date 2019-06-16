$(document).on('turbolinks:load', function () {
    let mof_page = document.getElementById('mof-page');

    if (mof_page == undefined) {
        console.log('wrong page');
        return
    }
    let right = document.getElementById('right');
    let id = window.location.toString().split("/mofs/")[1].split("/")[0];
    $.get("/mofs/" + id + ".json", function (data) {
        for (let i = 0; i < data['isotherms'].length; i++) {
            create_isotherm(data['isotherms'][i])
        }
    });


    function create_isotherm(json) {
        let child = document.createElement('canvas');
        let id = 'isotherm_graph_' + json.id;
        child.setAttribute('id', id);
        right.appendChild(child);

        let ctx = document.getElementById(id).getContext('2d');


        let gases = {}; // inchi: [ {x: 1, y:}, ... ]
        for (let i = 0; i < json['isotherm_data'].length; i++) {
            let pressure_pt = json['isotherm_data'][i];
            let pressure = pressure_pt['pressure'];
            for (let j = 0; j < pressure_pt['species_data'].length; j++) {
                let isodata = pressure_pt['species_data'][j];
                let pair = {x: pressure, y: isodata['adsorption']};
                if (gases[isodata['name']]) {
                    gases[isodata['name']].push(pair)
                } else {
                    gases[isodata['name']] = [pair]
                }
            }
        }

        let datasets = [];
        console.log("gases", gases);
        let names = [];
        for (let name in gases) {
            names.push(name)
            datasets.push({label: name, data: gases[name]})
        }
        ;

        let myChart = new Chart(ctx, {
            type: 'scatter',
            data: {
                datasets: datasets,
            },
            options: {
                title: {
                    display: true,
                    text: json['doi'] + ' digitized by ' + json['digitizer']
                },
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });


    }


});