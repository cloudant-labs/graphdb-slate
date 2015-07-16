---
title: IBM Graph Data Store - Getting started

language_tabs:
#  - http
#  - shell: curl
#  - javascript: node.js
#  - python

---

# Getting started with the Graph Data Store

### Graph Database Concepts

#### What is a graph database?

A graph database is a database that uses graph structures with vertices (also called nodes),
edges (also called arcs or lines), and properties to represent and store data.
This structure provides index-free adjacency.
Structuring data in a graph database makes looking at the data set simple.
Each element can be linked to other elements using one or more edges.
Graph processing is called traversal.
A traversal visits the elements (vertices and edges) in a graph one at a time in a specific order.

You don’t need to be an engineer to create a graph database.
"If you can whiteboard it, you can graph it," is the new motto.
Team members (business analyst, developer, and DBA) can gather around a whiteboard to design a graph.
With a whiteboard drawing,
you can create a graph database and populate the database with properties and values.
Because of the flexible schema,
a graph can accommodate a wide range of properties.

#### Why would you use a graph database?

Today,
organizations want to analyze huge amounts of data with complex relationships.
A graph database is flexible and easy to query.
Examining the complex relationships between vertices, properties,
and edges can yield meaningful and valuable data.
Graph databases can be used to produce recommendations,
friends-of-friends,
the shortest route, fraud detection and more.
The following list shows other reasons why you might use a graph database.

-	Analyze how things are interconnected.
-	Analyze data to follow the relationships between people, products, and so on.
-	Process large amounts of raw data and generate results into a graph.
-	Work with data that involves complex relationships and dynamic schema.
-	Address constantly changing business requirements during iterative development cycles.
-	Because the data naturally fits a graph.

#### What is the structure of a graph database?

A graph database uses the structure of a property graph.
Graph computing distinguishes between structure (the graph) and process (traversal).
Traversal is the process of visiting the elements (the vertices and edges) in a graph,
in a systematic fashion.

The following list describes the components of a graph database.

<ul>
<li>Structure (the property graph)</li>
<ul>
<li>Graph – maintains a set of vertices, edges, and access to database functions such as traversals.</li>
<li>Elements – vertices and edges are represented in JSON (JavaScript Object Notation).</li>
<ul>
<li>Vertices (also called nodes) – a document that represents people, businesses, accounts, or anything else you want to track, and additional fields added by the database.</li>
<li>Edges (also called arcs or lines) - represents a connection or relationship between two vertices. Each edge contains a unique identifier, a start and end node, and a set of properties.</li>
</ul>
<li>Property – a string key associated with a value and attached to an element, such as a vertex or an edge.</li>
</ul>
<li>Process – use traversal to analyze the structure or graph. A traversal visits all the elements in a graph and checks and updates their values, usually in a specific order.</li>
</ul>

### Using a Bluemix service

IBM Graph Data Store is a service provided within the Bluemix platform.
As you develop your mobile or web application,
you can use Bluemix services as needed,
leaving you to focus on your application logic and design.

A full list of the available services is [available](https://console.ng.bluemix.net/catalog/).

There are three steps to using a Bluemix service:

1.	Create an instance of the service.
	Do this by [requesting a new service instance](https://www.ng.bluemix.net/docs/services/reqnsi.html#req_instance).
2.	(Optional) Identify the application that will use the service.
	If your application is a Bluemix application,
	you can identify the application when you [create the service instance](https://www.ng.bluemix.net/docs/services/reqnsi.html#req_instance).
	If your application is [external](https://www.ng.bluemix.net/docs/services/reqnsi.html#accser_external),
	and is not a Bluemix application,
	you can leave the service unbound.
3.	Write code in your application that [interacts with the service](https://www.ng.bluemix.net/docs/services/reqnsi.html#config).

### Configuring your application to interact with the Graph Data Store service

When you create an instance of a Graph Data Store service,
you are provided with the details necessary for your application to interact with the service.
The details are in JSON format.

In the following example,
the data for each of the credential fields is abbreviated for convenience:

``` json
{
	"credentials": {
		"apiURL": "https://gdsexample.stage1.ng.bluemix.net/graphs/686....",
		"username": "75e1...3b67",
		"password": "742f...b790"
	}
}
```

If you are creating a Bluemix application,
these credentials are stored for you in the `VCAP_SERVICES` environment variable.

You should ensure that your application is configured to use:

-	Graph Data Store endpoints, identifed by the `apiURL` value.
-	The service instance username, identified by the `username` value.
-	The service instance password, identified by the `password` value.

With these configuration changes made,
your application should be able to interact with your Graph Data Store instance.

### Loading data into a Graph Data Store

#### Vertices

In IBM Graph Data Store,
a vertex is simply an object that has,
as a minimum,
an `id` and a `label`.
Optionally,
you can have some properties.

To be useful,
a vertex must be connected to other vertices using [edges](#edges).

In the following example,
there are two vertices,
both labelled as `person`,
and distinguished from each other by having unique IDs.
Each vertex also has some properties,
consisting of the name of the person,
and their job.

![Diagram with two example vertices](GDS001.png)

In Graph Data Store,
you create vertices using the [Vertex APIs](api.html#vertex-apis).

#### Edges

An edge is a connection between two vertices.

In Graph Data Store,
an edge is unidirectional.
In other words,
an edge goes _from_ one vertex _to_ another vertex.
If you require an edge to go _back_ to the first vertex,
you would need a second edge.

In the following diagram,
we have added two more vertices,
and also created two edges,
with the IDs 3699 and 7736,
respectively.
However,
the edges are not yet connected to any vertices.
In other words,
we have not yet indicated how the edges help define relationships between any of the vertices.

![Diagram with two example edges](GDS002.png)

#### Connecting two vertices using edges

First we define edge 3699 as being an incoming edge to vertex f7456.

![Diagram where edge 3699 is an incoming edge to vertex f7456](GDS003.png)

Next we define edge 3699 as an outgoing edge from vertex a6773.

![Diagram where edge 3699 is an outgoing edge from vertex a6773](GDS004.png)

We now have a uni-directional relationship from an actor to a movie.
Next,
we need a similar uni-directional relationship from the movie to the actor.
This time,
we use edge 7736.

As before,
we first define edge 7736 as being an incoming edge to vertex a6773.

![Diagram where edge 7736 is an incoming edge to vertex a6773](GDS005.png)

Finally,
we define edge 7736 as being an outgoing edge from vertex f7456.

![Diagram where edge 7736 is an outgoing edge from vertex f7456](GDS006.png)


In Graph Data Store,
you create edges and connect them to vertices using the [Edge APIs](api.html#edge-apis).

#### Bulk loading data into Graph Data Store

While individual vertices and edges can be created in a Graph Data Store
by using the corresponding [API](api.html) calls,
an alternative is to load all the data in one go using the [Input/Output APIs](api.html#input/output-apis).

The data can be provided in one of two formats:

-	[GraphML](http://graphml.graphdrawing.org/) is an XML-based format.
-	[GraphSON](http://tinkerpop.incubator.apache.org/docs/3.0.0-incubating/#graphson-reader-writer)
	is a JSON-based format, created as part of the Apache Tinkerpop work.

While both formats are supported in Graph Data Store,
the GraphSON format is more familiar to those using JSON for their applications,
and therefore is the format used in this documentation.

#### Example of GraphSON format data

``` json
{
  "vertices":[
    {"name":"marko","age":29,"_id":1,"_type":"vertex"},
    {"name":"vadas","age":27,"_id":2,"_type":"vertex"},
    {"name":"lop","lang":"java","_id":3,"_type":"vertex"},
    {"name":"josh","age":32,"_id":4,"_type":"vertex"},
    {"name":"ripple","lang":"java","_id":5,"_type":"vertex"},
    {"name":"peter","age":35,"_id":6,"_type":"vertex"}
  ],
  "edges":[
    {"weight":0.5,"_id":7,"_type":"edge","_outV":1,"_inV":2,"_label":"knows"},
    {"weight":1.0,"_id":8,"_type":"edge","_outV":1,"_inV":4,"_label":"knows"},
    {"weight":0.4,"_id":9,"_type":"edge","_outV":1,"_inV":3,"_label":"created"},
    {"weight":1.0,"_id":10,"_type":"edge","_outV":4,"_inV":5,"_label":"created"},
    {"weight":0.4,"_id":11,"_type":"edge","_outV":4,"_inV":3,"_label":"created"},
    {"weight":0.2,"_id":12,"_type":"edge","_outV":6,"_inV":3,"_label":"created"}
  ]
}
```

In the example GraphSON data,
you can see that six vertices are defined,
with IDs from 1 to 6.
Each vertex has two properties: a name field and an age field.

The data also defines six edges.
The key aspect to note is that each edge connects into an 'incoming vertex' and 'outgoing vertex'.