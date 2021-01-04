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
//= require rails-ujs
//= require jquery.3.1.js
//= require jquery.dataTables.min.js
//= require dataTables.responsive.min.js
//= require dataTables.buttons.min.js
//= require activestorage

//= require_tree .
//= require nouislider

window.addEventListener('DOMContentLoaded', (event) => {
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
