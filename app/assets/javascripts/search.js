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


const MIN_MAXES = {
    'pld_min': 0,
    'pld_max': 20,
    'lcd_min': 0,
    'lcd_max': 100,
    'vf_min': 0,
    'vf_max': 1,
    'sa_m2g_min': 0,
    'sa_m2g_max': 10000,
    'sa_m2cm3_min': 0,
    'sa_m2cm3_max': 5000,
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
        start: [MIN_MAXES['pld_min'], MIN_MAXES['pld_max']],
        step: .1,
        range: {
            'min': [MIN_MAXES['pld_min']],
            'max': [MIN_MAXES['pld_max']]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: '',
        })
    });
    noUiSlider.create(lcd, {
        start: [MIN_MAXES['lcd_min'], MIN_MAXES['lcd_max']],
        step: .1,
        range: {
            'min': [MIN_MAXES['lcd_min']],
            'max': [MIN_MAXES['lcd_max']]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: '',
        })
    });
    noUiSlider.create(vf, {
        start: [MIN_MAXES['vf_min'], MIN_MAXES['vf_max']],
        step: .01,
        mark: '.',
        range: {
            'min': [MIN_MAXES['vf_min']],
            'max': [MIN_MAXES['vf_max']]
        },
        connect: true,
        format: wNumb({
            decimals: 2,
            thousand: ''
        })
    });
    noUiSlider.create(sa_m2g, {
        start: [MIN_MAXES['sa_m2g_min'], MIN_MAXES['sa_m2g_max']],
        step: 100,
        range: {
            'min': [MIN_MAXES['sa_m2g_min']],
            'max': [MIN_MAXES['sa_m2g_max']]
        },
        connect: true,
        format: wNumb({
            decimals: 0,
            thousand: '',
        })
    });
    noUiSlider.create(sa_m2cm3, {
        start: [MIN_MAXES['sa_m2cm3_min'], MIN_MAXES['sa_m2cm3_max']],
        step: 100,
        range: {
            'min': [MIN_MAXES['sa_m2cm3_min']],
            'max': [MIN_MAXES['sa_m2cm3_max']]
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
                // 'csv', 'excel',
            ],
            "pageLength": 15,
            "columnDefs": [
                {"width": "5%", "targets": 0}
            ]
        }
    );
}


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
last_search = "";

const GASES_DOM_ID_AND_NAME = [
    ["N2", "Nitrogen"],
    ["Ar", "Argon"],
    ["Xe", "Xenon"],
    ["Kr", "Krypton"],
    ["H2", "Hydrogen"],
    ["CO2", "CarbonDioxide"],
    ["CH4", "Methane"],
    ["H2O", "Water"],
];

function get_params() {

    // mofid / mofkey
    let idkey = document.getElementById('mofidkey').value;

    // gases checkboxes
    let gases = [];
    GASES_DOM_ID_AND_NAME.forEach(function (gas) {
        let dom_id = gas[0];
        let name = gas[1];
        let checked = document.getElementById(dom_id).checked;
        if (checked) {
            gases = gases.concat(name);
        }
    })


    // Get elements from select bar
    let elements_object = document.getElementById("elements_label").selectedOptions;
    let num_elements = elements_object.length;
    let elements = [];
    for (let i = 0; i < num_elements; i++) {
        elements[i] = elements_object[i].text;
    }

    let select_obj = document.getElementById("db_choice");
    let db_choice = select_obj.options[select_obj.selectedIndex].value;


    let url_params = {
        'vf_min': vf.noUiSlider.get()[0],
        'vf_max': vf.noUiSlider.get()[1],
        'pld_min': pld.noUiSlider.get()[0],
        'pld_max': pld.noUiSlider.get()[1],
        'lcd_min': lcd.noUiSlider.get()[0],
        'lcd_max': lcd.noUiSlider.get()[1],
        'sa_m2g_min': sa_m2g.noUiSlider.get()[0],
        'sa_m2g_max': sa_m2g.noUiSlider.get()[1],
        'sa_m2cm3_min': sa_m2cm3.noUiSlider.get()[0],
        'sa_m2cm3_max': sa_m2cm3.noUiSlider.get()[1],
    };

    let doi = document.getElementById("doi_label").value;
    if (doi !== "") {
        url_params['doi'] = doi;
    }

    if (gases.length !== 0) {
        url_params["gases"] = gases;
    }

    if (elements.length !== 0) {
        url_params['elements'] = elements;
    }

    if (db_choice !== "Any") {
        url_params['database'] = db_choice;
    }

    let name = document.getElementById("name").value;
    if (name !== '') {
        url_params['name'] = name;
    }


    for (let key in url_params) {
        if (key in MIN_MAXES) {
            if (MIN_MAXES[key] == url_params[key]) {
                delete url_params[key]
            }
        }
    }

    if (active === "mofid" && idkey !== "") {
        url_params["mofid"] = idkey;
    } else if (active === "mofkey" && idkey !== "") {
        url_params["mofkey"] = idkey;
    }

    return url_params
}

function refresh() {


    const url_params = get_params()

    // Don't put anything crazy in url_params
    // b/c we use JSONify to compare them
    const flat_params = JSON.stringify(url_params)
    if (last_search === flat_params) {
        console.debug("Query matches last search skipping...")
        return;
    }
    last_search = flat_params

    start_loading();

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
    $.get("/mofs", html_params, function (data, status, xhr) {
        // First get the mof results
        finish_search(data)

        // Then remove the html param and make a separate request to get the # of MOFs
        delete html_params["html"]
        $.getJSON("/mofs/count.json", html_params, function (data, status, xhr) {
            const count = data['count'];
            if (data['status'] === 'success') {
                count_cache[url_params_as_string] = count;
                set_link(url_params, count);
            } else {
                count_cache[url_params_as_string] = "Too many mofs to count...";
                set_link(url_params, "Too many mofs to count...");
            }

        })
    });


}
