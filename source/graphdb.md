---
title: GraphDB - API

language_tabs:
#  - http 
#  - shell: curl
#  - javascript: node.js
#  - python

---

## Getting started with the GraphDB service

The GraphDB service provides a REST API that enables you to store your
data in a [graph database](http://en.wikipedia.org/wiki/Graph_database).
With nodes, edges, and properties, you can easily discover and explore
the relationships in a property graph with index-free adjacency. The
GraphDB service provides a graph-based NoSQL store that creates a rich
and extensible representation of your data in an accessible way.

### Learn more

-   [Apache TinkerPop: An Open Source Graph Computing Framework](http://tinkerpop.incubator.apache.org/)

-   [Titan: Distributed Graph Database](http://titan.thinkaurelius.com/)

-   [Gremlin: Graph Traversal Steps](http://www.tinkerpop.com/docs/3.0.0.M7/#graph-traversal-steps)

### Example Java Code

The following example code shows a sample application written in Java
that uses the GraphDB service. 

#### Get the GraphDB service URL

```java
    String apiURL = null;
    CloseableHttpClient client = HttpClients.createDefault();
    Map envs = System.getenv();
    if (envs.get("VCAP_APPLICATION") != null) {
        // app running in Bluemix
        if (envs.get("VCAP_SERVICES") != null) {
            // get the services bound to the app
            String graphServiceName = "TinkerPop GraphDB";
            JSONObject vcapSvcs = new JSONObject( envs.get("VCAP_SERVICES").toString() );
            if (!vcapSvcs.isNull(graphServiceName)) {
                // get the URL for the GraphDB service
                apiURL = vcapSvcs.getJSONArray(graphServiceName)
                    .getJSONObject(0)
                    .getJSONObject("credentials")
                    .getString("apiURL");
            }
        }
    }
```             

#### Define graph schema

```java
    String schemaFileName = "/graph-schema.json";
    FileReader schemaFileReader = new FileReader(sc.getRealPath(schemaFileName));
    JSONObject postData = new JSONObject(schemaFileReader);
    HttpPost httpPost = new HttpPost(apiURL + "/schema");
    StringEntity strEnt = new StringEntity(postData.toString(), ContentType.APPLICATION_JSON);
    httpPost.setEntity(strEnt);
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
```
                
#### Bulk load a GraphML file

```java
    HttpPost httpPost = new HttpPost(apiURL + "/bulkload/graphml");
    String fieldName = "graphml";
    String contentType = "application/xml";
    String fileName = "seed-airports-routes.xml";
    File file = new File(sc.getRealPath(fileName));
    FileBody fb = new FileBody(file, contentType);
    MultipartEntityBuilder meb = MultipartEntityBuilder.create();
    meb.setMode(HttpMultipartMode.BROWSER_COMPATIBLE);
    meb.addPart("fieldName", new StringBody(fieldName));
    meb.addPart("contentType", new StringBody(contentType));
    meb.addPart("name", new StringBody(fileName));
    meb.addPart(fieldName, fb);
    httpPost.setEntity(meb.build());
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    EntityUtils.consume(httpEntity);
```
             
#### Create a vertex

```java
    String postURL = apiURL + "/vertices";
    HttpPost httpPost = new HttpPost(postURL);
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject airport = data.getJSONObject(0);
    }
```
                
#### Get all vertices

```java
    // this is generally a bad practice
    HttpGet httpGet = new HttpGet(apiURL + "/vertices");
    HttpResponse httpResponse = client.execute(httpGet);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONArray airports = jsonContent.getJSONArray("result");
```
                
#### Get a vertex by id

```java
    HttpGet httpGet = new HttpGet(apiURL + "/vertices/" + vid);
    HttpResponse httpResponse = client.execute(httpGet);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject airport = data.getJSONObject(0);
    }
```
                
#### Get a vertex by indexed property

```java
    HttpGet httpGet = new HttpGet(apiURL + "/vertices?code=" + code);
    HttpResponse httpResponse = client.execute(httpGet);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject airport = data.getJSONObject(0);
    }
```
              
#### Update a vertex

```java
    String vertexId = "256";
    String postURL = apiURL + "/vertices/" + vertexId;
    JSONObject postData = new JSONObject();
    postData.put("code", code.toUpperCase());
    postData.put("name", name);
    postData.put("city", city);
    postData.put("state", state);
    postData.put("lat", Double.valueOf(lat));
    postData.put("lon", Double.valueOf(lon));
    HttpPost httpPost = new HttpPost(postURL);
    StringEntity strEnt = new StringEntity(postData.toString(), ContentType.APPLICATION_JSON);
    httpPost.setEntity(strEnt);
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject airport = data.getJSONObject(0);
    }
```
             
#### Delete a vertex

```java
    String vertexId = "256";
    HttpDelete httpDelete = new HttpDelete(apiURL + "/vertices/" + vertexId);
    httpResponse = client.execute(httpDelete);
    httpEntity = httpResponse.getEntity();
    content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
```
             
#### Get all edges

```java
    // this is generally a bad practice
    HttpGet httpGet = new HttpGet(apiURL + "/edges");
    HttpResponse httpResponse = client.execute(httpGet);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
```
             
#### Create an edge

```java
    String postURL = apiURL + "/edges";
    String vertexId1 = "256";
    String vertexId2 = "512";
    String routeLabel = "route";
    JSONObject postData = new JSONObject();
    postData.put("outV", vertexId1);
    postData.put("inV", vertexId2);
    postData.put("label", routeLabel);
    HttpPost httpPost = new HttpPost(postURL);
    StringEntity strEnt = new StringEntity(postData.toString(), ContentType.APPLICATION_JSON);
    httpPost.setEntity(strEnt);
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject route = data.getJSONObject(0);
    }
```
             
#### Get an edge by id

```java
    String edgeId = "lc-74-36d-e8";
    HttpGet httpGet = new HttpGet(apiURL + "/edges/" + edgeId);
    HttpResponse httpResponse = client.execute(httpGet);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject route = data.getJSONObject(0);
    }
```
             
#### Update an edge

```java
    String edgeId = "lc-74-36d-e8";
    String postURL = apiURL + "/edges/" + edgeId;
    JSONObject postData = new JSONObject();
    postData.put("timestamp", System.currentTimeMillis());
    HttpPost httpPost = new HttpPost(postURL);
    StringEntity strEnt = new StringEntity(postData.toString(), ContentType.APPLICATION_JSON);
    httpPost.setEntity(strEnt);
    HttpResponse httpResponse = client.execute(httpPost);
    HttpEntity httpEntity = httpResponse.getEntity();
    String content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
    JSONObject jsonContent = new JSONObject(content);
    JSONObject result = jsonContent.getJSONObject("result");
    JSONArray data = result.getJSONArray("data");
    if (data.length() > 0) {
        JSONObject route = data.getJSONObject(0);
    }
```
             
#### Delete an edge

```java
    String edgeId = "lc-74-36d-e8";
    HttpDelete httpDelete = new HttpDelete(apiURL + "/edges/" + edgeId);
    httpResponse = client.execute(httpDelete);
    httpEntity = httpResponse.getEntity();
    content = EntityUtils.toString(httpEntity);
    EntityUtils.consume(httpEntity);
```
             
### Example Node.js Code

The following example code shows a sample Node.js application that uses the GraphDB service.

#### Get the GraphDB service URL

```javascript
    if (process.env.VCAP_SERVICES) {
      var vcapServices = JSON.parse(process.env.VCAP_SERVICES);
      if (vcapServices['TinkerPop GraphDB']) {
        var tp3 = vcapServices['TinkerPop GraphDB'][0];
        process.env.graphDBURL = tp3.credentials.apiURL;
      }
    }
```
             
#### Define graph schema

```javascript
    var schemaData = fs.readFile('./public/graph-schema.json', function(err, data) {
      var schemaRequest = {
        uri: process.env.graphDBURL + '/schema',
        method: 'POST',
        json: JSON.parse(data.toString())
      };
      request.post(schemaRequest, function(error, resp, body) {
        var robj = JSON.parse(body);
        var result = (robj.result && robj.result.data && robj.result.data.length > 0) ? robj.result.data[0] : {};
      });
    });
```
             
#### Bulk load a GraphML file

```javascript
    var request = require('request');
    var fs = require('fs');
    var bulkloadUrl = process.env.graphDBURL + '/bulkload/graphml';
    var bulkloadOpts = { formData: {
      'graphml': fs.createReadStream(__dirname + '/../public/seed-airports-routes.xml'),
      'type': 'application/xml',
    }};
    request.post(bulkloadUrl, bulkloadOpts, function(error2, resp2, obj2) {
      var robj = JSON.parse(obj2);
      var result = (robj.result && robj.result.data && robj.result.data.length > 0) ? robj.result.data[0] : {};
      res.send(result);
    });
```
             
#### Create a vertex

```javascript
    var url2 = process.env.graphDBURL + '/vertices';
    var data = {
      code: "LAS",
      name: "McCarran International Airport",
      city: "Las Vegas",
      state: "NV",
      lat: 36.084143,
      lon: -115.15368
    };
    var requestOpts = {
      uri: url2,
      method: 'POST',
      json: data
    };
    request.post(url2, function(error2, resp2, body2) {
      var obj2 = JSON.parse(body2);
      var result2 = (obj2.result && obj2.result.data && obj2.result.data.length > 0) ? obj2.result.data[0] : {};
      res.send(result2);
    });
```
             
#### Get all vertices

```javascript
    // this is generally a bad practice
    var url = process.env.graphDBURL + '/vertices';
    request.get(url, function(error, resp, body) {
      var obj = JSON.parse(body);
      var result = (obj.result && obj.result.data) ? obj.result.data : [];
      res.send(result);
    });
```
             
#### Get a vertex by property

```javascript
    var url = process.env.graphDBURL + '/vertices?code=' + req.params.code;
    request.get(url, function(error, resp, body) {
      var obj = JSON.parse(body);
      var result = (obj.result && obj.result.data && obj.result.data.length > 0) ? obj.result.data[0] : {};
      res.send(result);
    });
```
             
#### Run a Gremlin traversal

```javascript
    var url = process.env.graphDBURL + '/gremlin';
    var existsQuery = "g.V().has('code','" + req.body.orig + "').out('route').has('code', '" + req.body.dest + "')";
    var existsOpts = { json: { gremlin: existsQuery } };
    request.post(url, existsOpts, function(error, resp, obj) {
      var result = (obj.result && obj.result.data && obj.result.data.length > 0) ? obj.result.data[0] : null;
      if (result) {
        // found a route from orig to dest
        console.log('route exists from ' + req.body.orig + ' to ' + req.body.dest);
      }
    });
```
             
REST API
--------

The GraphDB service provides a REST API for manipulating the graph.

### Vertex APIs

Vertices are the most basic objects in a graph. A vertex may have
properties and a label associated with it. Starting from any vertex, a
traversal explores the graph structure by the incident edges to visit
the connected vertices.

| Method |  URI |  Request | Response  | Description |
| -------|------|----------|-----------|-------------|
| POST   |  /vertices | - | [ {"id":"256"} ] | Creates a vertex |
| POST   |  /vertices | { "key1":"A", "key2":"B" } | [ {"id":"256", "key1":"A", "key2":"B"} ] | Creates a vertex with properties specified as key-value pairs |
| POST   |  /vertices/\<v0\> | { "key1":"C", "key3":"D" } | [ {"id":"256", "key1":"C", "key2":"B", "key3":"D"} ] | Updates existing vertex v0 with properties specfied as key-value pairs |
| PUT    |  /vertices/\<v0\> | { "key8":"Y", "key9":"Z" } | [ {"id":"256", "key8":"Y", "key9":"Z"} ] | Updates existing vertex v0 by deleting previous properties and replacing with properties specfied as key-value pairs |
| GET    |  /vertices | - | [ {"id":"256", "key":"value"}, {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ] | Get all vertices and their properties. Global graph operations like this will perform slowly. Indexes should be utilized for performance. |
| GET    |  /vertices?\<key\>=\<value\> | - | [ {"id":"256", "key":"value"}, {"id":"768", "key":"value"}, {"id":"1280", "key":"value"} ] | Get all vertices for a key index that have the specified properties. |
| GET    |  /vertices/\<v0\> | - | [ {"id":"256", "key":"value"} ] | Get a vertex by id and all of its properties |
| GET    |  /vertices/\<v0\>/out | - | [ {"id":"512"}, {"id":"768", "key":"value"} ] | Get the adjacent out vertices and all of their properties for vertex v0 |
| GET    |  /vertices/\<v0\>/in  | - | [ {"id":"1024"}, {"id":"1280", "key":"value"} ] | Get the adjacent in vertices and all of their properties for vertex v0 |
| GET    |  /vertices/\<v0\>/both | - | [ {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ] | Get the adjacent in and out vertices and all of their properties for vertex v0 |
| GET    |  /vertices/\<v0\>/outCount | - | [ 2 ] | Get the adjacent out vertex count for vertex v0 |
| GET    |  /vertices/\<v0\>/inCount | - | [ 2 ] | Get the adjacent in vertex count for vertex v0 |
| GET    |  /vertices/\<v0\>/bothCount | - | [ 4 ] | Get the adjacent in and out vertex count for vertex v0 |
| GET    |  /vertices/\<v0\>/outIds | - | [ 512, 768 ] | Get the adjacent out vertex ids for vertex v0 |
| GET    |  /vertices/\<v0\>/inIds | - | [ 1024, 1280 ] | Get the adjacent in vertex ids for vertex v0 |
| GET    |  /vertices/\<v0\>/bothIds | - | [ 512, 768, 1024, 1280 ] | Get the adjacent in and out vertex ids for vertex v0 |
| DELETE |  /vertices/\<v0\> | - | [ true ] | Deletes the vertex v0. Edges connected to the vertex are also deleted. |
| DELETE |  /vertices/\<v0\>?\<key\> | - | [ true ] | Deletes properties by key on vertex v0. Edges connected to the vertex are also deleted. |

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Edge APIs

Edges are a labeled relationship that connects two vertices. An edge
typically has a direction associated with it, from vertex 'outV' to
vertex 'inV'. Edges may have properties associated with them also.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| POST   |  /edges | { "outV": 256, "label": "knows", "inV": 512 } | [ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows"} ] | Creates an edge from vertex with id 256 to vertex with id 512 using 'knows' as the edge label |
| POST   |  /edges | { "outV": 256, "label": "knows", "inV": 512, "key1": "A", "key2": "B" } | [ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "A", "key2": "B"} ] | Creates an edge from vertex with id 256 to vertex with id 512 using 'knows' as the edge label. Properties for the edge are specified as key-value pairs. |
| POST   |  /edges/\<e0\> | { "key1": "C", "key3": "D" } | [ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "C", "key2": "B", "key3": "D"} ] | Updates existing edge e0 with properties specified key-value pairs. The incident vertices and labels cannot be changed. |
| PUT    |  /edges/\<e0\> | { "key8": "Y", "key9": "Z" } | [ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key8": "Y", "key9": "Z"} ] | Updates existing edge e0 by deleting previous properties and and replacing with the properties specified by key-value pairs. The incident vertices and labels cannot be changed. |
| GET    |  /edges | - | [ {"id":"lc-74-36d-e8", "key":"value"} ] | Get all edges and their properties. Global graph operations like this will perform slowly. Indexes should be utilized for performance. |
| GET    |  /edges/\<e0\> | - | [ {"id":"lc-74-36d-e8", "key":"value"} ] | Get an edge by id and all of its properties |
| DELETE |  /edges/\<e0\> | - | [ true ] | Deletes the edge e0 |
| DELETE |  /edges/\<e0\>?\<key\> | - | [ true ] | Deletes properties by key on edge e0 |

### Gremlin APIs

Gremlin is a domain-specific language for graph traversals. Gremlin
gives you the power to express deep or complex graph traversals that
cannot be performantly with the basic vertex and edge APIs. To use
Gremlin with your graph, simply POST the Gremlin traversal inside a JSON
object to the Gremlin endpoint. Please refer to the [Gremlin 3.0.0.M7
documentation](http://www.tinkerpop.com/docs/3.0.0.M7/#graph-traversal-steps)
for details on the specific graph traversal steps that are currently
supported.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| POST   |  /gremlin | {"gremlin": "g.V(256).out().out()"} | [ {"id":"768"}, {"id":"1024"}, {"id":"1280"} ] | Performs a traversal from the starting node out to its second degree neighbors |

### Input/Output APIs

Two formats are supported for bulk input and output of graph data:

1.  [GraphML](http://graphml.graphdrawing.org/) is a simple file format
    that is used to describe a graph using XML. Here is an [example
    file](https://raw.githubusercontent.com/tinkerpop/tinkerpop3/master/data/tinkerpop-classic.xml)
    provided by TinkerPop 3. To bulkload a GraphML file into your graph,
    simply POST the GraphML (either as a form text input named 'graphml'
    or as a file input named 'graphml' in a multi-part form) to the
    GraphML bulkload endpoint. One advantage of the GraphML format is
    that it supported by many tools, such as Gephi for graph
    visualization. Some disadvantages are that GraphML is a lossy
    format, in that it only supports primitive data types, and it lacks
    support for graph variables and nested properties.
2.  [GraphSON](http://tinkerpop.incubator.apache.org/docs/3.0.0-SNAPSHOT/#graphson-reader-writer)
    is a JSON-based format that TinkerPop has evolved over several
    releases. As a JSON-based format, it is easily consumed in modern
    web and RESTful applications. Here is an [example
    file](https://raw.githubusercontent.com/tinkerpop/tinkerpop3/master/data/tinkerpop-classic.json)
    provided by TinkerPop 3.

| Method | URI | Response | Description |
|--------|-----|----------|-------------|
| POST   |  /bulkload/graphml | | [ true ] | Submits the GraphML data to be loaded into the graph using the `multipart/form-data` encoding (e.g. with an HTML form) |
| POST   |  /bulkload/graphson | [ true ] | Submits the GraphSON file to be loaded into the graph using the `multipart/form-data` encoding (e.g. with an HTML form) |
| GET    |  /extract | \<xml version="1.0" ?\>\<graphml\>\<graph id="G" edgedefault="directed"\>\<node id="1"/\>\<node id="2"/\>\<edge id=3 source="1" target="2"/\>\</graph\>\</graphml\> | Returns the graph in GraphML format
| GET    |  /extract | {"variables":{},"vertices":[{"id":1,"label":"vertex"}],"edges":[]} | Returns the graph in GraphSON format |

### Schema APIs

A graph schema is defined by its edge labels, vertex labels, and
property keys. You can build a graph without defining a schema
explicity, however doing so can improve query performance by leveraging
graph indexes, simplify the model by restricting cardinalities, and
optimize query filtering by using data types. When using a schema, the
best practice is to define it before populating the graph with data.
Please refer to the Titan documentation on
[schema](http://s3.thinkaurelius.com/docs/titan/0.5.4/schema.html) and
[indexing](http://s3.thinkaurelius.com/docs/titan/0.5.4/indexes.html)
for more details on the options. Here is an [example
schema](http://shortestpathjs.stage1.mybluemix.net/graph-schema.json)
used by the sample applcation.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| GET    | /schema | - | [ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ] | Returns the schema as a JSON document |
| POST   |  /schema | { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } | [ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ] | Updates the schema. |
                                                                                                                      
