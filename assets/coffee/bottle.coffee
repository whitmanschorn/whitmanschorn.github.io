# Whitman Schorn 2014
dragBool = false;
staggerBool = true;
staggerInt = 20;
event2key =
  97: "a"
  66: "b"
  99: "c"
  68: "d"
  101: "e"
  102: "f"
  103: "g"
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
  114: "r"
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

resizeFit = (selector) -> 
  $(selector).bigtext()


setAnimation = (animationName) ->
  console.log "setting #{animationName}"
  animStr = animationName


forceIn = ->
  $("#bottle div").velocity "fadeIn" 

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
    when "n"
      nextAnimation()
    when "b"
      prevAnimation()
    else

refreshAnimation = ->
  $("#bottle div").velocity(animStr, {stagger: staggerInt, drag: dragBool})

nextAnimation = ->
  $("#uiPackEffects option:selected").next().attr "selected", "selected"
  setAnimation $( "select option:selected" ).val()
  refreshAnimation()

prevAnimation = ->
  $("#uiPackEffects option:selected").prev().attr "selected", "selected"
  setAnimation $( "select option:selected" ).val()
  refreshAnimation()



$(document).ready ->

  console.log "Hello 2 world"
  resizeFit "#bottle"


  $(document).on('keyup', documentKeys);

  $("#anim").submit (evt) ->
    evt.preventDefault()
    setAnimation $( "input.anim-box" ).val()
    refreshAnimation()

  $("#uiPackEffects").change (evt) ->
    evt.preventDefault()
    setAnimation $( "select option:selected" ).val()
    refreshAnimation()

  # $(".border-btn").click ->
  #   console.log "hey"
  #   $("#bottle").toggleClass("border")

  $(".next-btn").click ->
    nextAnimation()

  $(".refresh-btn").click ->
    refreshAnimation()


  $(".force-in-btn").click ->
    forceIn()


  $(".stagger-btn").click ->
    toggleStagger()
