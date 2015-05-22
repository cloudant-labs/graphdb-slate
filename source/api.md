---
title: Cloudant Documentation - API reference

language_tabs:
  - http 
  - shell: curl
#  - javascript: node.js
#  - python

toc_footers:
  - <a href="https://cloudant.com/">Cloudant</a>
  - <a href="https://cloudant.com/sign-up/">Sign up</a> / <a href="https://cloudant.com/sign-in/">Sign in</a>
  - <a href="http://stackoverflow.com/questions/tagged/cloudant">Cloudant on StackOverflow</a>
  - <a href='http://github.com/tripit/slate'>Documentation Powered by Slate</a>
  - <a href="https://github.com/cloudant-labs/slate">Documentation Source</a>

includes:
  - api/index

---

<script>
fragments = {
  '#http': '/http.html',
  '#account': '/account.html',
  '#authentication': '/authentication.html',
  '#authorization': '/authorization.html',
  '#cors': '/cors.html',
  '#databases': '/databases.html',
  '#documents': '/documents.html',
  '#attachments': '/attachments.html',
  '#query': '/cloudant_query.html',
  '#design-documents': '/design_documents.html',
  '#creating-views': '/creating_views.html',
  '#search': '/search.html',
  '#cloudant-geospatial': '/geo.html',
  '#replication': '/replication.html',
  '#advanced-replication': '/advanced_replication.html',
  '#active_tasks': '/active_tasks.html',
  '#advanced': '/advanced.html'
}
fragment = window.location.hash;
console.log('fragment is ' + fragment);
dest = fragments[fragment];
console.log('dest is ' + dest);
if (dest) {
  window.location = dest;
}
</script>


