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

// Change the order of jquery/datatables/and require_tree at your own peril.
// I highly recommend not touching this.
//= require "./application/vendor/jquery.3.1.js"
//= require "./application/vendor/jquery.dataTables.min.js"
//= require "./application/vendor/dataTables.responsive.min.js"
//= require activestorage
//= require_tree ./application
//= require "nouislider"




window.addEventListener('DOMContentLoaded', (event) => {
    const env = document.querySelector('body').dataset['rails_env']

    if (env === 'production') {
        window.dataLayer = window.dataLayer || [];
        function gtag() {dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', 'UA-111016820-6');
    }
});
