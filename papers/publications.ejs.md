```{=html}
<style>
.pub-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}
.pub-item {
  font-size: 0.95rem;
  line-height: 1.6;
  padding-bottom: 0.85rem;
  border-bottom: 1px solid var(--bs-border-color);
}
.pub-item:last-child {
  border-bottom: none;
}
.pub-link {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.82rem;
  margin-top: 0.3rem;
  color: var(--bs-link-color);
  text-decoration: none;
}
.pub-link:hover {
  text-decoration: underline;
}
</style>

<ul class="pub-list list">
<% for (const item of items) { %>
<li class="pub-item" <%= metadataAttrs(item) %>>
  <span class="pub-citation"><%= item.citation %></span><br>
  <a class="pub-link pub-doi" href="#">
    <i class="bi bi-box-arrow-up-right"></i>
    <span class="pub-doi-text"><%= item.doi %></span>
  </a>
</li>
<% } %>
</ul>

<script>
document.querySelectorAll('.pub-doi').forEach(function(el) {
  var doi = el.querySelector('.pub-doi-text').textContent.trim();
  el.href = 'https://doi.org/' + doi;
  el.target = '_blank';
  el.rel = 'noopener';
});
</script>
```
