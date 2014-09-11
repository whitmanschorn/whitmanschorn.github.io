#
# You should add the Facebook App ID and the channel url (optional), in the #fb-root element, as a data- attribute:
#   <div id="fb-root" data-app-id="<%= ENV['FACEBOOK_APP_ID'] %>" data-channel-url="<%= url_no_scheme('/channel.html') %>"></div>
#


App = {}


window.publishHelloWorld = (args) =>
    console.log 'hello world args:'
    console.log args
    FB.api "/#{args.page_id}/feed", "post",
        message: "Hello, world! #{Math.random(1000)}"
        access_token: args.access_token
        , (response) =>
            response.requestArgs = args
            @feed.renderResponse response


window.pageLogin = =>
    FB.api "/me/accounts?fields=name,access_token,link", (response) ->
        list = document.getElementById("pagesList")
        
        if response.error?
            #call attention to the error
            setPageMask('.loadingLogin')
        else if response.data?
            i = 0

            ALWAYS_FIRST_PAGE = true
            #only page? auto-pick
            if response.data.length == 1 or ALWAYS_FIRST_PAGE
                autoSelected = response.data[0]
                document.getElementById("pageName").innerHTML = "<a href=\"" + autoSelected.link + "\">" + "<i class=\"fa fa-facebook-square\"></i>" + "</a> " + autoSelected.name
                initApp(autoSelected.id, autoSelected.access_token)
            else
                while i < response.data.length
                    li = document.createElement("li")
                    li.innerHTML =  "<a href=\"" + response.data[i].link + "\">" + "<i class=\"fa fa-facebook-square\"></i>" + "</a> " + response.data[i].name
                    li.dataset.token = response.data[i].access_token
                    li.dataset.link = response.data[i].link
                    li.dataset.id = response.data[i].id
                    li.className = "btn-mini"
                    li.onclick = ->
                      document.getElementById("pageName").innerHTML = @innerHTML
                      initApp(@dataset.id, @dataset.token)
                      return

                    list.appendChild li
                    i++
        

        return


window.requestPermission = ->
    $('#pageName').text ''
    $('#pageError').text 'Please give this app requested permissions to use it :)'


window.requestLogin = ->
    $('#pageName').text ''
    $('#pageError').text 'Please login to this app to use it :)'


window.setPageMask = (maskSelector) =>
    am = $('.activeMask')
    nm = $( maskSelector + "")
    if $(am)[0] == $(nm)[0]
        console.error "no change in mask"
    else
        #am transition out, nm transition in
        am
            .velocity("transition.flipXOut")
        am.removeClass 'activeMask'
        nm
            .velocity("transition.flipXIn")    
        #add activeMas
        nm.addClass 'activeMask'



window.initApp = (page_id, access_token) =>
    FB.api("/#{page_id}/promotable_posts", (data) =>
                # TODO: THESE ARE OUT POSTS
                if data.data?
                    @feed = new App.FeedCollectionView({collection: new App.FeedCollection( _.map(data.data, (s) -> new App.PostModel(s) ) )})
                    @feed.render()
                    $('#compose-btn').click ->
                        @compose = new App.ComposeView({model: new Backbone.Model({page_id: page_id, access_token: access_token})})
                        @compose.renderComposeSelection()
            )

window.fetchInsightData = (page_id) =>
    console.log 'pid'
    console.log page_id
    FB.api("/#{page_id}/insights/post_impressions?since=1410015034&until=1410315034", (data) ->
                # TODO: THESE ARE OUT POSTS
                if data.error? 
                    data.data = data.error

                if data?
                    console.log data
                    @insighter = new App.PostInsightView(model: new Backbone.Model(data))
                    @insighter.render()
                  
                
            )



window.fbAsyncInit = =>
    FB.init
        appId: document.getElementById("fb-root").getAttribute("data-app-id")
        status: true,
        cookie: true,
        xfbml: true
 
    FB.Event.subscribe('auth.login', (response) ->
        window.location = window.location
    )
    FB.Canvas.setAutoGrow()

    #set state to loading...

    

    FB.getLoginStatus((data) ->
        if(data.status == "connected")
       #     setPageMask('#content') #means no mask
            console.log "connected data"
            console.log data
            uid = data.authResponse.userID
            accessToken = data.authResponse.accessToken;


            FB.api "/me/permissions", (response) ->
                console.log "perms"
                console.log response




            #cry for me i cant get permissions
            #accessToken = 'CAACEdEose0cBAIVIv3zyEOEJdu6I4h91yBN7OvoGtfSirKQjJ1GMCpKY7ZAa48JAKE7tjyz6Gk1etOQHUWEE17REUiEv3zXPoCZBXRAfZBkZCTi0mZCjtFZBZCpkjFazKsJdwUFqfSHPceZBSO89S1ba3RNj2yV5rYRK9iiI1ZCtBWmlnra8E6Y7vXMfDkWTLgDZBiTUmkdUtGdhtdmMe2E2ar'
            FB.api("/me", (data) ->
                # TODO: INITIALIZE APP HERE.
                setPageMask('.content')





                pageLogin()
                
            )

        else if (data.status == "not_authorized")
           # requestPermission()
            setPageMask('.loadingPermission')

          # the user is logged in to Facebook,
          # but has not authenticated your app  
        else
            setPageMask('.loadingLogin')
          #  requestLogin()
          # the user isn't logged in to Facebook.       
        )

    
PageScript = document.getElementsByTagName("script")[0]
return if document.getElementById("FBScript")
FBScript = document.createElement("script")
FBScript.id = "FBScript"
FBScript.async = true
FBScript.src = "//connect.facebook.net/en_US/all.js"
PageScript.parentNode.insertBefore(FBScript, PageScript)