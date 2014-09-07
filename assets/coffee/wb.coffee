#
# You should add the Facebook App ID and the channel url (optional), in the #fb-root element, as a data- attribute:
#   <div id="fb-root" data-app-id="<%= ENV['FACEBOOK_APP_ID'] %>" data-channel-url="<%= url_no_scheme('/channel.html') %>"></div>
#





window.publishHelloWorld = =>
	pageToken = document.getElementById("pageToken").innerHTML
	FB.api "/me/feed", "post",
		message: "Hello, world! #{Math.random(1000)}"
		access_token: pageToken
		, (response) ->
			console.log "API response"
			console.log response
			document.getElementById("publishBtn").innerHTML = "API response is " + response.id


window.pageLogin = =>
	console.log 'loggin'
	FB.api "/me/accounts?fields=name,access_token,link", (response) ->
	  console.log response
	  list = document.getElementById("pagesList")
	  i = 0

	  while i < response.data.length
	    li = document.createElement("li")
	    li.innerHTML = response.data[i].name
	    li.dataset.token = response.data[i].access_token
	    li.dataset.link = response.data[i].link
	    li.className = "btn btn-mini"
	    li.onclick = ->
	      document.getElementById("pageName").innerHTML = @innerHTML
	      document.getElementById("pageToken").innerHTML = @dataset.token
	      document.getElementById("pageLink").setAttribute "href", @dataset.link
	      return

	    list.appendChild li
	    i++
	  console.log "done"
	  return


window.fbAsyncInit = ->
  FB.init
    appId: document.getElementById("fb-root").getAttribute("data-app-id")
    status: true,
    cookie: true,
    xfbml: true
 
  FB.Event.subscribe('auth.login', (response) ->
    window.location = window.location
  )
  FB.Canvas.setAutoGrow()
  FB.getLoginStatus((data) ->
    if (data.status == "connected")
      uid = data.authResponse.userID
      accessToken = data.authResponse.accessToken;
      FB.api("/me", (data) ->
        console.log("Hello #{data.name}")
      )
    else
      if (response.status == "not_authorized")
      # the user is logged in to Facebook,
      # but has not authenticated your app
      else
      # the user isn't logged in to Facebook.
    )
 
PageScript = document.getElementsByTagName("script")[0]
return if document.getElementById("FBScript")
FBScript = document.createElement("script")
FBScript.id = "FBScript"
FBScript.async = true
FBScript.src = "//connect.facebook.net/en_US/all.js"
PageScript.parentNode.insertBefore(FBScript, PageScript)