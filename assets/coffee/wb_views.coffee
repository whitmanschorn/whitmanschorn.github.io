Handlebars.registerHelper "relativeTime", (timeString) ->
  moment(timeString).fromNow()

Handlebars.registerHelper "prettifyURL", (link) ->
	url = link.split('/')
	ans = url[2]
	ans = ans.replace('www.', '')
	ans


window.renderData = =>
	$('body').append(template(data));


class App.PostModel extends Backbone.Model

	initialize: (options) ->
		#find our useful timestamp
		if not @get('timestamp')?
			console.log 'override ts'
			if options.is_published? and options.is_published is false
				@set('timestamp', options.scheduled_publish_time * 1000)
			else
				@set('timestamp', options.updated_time)



class App.PostView extends Backbone.View
	className: 'post-bar bar'
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


	events:
		'click .detail-delete' : 'postDelete'


	postDelete: ->
		console.log 'hitting delete'
		console.log @model.get('page_access_token')
		deletePost(@model.get('id'), @model.get('page_access_token'))
		@emptyDetailView()

	emptyDetailView: ->
		$('#post-detail').empty()
		$('.insight-section').empty()


	render: =>
		sm = JSON.stringify(@model.toJSON(), null, 4)
		@model.set('is_image', @model.get('type') is 'image')
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



class App.PageController extends Backbone.View

	initialize: (data, access_token, page_id) ->
		@pageNumber = 1
		@pageNumberEl = $('.page-number')
		@paginate(data, access_token)
		$('#compose-btn').click ->
			@compose = new App.ComposeView({model: new Backbone.Model({page_id: page_id, access_token: access_token})})
			@compose.renderComposeSelection()
		

	assignPagination: (paging) ->
		$('#next-btn').unbind 'click'
		$('#prev-btn').unbind 'click'

		$('#next-btn').click =>
			@pageNumber++
			paginateFeed paging.next
		$('#prev-btn').click =>
			@pageNumber--
			paginateFeed paging.previous


	paginate: (data, access_token) =>
		@pageNumberEl.text @pageNumber
		@feed = new App.FeedCollectionView({collection: new App.FeedCollection( _.map(data.data, (s) => 
			tempModel = new App.PostModel(s)
			tempModel.set('page_access_token', access_token)
			tempModel ) )})
		if data.paging?
			@assignPagination data.paging

		@feed.render()

class App.ComposeView extends Backbone.View
	postComposeTemplate = Handlebars.compile($('#post-compose-template').html())


	initialize: =>
		$('.post-list li').click @unselect
		@isURL = false
		@isScheduling = false
		$(window).on('sucessfulPost', @composeCancel)

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


	composeSchedule: ->
		@isScheduling = not @isScheduling
		$('.compose-schedule').toggleClass 'is-active'
		$('#post-detail').append @render()
		if @isScheduling
			@dpi = $('.datepicker').pickadate({
				container: '#schedule-root'
				})
			@tpi = $('.timepicker').pickatime({
				container: '#schedule-root'
				})

		# picker = input.pickadate('picker')
		# picker.open()
		# console.log 'woah done'

	composePost: ->
		@submitPost()


	composeCancel: =>
		@unselect()
		$('#post-detail').empty()
		$('.insight-section').empty()


	readPostArgs: =>
		postArgs = {page_id : @model.get('page_id')}
		postArgs.access_token = @model.get('access_token')
		#determine timing
		if @isScheduling
			schedString = $('.datepicker').val() + " " + $('.timepicker').val()
			schedMoment = moment(schedString, 'DD MMM, YYYY h:mma')
			schedTimestamp = schedMoment.unix()
			nowMoment = moment()
			diffAmount = nowMoment.diff(schedMoment, 'minutes')
			if diffAmount < -10
				postArgs.scheduled_publish_time = schedTimestamp
				postArgs.published = false
			else if diffAmount > 1
				postArgs.backdated_time = schedTimestamp
		#determine post
		if @isURL
			postArgs.link = $('#compose-link').val()
			postArgs.picture = $('#compose-picture').val()
			postArgs.name = $('#compose-name').val() #title in link preview
			postArgs.caption = $('#compose-caption').val()
			postArgs.description = $('#compose-description').val()
		else
			postArgs.message = $('#compose-message').val() #for a bunch of fields. 

		postArgs


	render: =>
		@select()
		@$el.html postComposeTemplate({isURL: @isURL, isScheduling: @isScheduling})
		@$el

	submitPost: (ts = 0) =>

		postArgs = @readPostArgs()

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

	finishPostDelete: (res) ->
		console.log 'post deletion result'
		console.log res
		if not res.success
			alert 'Post deletion failed.'
		else
			@collection.remove @collection.get(res.post_id)
			@render()


	renderPostResponse: (res) ->
		if res.error?
			console.error res.error
			alert res.error.error_user_msg
			return

		ts = res.requestArgs.scheduled_publish_time
		console.log 'res args now'
		console.log res.requestArgs


		if not ts?
			ts = res.requestArgs.backdated_time
		if not ts? 
			ts = moment().unix()
		console.log 'ts now'
		ts = ts * 1000

		if res.requestArgs.message? 
			postType = 'status'
			story = res.requestArgs.message

		else
			postType = 'link'
			story = res.requestArgs.name
			message = res.requestArgs.name


		newModel = new App.PostModel({id: res.id, type: postType, story: story, message: message, timestamp: ts})
		$(window).trigger("sucessfulPost", newModel);
		@collection.unshift newModel
		@render()
		#newPost.renderPostSelection()
		#create new view + model + add to collection here

	render: ->
		$('.post-list').empty()
		@collection.each (post) =>
			postR = switch
				when post.get('type') is 'status' then new App.PostStatusView({model: post})
				when post.get('type') is 'link' then new App.PostStatusView({model: post})
				when post.get('type') is 'photo' then new App.PostPhotoView({model: post})
				when post.get('type') is 'video' then new App.PostPhotoView({model: post})
				else new App.PostStatusView({model: post})
			$('.post-list').append postR.render()

		$('.post-list li').velocity("transition.flipYIn", {stagger: 100})
	



