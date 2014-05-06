# Search

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

> Example search index:

```javascript
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

Search indexes allow databases to be queried using [Lucene Query Parser Syntax](http://lucene.apache.org/core/4_3_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Overview).

Option | Description | Values | Default
-------|-------------|--------|---------
store | If `true`, the value will be returned in the search result; otherwise, it will not be. | `true`, `false` | `false`
index | whether (and how) the data is indexed. See [Analyzers](#analyzers) for more info. | `analyzed`, `analyzed_no_norms`, `no`, `not_analyzed`, `not_analyzed_no_norms` | analyzed
facet | creates a faceted index. See [Faceting](#faceting) for more info. | `true`, `false` | `false`

## Analyzers

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
standard | Default analyzer; implements the Word Break rules from the [Unicode Text Segmentation algorithm](#http://www.unicode.org/reports/tr29/)
email | Like standard but tries harder to match an email address as a complete token.
keyword | Input is not tokenized at all.
simple | Divides text at non-letters.
whitespace | Divides text at whitespace boundaries.
classic | The standard Lucene analyzer circa release 3.1. You'll know if you need it.

### Language-Specific Analyzers

These analyzers will omit very common words in the specific language, and many also [remove prefixes and suffixes](http://en.wikipedia.org/wiki/Stemming). The name of the language is also the name of the analyzer.

<script type="text/javascript">
function toggleMe(a){
var e=document.getElementById(a);
if(!e)return true;
if(e.style.display=="none"){
e.style.display="block"
}
else{
e.style.display="none"
}
return true;
}
</script>

<input type="button" onclick="return toggleMe('lang')" value="Languages">
<div id="lang" style="display:none">

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
</div>

### Per-Field Analyzers

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

Sometimes a single analyzer isn't enough. You can use the `perfield` analyzer to configure different analyzers for different field names.

### Stop Words

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

You may want to define a set of words that do not get indexed. These are called stop words. You define stop words in the design document by turning the analyzer string into an object.

<aside>The `keyword`, `simple` and `whitespace` analyzers do not support stop words.</aside>

## Queries

```shell
TODO
```

```python
TODO
```

Once you've got an index written, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DOCUMENT/_search/$INDEX_NAME`. Specify your search query in the `query` query parameter.

**Query Parameters**

Argument | Description | Optional | Type | Supported Values
---------|-------------|----------|------|------------------
query | A Lucene query | no | string or number |  
bookmark | A bookmark that was received from a previous search. This allows you to page through the results. If there are no more results after the bookmark, you will get a response with an empty rows array and the same bookmark. That way you can determine that you have reached the end of the result list. | yes | string |  
stale | Don't wait for the index to finish building to return results. | yes | string | ok
limit | Limit the number of the returned documents to the specified number. In case of a grouped search, this parameter limits the number of documents per group. | yes | numeric | 
include_docs | Include the full content of the documents in the response | yes | boolean |
sort | Specifies the sort order of the results. In a grouped search (i.e. when group_field is used), this specifies the sort order within a group. The default sort order is relevance. | yes | JSON | A JSON string of the form "fieldname<type>" or -fieldname<type> for descending order, where fieldname is the name of a string or number field and type is either number or string or a JSON array of such strings. The type part is optional and defaults to number. Some examples are "foo", "-foo", "bar<string>", "-foo<number>" and ["-foo<number>", "bar<string>"]. String fields used for sorting must not be analyzed fields. The field(s) used for sorting must be indexed by the same indexer used for the search query.
group_field | Field by which to group search matches. | yes | String | A string containing the field name and optionally the type of the field (string or number) in angle brackets. If the type is not specified, it defaults to string. For example, `age<number>`.
group_limit | Maximum group count. This field can only be used if group_field is specified. | yes | Numeric | 
group_sort | This field defines the order of the groups in a search using group_field. The default sort order is relevance. | yes | JSON | This field can have the same values as the sort field, so single fields as well as arrays of fields are supported.
ranges | This field defines ranges for faceted, numeric search fields. The value is a JSON object where the fields names are numeric, faceted search fields and the values of the fields are again JSON objects. Their field names are names for ranges, the values are Strings describing the range, e.g. “[0 TO 10]” | yes | JSON | The value must be on object whose fields again have objects as their values. These objects must have string describing ranges as their field values.
counts | This field defines an array of names of string fields, for which counts should be produced. The response will contain counts for each unique value of this field name among the documents matching the search query. | yes | JSON | A JSON array of field names
drilldown | This field can be used several times. Each use defines a pair of a field name and a value. The search will only match documents that have the given value in the field name. It differs from using “fieldname:value” in the q parameter only in that the values aren’t analyzed. | yes | JSON | A JSON array with two elements, the field name and the value.

## Query Syntax

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

The Cloudant search query syntax is based on the Lucene syntax. Search queries take the form of name:value (unless the name is omitted, in which case they hit the default field as we demonstrated in the first example, above).

Queries over multiple fields can be logically combined and groups and fields can be grouped. The available logical operators are: AND, +, OR, NOT and -, and are case sensitive. Range queries can run over strings or numbers.

If you want a fuzzy search you can run a query with `~` to find terms like the search term, for instance `look~` will find terms book and took.

You can also increase the importance of a search term by using the boost character `^`. This makes matches containing the term more relevant, e.g. `cloudant "data layer"^4` will make results containing "data layer" 4 times more relevant. The default boost value is 1. Boost values must be positive, but can be less than 1 (e.g. 0.5 to reduce importance).

Wild card searches are supported, for both single (`?`) and multiple (`*`) character searches. `dat?` would match date and data, `dat*` would match date, data, database, dates etc. Wildcards must come after a search term, so you cannot do a query like *base.

Result sets from searches are limited to 200 rows, and return 25 rows by default. The number of rows returned can be changed via the limit parameter. The response contains a bookmark. If the bookmark is passed back as a URL parameter you'll skip through the rows you've already seen and get the next set of results.

The following characters require escaping if you want to search on them:

`+ - && || ! ( ) { } [ ] ^ " ~ * ? : \ /`

Escape these with a preceding backslash character.

For more information, see the [Lucene Query Parser Syntax](http://lucene.apache.org/core/4_3_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Overview).

## Faceting

```javascript
function(doc) {
  index("type", doc.type, {"facet": true});
  index("price", doc.price, {"facet": true});
}
```

> `ranges` example

```
?q=*:*&ranges={"price":{"cheap":"[0 TO 100]","expensive":"{100 TO Infinity}"}}
```

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

Cloudant Search also supports faceted searching, which allows you to discover aggregate information about all your matches quickly and easily. You can even match all documents (using the special `?q=*:*` query syntax) and use the returned facets to refine your query. To indicate a field should be indexed for faceted queries, set `{"facet": true}` in its options.

### Counts

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

### Ranges

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
