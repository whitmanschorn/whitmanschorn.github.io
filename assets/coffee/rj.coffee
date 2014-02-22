
$(document).ready ->

  rjSize = 0.42
  hgSize = 0.82
  whereSize = 0.96

  $("#r").fitText rjSize , { minFontSize: '20px', maxFontSize: '360px' }
  $("#j").fitText rjSize , { minFontSize: '20px', maxFontSize: '360px' }
  
  #data.0.images.original.url = "http://media0.giphy.com/media/13JmZ4Wk8YbHkk/giphy.gif"
  $("#title").click ->
    $(".block1").animate
      margin: "0 -400% 0 0"
    , 500, ->

    $(".block2").animate
      margin: "-100px 0 0 0"
    , 500, ->
      $(".block2").css "display", "block"
      $("#hg").fitText hgSize
      $("#where").fitText whereSize , { minFontSize: '20px', maxFontSize: '120px' }
      xhr = $.get("http://api.giphy.com/v1/gifs/random?&api_key=dc6zaTOxFJmzC&limit=1&tag=romeo+juliet")
      xhr.done (data) ->
        nurl = data.data.image_url + ""
        $("#container").css("background", "url(" + nurl + ") no-repeat center center fixed").css("background-size", "cover").css("-webkit-background-size", "cover").css("-o-background-size", "cover").css "-moz-background-size", "cover"


    $(".block1").css "display", "none"


  $(".back").click ->
    $(".block1").css "display", "block"

    $(".block1").animate
      margin: "0 0 0 0"
    , 500, ->

    $(".block2").animate
      margin: "-200px 0 0 0"
    , 500, ->
      $(".block2").css "display", "none"

