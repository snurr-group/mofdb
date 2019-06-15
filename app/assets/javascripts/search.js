// 4 Sliders to choose ranges




document.addEventListener("DOMContentLoaded", function(event) {

    var pld = document.getElementById('pld_slider');
    var lcd = document.getElementById('lcd_slider');
    var vf = document.getElementById('vf_slider');
    var sa_m2g = document.getElementById('sa_m2g_slider');
    var sa_m2cm3 = document.getElementById('sa_m2cm3_slider');
    var limit = document.getElementById('limit');


    noUiSlider.create(pld, {
        start: [0,20],
        step: .1,
        range: {
            'min': [0],
            'max': [20]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: '',
        })
    });
    noUiSlider.create(lcd, {
        start: [0,100],
        step: .1,
        range: {
            'min': [0],
            'max': [100]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: '',
        })
    });
    noUiSlider.create(vf, {
        start: [0,1],
        step: .01,
        mark: '.',
        range: {
            'min': [0],
            'max': [1]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: ''
        })
    });
    noUiSlider.create(sa_m2g, {
        start: [0,5000],
        step: 100,
        range: {
            'min': [0],
            'max': [5000]
        },
        connect: true,
        format: wNumb({
            decimals: 0,
            thousand: '',
        })
    });

    noUiSlider.create(sa_m2cm3, {
        start: [0,5000],
        step: 100,
        range: {
            'min': [0],
            'max': [5000]
        },
        connect: true,
        format: wNumb({
            decimals: 0,
            thousand: '',
        })
    });

    $('#elements_label').chosen();

    pld.noUiSlider.on('update', function (values) {
        document.getElementById("pld_min").innerHTML = values[0];
        document.getElementById("pld_max").innerHTML = values[1];
    });
    lcd.noUiSlider.on('update', function (values) {
        document.getElementById("lcd_min").innerHTML = values[0];
        document.getElementById("lcd_max").innerHTML = values[1];
    });
    vf.noUiSlider.on('update', function (values) {
        document.getElementById("vf_min").innerHTML = values[0];
        document.getElementById("vf_max").innerHTML = values[1];
    });
    sa_m2g.noUiSlider.on('update', function (values) {
        document.getElementById("sa_m2g_min").innerHTML = values[0];
        document.getElementById("sa_m2g_max").innerHTML = values[1];
    });
    sa_m2cm3.noUiSlider.on('update', function (values) {
        document.getElementById("sa_m2cm3_min").innerHTML = values[0];
        document.getElementById("sa_m2cm3_max").innerHTML = values[1];
    });

    $("#checkboxes").click(function() {
        console.log("triggered by Checkboxes");
        refresh()
    });
    $("#limit").click(function() {
        console.log("triggered by Limit");
        refresh()
    });

    $("#dbchoice").change(function() {
        console.log("triggered by database");
        refresh()
    });

    pld.noUiSlider.on('end',function() {
        console.log("triggered by PLD");
        refresh()
    });
    lcd.noUiSlider.on('end',function() {
        console.log("triggered by LCD");
        refresh()
    });
    vf.noUiSlider.on('end',function() {
        console.log("triggered by VF");
        refresh()
    });
    sa_m2g.noUiSlider.on('end',function() {
        console.log("triggered by SA");
        refresh()
    });
    sa_m2cm3.noUiSlider.on('end',function() {
        console.log("triggered by SA");
        refresh()
    });

    $( '#name' ).bind('keypress', function(e){
        if ( e.keyCode == 13 | e.keyCode == 9) {
            console.log("triggered by enter key");
            refresh();
        }
    });

    $("#checkboxes").keydown(function() {
        console.log("triggered by checkboxes");
        refresh();
    });

    $("#doi_label").keydown(function() {
        console.log("triggered by doi");
        refresh()
    });

    $('.chosen-select').on('change', function(evt, params) {
        console.log("triggered by elements");
        refresh()
    });
});



var cache = {}; // Caches search_keys so that we don't do multiple sql queries on the same args
var latest_query = {}; // Stores the most recent query so the table doesn't get updated with old queries

function set_table(data,loc) {
    document.getElementById('table_inner').innerHTML = data ;
    window.history.pushState("object or string", "MOFDB Search", loc);
    $("#mof_table").DataTable(
        {
            "oLanguage": {
                "sSearch": "Filter results" // Less confusing than the defaut "Search" since it doesn't actually do a new search just filter the table
            },
            responsive: true,
            dom: 'Bfrtip',
            buttons: [
                'csv', 'pdf', 'excel',
            ],
            "pageLength": 15,
            "columnDefs": [
                { "width": "5%", "targets": 0 }
            ]
        }
    );
};


    //
    // var vf_min = vf.noUiSlider.get()[0];
    // var vf_max = vf.noUiSlider.get()[1];
    //
    // var pld_min = pld.noUiSlider.get()[0];
    // var pld_max = pld.noUiSlider.get()[1];
    //
    // var lcd_min = lcd.noUiSlider.get()[0];
    // var lcd_max = lcd.noUiSlider.get()[1];
    //
    // var sa_m2g_min = sa_m2g.noUiSlider.get()[0];
    // var sa_m2g_max = sa_m2g.noUiSlider.get()[1];
    //
    // var sa_m2cm3_min = sa_m2cm3.noUiSlider.get()[0];
    // var sa_m2cm3_max = sa_m2cm3.noUiSlider.get()[1];
    //
    //
    // var name = document.getElementById("name").value;
    // var N2 = document.getElementById("N2").checked;
    // var X2 = document.getElementById("X2").checked;
    // var Kr = document.getElementById("Kr").checked;
    // var H2 = document.getElementById("H2").checked;
    // var CO2 = document.getElementById("CO2").checked;
    // var CH4 = document.getElementById("CH4").checked;
    // var H2O = document.getElementById("H2O").checked;
    //
    // var doi = document.getElementById("doi_label").value;
    //
    // var limit = document.getElementById("limit").checked;
    //
    // // Get elements from select bar
    // var elements_object = document.getElementById("elements_label").selectedOptions;
    // var num_elements = elements_object.length;
    // var elements = [];
    // var i;
    // for(i=0; i<num_elements; i++) {
    //     elements[i] = elements_object[i].text;
    // }
    //
    //
    // var select_obj = document.getElementById("dbchoice");
    // var db_choice = select_obj.options[select_obj.selectedIndex].value;
    //
    //