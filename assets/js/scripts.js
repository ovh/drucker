var navbarButton = document.getElementById('navbar-toggle');
var navMain = document.getElementById('navbar-entries');
var navbarToggle = false;

var toggleNav = function() {
    navbarToggle = !navbarToggle;

    if (navbarToggle) {
        navMain.classList.add('navbar__entries--active');
    }
    else {
        navMain.classList.remove('navbar__entries--active');
    }
}

navbarButton.addEventListener('click', toggleNav);
