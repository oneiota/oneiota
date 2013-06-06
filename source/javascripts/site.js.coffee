$ ->

  ## Site variables
  articleCounter = 0
  #projects = window.projects

  ## New Constructors
  WaypointCheck = ->
    @articesLoaded = false
    @current = 0
    @projects

  waypointCheck = new WaypointCheck()

  waypointCheck.updateTitle = (articleId) -> 
    # Update page title
    projectTitle = $('#'+ articleId).data('title')
    $('title').html('Iota &#124; ' + projectTitle)

  waypointCheck.loadArticles = (articleIds) ->
    $.get "/articles", (data) ->
      waypointCheck.articesLoaded = true
      waypointCheck.projects = $(data).filter("article")
      waypointCheck.appendArticles()

  waypointCheck.appendArticles = ->
    if @projects.length >= 2
      nextArticles = @projects.splice(0,2)
      $(".main").append nextArticles
      @.resetWaypoints()
    else if @projects.length == 1
      nextArticle = @projects.splice(0,1)
      $(".main").append nextArticle
      @.resetWaypoints()
    else
      console.log 'no more articles'

  ## Assign Waypoints
  waypointCheck.assignWaypoints = ->
    # Title change handler
    $('article').waypoint ((direction) ->
      if direction == 'down'
        waypointCheck.updateTitle(@id)
      else
        waypointCheck.updateTitle($.waypoints('above')[0].id)
    ),
      offset: '100%' #'bottom-in-view'
      triggerOnce: false

    # Page ajax handler
     $('article').eq(($('article').size() - 2)).waypoint ((direction) ->
       if direction == 'down'
        if !waypointCheck.articesLoaded
          waypointCheck.loadArticles()
        else
          waypointCheck.appendArticles()
     ),
      offset: 'bottom-in-view'
      triggerOnce: false

  ## Reset when content is loaded in
  waypointCheck.resetWaypoints = ->
    $.waypoints('destroy')
    @.assignWaypoints()

  waypointCheck.assignWaypoints()
