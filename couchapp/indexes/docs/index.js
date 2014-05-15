function (doc) {
  Object.keys(doc).forEach(function (key) {
    if (key[0] !== '_') {
      if (typeof(doc[key]) !== 'object') {
        index(key, doc[key]);
      } else if (doc[key].forEach) {
        // TODO
      } else {
        // TODO
      }
    }
  });
}