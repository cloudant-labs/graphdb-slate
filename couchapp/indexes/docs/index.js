function (doc) {
  index('title', doc.title, { store: true });
  index('text', doc.text, { store: true });
  index('default', doc.text);
}