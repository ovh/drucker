var navbarButton = document.getElementById('navbar-toggle');
var navMain = document.getElementById('navbar-entries');
var navIcon = document.getElementById('navbar-icon');
var navbarToggle = false;

var toggleNav = function() {
    navbarToggle = !navbarToggle;

    if (navbarToggle) {
        navMain.classList.add('navbar__entries--active');
        navIcon.classList.add('navbar__icon--active');
    }
    else {
        navMain.classList.remove('navbar__entries--active');
        navIcon.classList.remove('navbar__icon--active');
    }
}

navbarButton.addEventListener('click', toggleNav);
