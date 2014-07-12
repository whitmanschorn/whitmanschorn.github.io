# Whitman Schorn 2014


resizeFit = (selector) -> 
  $(selector).bigtext()


$(document).ready ->

  console.log "Hello 2 world"
  resizeFit "#bottle"

  $(".border-btn").click ->
    console.log "hey"
    $("#bottle").toggleClass("border")
