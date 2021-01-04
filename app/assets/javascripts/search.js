// 4 Sliders to choose ranges

function dictToURI(dict) {
    var str = [];
    for (var p in dict) {
        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(dict[p]));
    }
    return str.join("&");
}

active = 'mofid';

window.onbeforeunload = function () {
    pld = document.getElementById('pld_slider');
    lcd = document.getElementById('lcd_slider');
    vf = document.getElementById('vf_slider');
    sa_m2g = document.getElementById('sa_m2g_slider');
    sa_m2cm3 = document.getElementById('sa_m2cm3_slider');
    if (pld == undefined) {
        return
    } else {
        pld.noUiSlider.destroy();
        lcd.noUiSlider.destroy();
        vf.noUiSlider.destroy();
        sa_m2g.noUiSlider.destroy();
        sa_m2cm3.noUiSlider.destroy();
    }
};

function toggle(mode) {
    console.log(mode);
    if (mode == "mofid") {
        active = mode;
        document.getElementById('mofid_button').classList.add('active');
        document.getElementById('mofkey_button').classList.remove('active');
    } else if (mode == "mofkey") {
        active = mode;
        document.getElementById('mofkey_button').classList.add('active');
        document.getElementById('mofid_button').classList.remove('active');
    }
}

$(document).on('DOMContentLoaded', function () {
    // Prepare Sliders
    pld = document.getElementById('pld_slider');

    if (!pld) {
        return
    }

    document.getElementById('mofid_button').addEventListener('click', function () {
        toggle("mofid");
    });
    document.getElementById('mofkey_button').addEventListener('click', function () {
        toggle("mofkey");
    });

    if (pld == undefined) {
        return
    }

    lcd = document.getElementById('lcd_slider');
    vf = document.getElementById('vf_slider');
    sa_m2g = document.getElementById('sa_m2g_slider');
    sa_m2cm3 = document.getElementById('sa_m2cm3_slider');
    limit = document.getElementById('limit');


    noUiSlider.create(pld, {
        start: [0, 20],
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
        start: [0, 100],
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
        start: [0, 1],
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
        start: [0, 10000],
        step: 100,
        range: {
            'min': [0],
            'max': [10000]
        },
        connect: true,
        format: wNumb({
            decimals: 0,
            thousand: '',
        })
    });

    noUiSlider.create(sa_m2cm3, {
        start: [0, 5000],
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

    $("#checkboxes").click(function () {
        console.log("triggered by Checkboxes");
        refresh()
    });
    $("#limit").click(function () {
        console.log("triggered by Limit");
        refresh()
    });

    $("#dbchoice").change(function () {
        console.log("triggered by database");
        refresh()
    });

    pld.noUiSlider.on('set', function () {
        console.log("triggered by PLD");
        refresh()
    });
    lcd.noUiSlider.on('set', function () {
        console.log("triggered by LCD");
        refresh()
    });
    vf.noUiSlider.on('set', function () {
        console.log("triggered by VF");
        refresh()
    });
    sa_m2g.noUiSlider.on('set', function () {
        console.log("triggered by SA");
        refresh()
    });
    sa_m2cm3.noUiSlider.on('set', function () {
        console.log("triggered by SA");
        refresh()
    });

    $('#name').bind('keypress', function (e) {
        if (e.keyCode == 13 | e.keyCode == 9) {
            console.log("triggered by enter key: name");
            refresh();
        }
    });

    $('#mofidkey').bind('keypress', function (e) {
        if (e.keyCode == 13 | e.keyCode == 9) {
            console.log("triggered by enter key: mofid ");
            refresh();
        }
    });

    $("#checkboxes").keydown(function () {
        console.log("triggered by checkboxes");
        refresh();
    });

    $("#doi_label").keydown(function () {
        console.log("triggered by doi");
        refresh()
    });

    $('.chosen-select').on('change', function (evt, params) {
        console.log("triggered by elements");
        refresh()
    });

    $('#db_choice').on('change', function () {
        console.log("triggered by db choice");
        refresh();
    });

    start_loading();
    set_table();
    refresh();

});

function start_loading() {

    // turn on loading svg and turn off table
    document.getElementById('table_wrap').style.opacity = '0.2';
    document.getElementById('loading').style.display = 'unset'
}

function finish_loading() {
    // turn off loading svg turn on table
    document.getElementById('table_wrap').style.opacity = '1';
    document.getElementById('loading').style.display = 'none'
}

table = undefined;

function set_table(data) {
    // Setup data table with data in the form of a "string" containing <tr>s


    if (table != undefined) {
        table.destroy();
    }

    if (data != undefined) {
        document.getElementById('mof_tbody').innerHTML = data;
    } else {
        document.getElementById('mof_tbody').innerHTML = "   Loading..."
    }

    table = $("#mof_table").DataTable(
        {
            "oLanguage": {
                "sSearch": "Filter results" // Less confusing than the defaut "Search" since it doesn't actually do a new search just filter the table
            },
            "aaSorting": [],
            responsive: true,
            dom: 'Bfrtip',
            buttons: [
                'csv', 'pdf', 'excel',
            ],
            "pageLength": 15,
            "columnDefs": [
                {"width": "5%", "targets": 0}
            ]
        }
    );
};


function unset_link() {
    const countSpan = document.getElementById('mofdb-count');
    countSpan.innerHTML = "<i>(loading#)</i>"

}
function set_link(url, count) {
    const copy = Object.assign({}, url)
    delete copy['cifs']
    delete copy['html']
    copy['bulk'] = true
    const link = document.getElementById('download_cifs');
    const countSpan = document.getElementById('mofdb-count');
    countSpan.innerText = count
    link.href = '/mofs.json?' + dictToURI(copy)
}

search_cache = {};
count_cache = {}

function get_params() {
    let vf_min = vf.noUiSlider.get()[0];
    let vf_max = vf.noUiSlider.get()[1];

    let pld_min = pld.noUiSlider.get()[0];
    let pld_max = pld.noUiSlider.get()[1];

    let lcd_min = lcd.noUiSlider.get()[0];
    let lcd_max = lcd.noUiSlider.get()[1];

    let sa_m2g_min = sa_m2g.noUiSlider.get()[0];
    let sa_m2g_max = sa_m2g.noUiSlider.get()[1];

    let sa_m2cm3_min = sa_m2cm3.noUiSlider.get()[0];
    let sa_m2cm3_max = sa_m2cm3.noUiSlider.get()[1];


    let name = document.getElementById("name").value;
    let idkey = document.getElementById('mofidkey').value;
    let N2 = document.getElementById("N2").checked;
    let Ar = document.getElementById("Ar").checked;
    let X2 = document.getElementById("Xe").checked;
    let Kr = document.getElementById("Kr").checked;
    let H2 = document.getElementById("H2").checked;
    let CO2 = document.getElementById("CO2").checked;
    let CH4 = document.getElementById("CH4").checked;
    let H2O = document.getElementById("H2O").checked;
    let gases = [];


    if (N2)
        gases = gases.concat("Nitrogen");
    if (X2)
        gases = gases.concat("Xenon");
    if (Kr)
        gases = gases.concat("Krypton");
    if (H2)
        gases = gases.concat("Hydrogen");
    if (CO2)
        gases = gases.concat("CarbonDioxide");
    if (CH4)
        gases = gases.concat("Methane");
    if (H2O)
        gases = gases.concat("Water");
    if (Ar)
        gases = gases.concat("Argon");

    let doi = document.getElementById("doi_label").value;


// Get elements from select bar
    let elements_object = document.getElementById("elements_label").selectedOptions;
    let num_elements = elements_object.length;
    let elements = [];
    let i;
    for (i = 0; i < num_elements; i++) {
        elements[i] = elements_object[i].text;
    }

    let select_obj = document.getElementById("db_choice");
    let db_choice = select_obj.options[select_obj.selectedIndex].value;

    let url_params = {
        "vf_min": vf_min,
        "vf_max": vf_max,

        "pld_min": pld_min,
        "pld_max": pld_max,

        "lcd_min": lcd_min,
        "lcd_max": lcd_max,

        "sa_m2g_min": sa_m2g_min,
        "sa_m2g_max": sa_m2g_max,

        "sa_m2cm3_min": sa_m2cm3_min,
        "sa_m2cm3_max": sa_m2cm3_max,

        "name": name,
        "gases": gases,

        "database": db_choice,
        "elements": elements,

        "doi": doi
    };

    if (active == "mofid") {
        url_params["mofid"] = idkey;
    } else if (active == "mofkey") {
        url_params["mofkey"] = idkey;
    }
    return url_params
}

function refresh() {

    start_loading();

    const url_params = get_params()

    let html_params = Object.assign({}, url_params); // Copy params to html_params and add the flag so the api returns table rows
    html_params['html'] = true;
    url_params['cifs'] = true; // The link "Download Cifs" needs to return a zip so add this flag
    let url_params_as_string = dictToURI(url_params);

    function finish_search(data) {
        search_cache[url_params_as_string] = data;
        finish_loading();
        set_table(data);

    }

    if (search_cache[url_params_as_string] && count_cache[url_params_as_string]) {
        console.log("cache hit");
        finish_loading();
        set_table(search_cache[url_params_as_string]);
        set_link(url_params, count_cache[url_params_as_string]);
        return
    }

    unset_link()
    $.get("/mofs/search", html_params, function (data, status, xhr) {
        // First get the mof results
        finish_search(data)

        // Then remove the html param and make a separate request to get the # of MOFs
        delete html_params["html"]
        $.getJSON("/mofs/count", html_params, function (data, status, xhr) {
            const count = xhr.getResponseHeader('mofdb-count')
            count_cache[url_params_as_string] = count;
            set_link(url_params, count);
        })
    });
}
