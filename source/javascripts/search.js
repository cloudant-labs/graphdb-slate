var res;
$(function () {
  var search_box = '#searchbox form';
  var query_input = search_box + '> input[name="search"]';
  var query_url = '_search/docs';

  function on_submit (event) {
    var query = $(query_input).val();

    $.get(query_url, { q: query })
     .done(function (response) {
      res = response;
     })
     .fail(function (jqXHR, status) {
      // TODO
     });

    return false;
  }

  $(search_box).submit(on_submit);
});