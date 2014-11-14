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
function(employee) {
  if(employee.training) {
    emit(employee.number, employee.training);
  }
}
```

> Simplified example data:

```json
{
  _id:"23598567",
  "number":"23598567",
  "training":"2014/05/21 10:00:00"
}

{
  _id:"10278947",
  "number":"10278947"
}

{
  _id:"23598567",
  "number":"23598567",
  "training":"2014/07/30 12:00:00"
}
```

> Example response from running the view query

```json
{
  "total_rows": 2,
  "offset": 0,
  "rows": [
    {
      "id":"23598567",
      "number":"23598567",
      "training":"2014/05/21 10:00:00"
    },

    {
      "id":"23598567",
      "number":"23598567",
      "training":"2014/07/30 12:00:00"
    }

  ]
}
```

The simplest form of view is a map function.
The map function produces output data that represents an analysis (a mapping) of the documents stored within the database.

For example,
you might want to find out which employees have had some safety training,
and the date when that training was completed.
You could do this by inspecting each document,
looking for a field in the document called "training".
If the field is present,
the employee completed the training on the date recorded as the value.
If the field is not present,
the employee has not completed the training.

Using the `emit` function in the example view function makes it easy to produce a list in response to running a query using the view.
The list consists of key and value pairs,
where the key helps you identify the specific document and the value provides just the precise detail you want.
The list also includes metadata such as the number of key:value pairs returned.

<aside class="notice">The document `_id` is automatically included in each of the key:value pair result records.
This is to make it easier for the client to work with the results.</aside>

### Storing the view definition

> Example for `PUT`ting a view, stored in a file (`view.def`), into a design document (`training`):

```sourceCode
curl -X PUT /<database>/_design/training --data-binary @view.def
```

> Example format for the view:

```json
{
  "views" : {
    "hadtraining" : {
      "map" : "function(employee) { if(employee.training) { emit(employee.number, employee.training); } }"
    }
  }
}
```

Each view is a Javascript function.
Views are stored in design documents.
So,
to store a view,
we simply store the function definition within a design document.

Do this by `PUT`ting the view definition content into a `_design` document.
In this example,
the `hadtraining` view is defined as a map function,
and is available within the `views` field of the design document.