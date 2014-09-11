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
		console.log @model.toJSON
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


	initialize: ->
		$('.post-list li').click @unselect

	events:
		'click #compose-switch' : 'composeSwitch'
		'click #compose-post' : 'composePost'
		'click #compose-schedule' : 'composeSchedule'
		'click #compose-cancel' : 'composeCancel'
		

	select: ->
		$('.post-list li.selected').removeClass 'selected'
		$('#compose-btn').addClass 'selected'

	unselect: ->
		$('#compose-btn').removeClass 'selected'

	composeSwitch: ->
		console.log 'switch fired'	

	composePost: ->
		console.log 'post fired'	

	composeSchedule: ->
		console.log 'schedule fired'	

	composeCancel: ->
		console.log 'cancel fired'	
		@unselect()
		$('#post-detail').empty()
		$('.insight-section').empty()



	render: =>
		@select()
		@$el.html postComposeTemplate({})
		@$el

	submitPost: (ts = 0) ->
		page_id = @model.get('page_id')
		postArgs = {}
		postArgs.message = $('#compose-message').text #for a bunch of fields. 
		if not postArgs.message?
			postArgs.link = $('#compose-link').text
			postArgs.picture = $('#compose-picture').text
			postArgs.name = $('#compose-name').text #title in link preview
			postArgs.caption = $('#compose-caption').text
			postArgs.description = $('#compose-description').text


		if ts = 0
			console.log 'defaulting to now'
			ts = moment() #defaults to now
		

	renderComposeSelection: ->
		$('#app-right').velocity("transition.slideUpOut", 
			duration: 150,
			complete: =>
				$('.insight-section').empty()
				$('#post-detail').empty()
				$('#post-detail').append @render()
				$('#app-right').velocity("transition.slideUpIn", {stagger: 100}))






class App.FeedCollectionView extends Backbone.View

	renderResponse: (res) ->
		if res.error?
			console.error res.error

		console.log "WOO"
		console.log res
		#create new view + model + add to collection here

	render: ->
		$('.post-list').empty()
		@collection.each (post) =>
			postR = switch
				when post.get('type') is 'status' then new App.PostStatusView({model: post})
				when post.get('type') is 'photo' then new App.PostPhotoView({model: post})
				when post.get('type') is 'video' then new App.PostPhotoView({model: post})
				else null
			$('.post-list').append postR.render()

		$('.post-list li').velocity("transition.flipYIn", {stagger: 100})
	



