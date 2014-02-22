// Generated by CoffeeScript 1.7.1
$(document).ready(function() {
  var hgSize, rjSize, whereSize;
  rjSize = 0.42;
  hgSize = 0.82;
  whereSize = 0.96;
  $("#r").fitText(rjSize, {
    minFontSize: '20px',
    maxFontSize: '360px'
  });
  $("#j").fitText(rjSize, {
    minFontSize: '20px',
    maxFontSize: '360px'
  });
  $("#title").click(function() {
    $(".block1").animate({
      margin: "-200% 0 0 0"
    }, 500, function() {
      return $(".block1").css("display", "none");
    });
    return $(".block2").animate({
      margin: "0 0 -100px 0"
    }, 500, function() {
      var xhr;
      $(".block2").css("display", "block");
      $("#hg").fitText(hgSize);
      $("#where").fitText(whereSize, {
        minFontSize: '20px',
        maxFontSize: '120px'
      });
      xhr = $.get("http://api.giphy.com/v1/gifs/random?&api_key=dc6zaTOxFJmzC&limit=1&tag=romeo+juliet");
      return xhr.done(function(data) {
        var nurl;
        nurl = data.data.image_url + "";
        return $("#container").css("background", "url(" + nurl + ") no-repeat center center fixed").css("background-size", "cover").css("-webkit-background-size", "cover").css("-o-background-size", "cover").css("-moz-background-size", "cover");
      });
    });
  });
  return $(".back").click(function() {
    $(".block1").css("display", "block");
    $("#r").fitText(rjSize, {
      minFontSize: '20px',
      maxFontSize: '360px'
    });
    $("#j").fitText(rjSize, {
      minFontSize: '20px',
      maxFontSize: '360px'
    });
    $(".block1").animate({
      margin: "0 0 0 0"
    }, 500, function() {});
    return $(".block2").animate({
      margin: "0 0 -200px 0"
    }, 500, function() {
      return $(".block2").css("display", "none");
    });
  });
});
