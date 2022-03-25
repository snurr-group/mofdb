// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

// Don't include plotly. It's huge. We only load this on the mofs#show pages for the graphs.
// Also skip ngl the graphis library for showing CIF files.
// They are all in plots_bundle.js
//= stub plotly-latest.min.js
//= stub plots_bundle.js
//= stub ngl.js


// Change the order of jquery/datatables/and require_tree at your own peril.
// I highly recommend not touching this.
//= require "jquery.3.1.js"
//= require "jquery.dataTables.min.js"
//= require "dataTables.responsive.min.js"
//= require activestorage
//= require_tree .
//= require "nouislider"




window.addEventListener('DOMContentLoaded', (event) => {
    hljs.highlightAll();
    const env = document.querySelector('body').dataset['rails_env']

    if (env === 'production') {
        window.dataLayer = window.dataLayer || [];
        function gtag() {dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'UA-111016820-6');
    }

    document.querySelectorAll('.copy').forEach(function (item) {
        item.addEventListener('click',function() {
            copyText(item.dataset.copy);
        });
    });
});

function copyText (textToCopy) {
    this.copied = false;

    // Create textarea element
    const textarea = document.createElement('textarea');

    // Set the value of the text
    textarea.value = textToCopy;

    // Make sure we cant change the text of the textarea
    textarea.setAttribute('readonly', '');

    // Hide the textarea off the screnn
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';

    // Add the textarea to the page
    document.body.appendChild(textarea);

    // Copy the textarea
    textarea.select();

    try {
        var successful = document.execCommand('copy');
        this.copied = true
    } catch(err) {
        this.copied = false
    }
    textarea.remove()
}
