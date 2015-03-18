<script type="text/javascript">
  $(document).ready(function() {
    var searchForm = $("form.search");
    
    
    //select request type
    var requestTypeSelect = $('div.test-form-container select.request-type')
    requestTypeSelect.on("change", function(){
      var type = requestTypeSelect.val();
      if (type == 'search') {
        searchForm.show();    
      } else {
        searchForm.hide();
      }
    });
  
  
    //syntax highlighting
    var highlight = function(elem) {
      elem.each(function(i, block) {
        hljs.highlightBlock(block);
      });
    };
    
  
    //search form    
    var queryInput = $('form.search #test-search-query');
    var outputField = $("#search-output-marker").next();
    var httpRequestField = $("#search-request-http-marker").next();
    var curlRequestField = $("#search-request-curl-marker").next();
    var initForm = function(query) {
      queryInput.val(query);
    };
    var requestChanged = function() {
      httpRequestField.text('GET /examples/_design/ddoc/_search/books?q=' + queryInput.val() + ' HTTP/1.1');
      highlight(httpRequestField);
      curlRequestField.text('curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/examples/_design/ddoc/_search/books?q=' + queryInput.val());
      highlight(curlRequestField);
    }
    var predefinedSelect = $('form.search select.predefined');
    predefinedSelect.on('change', function() {
      var request = predefinedSelect.val();
      if (request == 'author-is-john') {
        initForm('author:John');
      }
      if (request == 'sorting') {
        initForm('');
      }
      requestChanged();
    });
    initForm('author:John');
    highlight(outputField);
    highlight(httpRequestField);
    highlight(curlRequestField);
    queryInput.on("change keyup keypress", requestChanged);
    searchForm.submit(function(event) {
      var query = queryInput.val();
      jQuery.ajax({
        url: '//examples.cloudant.com/docs-examples/_design/ddoc/_search/books?q=' + query,
        type: 'GET',
        beforeSend: function(xhr) {
          xhr.setRequestHeader("Authorization", "Basic " + btoa('thereencespedgetytolisir:c1IimpBSAC3b3A66N8LHKwKF'));
        },
        error: function(one, two) {
        },
        complete: function(jqXHR, textStatus) {
          var result = JSON.stringify(jQuery.parseJSON(jqXHR.responseText), null, '    ');
          
          outputField.show();
          outputField.text(result);
          highlight(outputField);
        }
      });
      event.preventDefault();
    });
  });
</script>

## Try it!

<p id="search-request-http-marker"></p>

```http
GET /examples/_design/ddoc/_search/books?q=author:John HTTP/1.1
```

<p id="search-request-curl-marker"></p>

```shell
curl https://$USERNAME:$PASSWORD@$USERNAME.cloudant.com/examples/_design/ddoc/_search/books?q=author:John
```

<p id="search-output-marker"></p>

```json
{
  "total_rows": 1,
  "bookmark": "g2wAAAABaANkACFkYmNvcmVAZGIxMS5tZXJpdGFnZS5jbG91ZGFudC5uZXRsAAAAAm4EAAAAAIBuBAD___-_amgCRkACik3gAAAAYRtq",
  "rows": [
    {
      "id": "book91",
      "order": [
        2.3175313472747803,
        27
      ],
      "fields": {
        "author": "John Steinbeck",
        "title_English": "The Grapes of Wrath"
      }
    }
  ]
}
```

You can try out requests and output will be shown in the code column to the right. We have put together some sample data so that you can play with Cloudant straight away.

<div class="test-form-container">

  <label for="request-type">Type of request</label>
  <select name="request-type" class="request-type">
  
    <option selected="selected" value="search">Search</option>
    <option value="query">Cloudant Query</option>
  </select>
  <span style="top: -34px; margin-left: 20px; position: relative; left: 40%; color: white; pointer-events: none;" >&#9660;</span>
  <br>
  <form action="#" class="search">
      <label for="predefined">Predefined queries</label>
      <select name="predefined" class="predefined">
        <option selected="selected" value="author-is-john">Books written by John</option>
        <option value="sorting">Search with sorting</option>
      </select>
      <span style="top: -34px; margin-left: 20px; position: relative; left: 40%; color: white; pointer-events: none;" >&#9660;</span>
      <label for="query">Search query (q)</label>
      <input size="100" type="text" name="query" id="test-search-query">
      <input type="submit" value="search" class="submit-button"></input>
  </form>

</div>

<style type="text/css">
  div.test-form-container {
    clear:none;
  }
  div.test-form-container * {
    margin: 0;
    padding: 0;
  }
  div.test-form-container input, div.test-form-container select, div.test-form-container label {
    margin-left: 40px;
    display: block;
  }
  div.test-form-container input, div.test-form-container select {
    margin-bottom: 12px;
    width: 40%;
    height: 24px;
  }
  
  .test-form-container input {
    padding-left: 5px;
  }
  
  .test-form-container .submit-button {
    width: 100px;
    padding: 0;
  }
  
</style>
