const post = (url, key, value) => {
    const csrf = document.querySelector("meta[name='csrf-token']");
    let auth_token = csrf ? csrf.content : null;
    $.ajax({url: url,
        method: 'POST',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': auth_token,
            'X-Requested-With': 'XMLHttpRequest',
            [key]: value,
        },
        success: (data) => {
            console.info("server replied, reloading page");
            window.location.reload()
        }}
    );
}

$(document).on('DOMContentLoaded', function () {
    const unitsSelect = document.getElementById('loadingUnitsSelector')
    unitsSelect.addEventListener('change', (event) => {
        const units = document.getElementById("loadingUnitsSelector").value
        console.info("units", units)
        post(`/setUnits`, "loading", units)
    });
    const pressureSelector = document.getElementById('pressureUnitsSelector')
    pressureSelector.addEventListener('change', (event) => {
        const units = document.getElementById("pressureUnitsSelector").value
        console.info("units", units)
        post(`/setUnits`, "pressure", units)
    });
});

