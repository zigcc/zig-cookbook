(() => {
  const root = document.documentElement;
  const body = document.body;
  const tocToggle = document.querySelector('#toc-toggle');
  const sidebarCollapse = document.querySelector('#sidebar-collapse');
  const sidebarExpand = document.querySelector('#sidebar-expand');
  const search = document.querySelector('#toc-search');
  const savedSections = JSON.parse(localStorage.getItem('zig-cookbook-sections') || '{}');

  root.removeAttribute('data-theme');
  localStorage.removeItem('zig-cookbook-theme');

  const normalizePath = (path) => {
    const withoutIndex = path.replace(/index\.html$/, '');
    return withoutIndex.replace(/\/$/, '') || '/';
  };

  const markActiveLink = () => {
    const currentPath = normalizePath(location.pathname);
    document.querySelectorAll('.toc-nav a[href]').forEach((link) => {
      try {
        const isCurrent = normalizePath(new URL(link.getAttribute('href'), location.origin).pathname) === currentPath;
        link.classList.toggle('active', isCurrent);
        if (isCurrent) link.setAttribute('aria-current', 'page');
        else link.removeAttribute('aria-current');
      } catch {
        link.classList.remove('active');
        link.removeAttribute('aria-current');
      }
    });
  };

  const setupSections = () => {
    document.querySelectorAll('.toc-nav li').forEach((item, index) => {
      const children = Array.from(item.children).find((child) => child.tagName === 'UL');
      if (!children) return;

      item.classList.add('has-children');
      const label = Array.from(item.children).find((child) => ['A', 'P', 'SPAN'].includes(child.tagName));
      const toggle = document.createElement('button');
      toggle.className = 'chapter-fold-toggle';
      toggle.type = 'button';
      toggle.setAttribute('aria-label', 'Toggle section');
      toggle.setAttribute('aria-expanded', String(savedSections[index] === true));
      toggle.innerHTML = '<span aria-hidden="true">›</span>';
      label?.after(toggle);

      if (savedSections[index] === true) item.classList.add('expanded');

      toggle.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        const expanded = item.classList.toggle('expanded');
        toggle.setAttribute('aria-expanded', String(expanded));
        const sections = JSON.parse(localStorage.getItem('zig-cookbook-sections') || '{}');
        sections[index] = expanded;
        localStorage.setItem('zig-cookbook-sections', JSON.stringify(sections));
      });
    });

    document.querySelectorAll('.toc-nav a[aria-current="page"]').forEach((link) => {
      let parent = link.closest('li');
      while (parent) {
        if (parent.classList.contains('has-children')) {
          parent.classList.add('expanded');
          parent.querySelector(':scope > .chapter-fold-toggle')?.setAttribute('aria-expanded', 'true');
        }
        parent = parent.parentElement?.closest('li');
      }
    });
  };

  tocToggle?.addEventListener('click', () => {
    const open = body.classList.toggle('toc-open');
    tocToggle.setAttribute('aria-expanded', String(open));
  });

  const toggleSidebar = () => {
    body.classList.toggle('sidebar-collapsed');
    localStorage.setItem('zig-cookbook-sidebar', body.classList.contains('sidebar-collapsed') ? 'hidden' : 'visible');
  };

  sidebarCollapse?.addEventListener('click', toggleSidebar);
  sidebarExpand?.addEventListener('click', toggleSidebar);

  document.querySelector('.toc-nav')?.addEventListener('click', (event) => {
    if (event.target.closest('a') && window.matchMedia('(max-width: 800px)').matches) {
      body.classList.remove('toc-open');
      tocToggle?.setAttribute('aria-expanded', 'false');
    }
  });

  search?.addEventListener('input', () => {
    const query = search.value.trim().toLowerCase();
    document.querySelectorAll('.toc-nav li').forEach((item) => {
      item.hidden = Boolean(query) && !item.textContent.toLowerCase().includes(query);
    });
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === '/' && document.activeElement !== search) {
      event.preventDefault();
      search?.focus();
    }
    if (event.key === 'Escape') search?.blur();
  });

  markActiveLink();
  if (localStorage.getItem('zig-cookbook-sidebar') === 'hidden') body.classList.add('sidebar-collapsed');
  setupSections();
})();
