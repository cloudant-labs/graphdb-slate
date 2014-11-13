## Using Views

Views are used to obtain data stored within a database.
Views are written using Javascript functions,
and work by letting you search for content that matches specific criteria.
The criteria are specified within the function,
or supplied as arguments to the function.

### Querying a view

-   **Method**: `GET /db/_design/<design-doc>/_view/<view-name>`
-   **Request**: None
-   **Response**: JSON of the documents returned by the view
-   **Roles permitted**: \_reader

Executes the specified `view-name` from the specified `design-doc` design document.

#### Query Arguments

Argument | Description | Optional | Type | Default | Supported values
---------|-------------|----------|------|---------|-----------------
`descending` | Return the documents in descending by key order. | yes | Boolean | false | 
`endkey` | Stop returning records when the specified key is reached. | yes | String or JSON array | | 
`endkey_docid` | Stop returning records when the specified document ID is reache.d | yes | String | | 
`group` | Group the results using the reduce function to a group or single row. | yes | Boolean | false | 
`group_level` | Only applicable if the view uses complex keys: keys that are JSON arrays. Groups reduce results for the specified number of array fields. | yes | Numeric | | 
`include_docs` | Include the full content of the documents in the response. | yes | Boolean | false | 
`inclusive_end` | Include rows with the specified end key. | yes | Boolean | true | 
`key` | Return only documents that match the specified key. Note: Leys are JSON values, and must be URL-encoded. | yes | String | | 
`limit` | Limit the number of returned documents to the specified value. | yes | Numeric | | 
`reduce` | Use the reduce function. | yes | Boolean | true | 
`skip` | Skip this number of rows from the start. | yes | Numeric | 0 | 
`stale` | Allow the results from a stale view to be used. This makes the request return immediately, even if the view has not been completely built yet. If this parameter is not given, a response is returned only after the view has been built. | yes | String | false | `ok`: Allow stale views.<br/>`update_after`: Allow stale views, but update them immediately after the request.
`startkey` | Return records starting with the specified key. | yes | String or JSON array | | 
`startkey_docid` | Return records starting with the specified document ID. | yes | String | | 

#### Querying Views and Indexes

When a view is defined in a design document,
a corresponding index is also created,
based on the key information defined within the view.
The index helps improve performance when using the view to access documents,
for example when searching or selecting documents.
To save time,
the index is not populated with content until the view is used.

The index content is generated when the view is first used.
The index content is updated incrementally and automatically when the view is used again after any one of the following three situations has occurred:

-   A new document has been added to the database.
-   An existing document has been deleted from the database.
-   An existing document in the database has been updated or modified in some way.

When a view is being applied to the database,
a check is first made to see if any index updates should be performed.
If any updates are required,
they are completed before the view query is applied.

View indexes are rebuilt entirely when the view definition changes.
This ensures that changes to the view definitions are reflected in the view indexes.
To achieve this,
a 'fingerprint' of the view definition is created whenever the design document is updated.
If the fingerprint changes,
then the view indexes are completely rebuilt.

<aside class="notice">View index rebuilds occur whenever a change occurs to any one view from all the views defined in the design document.
For example,
if you have a design document with three views,
and you update the design document,
all three view indexes within the design document are rebuilt.</aside>

The results returned by a view are updated when the view is queried.
This means that there might be a delay in returning the results when the view is accessed,
especially if there are a large number of documents in the database and the view index does not exist or is not current because the database content has been modified.

It is not possible to eliminate these delays,
but you might reduce them by trying the following techniques:

-   Create the view definition in the design document in your database before inserting or updating documents. If this is allowed while the view is being accessed, the index can be updated incrementally.
-   Manually force a view request from the database. You can do this either before users are allowed to use the view, or you can access the view manually after documents are added or updated.
-   Use `/db/_changes` to monitor for changes to the database and then access the view to force the corresponding view index to be updated. See api-changes for more information.

None of these can completely eliminate the need for the indexes to be rebuilt or updated when the view is accessed, but they may lessen the effects on end-users of the index update affecting the user experience.

Another alternative is to allow users to access a 'stale' version of the view index, rather than forcing the index to be updated and displaying the updated results. Using a stale view may not return the latest information, but will return the results of the view query using an existing version of the index.

For example, to access the existing stale view `by_recipe` in the `recipes` design document:

```
/recipes/_design/recipes/_view/by_recipe?stale=ok
```

Accessing a stale view:

-   Does not trigger a rebuild of the view indexes, even if there have been changes since the last access.
-   Returns the current version of the view index, if a current version exists.
-   Returns an empty result set if the given view index does exist.

As an alternative, you use the `update_after` value to the `stale` parameter. This causes the view to be returned as a stale view, but for the update process to be triggered after the view information has been returned to the client.

In addition to using stale views, you can also make use of the `update_seq` field in the view information. The returned value can be compared to the current update sequence exposed in the database information (returned by api-get-db).

#### Sorting Returned Rows

Each element within the returned array is sorted using native UTF-8 sorting according to the contents of the key portion of the emitted content. The basic order of output is as follows:

-   `null`
-   `false`
-   `true`
-   Numbers
-   Text (case sensitive, lowercase first)
-   Arrays (according to the values of each element, in order)
-   Objects (according to the values of keys, in key order)

You can reverse the order of the returned view information by using the `descending` query value set to true. For example, Retrieving the list of recipes using the `by_title` (limited to 5 records) view:

``` json
{
   "offset" : 0,
   "rows" : [
      {
         "id" : "3-tiersalmonspinachandavocadoterrine",
         "key" : "3-tier salmon, spinach and avocado terrine",
         "value" : [
            null,
            "3-tier salmon, spinach and avocado terrine"
         ]
      },
      {
         "id" : "Aberffrawcake",
         "key" : "Aberffraw cake",
         "value" : [
            null,
            "Aberffraw cake"
         ]
      },
      {
         "id" : "Adukiandorangecasserole-microwave",
         "key" : "Aduki and orange casserole - microwave",
         "value" : [
            null,
            "Aduki and orange casserole - microwave"
         ]
      },
      {
         "id" : "Aioli-garlicmayonnaise",
         "key" : "Aioli - garlic mayonnaise",
         "value" : [
            null,
            "Aioli - garlic mayonnaise"
         ]
      },
      {
         "id" : "Alabamapeanutchicken",
         "key" : "Alabama peanut chicken",
         "value" : [
            null,
            "Alabama peanut chicken"
         ]
      }
   ],
   "total_rows" : 2667
}
```

Requesting the same in descending order will reverse the entire view content. For example the request

```
GET /recipes/_design/recipes/_view/by_title?limit=5&descending=true
Accept: application/json
Content-Type: application/json
```

Returns the last 5 records from the view:

``` json
{
   "offset" : 0,
   "rows" : [
      {
         "id" : "Zucchiniinagrodolcesweet-sourcourgettes",
         "key" : "Zucchini in agrodolce (sweet-sour courgettes)",
         "value" : [
            null,
            "Zucchini in agrodolce (sweet-sour courgettes)"
         ]
      },
      {
         "id" : "Zingylemontart",
         "key" : "Zingy lemon tart",
         "value" : [
            null,
            "Zingy lemon tart"
         ]
      },
      {
         "id" : "Zestyseafoodavocado",
         "key" : "Zesty seafood avocado",
         "value" : [
            null,
            "Zesty seafood avocado"
         ]
      },
      {
         "id" : "Zabaglione",
         "key" : "Zabaglione",
         "value" : [
            null,
            "Zabaglione"
         ]
      },
      {
         "id" : "Yogurtraita",
         "key" : "Yogurt raita",
         "value" : [
            null,
            "Yogurt raita"
         ]
      }
   ],
   "total_rows" : 2667
}
```

The sorting direction is applied before the filtering is applied using the `startkey` and `endkey` query arguments. For example the following query:

```
GET /recipes/_design/recipes/_view/by_ingredient?startkey=%22carrots%22&endkey=%22egg%22
Accept: application/json
Content-Type: application/json
```

Will operate correctly when listing all the matching entries between “carrots” and `egg`. If the order of output is reversed with the `descending` query argument, the view request will return no entries:

```
GET /recipes/_design/recipes/_view/by_ingredient?descending=true&startkey=%22carrots%22&endkey=%22egg%22
Accept: application/json
Content-Type: application/json
```

The returned result is empty:

``` json
{
   "total_rows" : 26453,
   "rows" : [],
   "offset" : 21882
}
```

The results will be empty because the entries in the view are reversed before the key filter is applied, and therefore the `endkey` of “egg” will be seen before the `startkey` of “carrots”, resulting in an empty list.

Instead, you should reverse the values supplied to the `startkey` and `endkey` parameters to match the descending sorting applied to the keys. Changing the previous example to:

```
GET /recipes/_design/recipes/_view/by_ingredient?descending=true&startkey=%22egg%22&endkey=%22carrots%22
Accept: application/json
Content-Type: application/json
```

#### Specifying Start and End Values

The `startkey` and `endkey` query arguments can be used to specify the range of values to be displayed when querying the view.

### Querying a view using a list of keys

-   **Method**: `POST /db/_design/design-doc/_view/view-name`
-   **Request**: List of keys to be returned from specified view
-   **Response**: JSON of the documents returned by the view
-   **Roles permitted**: \_reader

#### Query Arguments

<table>
<colgroup>
<col width="6%" />
<col width="45%" />
<col width="3%" />
<col width="7%" />
<col width="3%" />
<col width="34%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Argument</th>
<th align="left">Decription</th>
<th align="left">Optional</th>
<th align="left">Type</th>
<th align="left">Default</th>
<th align="left">Supported Values</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>descending</code></td>
<td align="left">Return the documents in descending by key order</td>
<td align="left">yes</td>
<td align="left">boolean</td>
<td align="left">false</td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>endkey</code></td>
<td align="left">Stop returning records when the specified key is reached</td>
<td align="left">yes</td>
<td align="left">string or JSON array</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><code>endkey_docid</code></td>
<td align="left">Stop returning records when the specified document ID is reached</td>
<td align="left">yes</td>
<td align="left">string</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>group</code></td>
<td align="left">Group the results using the reduce function to a group or single row</td>
<td align="left">yes</td>
<td align="left">boolean</td>
<td align="left">false</td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><code>group_level</code></td>
<td align="left">Only applicable if the view uses complex keys, i.e. keys that are JSON arrays. Groups reduce results for the specified number of array fields.</td>
<td align="left">yes</td>
<td align="left">numeric</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>include_docs</code></td>
<td align="left">Include the full content of the documents in the response</td>
<td align="left">yes</td>
<td align="left">boolean</td>
<td align="left">false</td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><code>inclusive_end</code></td>
<td align="left">included rows with the specified endkey</td>
<td align="left">yes</td>
<td align="left">boolean</td>
<td align="left">true</td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>key</code></td>
<td align="left">Return only documents that match the specified key. Note that keys are JSON values and must be URL-encoded.</td>
<td align="left">yes</td>
<td align="left">string</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><code>limit</code></td>
<td align="left">Limit the number of the returned documents to the specified number</td>
<td align="left">yes</td>
<td align="left">numeric</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>reduce</code></td>
<td align="left">Use the reduce function</td>
<td align="left">yes</td>
<td align="left">boolean</td>
<td align="left">true</td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"><code>skip</code></td>
<td align="left">Skip this number of rows from the start</td>
<td align="left">yes</td>
<td align="left">numeric</td>
<td align="left">0</td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>stale</code></td>
<td align="left">Allow the results from a stale view to be used. This makes the request return immediately, even if the view has not been completely built yet.</td>
<td align="left">yes</td>
<td align="left">string</td>
<td align="left">false</td>
<td align="left"><code>ok</code>: Allow stale views, <code>update_after</code>: Allow stale views, but update them immediately after the request</td>
</tr>
<tr class="odd">
<td align="left"><code>startkey</code></td>
<td align="left">Return records starting with the specified key</td>
<td align="left">yes</td>
<td align="left">string or JSON array</td>
<td align="left"></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"><code>startkey_docid</code></td>
<td align="left">Return records starting with the specified document ID</td>
<td align="left">yes</td>
<td align="left">string</td>
<td align="left"></td>
<td align="left"></td>
</tr>
</tbody>
</table>

Executes the specified `view-name` from the specified `design-doc` design document. Unlike the `GET` method for accessing views, the `POST` method supports the specification of explicit keys to be retrieved from the view results. The remainder of the `POST` view functionality is identical to the api-get-view API.

For example, the request below will return all the recipes where the key for the view matches either “claret” or “clear apple cider” :

```
POST /recipes/_design/recipes/_view/by_ingredient
Content-Type: application/json

{
   "keys" : [
      "claret",
      "clear apple juice"
   ]
}
```

The returned view data contains the standard view information, but only where the keys match.

``` json
{
   "total_rows" : 26484,
   "rows" : [
      {
         "value" : [
            "Scotch collops"
         ],
         "id" : "Scotchcollops",
         "key" : "claret"
      },
      {
         "value" : [
            "Stand pie"
         ],
         "id" : "Standpie",
         "key" : "clear apple juice"
      }
   ],
   "offset" : 6324
}
```

#### Multi-document Fetching

By combining the `POST` method to a given view with the `include_docs=true` query argument you can obtain multiple documents from a database. The result is more efficient than using multiple api-get-doc requests.

For example, sending the following request for ingredients matching “claret” and “clear apple juice”:

```
POST /recipes/_design/recipes/_view/by_ingredient?include_docs=true
Content-Type: application/json

{
   "keys" : [
      "claret",
      "clear apple juice"
   ]
}
```

Returns the full document for each recipe:

``` json
{
   "offset" : 6324,
   "rows" : [
      {
         "doc" : {
            "_id" : "Scotchcollops",
            "_rev" : "1-bcbdf724f8544c89697a1cbc4b9f0178",
            "cooktime" : "8",
            "ingredients" : [
               {
                  "ingredient" : "onion",
                  "ingredtext" : "onion, peeled and chopped",
                  "meastext" : "1"
               },
            ...
            ],
            "keywords" : [
               "cook method.hob, oven, grill@hob",
               "diet@wheat-free",
               "diet@peanut-free",
               "special collections@classic recipe",
               "cuisine@british traditional",
               "diet@corn-free",
               "diet@citrus-free",
               "special collections@very easy",
               "diet@shellfish-free",
               "main ingredient@meat",
               "occasion@christmas",
               "meal type@main",
               "diet@egg-free",
               "diet@gluten-free"
            ],
            "preptime" : "10",
            "servings" : "4",
            "subtitle" : "This recipe comes from an old recipe book of 1683 called 'The Gentlewoman's Kitchen'. This is an excellent way of making a rich and full-flavoured meat dish in a very short time.",
            "title" : "Scotch collops",
            "totaltime" : "18"
         },
         "id" : "Scotchcollops",
         "key" : "claret",
         "value" : [
            "Scotch collops"
         ]
      },
      {
         "doc" : {
            "_id" : "Standpie",
            "_rev" : "1-bff6edf3ca2474a243023f2dad432a5a",
            "cooktime" : "92",
            "ingredients" : [
...            ],
            "keywords" : [
               "diet@dairy-free",
               "diet@peanut-free",
               "special collections@classic recipe",
               "cuisine@british traditional",
               "diet@corn-free",
               "diet@citrus-free",
               "occasion@buffet party",
               "diet@shellfish-free",
               "occasion@picnic",
               "special collections@lunchbox",
               "main ingredient@meat",
               "convenience@serve with salad for complete meal",
               "meal type@main",
               "cook method.hob, oven, grill@hob / oven",
               "diet@cow dairy-free"
            ],
            "preptime" : "30",
            "servings" : "6",
            "subtitle" : "Serve this pie with pickled vegetables and potato salad.",
            "title" : "Stand pie",
            "totaltime" : "437"
         },
         "id" : "Standpie",
         "key" : "clear apple juice",
         "value" : [
            "Stand pie"
         ]
      }
   ],
   "total_rows" : 26484
}
```

### Sending several queries to a view

-   **Method**: `POST /db/_design/design-doc/_view/view-name`
-   **Request**: A JSON document containing an array of query objects
-   **Response**: A JSON document containing an array of response object - one per query
-   **Roles permitted**: \_reader

This in an example of a request body:

The JSON object contains only the `queries` field, which holds an array of query objects. Each query object can have fields for the parameters of a query. The field names and their meaning are the same as the query parameters of a regular view request.

Here is an example of a response:

The JSON object contains only the `results` field, which holds an array of result objects - one for each query. Each result object contains the same fields as the response to a regular view request.
