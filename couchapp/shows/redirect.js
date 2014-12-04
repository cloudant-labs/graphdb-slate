function(doc, req) {
    return { code : 301, headers: { "Location": 'https://docs.cloudant.com/' + req.query.fragment } };
}
