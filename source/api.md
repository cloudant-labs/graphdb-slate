---
title: IBM Graph Data Store - API

language_tabs:
#  - http
#  - shell: curl
#  - javascript: node.js
#  - python

---

# API reference

IBM Graph Data Store provides a REST API for manipulating the graph.

### Vertex APIs

Vertices are the most basic objects in a graph. A vertex can contain
properties and an associated label. Beginning from any vertex, a
traversal explores the graph structure via the incident edges to visit
the connected vertices.

| Method |  URI |  Request | Response  | Description |
| -------|------|----------|-----------|-------------|
| `POST`   | `/vertices` | `-` | `[ {"id":"256"} ]` | Creates a vertex |
| `POST`   |  `/vertices` | `{ "key1":"A", "key2":"B" }` | `[ {"id":"256", "key1":"A", "key2":"B"} ]` | Creates a vertex with properties specified as key-value pairs. |
| `POST`   |  `/vertices/<v0>` | `{ "key1":"C", "key3":"D" }` | `[ {"id":"256", "key1":"C", "key2":"B", "key3":"D"} ]` | Updates existing vertex `v0` with properties specified as key-value pairs. |
| `PUT`    |  `/vertices/<v0>` | `{ "key8":"Y", "key9":"Z" }` | `[ {"id":"256", "key8":"Y", "key9":"Z"}` ] | Updates existing vertex `v0` by deleting previous properties and replacing them with properties specified as key-value pairs. |
| `GET`    |  `/vertices` | `-` | `[ {"id":"256", "key":"value"}, {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get all vertices and their properties. Global graph operations like this can perform slowly. Indices should be utilized for performance. |
| `GET`    |  `/vertices?<key>=<value>` | `-` | `[ {"id":"256", "key":"value"}, {"id":"768", "key":"value"}, {"id":"1280", "key":"value"} ]` | Get all vertices for a key index that has the specified properties. |
| `GET`    |  `/vertices/<v0>` | `-` | `[ {"id":"256", "key":"value"} ]` | Get a vertex by id and all of its properties. |
| `GET`    |  `/vertices/<v0>/out` | `-` | `[ {"id":"512"}, {"id":"768", "key":"value"} ]` | Get the adjacent out vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/in`  | `-` | `[ {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get the adjacent in vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/both` | `-` | `[ {"id":"512"}, {"id":"768", "key":"value"}, {"id":"1024"}, {"id":"1280", "key":"value"} ]` | Get the adjacent in and out vertices and all of their properties for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/outCount` | `-` | `[ 2 ]` | Get the adjacent out vertex count for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/inCount` | `-` | `[ 2 ]` | Get the adjacent in vertex count for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/bothCount` | `-` | `[ 4 ]` | Get the adjacent in and out vertex count for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/outIds` | `-` | `[ 512, 768 ]` | Get the adjacent out vertex ids for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/inIds` | `-` | `[ 1024, 1280 ]` | Get the adjacent in vertex ids for vertex `v0`. |
| `GET`    |  `/vertices/<v0>/bothIds` | `-` | `[ 512, 768, 1024, 1280 ]` | Get the adjacent in and out vertex ids for vertex `v0`. |
| `DELETE` |  `/vertices/<v0>` | `-` | `[ true ]` | Delete vertex `v0` and the connected edges. |
| `DELETE` |  `/vertices/<v0>?<key>` | `-` | `[ true ]` | Delete properties by key on vertex `v0` and the connected edges. |

### Edge APIs

Edges represent a connection or relationship between two vertices. An edge
might include a direction (`from vertex 'outV' to
vertex 'inV'`), properties, and an associated label.

| Method | URI | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| `POST`   |  `/edges` | `{ "outV": 256, "label": "knows", "inV": 512 }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows"} ]` | Creates an edge from vertex with `id 256` to vertex with `id 512` using 'knows' as the edge label. |
| `POST`   |  `/edges` | `{ "outV": 256, "label": "knows", "inV": 512, "key1": "A", "key2": "B" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "A", "key2": "B"} ]` | Creates an edge from vertex with `id 256` to vertex with `id 512` using 'knows' as the edge label. Properties for the edge are specified as key-value pairs. |
| `POST`   |  `/edges/<e0>` | `{ "key1": "C", "key3": "D" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key1": "C", "key2": "B", "key3": "D"} ]` | Updates existing edge `e0` with properties specified as key-value pairs. The incident vertices and labels cannot be changed. |
| `PUT`   |  `/edges/<e0>` | `{ "key8": "Y", "key9": "Z" }` | `[ {"id":"lc-74-36d-e8", "outV": 256, "inV": 512, "label": "knows", "key8": "Y", "key9": "Z"} ]` | Updates existing edge `e0` by deleting previous properties and replacing them with the properties specified by key-value pairs. The incident vertices and labels cannot be changed. |
| `GET`    |  `/edges` | `-` | `[ {"id":"lc-74-36d-e8", "key":"value"} ]` | Get all edges and their properties. Global graph operations like this can perform slowly. Indexes must be utilized for performance. |
| `GET`    |  `/edges/<e0>` | `-` | `[ {"id":"lc-74-36d-e8", "key":"value"} ]` | Get an edge by id and all of its properties. |
| `DELETE` |  `/edges/<e0>` | `-` | `[ true ]` | Deletes the edge `e0`. |
| `DELETE` |  `/edges/<e0>?<key>` | `-` | `[ true ]` | Deletes properties by key on edge `e0`. |

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

Here is a Tinkerpop 3 [example file](https://github.com/apache/incubator-tinkerpop/blob/master/data/tinkerpop-classic.xml). To bulk load a GraphML file into your graph, POST the GraphML (as either form text input named ‘graphml’ or as a file input named ‘graphml’ in a multi-part form) to the GraphML bulk load endpoint.

[GraphSON](http://tinkerpop.incubator.apache.org/docs/3.0.0-SNAPSHOT/#graphson-reader-writer) is a JSON-based format extended from earlier versions of TinkerPop. As a JSON-based format, it is easily consumed in modern Web and RESTful applications. Here is a Tinkerpop 3 [example file](https://github.com/apache/incubator-tinkerpop/blob/master/data/tinkerpop-crew.json).

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

| Method | URI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Request | Response | Description |
|--------|-----|---------|----------|-------------|
| `GET`    | `/schema` | `-` | `[ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ]` | Returns the schema as a JSON document. |
| `POST`   |  `/schema` | `{ "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] }` | `[ { "edgeIndexes": [], "edgeLabels": [ {"directed": true, "multiplicity":"SIMPLE", "name":"route"} ], "propertyKeys": [ {"cardinality":"SINGLE", "dataType":"String", "name":"city"} ], "vertexIndexes": [ {"composite":false, "name":"cityIndex", "propertyKeys":[ "city" ], "unique":false} ], "vertexLabels": [ {"name": "location"} ] } ]` | Updates the schema. |
