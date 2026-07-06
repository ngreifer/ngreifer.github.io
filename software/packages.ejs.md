```{=html}
<style>
.pkg-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.25rem;
  margin-top: 1rem;
}
.pkg-card {
  border: 1px solid var(--bs-border-color);
  border-radius: 0.5rem;
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  background: var(--bs-body-bg);
}
.pkg-header {
  display: flex;
  align-items: center;
  gap: 0.85rem;
}
.pkg-logo {
  width: 54px;
  height: 54px;
  object-fit: contain;
  border-radius: 6px;
  flex-shrink: 0;
}
.pkg-title-link {
  color: inherit;
  text-decoration: none;
}
.pkg-title-link:hover {
  color: var(--bs-link-color);
  text-decoration: underline;
}
.pkg-name {
  font-family: var(--bs-font-monospace);
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
}
.pkg-version {
  font-size: 0.78rem;
  color: var(--bs-secondary-color);
  margin: 0;
}
.pkg-subtitle {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--bs-body-color);
  margin: 0;
}
.pkg-desc {
  font-size: 0.9rem;
  color: var(--bs-secondary-color);
  line-height: 1.55;
  flex: 1;
  margin: 0;
}
.pkg-preview {
  width: 100%;
  border-radius: 6px;
  border: 1px solid var(--bs-border-color);
  object-fit: cover;
  max-height: 160px;
  background-color: white;
}
.pkg-authors {
  font-size: 0.82rem;
  color: var(--bs-secondary-color);
}
.pkg-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
}
.pkg-tag {
  font-size: 0.75rem;
  padding: 0.15rem 0.55rem;
  border-radius: 20px;
  background: var(--bs-secondary-bg);
  color: var(--bs-secondary-color);
  border: 1px solid var(--bs-border-color);
}
.pkg-links {
  display: flex;
  gap: 0.4rem;
  padding-top: 0.6rem;
  border-top: 1px solid var(--bs-border-color);
  flex-wrap: wrap;
  margin-top: auto;
}
.pkg-link {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.82rem;
  padding: 0.25rem 0.6rem;
  border-radius: 0.3rem;
  border: 1px solid #ddd;
  color: #333;
  text-decoration: none;
  background: #f0f0f0;
}
.pkg-link:hover {
  color: #333;
  border-color: #aaa;
  background: #e0e0e0;
}
</style>

<div class="pkg-grid list">
<% for (const item of items) { %>
<%
  const pkg = {
    logo:    item.logo    || null,
    preview: item.preview || null,
    github:  item.github  || null,
    cran:    item.cran    || null,
    docs:    item.docs    || null
  };
%>
<div class="pkg-card" data-pkg="<%- JSON.stringify(pkg) %>" <%= metadataAttrs(item) %>>

  <div class="pkg-header">
    <% if (item.logo) { %>
    <img class="pkg-logo" src="" alt="<%= item.title %> logo">
    <% } %>
    <div>
      <a class="pkg-title-link pkg-name listing-title" href="#"><%= item.title %></a>
      <% if (item.version) { %>
      <p class="pkg-version"><%= item.version %></p>
      <% } %>
    </div>
  </div>

  <% if (item.subtitle) { %>
  <p class="pkg-subtitle listing-subtitle"><%= item.subtitle %></p>
  <% } %>

  <p class="pkg-desc listing-description"><%= item.description %></p>

  <% if (item.preview) { %>
  <img class="pkg-preview" src="" alt="<%= item.title %> sample output">
  <% } %>

  <% if (item.categories && item.categories.length > 0) { %>
  <div class="pkg-tags">
    <% for (const cat of item.categories) { %>
    <span class="pkg-tag listing-categories"><%= cat %></span>
    <% } %>
  </div>
  <% } %>

  <% if (item.author) { %>
  <div class="pkg-authors listing-author">
    <i class="bi bi-person"></i> <%= item.author %>
  </div>
  <% } %>

  <div class="pkg-links">
    <% if (item.github) { %>
    <a class="pkg-link pkg-github" href="#">
      <i class="bi bi-github"></i> GitHub
    </a>
    <% } %>
    <% if (item.cran) { %>
    <a class="pkg-link pkg-cran" href="#">
      <i class="bi bi-box-seam"></i> CRAN
    </a>
    <% } %>
    <% if (item.docs) { %>
    <a class="pkg-link pkg-docs" href="#">
      <i class="bi bi-book"></i> Docs
    </a>
    <% } %>
  </div>

</div>
<% } %>
</div>

<script>
document.querySelectorAll('.pkg-card[data-pkg]').forEach(function(card) {
  var pkg = JSON.parse(card.getAttribute('data-pkg'));
  var primaryUrl = pkg.docs || pkg.cran || pkg.github || null;
  if (primaryUrl) {
    var titleLink = card.querySelector('.pkg-title-link');
    if (titleLink) {
      titleLink.href = primaryUrl;
      titleLink.target = '_blank';
      titleLink.rel = 'noopener';
    }
  }
  if (pkg.logo) {
    var logo = card.querySelector('.pkg-logo');
    if (logo) logo.src = pkg.logo;
  }
  if (pkg.preview) {
    var preview = card.querySelector('.pkg-preview');
    if (preview) preview.src = pkg.preview;
  }
  if (pkg.github) {
    var a = card.querySelector('.pkg-github');
    if (a) { a.href = pkg.github; a.target = '_blank'; a.rel = 'noopener'; }
  }
  if (pkg.cran) {
    var a = card.querySelector('.pkg-cran');
    if (a) { a.href = pkg.cran; a.target = '_blank'; a.rel = 'noopener'; }
  }
  if (pkg.docs) {
    var a = card.querySelector('.pkg-docs');
    if (a) { a.href = pkg.docs; a.target = '_blank'; a.rel = 'noopener'; }
  }
});
</script>
```
