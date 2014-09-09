
Handlebars.registerHelper "fullName", (person) ->
  person.firstName + " " + person.lastName


Handlebars.registerHelper "relativeTime", (timeString) ->
  moment(timeString).fromNow()



window.renderData = =>
	$('body').append(template(data));


class App.PostModel extends Backbone.Model



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
			complete: ->
				$('#post-detail').empty()
				$('#post-detail').append detail.render()
				$('#app-right').velocity("transition.slideUpIn", {stagger: 100}))
			




class App.PostInsightView extends Backbone.View
	postInsightTemplate = Handlebars.compile($('#post-insight-template').html())
	className: 'insight-view'

	render: =>
		@$el.html postInsightTemplate({ insight: @model.get('insight') })
		$('.insight-section').empty()
		$('.insight-section').append @$el
		@$el
		




class App.PostDetailView extends Backbone.View
	postDetailTemplate = Handlebars.compile($('#post-detail-template').html())


	render: =>
		fetchInsightData()
		@$el.html postDetailTemplate({ blob: JSON.stringify(@model.toJSON(), null, 4) })
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




