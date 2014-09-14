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

	initialize: ->
		dataset = @model.get('data') 
		all_impressions = dataset[0].values[0].value
		all_reach = dataset[1].values[0].value
		fan_impressions = dataset[2].values[0].value
		fan_reach = dataset[3].values[0].value
		nonfan_reach = all_reach - fan_reach
		nonfan_impressions= all_impressions - fan_impressions

		@fan_engagement = @percentify fan_impressions/all_impressions
		@fan_saturation = @percentify fan_reach/all_reach
		@fan_affinity = @percentify (( (fan_impressions / fan_reach)   /  (nonfan_impressions / nonfan_reach) ))
		if all_reach * all_impressions == 0
			@fan_engagement = @fan_saturation = ""
		if fan_reach * nonfan_reach == 0
			@fan_affinity = ""

	percentify: (num) ->
		(num * 100).toPrecision(4) + "%"	
		
	render: =>
		@$el.html postInsightTemplate(dataset: @model.get('data'), fan_engagement: @fan_engagement, fan_saturation: @fan_saturation, fan_affinity: @fan_affinity)
		$('.insight-section').empty()
		$('.insight-section').append @$el
		@$el
		

class App.PostDetailView extends Backbone.View
	postDetailTemplate = Handlebars.compile($('#post-detail-template').html())


	events:
		'click .detail-delete' : 'postDelete'


	postDelete: =>
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
		if data.paging?
			@paginate(data, access_token)
		$('#compose-btn').click ->
			@compose = new App.ComposeView({model: new Backbone.Model({page_id: page_id, access_token: access_token})})
			@compose.renderComposeSelection()
		

	assignPagination: (paging) ->
		$('#next-btn').unbind 'click'
		$('#prev-btn').unbind 'click'

		$('#next-btn').click =>
			paginateFeed paging.next
		$('#prev-btn').click =>
			paginateFeed paging.previous


	paginate: (data, access_token) =>
		if data.data.length
			@feed = new App.FeedCollectionView({collection: new App.FeedCollection( _.map(data.data, (s) => 
				tempModel = new App.PostModel(s)
				tempModel.set('page_access_token', access_token)
				tempModel ) )})
			@pageNumberEl.text moment(@feed.collection.at(0).get('timestamp')).format('ha, MMM DD YYYY')
			$('#pagination-label').velocity("callout.pulse", duration: 100)
			
		
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
		$('.schedule-controls').toggleClass 'visible'
		if @isScheduling
			@dpi = $('.datepicker').pickadate({
				container: '#schedule-root'
				})
			@tpi = $('.timepicker').pickatime({
				container: '#schedule-root'
				})


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
			inputDate = $('.datepicker').val()
			dateString = if inputDate is '' then moment().format('DD MMM, YYYY') else inputDate
			schedString = dateString + " " + $('.timepicker').val()
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
		if not res.success
			alert 'Post deletion failed. Please refresh the page and try again.'
		else
			@collection.remove @collection.get(res.post_id)
			$("[data-pid=\"#{res.post_id}\"]").parent().velocity('transition.slideUpOut',
				complete: ->
					$("[data-pid=\"#{res.post_id}\"]").parent().remove()
					)
			
	renderPostResponse: (res) ->
		if res.error?
			console.error res.error
			alert res.error.error_user_msg
			return

		ts = if res.requestArgs.scheduled_publish_time? then res.requestArgs.scheduled_publish_time else if res.requestArgs.backdated_time? then res.requestArgs.backdated_time else moment().unix()
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
	



