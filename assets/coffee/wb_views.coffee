Handlebars.registerHelper "relativeTime", (timeString) ->
  moment(timeString).fromNow()


window.renderData = =>
	$('body').append(template(data));


class App.PostModel extends Backbone.Model

	initialize: (options) ->
		#find our useful timestamp
		if options.is_published? and options.is_published is false
			@set('timestamp', options.scheduled_publish_time * 1000)
		else
			@set('timestamp', options.updated_time)






class App.PostView extends Backbone.View
	className: 'post-bar'
	tagName: 'li'

	initialize: ->
		_.bindAll(@, 'selectPost')


	events:
		'click' : 'selectPost'


	selectPost: ->
		if not @$el.hasClass 'selected'
			@$el.siblings().removeClass('selected')
			@$el.addClass 'selected'
			@renderPostSelection()

	renderPostSelection: ->
		detail = new App.PostDetailView({model: @model})

		$('#app-right').velocity("transition.slideUpOut", 
			duration: 150,
			complete: =>
				fetchInsightData(@model.get('id'))
				$('#post-detail').empty()
				$('#post-detail').append detail.render()
				$('#app-right').velocity("transition.slideUpIn", {stagger: 100}))


			

class App.PostInsightView extends Backbone.View
	postInsightTemplate = Handlebars.compile($('#post-insight-template').html())
	className: 'insight-view'


	render: =>
		@$el.html postInsightTemplate(@model.get('data')[0])
		$('.insight-section').empty()
		$('.insight-section').append @$el
		@$el
		

class App.PostDetailView extends Backbone.View
	postDetailTemplate = Handlebars.compile($('#post-detail-template').html())

	render: =>
		sm = JSON.stringify(@model.toJSON(), null, 4)
		@model.set('blob', sm)
		@$el.html postDetailTemplate(@model.toJSON())
		@$el


class App.PostStatusView extends App.PostView
	postStatusTemplate = Handlebars.compile($('#status-post-template').html())

	render: =>
		if not @model.get('message')
			@model.set('message', @model.get('story'))
		@$el.html postStatusTemplate( @model.toJSON() )
		@$el


class App.PostPhotoView extends App.PostView
	postPhotoTemplate = Handlebars.compile($('#photo-post-template').html())

	render: =>
		if not @model.get('story')
			@model.set('story', @model.get('message'))
		@$el.html postPhotoTemplate( @model.toJSON() )
		@$el

class App.FeedCollection extends Backbone.Collection



class App.ComposeView extends Backbone.View
	postComposeTemplate = Handlebars.compile($('#post-compose-template').html())


	initialize: =>
		$('.post-list li').click @unselect
		@isURL = true

	events: ->
		'click .compose-switch' : 'composeSwitch'
		'click .compose-post' : 'composePost'
		'click .compose-schedule' : 'composeSchedule'
		'click .compose-cancel' : 'composeCancel'

		

	select: ->
		$('.post-list li.selected').removeClass 'selected'
		$('#compose-btn').addClass 'selected'

	unselect: ->
		$('#compose-btn').removeClass 'selected'

	composeSwitch: =>
		@isURL = not @isURL

		$('#post-detail').velocity("transition.slideUpOut", 
			duration: 150,
			complete: =>
				$('#post-detail').append @render()
				$('#post-detail').velocity("transition.slideUpIn", duration: 100)

				)



	composePost: ->
		@submitPost()

	composeSchedule: ->
		console.log 'schedule fired'	

	composeCancel: ->
		@unselect()
		$('#post-detail').empty()
		$('.insight-section').empty()



	render: =>
		@select()
		@$el.html postComposeTemplate({isURL: @isURL})
		@$el

	submitPost: (ts = 0) =>
		postArgs = {page_id : @model.get('page_id')}
		postArgs.access_token = @model.get('access_token')
		if @isURL
			postArgs.link = $('#compose-link').val()
			postArgs.picture = $('#compose-picture').val()
			postArgs.name = $('#compose-name').val() #title in link preview
			postArgs.caption = $('#compose-caption').val()
			postArgs.description = $('#compose-description').val()
		else
			postArgs.message = $('#compose-message').val() #for a bunch of fields. 


		if not (postArgs.message? or postArgs.link?)
			console.error 'need to complete post before submitting'


		if ts = 0
			console.log 'defaulting to now'
			ts = moment() #defaults to now
		publishHelloWorld postArgs
		

	renderComposeSelection: ->
		$('#app-right').velocity("transition.slideUpOut", 
			duration: 150,
			complete: =>
				$('.insight-section').empty()
				$('#post-detail').html @render({isURL: @isURL})
				$('#app-right').velocity("transition.slideUpIn", {stagger: 100, duration: 100}))






class App.FeedCollectionView extends Backbone.View

	populatePostModel: (args) ->

		
		return new App.PostModel(
			id: args.id
			)

	renderResponse: (res) ->
		if res.error?
			console.error res.error
			alert 'Publishing failed!'

		# console.log "response from post:"
		# console.log res
		# console.log res.requestArgs
		if res.requestArgs.message? 
			postType = 'status'
			story = res.requestArgs.message

		else
			postType = 'link'
			story = res.requestArgs.title

		console.log 'post type: '
		console.log postType
		newModel = new App.PostModel({id: res.id, type: postType, story: story, ts: moment().unix()})
		@collection.unshift newModel
		@render()
		#newPost.renderPostSelection()
		#create new view + model + add to collection here

	render: ->
		$('.post-list').empty()
		@collection.each (post) =>
			console.log post.get('type')
			postR = switch
				when post.get('type') is 'status' then new App.PostStatusView({model: post})
				when post.get('type') is 'link' then new App.PostStatusView({model: post})
				when post.get('type') is 'photo' then new App.PostPhotoView({model: post})
				when post.get('type') is 'video' then new App.PostPhotoView({model: post})
				else new App.PostStatusView({model: post})
			$('.post-list').append postR.render()

		$('.post-list li').velocity("transition.flipYIn", {stagger: 100})
	



