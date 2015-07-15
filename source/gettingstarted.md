---
title: IBM Graph Data Store - Getting started

language_tabs:
#  - http
#  - shell: curl
#  - javascript: node.js
#  - python

---

# Getting started with the Graph Data Store

### What is a graph database?

A graph database is a database that uses graph structures with vertices (nodes and dots), edges (arcs and lines), and properties to represent and store data. This structure provides index-free adjacency. Structuring data in a graph database makes looking at the data set simple. Each element contains a direct pointer to its adjacent elements. Therefore, no index lookups are necessary. Graph processing is called traversal. A traversal visits the elements (vertices and edges) in a graph one at a time in a specific order.

You don’t need to be an engineer to create a graph database. “If you can whiteboard it, you can graph it,” is the new motto. Team members (business analyst, developer, and DBA) can gather around a  whiteboard to design a graph. With a whiteboard drawing, you can create a graph database and populate the database with properties and values. Because of the flexible schema, a graph can accommodate a wide range of properties. Graph databases produce recommendations, friends-of-friends, the shortest route, fraud detection and more.

### Why would you use a graph database?

Today, companies want to analyze huge amounts of data with complex relationships.
A graph database is flexible and easy to query.
Examining the complex relationships between vertices, properties,
and edges can yield meaningful and valuable data.
The following list shows other reasons why you might use a graph database.

-	Analyze how things are interconnected.
-	Analyze data to follow the relationships between people, products, and so on.
-	Create an extensible schema and use mixed patterns.
-	Change production with very little impact to existing code.
-	Process large amounts of raw data and generate results into a graph.
-	Work with data that involves complex relationships and dynamic schema.
-	Address constantly changing business requirements during iterative development cycles.
-	Because the data naturally fits a graph.

### What is the structure of a graph database?

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
<li>Vertices (nodes, dots) – a document that represents people, businesses, accounts, or anything else you want to track, and additional fields added by the database.</li>
<li>Edges (arcs, lines) - represents a connection or relationship between two vertices. Each edge contains a unique identifier, a start and end node, and a set of properties.</li>
</ul>
<li>Property – a string key associated with a value and attached to an element, such as a vertex or an edge.</li>
</ul>
<li>Process – use traversal to analyze the structure or graph. A traversal visits all the elements in a graph and checks and updates their values, usually in a specific order.</li>
</ul>
