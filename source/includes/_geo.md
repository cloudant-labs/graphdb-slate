# Geo

> Example design document:

```json
{
  "_id": "_design/geo_index_example",
  "indexes": {
    "geo_index": {
      "index": "function (doc) { ... }"
    }
  }
}
```

> Example geo index:

```javascript
function (doc) {
  st_index(doc.geolocation);
}
```

> Example GeoJSON object:

```json
{ 
  "properties": { 
    "Name": "Quinlan's Ice Cream", 
    "Status": "Delicious" 
  }, 
  "type": "Feature", 
  "geometry": { 
    "coordinates": [-10.0, 10.0] 
    "type": "Point" 
  }
} 

```

<aside>Geo indexing is only available on dedicated clusters who purchased the feature.</aside>

Geo indexing allows you to perform sophisticated geo-spatial queries returning documents based on their geometric relationships.

The `st_index` function specifically indexes objects, called geometries, encoded as [GeoJSON](http://geojson.org/geojson-spec.html). GeoJSON objects which the `st_index` function can index must have a `geometry` field, containing the object's geometry ([examples here](http://geojson.org/geojson-spec.html#appendix-a-geometry-examples)), and a `type` field with the value `Feature`. The optional `properties` object can contain any fields and values; it's purely for your use as the developer.

## Queries

```shell
TODO
```

```python
TODO
```

Once you've got an index written, you can query it with a GET request to `https://$USERNAME.cloudant.com/$DATABASE/$DESIGN_DOCUMENT_ID/_geo/$INDEX_NAME`. All geo queries must provide these two query arguments: `relation` (a relation) and `g` (a geometry). Cloudant returns every document in the database whose indexed geometry has the specified relationship to the given geometry.

### Geometries

```
POLYGON(
  (
    -106.4739990234375%2039.774769485295465,
    -106.1553955078125%2040.23760536584024,
    -105.4193115234375%2040.11588965267845,
    -105.2655029296875%2039.61838363831913,
    -105.457763671875%2039.42346418978382,
    -106.20483398437499%2039.342794408952386,
    -106.4739990234375%2039.774769485295465
  )
)
```

Geometries are specified by the `g` query parameter, and indicate the geometry against which all indexed geometries will be compared and related. Use any of the following formats to specify a geometry in the query:

Function | Arguments | Description
---------|-----------|-------------
`POINT` | (x, y) | A single 2d point
`MULTIPOINT` | ((x1, y1), (x2, y2), ...) | Multiple unrelated 2d points
`LINESTRING` |  | 
`MULTILINESTRING` |  | 
`POLYGON` |  | 
`MULTIPOLYGON` |  | 
`GEOMETRYCOLLECTION` |  | 
`CIRCULARSTRING` |  | 
`COMPOUNDCURVE` |  | 
`CURVEPOLYGON` |  | 
`MULTICURVE` |  | 
`MULTISURFACE` |  | 
`CURVE` |  | 
`SURFACE` |  | 
`POLYHEDRALSURFACE` |  | 
`TIN` |  | 
`TRIANGLE` |  | 



### Relations

Relations are specified by the `relation` query parameter, and indicate how indexed geometries must relate to the geometry specified in the query.

Relation | Description
---------|------------
`disjoint` | True if the two geometries do not touch or intersect
`bbox` | True if indexed geometry is within the given geometry. This is equivalent to the opposite of `disjoint`
`equals` | True if the two geometries are the same
`intersect` | True if the two geometries intersect.
`touches` | True if and only if the only common points of the two geometries are in the union of the boundaries of the geometries
`crosses` | True if the intersection of the two geometries results in a value whose dimension is less than the geometries and the maximum dimension of the intersection value includes points interior to both the geometries, and the intersection value is not equal to either of the geometries
`within` | True if the indexed geometry is wholly inside the given geometry
`contains` | True if the given geometry is wholly inside the indexed geometry
`overlaps` | True if the intersection of the geometries results in a value of the same dimension as the geometries that is different from both of the geometries
