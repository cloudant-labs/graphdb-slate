## Using Views

### Retrieving information about a design document

-   **Method**: `GET /db/_design/design-doc/_info`
-   **Request**: None
-   **Response**: JSON of the design document information
-   **Roles permitted**: \_reader

Obtains information about a given design document, including the index, index size and current status of the design document and associated index information.

For example, to get the information for the `recipes` design document:

```
GET /recipes/_design/recipes/_info
Content-Type: application/json
```

This returns the following JSON structure:

``` json
{
   "name" : "recipes"
   "view_index" : {
      "compact_running" : false,
      "updater_running" : false,
      "language" : "javascript",
      "purge_seq" : 10,
      "waiting_commit" : false,
      "waiting_clients" : 0,
      "signature" : "fc65594ee76087a3b8c726caf5b40687",
      "update_seq" : 375031,
      "disk_size" : 16491
   },
}
```

The individual fields in the returned JSON structure are detailed below:

-   **name**: Name/ID of Design Document
-   **view\_index**: View Index
    -   **compact\_running**: Indicates whether a compaction routine is currently running on the view
    -   **disk\_size**: Size in bytes of the view as stored on disk
    -   **language**: Language for the defined views
    -   **purge\_seq**: The purge sequence that has been processed
    -   **signature**: MD5 signature of the views for the design document
    -   **update\_seq**: The update sequence of the corresponding database that has been indexed
    -   **updater\_running**: Indicates if the view is currently being updated
    -   **waiting\_clients**: Number of clients waiting on views from this design document
    -   **waiting\_commit**: Indicates if there are outstanding commits to the underlying database that need to processed

### Querying a view

-   **Method**: `GET /db/_design/design-doc/_view/view-name`
-   **Request**: None
-   **Response**: JSON of the documents returned by the view
-   **Roles permitted**: \_reader

#### Query Arguments

Argument | Description | Optional | Type | Default | Supported values
---------|-------------|----------|------|---------|-----------------
`descending` | Return the documents in descending by key order | yes | boolean | false | 

<table>
<colgroup>
<col width="5%" />
<col width="57%" />
<col width="2%" />
<col width="5%" />
<col width="2%" />
<col width="26%" />
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
<td align="left">Allow the results from a stale view to be used. This makes the request return immediately, even if the view has not been completely built yet. If this parameter is not given, a response will be returned only after the view has been built.</td>
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

Executes the specified `view-name` from the specified `design-doc` design document.

#### Querying Views and Indexes

The definition of a view within a design document also creates an index based on the key information defined within each view. The production and use of the index significantly increases the speed of access and searching or selecting documents from the view.

However, the index is not updated when new documents are added or modified in the database. Instead, the index is generated or updated, either when the view is first accessed, or when the view is accessed after a document has been updated. In each case, the index is updated before the view query is executed against the database.

View indexes are updated incrementally in the following situations:

-   A new document has been added to the database.
-   A document has been deleted from the database.
-   A document in the database has been updated.

View indexes are rebuilt entirely when the view definition changes. To achieve this, a 'fingerprint' of the view definition is created when the design document is updated. If the fingerprint changes, then the view indexes are entirely rebuilt. This ensures that changes to the view definitions are reflected in the view indexes.

> **note**
>
> View index rebuilds occur when one view from the same view group (i.e. all the views defined within a single design document) needs to be rebuilt. For example, if you have a design document with three views, and you update the document, all three view indexes within the design document will be rebuilt.

Because the view is updated when it has been queried, it can result in a delay in returned information when the view is accessed, especially if there are a large number of documents in the database and the view index does not exist. There are a number of ways to mitigate, but not completely eliminate, these issues. These include:

-   Create the view definition (and associated design documents) on your database before allowing insertion or updates to the documents. If this is allowed while the view is being accessed, the index can be updated incrementally.
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
