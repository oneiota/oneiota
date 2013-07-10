$ ->

  $('html').hide().fadeTo(500,1)

  ImageLoader = ->
    @loadArray = []
    @screenSize = (if (screen.width > 768) then 'desktop' else 'mobile')


  imageLoader = new ImageLoader()

  imageLoader.imageLoaded = (img) ->
    $(img).hide().addClass('articleimage')
    @.placeholder = $('img.notloaded').eq(0)
    # Add loaded image after placeholder -> then remove notloaded class -> add loaded
    @.placeholder.after($(img))
    @.placeholder.addClass('loaded').removeClass('notloaded')
    @.placeholder.waypoint
      triggerOnce: true
      offset: '75%'
      handler: (direction) ->
        nextSpan = $(this).prev('span')
        nextImg = $(this).next('.articleimage')
        $(this).addClass('scaleOut')
        $(nextSpan).addClass('scaleOut')
        $(nextImg).delay(200).fadeIn()

  imageLoader.loadImages = ->
  #unless @isLoading
    if @.loadArray.length isnt 0
      @.isLoading = true
      imgItem = @.loadArray.shift()
      img = new Image()
      timer = undefined

      img.src = imgItem.imgSrc;
      img.title = img.alt = imgItem.imgTitle;

      if img.complete or img.readyState is 4
        @.imageLoaded img
        @.loadImages()  if imgItem.length isnt 0
      else
        # handle 404 using setTimeout set at 10 seconds, adjust as needed
        timer = setTimeout(->
          imageLoader.loadImages()  if imgItem.length isnt 0
          $(img).unbind 'error load onreadystate'
        , 10000)
        $(img).bind 'error load onreadystatechange', (e) ->
          clearTimeout timer
          if e.type isnt 'error'
            imageLoader.imageLoaded img
            imageLoader.loadImages()  if imgItem.length isnt 0

  imageLoader.addImages = ->
    $('img.notloaded').each (index) ->
      imgItem = {}
      imgItem.imgSrc = $('img.notloaded').eq(index).data(imageLoader.screenSize)
      imgItem.imgTitle = $('img.notloaded').eq(index).attr('alt')
      imageLoader.loadArray.push(imgItem)

    @.loadImages()

  #Index Specific

  if $('.index').length

    ## New Constructors
    WaypointCheck = ->
      @articesLoaded = false
      @isLoading = false
      @current = 0
      @projects

    waypointCheck = new WaypointCheck()

    ## Functions
    
    ## Reset when content is loaded in

    waypointCheck.resetWaypoints = ->
      @.assignArticleWaypoints()

    ## Assign Waypoints
    waypointCheck.assignArticleWaypoints = ->
      $('article:gt(0)').waypoint
        triggerOnce: false
        offset: '100%'
        handler: (direction) ->
          if direction is 'down'
            waypointCheck.updateTitle(@id)
          else
            articleIndex = ($('article').index($('#' + @id)) - 1)
            waypointCheck.updateTitle($('article').eq(articleIndex).attr('id'))

      $('article').eq(($('article').size() - 2)).waypoint
        triggerOnce: true
        offset: 'bottom-in-view'
        handler: (direction) ->
          if direction is 'down'
            unless waypointCheck.articesLoaded
              waypointCheck.loadArticles()
            else
              waypointCheck.appendArticles()

    waypointCheck.updateTitle = (articleId) -> 
      # Update page title
      currentArticle = $('#'+ articleId)
      currentIndex = currentArticle.index()
      projectSlug = currentArticle.attr('id')
      projectTitle = currentArticle.data('title')
      newTitle = 'Iota | ' + projectTitle
      $('title').html(newTitle)
      $('.top-hud ul li').removeClass('active scaleIn slideIn')
      $('.top-hud ul li').eq(currentIndex-1).addClass('scaleIn')
      $('.top-hud ul li').eq(currentIndex).addClass('active slideIn')
      history.replaceState(null, projectTitle, projectSlug)

    waypointCheck.loadArticles = (articleIds) ->
      $.get '/articles', (data) ->
        waypointCheck.articesLoaded = true
        waypointCheck.projects = $(data).filter('article')
        waypointCheck.appendArticles()

    waypointCheck.appendArticles = ->
      if @projects.length >= 2
        nextArticles = @projects.splice(0,2)
        $('.main').append nextArticles
        @.resetWaypoints()
        imageLoader.addImages()
      else if @projects.length == 1
        nextArticle = @projects.splice(0,1)
        $('.main').append nextArticle
        @.resetWaypoints()
        imageLoader.addImages()
      else
        console.log 'no more articles'

    #Index specific startup functions
    waypointCheck.assignArticleWaypoints()

  #Site wide startup functions
  imageLoader.addImages()