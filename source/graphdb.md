---
title: Graph Data Store - API

language_tabs:
#  - http
#  - shell: curl
#  - javascript: node.js
#  - python

---

## Getting started with the Graph Data Store

The Graph Data Store service provides a REST API that enables you to store your
data in a [graph database](http://en.wikipedia.org/wiki/Graph_database).
You can easily discover and explore the relationships in a property graph with index-free adjacency using vertices, edges, and properties. The Graph Data Store provides a graph-based NoSQL store that creates a rich
and extensible representation of your data in an accessible way.

### Learn more

-   [Apache TinkerPop: An Open Source Graph Computing Framework](http://tinkerpop.incubator.apache.org/)

-   [Titan: Distributed Graph Database](http://titan.thinkaurelius.com/)

-   [Gremlin: Graph Traversal Steps](http://www.tinkerpop.com/docs/3.0.0.M7/#graph-traversal-steps)

### Example Java Code

The following example code shows a sample application written in Java
that uses the Graph Data Store.

#### Get the Graph Data Store URL

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
    // This operation is not recommended.
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
    // This operation is not recommended.
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

The following example code shows a sample Node.js application that uses the Graph Data Store.

#### Get the Graph Data Store URL

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
    // This operation is not recommended.
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

The Graph Data Store provides a REST API for manipulating the graph.

### Vertex APIs

Vertices are the most basic objects in a graph. A vertex can contain
properties and an associated label. Beginning from any vertex, a
traversal explores the graph structure via the incident edges to visit
the connected vertices.

| Method |  URI |  Request | Response  | Description |
| -------|------|----------|-----------|-------------|
| `POST`   | `/vertices` | `-` | `[ {"id":"256"} ]` | Creates a vertex |
| `POST`   |  `/vertices` | `{ "key1":"A", "key2":"B" }` | `[ {"id":"256", "key1":"A", "key2":"B"} ]` | Creates a vertex with properties specified as key-value pairs. |
| `POST`   |  `/vertices/\<v0\>` | `{ "key1":"C", "key3":"D" }` | `[ {"id":"256", "key1":"C", "key2":"B", "key3":"D"} ]` | Updates existing vertex `v0` with properties specified as key-value pairs. |
| `PUT`    |  `/vertices/\<v0\>` | `{ "key8":"Y", "key9":"Z" }` | `[ {"id":"256", "key8":"Y", "key9":"Z"}` ] | Updates existing vertex `v0` by deleting previous properties and replacing them with properties specified as key-value pairs. |
| `GET`    |  `/vertices` | `-` | `[ {"id":"256", "key":"value"}, {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get all vertices and their properties. Global graph operations like this can perform slowly. Indices should be utilized for performance. |
| `GET`    |  `/vertices?\<key\>=\<value\>` | `-` | `[ {"id":"256", "key":"value"}, {"id":"768", "key":"value"}, {"id":"1280", "key":"value"} ]` | Get all vertices for a key index that has the specified properties. |
| `GET`    |  `/vertices/\<v0\>` | `-` | `[ {"id":"256", "key":"value"} ]` | Get a vertex by id and all of its properties. |
| `GET`    |  `/vertices/\<v0\>/out` | `-` | `[ {"id":"512"}, {"id":"768", "key":"value"} ]` | Get the adjacent out vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/in`  | `-` | `[ {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get the adjacent in vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/both` | `-` | `[ {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get the adjacent in and out vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/outCount` | `-` | `[ 2 ]` | Get the adjacent out vertex count for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/inCount` | `-` | `[ 2 ]` | Get the adjacent in vertex count for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/bothCount` | `-` | `[ 4 ]` | Get the adjacent in and out vertex count for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/outIds` | `-` | `[ 512, 768 ]` | Get the adjacent out vertex ids for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/inIds` | `-` | `[ 1024, 1280 ]` | Get the adjacent in vertex ids for vertex `v0`. |
| `GET`    |  `/vertices/\<v0\>/bothIds` | `-` | `[ 512, 768, 1024, 1280 ]` | Get the adjacent in and out vertex ids for vertex `v0`. |
| `DELETE` |  `/vertices/\<v0\>` | `-` | `[ true ]` | Delete vertex `v0` and the connected edges. |
| `DELETE` |  `/vertices/\<v0\>?\<key\>` | `-` | `[ true ]` | Delete properties by key on vertex `v0` and the connected edges. |

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Edge APIs

Edges represent a connection or relationship between two vertices. An edge
might include a direction (`from vertex 'outV' to
vertex 'inV'`), properties, and an associated label.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| `POST`   |  `/edges` | `{ "outV": 256, "label": "knows", "inV": 512 }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows"} ]` | Creates an edge from vertex with `id 256` to vertex with `id 512` using 'knows' as the edge label. |
| `POST`   |  `/edges` | `{ "outV": 256, "label": "knows", "inV": 512, "key1": "A", "key2": "B" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "A", "key2": "B"} ]` | Creates an edge from vertex with `id 256` to vertex with `id 512` using 'knows' as the edge label. Properties for the edge are specified as key-value pairs. |
| `POST`   |  `/edges/\<e0\>` | `{ "key1": "C", "key3": "D" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "C", "key2": "B", "key3": "D"} ]` | Updates existing edge `e0` with properties specified as key-value pairs. The incident vertices and labels cannot be changed. |
| `PUT`   |  `/edges/\<e0\>` | `{ "key8": "Y", "key9": "Z" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key8": "Y", "key9": "Z"} ]` | Updates existing edge `e0` by deleting previous properties and replacing them with the properties specified by key-value pairs. The incident vertices and labels cannot be changed. |
| `GET`    |  `/edges` | `-` | `[ {"id":"lc-74-36d-e8", "key":"value"} ]` | Get all edges and their properties. Global graph operations like this can perform slowly. Indexes must be utilized for performance. |
| `GET`    |  `/edges/\<e0\>` | `-` | `[ {"id":"lc-74-36d-e8", "key":"value"} ]` | Get an edge by id and all of its properties. |
| `DELETE` |  `/edges/\<e0\>` | `-` | `[ true ]` | Deletes the edge `e0`. |
| `DELETE` |  `/edges/\<e0\>?\<key\>` | `-` | `[ true ]` | Deletes properties by key on edge `e0`. |

### Gremlin APIs

Gremlin is a domain-specific language for graph traversals. Using Gremlin,
you can express complex graph traversals that cannot be performed with basic vertex and edge APIs. To use
Gremlin with a graph, POST the Gremlin traversal inside a JSON object to the Gremlin endpoint. See [Gremlin 3.0.0.M7 documentation](http://www.tinkerpop.com/docs/3.0.0.M7/#graph-traversal-steps)
for more information about supported graph traversal steps.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| `POST`   |  `/gremlin` | `{"gremlin": "g.V(256).out().out()"}` | `[ {"id":"768"}, {"id":"1024"}, {"id":"1280"} ]` | Performs a traversal from the starting node to its second degree neighbors. |

### Input/Output APIs

Graph Data Store supports two formats of bulk input and output graph data: GraphML and GraphSON.

[GraphML](http://graphml.graphdrawing.org/) is a simple file format used to describe a graph using XML. Multiple tools, such as Gephi for graph visualization, support the GraphML format. However, GraphML is a lossy format that only supports primitive data types. It also lacks support for graph variables and nested properties.

Here is a Tinkerpop 3 [example file](https://raw.githubusercontent.com/tinkerpop/tinkerpop3/master/data/tinkerpop-classic.xml). To bulk load a GraphML file into your graph, POST the GraphML (as either form text input named ‘graphml’ or as a file input named ‘graphml’ in a multi-part form) to the GraphML bulk load endpoint.

[GraphSON](http://tinkerpop.incubator.apache.org/docs/3.0.0-SNAPSHOT/#graphson-reader-writer) is a JSON-based format extended from earlier versions of TinkerPop. As a JSON-based format, it is easily consumed in modern Web and RESTful applications. Here is a Tinkerpop 3 [example file](https://raw.githubusercontent.com/tinkerpop/tinkerpop3/master/data/tinkerpop-classic.json).

| Method | URI | Response | Description |
|--------|-----|----------|-------------|
| `POST`   |  `/bulkload/graphml` | | `[ true ]` |
| `POST`   |  `/bulkload/graphson` | `[ true ]` | Submits the GraphSON file to be loaded into the graph using the `multipart/form-data` encoding with an HTML form. |
| `GET`    |  `/extract` | `\<xml version="1.0" ?\>\<graphml\>\<graph id="G" edgedefault="directed"\>\<node id="1"/\>\<node id="2"/\>\<edge id=3 source="1" target="2"/\>\</graph\>\</graphml\>` | Returns the graph in GraphML format.|
| `GET`    |  `/extract` | `{"variables":{},"vertices":[{"id":1,"label":"vertex"}],"edges":[]}` | Returns the graph in GraphSON format. |

### Schema APIs

A graph schema is defined by its edge labels, vertex labels, and
property keys. You can build a graph without explicitly defining a schema. However, if you define a schema, it improves query performance by leveraging
graph indices, simplifying the model by restricting cardinalities, and
optimizing query filtering by using data types. As a best practice, you define the schema before populating the graph with data. See the Titan documentation on
[schema](http://s3.thinkaurelius.com/docs/titan/0.5.4/schema.html) and
[indexing](http://s3.thinkaurelius.com/docs/titan/0.5.4/indexes.html)
for more information. The sample application uses this [example
schema](http://shortestpathjs.stage1.mybluemix.net/graph-schema.json).

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| `GET`    | `/schema` | `-` | `[ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ]` | Returns the schema as a JSON document. |
| `POST`   |  `/schema` | `{ "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] }` | `[ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ]` | Updates the schema. |
