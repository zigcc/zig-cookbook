(function() {
  var btn = document.getElementById('toc-toggle');
  if (!btn) return;
  var body = document.getElementById('body');
  var toc = document.getElementById('toc');
  function closeToc() {
    body.classList.remove('toc-open');
    btn.setAttribute('aria-expanded', 'false');
  }

  function markAndCenterActive() {
    if (!toc) return;
    var links = toc.querySelectorAll('a[href]');
    var currentPath = location.pathname.replace(/\/$/, '');
    var activeLink = null;
    links.forEach(function(a) {
      try {
        var hrefPath = new URL(a.getAttribute('href'), location.origin).pathname.replace(/\/$/, '');
        if (hrefPath === currentPath) {
          a.setAttribute('aria-current', 'page');
          activeLink = a;
        } else {
          a.removeAttribute('aria-current');
        }
      } catch (_) {
        // ignore malformed hrefs
      }
    });
    if (activeLink) {
      var targetScrollTop = activeLink.offsetTop - (toc.clientHeight / 2) + (activeLink.offsetHeight / 2);
      if (!isNaN(targetScrollTop)) toc.scrollTop = Math.max(0, targetScrollTop);
    }
  }

  btn.addEventListener('click', function() {
    var isOpen = body.classList.toggle('toc-open');
    btn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    if (isOpen) {
      requestAnimationFrame(markAndCenterActive);
    }
  });
  if (toc) {
    toc.addEventListener('click', function(e) {
      var target = e.target;
      if (target && target.tagName === 'A') closeToc();
    });
  }
  // Initial mark and center on load (desktop)
  markAndCenterActive();
})(); 