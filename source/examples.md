---
title: IBM Graph Data Store - Examples

language_tabs:
#  - http
#  - shell: curl
#  - javascript: node.js
#  - python

---

# Examples

### Example Java Code

The following example code shows a sample application written in Java that uses the Graph Data Store.

#### Get the Graph Data Store URL and credentials

```java
String apiURL = null;
String basicAuth = null;
CloseableHttpClient client = HttpClients.createDefault();
Map envs = System.getenv();
if (envs.get("VCAP_APPLICATION") != null) {
	// app running in Bluemix
	if (envs.get("VCAP_SERVICES") != null) {
		// get the services bound to the app
		String graphServiceName = "GraphDataStore";
		JSONObject vcapSvcs = new JSONObject( envs.get("VCAP_SERVICES").toString() );
		if (!vcapSvcs.isNull(graphServiceName)) {
			JSONObject creds = vcapSvcs.getJSONArray(graphServiceName)
				.getJSONObject(0)
				.getJSONObject("credentials");
			// get the URL for the GraphDB service
			apiURL = creds.getString("apiURL");
			String username = creds.getString("username");
			String password = creds.getString("password");
			byte[] userpass = (username + ":" + password).getBytes();
			byte[] encoding = Base64.encodeBase64(userpass);
			basicAuth = "Basic " + new String(encoding));
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
httpPost.setHeader("Authorization", basicAuth);
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
httpPost.setHeader("Authorization", basicAuth);
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
httpPost.setHeader("Authorization", basicAuth);
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
httpGet.setHeader("Authorization", basicAuth);
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
httpGet.setHeader("Authorization", basicAuth);
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
httpGet.setHeader("Authorization", basicAuth);
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
httpPost.setHeader("Authorization", basicAuth);
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
httpDelete.setHeader("Authorization", basicAuth);
httpResponse = client.execute(httpDelete);
httpEntity = httpResponse.getEntity();
content = EntityUtils.toString(httpEntity);
EntityUtils.consume(httpEntity);
```

#### Get all edges

```java
// This operation is not recommended.
HttpGet httpGet = new HttpGet(apiURL + "/edges");
httpGet.setHeader("Authorization", basicAuth);
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
httpPost.setHeader("Authorization", basicAuth);
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
httpGet.setHeader("Authorization", basicAuth);
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
httpPost.setHeader("Authorization", basicAuth);
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
httpDelete.setHeader("Authorization", basicAuth);
httpResponse = client.execute(httpDelete);
httpEntity = httpResponse.getEntity();
content = EntityUtils.toString(httpEntity);
EntityUtils.consume(httpEntity);
```

### Example Node.js Code

The following example code shows a sample Node.js application that uses the Graph Data Store.

#### Get the Graph Data Store URL and credentials

```javascript
if (process.env.VCAP_SERVICES) {
	var vcapServices = JSON.parse(process.env.VCAP_SERVICES);
	var graphService = 'GraphDataStore'
	if (vcapServices[graphService] && vcapServices[graphService].length > 0) {
		var tp3 = vcapServices[graphService][0];
		process.env.graphDBURL = tp3.credentials.apiURL;
		process.env.username = tp3.credentials.username;
		process.env.password = tp3.credentials.password;
	}
}
```

#### Define graph schema

```javascript
var schemaData = fs.readFile('./public/graph-schema.json', function(err, data) {
	var schemaRequest = {
		uri: process.env.graphDBURL + '/schema',
		method: 'POST',
		auth: { user: process.env.username, pass: process.env.password },
		json: JSON.parse(data.toString())
	};
	request(schemaRequest, function(error, resp, body) {
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
var bulkloadOpts = {
	auth: { user: process.env.username, pass: process.env.password },
	formData: {
		'graphml': fs.createReadStream(__dirname + '/../public/seed-airports-routes.xml'),
		'type': 'application/xml',
	}
};
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
	auth: { user: process.env.username, pass: process.env.password },
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
var url = process.env.graphDBURL + '/vertices';
var opts = { auth: { user: process.env.username, pass: process.env.password } };
request.get(url, opts, function(error, resp, body) {
	var obj = JSON.parse(body);
	var data = (obj.result && obj.result.data) ? obj.result.data : [];
	res.send(data);
});
```

#### Get a vertex by property

```javascript
var url = process.env.graphDBURL + '/vertices?code=' + req.params.code;
var opts = { auth: { user: process.env.username, pass: process.env.password } };
request.get(url, opts, function(error, resp, body) {
	var obj = JSON.parse(body);
	var result = (obj.result && obj.result.data && obj.result.data.length > 0) ? obj.result.data[0] : {};
	res.send(result);
});
```

#### Run a Gremlin traversal

```javascript
var url = process.env.graphDBURL + '/gremlin';
var query = "g.V().has('code','" + req.body.orig + "').out('route').has('code', '" + req.body.dest + "')";
var opts = {
	auth: { user: process.env.username, pass: process.env.password },
	json: { gremlin: query }
};
request.post(url, opts, function(error, resp, obj) {
	var result = (obj.result && obj.result.data && obj.result.data.length > 0) ? obj.result.data[0] : null;
	if (result) {
		// found a route from orig to dest
		console.log('route exists from ' + req.body.orig + ' to ' + req.body.dest);
	}
});
```

