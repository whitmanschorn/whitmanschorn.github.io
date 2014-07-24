# Whitman Schorn 2014
dragBool = false;
staggerBool = true;
displayInfoBool = true;
staggerInt = 20;
event2key =
  97: "a"
  66: "b"
  99: "c"
  68: "d"
  101: "e"
  102: "f"
  71: "g"
  104: "h"
  105: "i"
  106: "j"
  107: "k"
  108: "l"
  109: "m"
  78: "n"
  111: "o"
  112: "p"
  113: "q"
  82: "r"
  83: "s"
  116: "t"
  117: "u"
  118: "v"
  119: "w"
  120: "x"
  121: "y"
  27: "esc"
  37: "left"
  39: "right"
  38: "up"
  40: "down"
  13: "enter"

animStr = "callout.bounce"
displayMode = "bottle"
displayModeOptions = ["bottle", "graph"]
resizeFit = (selector) -> 
  $(selector).bigtext()


setAnimation = (animationName) ->
  animStr = animationName

setCustomAnimation = (animationName, animationObject) ->
  $.Velocity.RegisterUI(animationName, animationObject);
  animStr = animationName

forceIn = ->
  $("#bottle div").velocity "fadeIn" 
  $("#graph svg rect").velocity "fadeIn" 


toggleDrag = -> 
  $(".drag-btn").toggleClass('is-active')
  dragBool = !dragBool

toggleStagger = -> 
  $(".stagger-btn").toggleClass('is-active')
  staggerBool = !staggerBool
  staggerInt = if staggerBool then 100 else 0

documentKeys = (event) ->
  myKey = event2key[event.which] # Ex : 'p'
  letter = String.fromCharCode(event.charCode)
  console.log event.type, event.which, event.charCode, myKey, letter
  switch myKey
    when "enter", "a"
      refreshAnimation()
    when "left", "s"
      toggleStagger()
    when "right", "d"
      toggleDrag()
    when "esc"
      forceIn()
    when "n", "down"
      nextAnimation()
    when "b", "up"
      prevAnimation()
    when "g"
      toggleGraph()      
    when "r"
      redrawGraph()          
    else

refreshAnimation = ->
  $("#bottle div").velocity(animStr, {stagger: staggerInt, drag: dragBool})
  $("#graph svg rect").velocity(animStr, {stagger: staggerInt, drag: dragBool})

nextAnimation = ->
  $("#uiPackEffects option:selected").next().attr "selected", "selected"
  setAnimation $( "select option:selected" ).val()
  refreshAnimation()

prevAnimation = ->
  $("#uiPackEffects option:selected").prev().attr "selected", "selected"
  setAnimation $( "select option:selected" ).val()
  refreshAnimation()

toggleGraph = =>
  gcs = $("#graph-container-switch")
  if gcs.hasClass("is-graph")
    $("#graph").velocity({ opacity: 0 }, { display: "none" });
    $("#container").velocity({ opacity: 1 }, { display: "inline-block" });
    displayMode = "bottle"
  else 
    $("#container").velocity({ opacity: 0 }, { display: "none" });
    $("#graph").velocity({ opacity: 1 }, { display: "inline-block" });
    displayMode = '"graph'
  gcs.toggleClass("is-graph")


redrawGraph = ->
  if $("#graph-container-switch").hasClass("is-graph")
    $("#graph").velocity({ opacity: 0 }, { display: "none", complete: ->
      d3.selectAll("#graph svg").remove()
      drawRandomChart()
      $("#graph").velocity({ opacity: 1 }, { display: "inline-block" });
     });

toggleInfo = ->
  displayInfoBool = !displayInfoBool
  if displayInfoBool
    $("#info p").velocity({ opacity: 1 }, { display: "inline-block" });
  else
    $("#info p").velocity({ opacity: 0 }, { display: "none" });




drawRandomChart = ->
  w = 600
  h = 200
  topMargin = 100

  barPadding = 5
  dataset = []
  maxValue = 20
  minValue = 2
  for num in [1...20]
    dataset.push( Math.floor(Math.random() * (maxValue - minValue)) + minValue)

  #Create SVG element
  svg = d3.select("#graph")
    .append("svg")
    .attr("width", w)
    .attr("height", h + topMargin)

  svg.selectAll("rect")
    .data(dataset)
    .enter()
    .append("rect")
    .attr("x", (d, i) ->
        i * (w / dataset.length)
      )
    .attr("y", (d) ->
        h - ((d / maxValue) * h)
      )
    .attr("width", w / dataset.length - barPadding)
    .attr("height", (d) ->
        (d / maxValue) * h
      )
    .attr "fill", (d) ->
        v = (d * 10) + 30
        "rgb(#{v}, #{v}, #{v + 10})"

$(document).ready =>

  resizeFit "#bottle"

  drawRandomChart()

  $(document).on('keyup', documentKeys);

  $("#anim").submit (evt) ->
    evt.preventDefault()
    setAnimation $( "input.anim-box" ).val()
    refreshAnimation()

  $("#uiPackEffects").change (evt) ->
    evt.preventDefault()
    setAnimation $( "select option:selected" ).val()
    refreshAnimation()

  $(".serif-btn").click ->
    $("#bottle").toggleClass('sans-serif')

  $(".next-btn").click ->
    nextAnimation()
  $(".prev-btn").click ->
    prevAnimation()

  $(".refresh-btn").click ->
    refreshAnimation()

  $(".force-in-btn").click ->
    forceIn()


  $(".stagger-btn").click ->
    toggleStagger()

  $(".new-graph-btn").click ->
    redrawGraph()

  $(".toggle-info-btn").click ->
    toggleInfo()

