## Creating Views

Views are used to obtain data stored within a database.
Views are written using Javascript functions.

### View concepts

Views are mechanisms for working with document content in databases.
A view can selectively filter documents.
It can speed up searching for content.
It can be used to 'pre-process' the results before they are returned to the client.

Views are simply Javascript functions,
defined within the view field of a design document.
When you use a view,
or more accurately when make a query using your view,
the system applies the Javascript function to each and every document in the database.
Views can be complex.
You might choose to define a collection of Javascript functions to create the overall view required.

### A simple view

> Example of a simple view, using a map function:

```sourceCode
function(doc) {
  if(doc.date && doc.title) {
    emit(doc.date, doc.title);
  }
}
```

The simplest form of view is a map function.
