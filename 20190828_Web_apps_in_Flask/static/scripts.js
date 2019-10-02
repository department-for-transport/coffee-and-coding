
//pass server all PQ text and get 2 predictions in response
function grabunit() {
  $('.pqbox').each(function(){
    var div = $(this);
    div.children('.unitbox').remove();
    $.getJSON(Flask.url_for("getunit"), {question: $(this).text()})
    .done(function(data) {


      div.append("<div class='unitbox'>" +'Neural Net: ' + data.team + "</div>");
    });
  });
}


