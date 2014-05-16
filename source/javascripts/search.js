$(function () {
  var search_box = '#searchbox form';
  var query_input = search_box + ' input[name="search"]';
  var query_url = '_search/docs';

  var typeahead_opts = {
    minLength: 3,
    highlight: true
  };

  var typeahead_data = {
    name: 'doc_matches',
    source: compute_suggestions,
    displayKey: function (row) {
      return row.fields.title;
    }
  };

  function compute_suggestions (query, cb) {
    $.get(query_url, { q: query }).done(function (response) {
      var res = JSON.parse(response);
      cb(res.rows);
    });
  }

  function on_submit (event) {
    console.log(arguments);
    var section_id = $(query_input).val().replace(' ', '-').toLowerCase();
    console.log(section_id);
    
    $('html, body').animate({
        scrollTop: $("#" + section_id).offset().top
    }, 200);

    return false;
  }

  $(query_input).typeahead(typeahead_opts, typeahead_data);
  $(search_box).submit(on_submit);
});