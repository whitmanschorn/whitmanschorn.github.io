rjSize = 0.42
hgSize = 0.82
whereSize = 0.96

resizeRJ = ->
  $("#r").fitText rjSize , { minFontSize: '20px', maxFontSize: '360px' }
  $("#j").fitText rjSize , { minFontSize: '20px', maxFontSize: '360px' }


 resizeOther = -> 
  $("#hg").fitText hgSize
  $("#where").fitText whereSize , { minFontSize: '20px', maxFontSize: '120px' }



$(document).ready ->


  resizeRJ()

  #data.0.images.original.url = "http://media0.giphy.com/media/13JmZ4Wk8YbHkk/giphy.gif"
  $("#title").click ->
    resizeRJ()
    $(".block1").toggleClass "showing"

    resizeOther()
    $(".block2").toggleClass "showing"
    xhr = $.get("http://api.giphy.com/v1/gifs/random?&api_key=dc6zaTOxFJmzC&limit=1&tag=romeo+juliet")
    xhr.done (data) ->
      nurl = data.data.image_url + ""
      $("#container").css("background", "url(" + nurl + ") no-repeat center center fixed").css("background-size", "cover").css("-webkit-background-size", "cover").css("-o-background-size", "cover").css "-moz-background-size", "cover"


  $(".back").click ->
    $(".block1").toggleClass "showing"
    resizeRJ()

    $(".block2").toggleClass "showing"
    resizeOther()

