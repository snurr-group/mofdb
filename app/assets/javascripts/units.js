$(document).on('DOMContentLoaded', function () {
    const unitsSelect = document.getElementById('supportedUnitsSelector')
    unitsSelect.addEventListener('change', (event) => {
        const units = event.target.value
        $.post(`/setUnits?units=${units}`, (data) => {
                window.location.reload()
            }
        );
    });

})
