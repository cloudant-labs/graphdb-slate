---
title: Graph Data Store Documentation - Try it!

language_tabs:
  - http 
  - shell: curl
#  - javascript: node.js
#  - python

---

<script type="text/javascript">
  $(document).ready(function() {
    var outputField = $("#output-marker").next();
    var httpRequestField = $("#request-http-marker").next();
    var curlRequestField = $("#request-curl-marker").next();
    var highlight = function(elem) {
      elem.each(function(i, block) {
        hljs.highlightBlock(block);
      });
    };
    var requestTypes = {
      gremlin: {
        queryInput: $('form.gremlin .query'),
        form: $('form.gremlin'),
        queries: {
          'six-degrees': { query: "{\n  \"gremlin\": \"g.V().hasLabel('person').has('type','Actor').has('name','Kevin Bacon').repeat(__.outE().inV().dedup().simplePath()).until(__.hasLabel('person').has('name','Bill Paxton')).limit(12).path()\"\n}" },
          'films-with-kevin-bacon': { query: "{\n  \"gremlin\": \"g.V().hasLabel('person').has('type','Actor').has('name','Kevin Bacon').outE().inV()\"\n}" },
          'actors-starring-in-apollo-13': { query: "{\n  \"gremlin\": \"g.V().hasLabel('film').has('type','Film').has('name','Apollo 13').outE().inV()\"\n}" },
          'default': 'six-degrees'
        },
        renderHttpRequest: function() {
          return 'POST /gremlin HTTP/1.1\nHost: example.com\n\n' + this.queryInput.val();
        },
        renderCurlRequest: function() {
          return "curl 'https://example.com/gremlin' -X POST -d \"" + this.queryInput.val().replace(/"/g, '\\"') + '"';
        },
        submitForm: function(event){
          var query = this.queryInput.val();
          jQuery.ajax({
            url: 'https://slate-backend.mybluemix.net/graph',
            type: 'POST',
            data: query,
            beforeSend: function(xhr) {
              //xhr.setRequestHeader("Authorization", "Basic " + btoa('thereencespedgetytolisir:c1IimpBSAC3b3A66N8LHKwKF'));
              xhr.setRequestHeader("Content-Type", "application/json");
            },
            error: function(one, two) {},
            complete: displayResult
          });
          event.preventDefault();
        }
    
      }
    };
    var saveFormState = function() {
      var requestType = requestTypeSelect.val();
      var predefinedQuery = $('form.' + requestType + ' .predefined').val();
      window.location.hash = '#requestType=' + requestType + '&predefinedQuery=' + predefinedQuery;
    };
    var displayResult = function(jqXHR, textStatus) {
      var result = JSON.stringify(jQuery.parseJSON(jqXHR.responseText), null, '    ');
      outputField.show();
      outputField.text(result);
      highlight(outputField);
    }
    
    for (var rt in requestTypes) {
      requestTypes[rt].form.submit(requestTypes[rt].submitForm);
    }
    
    var requestChanged = function(formName) {
      httpRequestField.text(requestTypes[formName].renderHttpRequest());
      highlight(httpRequestField);
      curlRequestField.text(requestTypes[formName].renderCurlRequest());
      highlight(curlRequestField);
      requestTypes[formName].submitForm({preventDefault:function(){}});
    }
    
    var requestTypeSelect = $('div.test-form-container select.request-type');
    var showSelectedType = function() {
      for (var requestType in requestTypes) {
        requestTypes[requestType].form.hide();
      }
      var type = requestTypeSelect.val();
      requestTypes[type].form.show();
    };
    requestTypeSelect.on("change", showSelectedType);
    requestTypeSelect.on("change", saveFormState);
    requestTypeSelect.on("change", function() {
      var rt = requestTypeSelect.val();
      var defaultQuery = requestTypes[rt].queries['default']
      initForm(rt, requestTypes[rt].queries[defaultQuery]);
      requestChanged(rt);
    });
    
    var initForm = function(formName, request) {
      $('form.' + formName + ' input[type=text]').val('');
      for (var field in request) {
        $('form.' + formName + ' .' + field).val(request[field]);
      }
    };
    var initPredefinedSelect = function(formName) {
      var predefinedSelect = $('form.' + formName + ' select.predefined');
      predefinedSelect.on('change', function() {
        var request = predefinedSelect.val();
        initForm(formName, requestTypes[formName].queries[request]);
        requestChanged(formName);
        saveFormState();
      });
    };
    for (var rt in requestTypes) {
      initPredefinedSelect(rt);
      initForm(rt, requestTypes[rt].queries['default']);
    }
    for (var rt in requestTypes) {
      var createFunc = function(rtp) { return function(){requestChanged(rtp)}}
      requestTypes[rt].form.on('keyup', $.debounce(createFunc(rt), 500));
    }
    //init form from query param values
    function getParameterByName(name) {
      name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
      var regex = new RegExp("[\\#&]" + name + "=([^&#]*)"), results = regex.exec(window.location.hash);
      return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }
    var requestType = getParameterByName('requestType');
    if (!requestType) { requestType = 'gremlin'; }
    var predefinedQuery = getParameterByName('predefinedQuery');
    if (!predefinedQuery) { predefinedQuery = requestTypes[requestType].queries['default']; }
    requestTypeSelect.val(requestType);
    $('form.' + requestType + ' .predefined').val(predefinedQuery);
    showSelectedType();
    initForm(requestType, requestTypes[requestType].queries[predefinedQuery]);
    requestChanged(requestType);
    $("#lang-selector a").unbind("click");
    $("#lang-selector a").bind("click", function(event) {
      var language = $(this).data("language-name");
      activateLanguage(language);
      event.preventDefault();
    });
  
  });
</script>

## Try it!

> Request

<p id="request-http-marker"></p>

```http

```

<p id="request-curl-marker"></p>

```shell

```

> Response

<p id="output-marker"></p>

```json

```

You can try out requests and output will be shown in the code column to the right. We have put together some sample data so that you can play with Graph Data Store straight away.

<div class="test-form-container">

  <label for="request-type">Type of request</label>
  <select name="request-type" class="request-type">
    <option selected="selected" value="gremlin">Gremlin</option>
  </select>
  <br>
  <form action="#" class="gremlin">
    <label for="predefined">Predefined queries</label>
    <select name="predefined" class="predefined">
      <option selected="selected" value="six-degrees">6 degrees of Kevin Bacon</option>
      <option value="films-with-kevin-bacon">Films with Kevin Bacon</option>
      <option value="actors-starring-in-apollo-13">Actors starring in Apollo 13</option>
    </select>
    <textarea rows="10" class="query" cols="80" id="requestBody"></textarea><br /><br />
  </form>
</div>
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

<style type="text/css">
  div.test-form-container {
    clear:none;
  }
  div.test-form-container * {
    margin: 0;
    padding: 0;
  }
  .test-form-container textarea, div.test-form-container input[type=text], div.test-form-container select, div.test-form-container label {
    margin-left: 40px;
    display: block;
  }
  .test-form-container textarea, div.test-form-container input[type=text], div.test-form-container select {
    margin-bottom: 12px;
    width: 40%;
    height: 24px;
  }
  .test-form-container textarea {
    height: 300px;
    font-family: monospace;
  }
  .test-form-container form {
    display: none;
  }
  .test-form-container form.search {
    display: block;
  }
  .test-form-container input[type=text] {
    padding-left: 5px;
  }
  .test-form-container input[type=checkbox] {
    display: inline;
    margin-left: 40px;
    width: 20px;
  }
  pre span.hljs-string {
    color: #00a69f;
  }
  pre span.hljs-number {
    color: #90a959;
  }
  pre.hljs span.hljs-title {
    color: #fff;
  }
  #hideCodeButton {
    display: none;
  }

</style>
