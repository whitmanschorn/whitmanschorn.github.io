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

	render: =>
		@$el.html postComposeTemplate({})
		@$el

	submitPost: (ts = 0) ->
		page_id = @model.get('page_id')
		postObject = {}
		postObject.message = $('#compose-message').text #for a bunch of fields. 
		if not postObject.message?
			postObject.link = $('#compose-link').text
			postObject.name = $('#compose-name').text #title in link preview
			postObject.caption = $('#compose-caption').text
			postObject.description = $('#compose-description').text




		if ts = 0
			console.log 'defaulting to now'
			ts = moment() #defaults to now
		

	renderComposeSelection: ->
		$('#app-right').velocity("transition.slideUpOut", 
			duration: 150,
			complete: =>
				fetchInsightData(@model.get('id'))
				$('#post-detail').empty()
				$('#post-detail').append @render()
				$('#app-right').velocity("transition.slideUpIn", {stagger: 100}))






class App.FeedCollectionView extends Backbone.View

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
	



