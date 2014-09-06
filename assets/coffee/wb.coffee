updateStatusCallback = ->
  alert "Status updated!!"
  return

# Your logic here
startLogin = ->
	FB.login (->
	  FB.api "/me/feed", "post",
	    message: "Hello, world!"
	),
	  scope: "publish_actions"


showAccountInfo = ->
  FB.api "/me?fields=name,picture", (response) ->
    Log.info "API response", response
    document.getElementById("accountInfo").innerHTML = ("<img src=\"" + response.picture.data.url + "\"> " + response.name)
    return

  document.getElementById("loginBtn").style.display = "none"
  return
FB.Event.subscribe "auth.statusChange", (response) ->
  Log.info "Status Change Event", response
  if response.status is "connected"
    showAccountInfo()
  else
    document.getElementById("loginBtn").style.display = "block"
  return

FB.getLoginStatus (response) ->
  Log.info "Login Status", response
  if response.status is "connected"
    showAccountInfo()
  else
    document.getElementById("loginBtn").style.display = "block"
  return
