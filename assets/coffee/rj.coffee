$("#r").fitText 0.400
$("#j").fitText 0.400
$(document).ready ->
  
  #data.0.images.original.url = "http://media0.giphy.com/media/13JmZ4Wk8YbHkk/giphy.gif"
  $("#title").click ->
    $(".block1").animate
      margin: "0 -400% 0 0"
    , 500, ->

    $(".block2").animate
      margin: "-200px 0 0 0"
    , 500, ->
      $(".block2").css "display", "inline-block"
      $("#hg").fitText 0.80
      $("#where").fitText 0.92
      xhr = $.get("http://api.giphy.com/v1/gifs/random?&api_key=dc6zaTOxFJmzC&limit=1&tag=romeo+juliet")
      xhr.done (data) ->
        console.log "success got data", data
        nurl = data.data.image_url + ""
        console.log data.data.image_url
        $("#container").css("background", "url(" + nurl + ") no-repeat center center fixed").css("background-size", "cover").css("-webkit-background-size", "cover").css("-o-background-size", "cover").css "-moz-background-size", "cover"
        console.log "N " + nurl
        return

      return

    return

  $(".back").click ->
    $(".block1").animate
      margin: "0 0 0 0"
    , 500, ->

    $(".block2").animate
      margin: "-200px 0 0 0"
    , 500, ->
      $(".block2").css "display", "none"
      $("#hg").fitText 0.80
      $("#where").fitText 0.95
      return

    return

  return
