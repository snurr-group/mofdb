$(document).on('DOMContentLoaded', function () {
    const unitsSelect = document.getElementById('supportedUnitsSelector')
    let auth_token = document.querySelector("meta[name='csrf-token']").content;
    unitsSelect.addEventListener('change', (event) => {
        const units = event.target.value
        $.ajax({url: `/setUnits?units=${units}`,
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': auth_token,
                    'X-Requested-With': 'XMLHttpRequest'
                },
            success: (data) => {
                window.location.reload()
            }}
        );
    });

})
