document.addEventListener("DOMContentLoaded", function(event) {
    var nav = document.getElementById("nav");
    stickybits(nav, {useStickyClasses: true});
    console.log('stuck');
});