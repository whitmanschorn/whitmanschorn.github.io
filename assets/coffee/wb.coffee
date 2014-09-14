#
# You should add the Facebook App ID and the channel url (optional), in the #fb-root element, as a data- attribute:
#   <div id="fb-root" data-app-id="<%= ENV['FACEBOOK_APP_ID'] %>" data-channel-url="<%= url_no_scheme('/channel.html') %>"></div>
#


App = {}

window.deletePost = (post_id, page_access_token) =>
    FB.api "/#{post_id}?access_token=#{page_access_token}", "delete", (response) =>
        response.post_id = post_id
        @controls.feed.finishPostDelete response

window.publishHelloWorld = (args) =>
    FB.api "/#{args.page_id}/feed?", "post", args, (response) =>
        response.requestArgs = args
        @controls.feed.renderPostResponse response

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
                #$(window).on('refreshFeed', initApp(autoSelected.id, autoSelected.access_token))
                initApp(autoSelected.id, autoSelected.access_token)

                #bind refresh

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
        am.velocity("transition.flipXOut")
        am.removeClass 'activeMask'
        nm.velocity("transition.flipXIn")    
        nm.addClass 'activeMask'



window.initApp = (page_id, access_token) =>
    FB.api("/#{page_id}/promotable_posts", (data) =>
                # TODO: THESE ARE OUT POSTS
                if data.data?
                    @controls = new App.PageController data, access_token, page_id

            )
window.paginateFeed = (pagination_string) =>
    pagination_strings = pagination_string.split('/')
    pagination_string = pagination_strings[4] + "/" + pagination_strings[5]
    FB.api("#{pagination_string}", (data) =>
                if data.data?
                    @controls.paginate data
            )


window.fetchInsightData = (page_id) =>
    FB.api("/#{page_id}/insights/post_impressions,post_impressions_unique,post_impressions_fan,post_impressions_fan_unique", (data) ->
                # TODO: More error handling?
                if data.error? 
                    data.data = data.error

                if data?
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
            uid = data.authResponse.userID
            accessToken = data.authResponse.accessToken;


            # FB.api "/me/permissions", (response) ->
            #     console.log "perms"
            #     console.log response

            setPageMask('.content')
            pageLogin()
  
        else if (data.status == "not_authorized")
            # user has not authenticated your app  
            setPageMask('.loadingPermission')
        else
            setPageMask('.loadingLogin')
            # user isn't logged in to Facebook.       
        )

    
PageScript = document.getElementsByTagName("script")[0]
return if document.getElementById("FBScript")
FBScript = document.createElement("script")
FBScript.id = "FBScript"
FBScript.async = true
FBScript.src = "//connect.facebook.net/en_US/all.js"
PageScript.parentNode.insertBefore(FBScript, PageScript)