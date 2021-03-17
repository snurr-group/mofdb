const post = (url, key, value) => {
    let auth_token = document.querySelector("meta[name='csrf-token']").content;
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
            window.location.reload()
        }}
    );
}

$(document).on('DOMContentLoaded', function () {
    const unitsSelect = document.getElementById('loadingUnitsSelector')
    unitsSelect.addEventListener('change', (event) => {
        const units = event.target.value
        post(`/setUnits`, "loading", units)
    });
    const pressureSelector = document.getElementById('pressureUnitsSelector')
    pressureSelector.addEventListener('change', (event) => {
        const units = event.target.value
        post(`/setUnits`, "pressure", units)
    });
});

