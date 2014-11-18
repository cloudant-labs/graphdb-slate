## Search

> Example design document:

```json
{
  "_id": "_design/search_example",
  "indexes": {
    "animals": {
      "index": "function(doc){ ... }"
    }
  }
}
```

Search indexes, defined in design documents, allow databases to be queried using [Lucene Query Parser Syntax](http://lucene.apache.org/core/4_3_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Overview). Search indexes are defined by an index function, similar to a map function in MapReduce views. The index function decides what data to index and store in the index.

### Index functions

> Example search index function:

```
function(doc){
  index("default", doc._id);
  if(doc.min_length){
    index("min_length", doc.min_length, {"store": "yes"});
  }
  if(doc.diet){
    index("diet", doc.diet, {"store": "yes"});
  }
  if (doc.latin_name){
    index("latin_name", doc.latin_name, {"store": "yes"});
  }
  if (doc.class){
    index("class", doc.class, {"store": "yes"});
  }
}
```

The function contained in the index field is a Javascript function that is called for each document in the database. It takes the document as a parameter, extracts some data from it and then calls the `index` function to index that data. The `index` function takes 3 parameters, where the third parameter is optional. The first parameter is the name of the index. If the special value `"default"` is used, the data is stored in the default index, which is queried if no index name is specified in the search. The second parameter is the data to be indexed. The third parameter is an object that can contain the fields `store` and `index`. If the `store` field contains the value `yes`, the value will be returned in search results, otherwise, it will only be indexed. The `index` field can have the following values describing whether and how the data is indexed:

-   `analyzed`: Index the tokens produced by running the field's value through an analyzer.
-   `analyzed_no_norms`: Index the tokens produced by running the field's value through an analyzer, and also separately disable the storing of norms.
-   `no`: Do not index the field value.
-   `not_analyzed`: Index the field's value without using an analyzer. This is necessary if the field will be used for sorting.
-   `not_analyzed_no_norms`: Index the field's value without an analyzer, and also disable the indexing of norms.

This index function indexes only a single field in the document. You, however, compute the value to be indexed from several fields or index only part of a field (rather than its entire value).

The `index` function also provides a third, options parameter that receives a JavaScript Object with the following possible values and defaults:

<table>
<colgroup>
<col width="3%" />
<col width="63%" />
<col width="26%" />
<col width="6%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Option</th>
<th align="left">Description</th>
<th align="left">Values</th>
<th align="left">Default</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>boost</code></td>
<td align="left">Analogous to the <code>boost</code> query string parameter, but done at index time rather than query time.</td>
<td align="left">Float</td>
<td align="left"><code>1.0</code> (no boosting)</td>
</tr>
<tr class="even">
<td align="left"><code>index</code></td>
<td align="left">Whether (and how) the data is indexed. The options available are explained in the <a href="http://lucene.apache.org/core/3_6_2/api/core/org/apache/lucene/document/Field.Index.html#enum_constant_summary">Lucene documentation</a>.</td>
<td align="left"><code>analyzed</code>, <code>analyzed_no_norms</code>, <code>no</code>, <code>not_analyzed</code>, <code>not_analyzed_no_norms</code></td>
<td align="left"><code>analyzed</code></td>
</tr>
<tr class="odd">
<td align="left"><code>store</code></td>
<td align="left">If <code>true</code>, the value will be returned in the search result; if <code>false</code>, the value will not be returned in the search result.</td>
<td align="left"><code>true</code>, <code>false</code></td>
<td align="left"><code>false</code></td>
</tr>
<tr class="even">
<td align="left"><code>facet</code></td>
<td align="left">If <code>true</code>, faceting will be turned on for the data being indexed. Faceting is off by default.</td>
<td align="left"><code>true</code>, <code>false</code></td>
<td align="left"><code>false</code></td>
</tr>
</tbody>
</table>



Option | Description | Values | Default
-------|-------------|--------|---------
store | If `true`, the value will be returned in the search result; otherwise, it will not be. | `true`, `false` | `false`
index | whether (and how) the data is indexed. See [Analyzers](#analyzers) for more info. | `analyzed`, `analyzed_no_norms`, `no`, `not_analyzed`, `not_analyzed_no_norms` | analyzed
facet | creates a faceted index. See [Faceting](#faceting) for more info. | `true`, `false` | `false`

### Analyzers

> Example analyzer document:

```json
{
  "_id": "_design/analyzer_example",
  "indexes": {
    "INDEX_NAME": {
      "index": "function (doc) { ... }",
      "analyzer": "$ANALYZER_NAME"
    }
  }
}
```

Analyzers are settings which define how to recognize terms within text. This can be helpful if you need to [index multiple languages](#language-specific-analyzers). 

Here's the list of generic analyzers supported by Cloudant search:

Analyzer | Description
---------|------------
standard | Default analyzer; implements the Word Break rules from the [Unicode Text Segmentation algorithm](http://www.unicode.org/reports/tr29/)
email | Like standard but tries harder to match an email address as a complete token.
keyword | Input is not tokenized at all.
simple | Divides text at non-letters.
whitespace | Divides text at whitespace boundaries.
classic | The standard Lucene analyzer circa release 3.1. You'll know if you need it.

#### Language-Specific Analyzers

These analyzers will omit very common words in the specific language, and many also [remove prefixes and suffixes](http://en.wikipedia.org/wiki/Stemming). The name of the language is also the name of the analyzer.

* arabic
* armenian
* basque
* bulgarian
* brazilian
* catalan
* cjk (Chinese, Japanese, Korean)
* chinese ([smartcn](http://lucene.apache.org/core/4_2_1/analyzers-smartcn/org/apache/lucene/analysis/cn/smart/SmartChineseAnalyzer.html))
* czech
* danish
* dutch
* english
* finnish
* french
* german
* greek
* galician
* hindi
* hungarian
* indonesian
* irish
* italian
* japanese ([kuromoji](http://lucene.apache.org/core/4_2_1/analyzers-kuromoji/overview-summary.html))
* latvian
* norwegian
* persian
* polish ([stempel](http://lucene.apache.org/core/4_2_1/analyzers-stempel/overview-summary.html))
* portuguese
* romanian
* russian
* spanish
* swedish
* thai
* turkish

#### Per-Field Analyzers

> Example of defining different analyzers for different fields:

```json
{
  "_id": "_design/analyzer_example",
  "indexes": {
    "INDEX_NAME": {
      "analyzer": {
        "name": "perfield",
        "default": "english",
        "fields": {
          "spanish": "spanish",
          "german": "german"
        }
      },
      "index": "function (doc) { ... }"
    }
  }
}
```

The `perfield` analyzer configures multiple analyzers for different fields.

<h3></h3>
#### Stop Words

> Example of defining non-indexed ('stop') words:

```json
{
  "_id": "_design/stop_words_example",
  "indexes": {
    "INDEX_NAME": {
      "analyzer": {
        "name": "portuguese",
        "stopwords": [
          "foo", 
          "bar", 
          "baz"
        ]
      },
      "index": "function (doc) { ... }"
    }
  }
}
```

Stop words are words that do not get indexed. You define them within a design document by turning the analyzer string into an object.

<aside>The `keyword`, `simple` and `whitespace` analyzers do not support stop words.</aside>

### Queries

```shell
curl https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_search/$INDEX_NAME?q=$QUERY \
     -u $USERNAME
```

```javascript
var nano = require('nano');
var account = nano("https://"+$USERNAME+":"+$PASSWORD+"@"+$USERNAME+".cloudant.com");
var db = account.use($DATABASE);

db.search($DESIGN_ID, $SEARCH_INDEX, {
  q: $QUERY
}, function (err, body, headers) {
  if (!err) {
    console.log(body);
  }
});
```

Once you've got an index written, you can query it with a `GET` request to `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_ID/_search/$INDEX_NAME`. Specify your search query in the `query` query parameter.

#### Query Parameters

<!-- The numeric `limit` was suggested by Glynn, in FB 40734. -->

Argument | Description | Optional | Type | Supported Values
---------|-------------|----------|------|------------------
`bookmark` | A bookmark that was received from a previous search. This allows you to page through the results. If there are no more results after the bookmark, you will get a response with an empty rows array and the same bookmark. That way you can determine that you have reached the end of the result list. | yes | string | 
`counts` | This field defines an array of names of string fields, for which counts should be produced. The response will contain counts for each unique value of this field name among the documents matching the search query. | yes | JSON | A JSON array of field names
`drilldown` | This field can be used several times. Each use defines a pair of a field name and a value. The search will only match documents that have the given value in the field name. It differs from using `"fieldname:value"` in the q parameter only in that the values are not analyzed. | yes | JSON | A JSON array with two elements, the field name and the value.
`group_field` | Field by which to group search matches. | yes | String | A string containing the field name and optionally the type of the field (string or number) in angle brackets. If the type is not specified, it defaults to string. For example, `age<number>`.
`group_limit` | Maximum group count. This field can only be used if group_field is specified. | yes | Numeric | 
`group_sort` | This field defines the order of the groups in a search using group_field. The default sort order is relevance. | yes | JSON | This field can have the same values as the sort field, so single fields as well as arrays of fields are supported.
`include_docs` | Include the full content of the documents in the response | yes | boolean |
`limit` | Limit the number of the returned documents to the specified number. In case of a grouped search, this parameter limits the number of documents per group. | yes | numeric | The limit value can be any positive integer number up to and including 200.
`query` | A Lucene query | no | string or number | 
`ranges` | This field defines ranges for faceted, numeric search fields. The value is a JSON object where the fields names are numeric, faceted search fields and the values of the fields are again JSON objects. Their field names are names for ranges. The values are Strings describing the range, for example `"[0 TO 10]"` | yes | JSON | The value must be on object whose fields again have objects as their values. These objects must have string describing ranges as their field values.
`sort` | Specifies the sort order of the results. In a grouped search (i.e. when group_field is used), this specifies the sort order within a group. The default sort order is relevance. | yes | JSON | A JSON string of the form `"fieldname<type>"` or `-fieldname<type>` for descending order, where fieldname is the name of a string or number field and type is either number or string or a JSON array of such strings. The type part is optional and defaults to number. Some examples are `"foo"`, `"-foo"`, `"bar<string>"`, `"-foo<number>"` and `["-foo<number>", "bar<string>"]`. String fields used for sorting must not be analyzed fields. The field(s) used for sorting must be indexed by the same indexer used for the search query.
`stale` | Don't wait for the index to finish building to return results. | yes | string | ok

<aside class="warning">Do not combine the `bookmark` and `stale` options. The reason is that both these options constrain the choice of shard replicas to use for determining the response. When used together, the options can result in problems when attempting to contact slow or unavailable replicas.</aside>








    <form action="#" id="testSearchForm">
        <label for="query">Search query (q)</label><br>
        <input size="100" style="width: 400px; display:block;" type="text" name="query" id="query"><br><br>
        <input type="submit" value="search" id="searchButton"></input><br>
    </form>
    <pre style="display:none;" id="search-output"></pre>









### Query Syntax

> Example search query:

```
// Birds
class:bird
// Animals that begin with the letter "l"
l*
// Carnivorous birds
class:bird AND diet:carnivore
// Herbivores that start with letter
"l" l* AND diet:herbivore
// Medium-sized herbivores 
min_length:[1 TO 3] AND diet:herbivore
// Herbivores that are 2m long or less 
diet:herbivore AND min_length:[-Infinity TO 2]
// Mammals that are at least 1.5m long 
class:mammal AND min_length:[1.5 TO Infinity]
// Find "Meles meles"
latin_name:"Meles meles"
// Mammals who are herbivore or carnivore
diet:(herbivore OR omnivore) AND class:mammal
```

The Cloudant search query syntax is based on the [Lucene syntax](http://lucene.apache.org/core/4_3_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Overview). Search queries take the form of name:value (unless the name is omitted, in which case they hit the default field, demonstrated in the example to your right).

Queries over multiple fields can be logically combined, and groups and fields can be further grouped. The available logical operators are case sensitive and are `AND`, `+`, `OR`, `NOT` and `-`. Range queries can run over strings or numbers.

If you want a fuzzy search you can run a query with `~` to find terms like the search term. For instance, `look~` will find terms book and took.

You can alter the importance of a search term by adding `^` + a positive number. This makes matches containing the term more or less relevant to the power of the boost value, with 1 as the default. Any decimal between 0 and 1 will reduce importance while anything over 1 will increase it.

Wild card searches are supported, for both single (`?`) and multiple (`*`) character searches. `dat?` would match date and data, `dat*` would match date, data, database, dates etc. Wildcards must come after the search term.

Result sets from searches are limited to 200 rows, and return 25 rows by default. The number of rows returned can be changed via the limit parameter. The response contains a bookmark. If the bookmark is passed back as a URL parameter you'll skip through the rows you've already seen and get the next set of results.

The following characters require escaping if you want to search on them: `+ - && || ! ( ) { } [ ] ^ " ~ * ? : \ /`

Escape these with a preceding backslash character.

### Faceting

> Example search query, specifying that faceted search is enabled:

```
function(doc) {
  index("type", doc.type, {"facet": true});
  index("price", doc.price, {"facet": true});
}
```

> Example of `ranges` faceted search:

```
?q=*:*&ranges={"price":{"cheap":"[0 TO 100]","expensive":"{100 TO Infinity}"}}
```

> Example results for faceted search `ranges` example:

```json
{
  "total_rows":100000,
  "bookmark":"g...",
  "rows":[...],
  "ranges": {
    "price": {
      "expensive": 278682,
      "cheap": 257023
    }
  }
}
```

Cloudant Search also supports faceted searching, which allows you to discover aggregate information about all your matches quickly and easily. You can match all documents using the special `?q=*:*` query syntax, and use the returned facets to refine your query. To indicate a field should be indexed for faceted queries, set `{"facet": true}` in its options.

#### Counts

> Example query

```
?q=*:*&counts=["type"]
```

> Example response

```json
{
  "total_rows":100000,
  "bookmark":"g...",
  "rows":[...],
  "counts":{
    "type":{
      "sofa": 10, 
      "chair": 100,
      "lamp": 97
    }
  }
}
```

The count facet syntax takes a list of fields and returns the number of query results for each unique value of each named field.

#### Ranges

> Example query

```
?q=*:*&ranges={"price":{"cheap":"[0 TO 100]","expensive":"{100 TO Infinity}"}}
```

> Example response

```json
{
  "total_rows":100000,
  "bookmark":"g...",
  "rows":[...],
  "ranges": {
    "price": {
      "expensive": 278682,
      "cheap": 257023
    }
  }
}
```

The range facet syntax reuses the standard Lucene syntax for ranges (inclusive range queries are denoted by square brackets, exclusive range queries are denoted by curly brackets) to return counts of results which fit into each specified category.

### Geographical searches

> Some example data...

```json
{
    "name":"Aberdeen, Scotland",
    "lat":57.15,
    "lon":-2.15,
    "type":"city"
}
```

> ... as well as a design document with a search index for them.

```
function(doc) {
    if (doc.type && doc.type == 'city') {
        index('city', doc.name, {'store': true});
        index('lat', doc.lat, {'store': true});
        index('lon', doc.lon, {'store': true});
    }
}
```

> An example query that sorts cities in the upper hemisphere by their distance to New York:

```shell
curl 'https://docs.cloudant.com/examples/_design/cities-designdoc/_search/cities?q=lat:[0+TO+90]&sort="<distance,lon,lat,-74.0059,40.7127,km>"'
```

```http
GET /examples/_design/cities-designdoc/_search/cities?q=lat:[0+TO+90]&sort="<distance,lon,lat,-74.0059,40.7127,km>" HTTP/1.1
Host: docs.cloudant.com
```

> Example response

```json
{
    "total_rows": 205,
    "bookmark": "g1AAAAEbeJzLYWBgYMlgTmGQS0lKzi9KdUhJMtfLTczJLyrRS87JL01JzCvRy0styQGqY0pkSLL___9_Fpjj5tDCOG974NGNieJZqAaY4DQgyQFIJtUjmyHXJivfY5PIgmaGKU4z8liAJEMDkAIasx9mTnPNv-PSgosTmbOI9QzEnAMQc-DuqY3U-vbZXTSRNSsLAMMnXIU",
    "rows": [
        {
            "id": "city180",
            "order": [
                8.530665755719783,
                18
            ],
            "fields": {
                "city": "New York, N.Y.",
                "lat": 40.78333333333333,
                "lon": -73.96666666666667
            }
        },
        {
            "id": "city177",
            "order": [
                13.756343205985946,
                17
            ],
            "fields": {
                "city": "Newark, N.J.",
                "lat": 40.733333333333334,
                "lon": -74.16666666666667
            }
        },
        {
            "id": "city178",
            "order": [
                113.53603438866077,
                26
            ],
            "fields": {
                "city": "New Haven, Conn.",
                "lat": 41.31666666666667,
                "lon": -72.91666666666667
            }
        }
    ]
}
```

In addition to searching by the content of textual fields,
you can also sort your results by their distance from a geographic coordinate. 

You will need to index two numeric fields (representing the longitude and latitude). 


You can then query using the special <distance...> sort field which takes 5 parameters:

- longitude field name: The name of your longitude field (“mylon” in this example)
- latitude field name: The name of your latitude field (“mylat” in this example)
- longitude of origin: The longitude of the place you want to sort by distance from
- latitude of origin: The latitude of the place you want to sort by distance from units
- The units to use (“km” or “mi” for kilometers and miles, respectively). The distance itself is returned in the order field


You can combine sorting by distance with any other search query, such as range searches on the latitude and longitude or queries involving non-geographical information. That way, you can search in a bounding box and narrow down the search with additional criteria. 


