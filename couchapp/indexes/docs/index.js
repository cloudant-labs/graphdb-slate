function (doc) {
  index('title', doc.title, { store: true });
  index('text', doc.text, { store: true });
  index('default', doc.text, { boost: 1.0, store: true});
  index('default', doc.title, { boost: 10.0, store: true});
}
