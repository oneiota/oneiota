#= require waypoints2.0.2.min
#= require jquery-ui-1.9.2.custom
#= require jquery.ui.touch-punch.min
#= require jquery.color-2.1.2.min
#= require feed
#= require intro

window.isTouch = if ($('html').hasClass('touch')) then true else false
window.isCanvas = if ($('html').hasClass('canvas')) then true else false
window.isIndex = if $('body').hasClass('index') then true else false
window.isFeed = if $('body').hasClass('feed') then true else false
window.isPortfolio = if $('body').hasClass('portfolio') then true else false
window.isBlood = if $('body').hasClass('blood') then true else false
window.isSingle = if $('body').hasClass('singleProject') then true else false
window.isRetina = if window.devicePixelRatio > 1 then true else false
window.mapLoaded = false

## New Constructors

HistoryController = ->
  @slugArray = []
  @popped = false 
  @prevSlug
  @currSlug
  @inMenu
  @scrollingBack = false

historyController = new HistoryController()

WaypointCheck = ->
  @filteredItems = []
  @articesLoaded = false
  @isLoading = false
  @currentProject = 0
  @nextProject
  @hudTimer
  @currentDirection
  @projectSlug = $('article:eq(0)').attr('id')
  @projectTitle = $('article:eq(0)').data('title')
  @ogfg = $('article:eq(0)').data('foreground')
  @ogbg = $('article:eq(0)').data('background')
  @lastProject = $('article').length - 1
  @lastFg
  @projects
  @showArrow
  @hideArrow
  @resetArrow
  @footerOpen = false
  @lastIndex = 0
  @arrowTab = '<div class="arrow-tab"><a href="#"></a><span>'

waypointCheck = new WaypointCheck()

ImageLoader = ->
  @loadArray = []
  @screenSize = if (screen.width > 880) then 'desktop' else 'mobile'
  @loadTimer = null
  @retryLoad = false

imageLoader = new ImageLoader()

MainMenu = ->
  @ogbg = '#262626'
  @ogfg = '#ffffff'

mainMenu = new MainMenu()

ObjectLoader = ->
  @fadeArray = ['fadeInSlide','fadeInSlideR','fadeInSlideL']
  @lastFade
  if window.isBlood
    @objectTarget = 'section'
    @objectSubTarget = '.content'
  else
    @objectTarget = 'article'
    @objectSubTarget = '.project'

objectLoader = new ObjectLoader()

CanvasArrow = (location, arrowWidth) ->
  element = document.createElement('canvas')
  $(element) 
    .attr('width', arrowWidth + 40).attr('height', '40')

  if arrowWidth >= 160
    arrowWidth = Math.abs(arrowWidth - 160)
  else
    arrowWidth = Math.abs(arrowWidth - 160) * -1

  context = element.getContext("2d")
  context.fillStyle = waypointCheck.ogfg
  context.bezierCurveTo((179.965+arrowWidth),0.945,(177.65+arrowWidth),0,(176+arrowWidth),0)
  context.lineTo((171+arrowWidth),0)
  context.lineTo(7,0)
  context.bezierCurveTo(3.15,0,0,3.15,0,7)
  context.lineTo(0,33)
  context.bezierCurveTo(0,36.85,3.15,40,7,40)
  context.lineTo((171+arrowWidth),40)
  context.lineTo((176+arrowWidth),40)
  context.bezierCurveTo((177.65+arrowWidth),40,(179.965+arrowWidth),39.055,(181.143+arrowWidth),37.9)
  context.lineTo((197.269+arrowWidth),22.1)
  context.bezierCurveTo((198.447+arrowWidth),20.945,(198.447+arrowWidth),19.055,(197.269+arrowWidth),17.9)
  context.closePath()
  context.fill()

  return element

waypointCheck.updateColors = (foreground, background) ->
  waypointCheck.lastFg = foreground
  if waypointCheck.footerOpen
    closeColor = background
  else
    closeColor = foreground
  $('nav').stop().animate({
    color: foreground
  }, 500 )
  $('.indexNav .icon-info').stop().animate({
    color: closeColor
  }, 500 )
  $('.navCounters .navPanel').stop().animate({
    backgroundColor: background
  }, 500 )
  if window.isCanvas
    waypointCheck.updateCanvas()

waypointCheck.endofline = (foreground) ->
  $('.indexNav .icon-info').stop().animate({
    color: foreground
  }, 500 )

waypointCheck.makeCanvas = ->
  $('.navCounters ul li .arrow-tab').each(-> 
    liWidth = $(this).width()
    liIndex = $(this).parent().index()
    canvasArrow = new CanvasArrow(liIndex, liWidth)
    $(canvasArrow)
      .addClass('canvasArrow')
      .text('unsupported browser')
      .appendTo($(this))
  )

waypointCheck.updateCanvas = ->
  $('.arrow-tab').css({'color':waypointCheck.ogbg})
  $('.canvasArrow').remove()
  waypointCheck.makeCanvas()

window.initialiseMaps = () ->
  
  MY_MAPTYPE_ID = 'custom_style';

  mapOptions =
    zoom: 16
    center: new google.maps.LatLng(-27.45480, 153.03905)
    disableDefaultUI: true
    zoomControl: false
    scrollwheel: false
    navigationControl: false
    mapTypeControl: false
    scaleControl: false
    draggable: if window.isTouch and imageLoader.screenSize is 'mobile' then false else true
    backgroundColor: '#262626'
    zoomControlOptions:
      style: google.maps.ZoomControlStyle.SMALL
      position: google.maps.ControlPosition.TOP_RIGHT
    mapTypeControlOptions: {
      mapTypeIds: [google.maps.MapTypeId.ROADMAP, MY_MAPTYPE_ID]
    },
    mapTypeId: MY_MAPTYPE_ID

  featureOpts = [
    featureType: 'all'
    elementType: 'all'
    stylers: [
      invert_lightness: true
    ,
      saturation: -100
    ,
      lightness: 5
    ]
  ]

  map = new google.maps.Map(document.getElementById("map-area"), mapOptions)

  iotaImage = '../images/iotaMarker.svg';
  iotaLatLng = new google.maps.LatLng(-27.45480, 153.03905);
  iotaMarker = new google.maps.Marker(
    clickable: false
    position: iotaLatLng
    map: map
    icon: iotaImage
    title: 'iota studio'
  )

  styledMapOptions =
    name: 'Custom Style'

  customMapType = new google.maps.StyledMapType(featureOpts, styledMapOptions)

  map.mapTypes.set(MY_MAPTYPE_ID, customMapType)

loadGoogleMaps = () ->
  googleMaps = document.createElement("script")
  googleMaps.type = "text/javascript"
  googleMaps.src = "https://maps.googleapis.com/maps/api/js?key=AIzaSyAxUiFoRbIsNrZo-NW_QSbIQfE-R7QcB4k&sensor=false&callback=window.initialiseMaps"
  document.body.appendChild googleMaps

mainMenu.updateColors = (foreground, background) ->
  $(".overlay").stop().animate({
    backgroundColor: background
  }, 300 )

imageLoader.imageLoaded = (img) ->
  targetArticle = $('article').eq(img.imgParent)
  $(img).addClass('fadeIn')
  targetPlaceholder = targetArticle.find('span.placeholder-bg').eq(0)
  targetAlt = targetArticle.find('span.placeholder-alt').eq(0)
  targetPlaceholder.after($(img))
  targetPlaceholder.remove()
  targetAlt.remove()
  imageLoader.loadImage()

imageLoader.loadImage = ->
  if imageLoader.loadArray.length isnt 0

    imgItem = imageLoader.loadArray.shift()
    img = new Image()
    imgTimer = undefined

    img.src = imgItem.imgSrc
    img.title = img.alt = imgItem.imgTitle
    img.imgParent = imgItem.imgParent

    if img.complete or img.readyState is 4
      imageLoader.imageLoaded(img)
    else
      imgTimer = setTimeout ->
        if !imageLoader.retryLoad
          imageLoader.retryLoad = true
          imageLoader.loadArray.unshift(imgItem)
          imageLoader.loadImage()
        else
          imageLoader.retryLoad = false
          $(img).unbind 'error load onreadystate'
          imageLoader.loadImage()  if imgItem.length isnt 0
      , 15000
      $(img).bind 'error load onreadystatechange', (e) ->
        clearTimeout imgTimer
        if e.type isnt 'error'
          imageLoader.imageLoaded(img)
        else
          imageLoader.loadImage()

imageLoader.addImages = (articleIndex) ->
  if !$('article').eq(articleIndex).hasClass('loaded')
    targetArticles = $('article').eq(articleIndex).find('span.placeholder-bg')
    targetArticles.each (index) ->
      imgItem = {}
      imgItem.imgSrc = targetArticles.eq(index).data(imageLoader.screenSize)
      imgItem.imgTitle = targetArticles.eq(index).attr('alt')
      imgItem.imgParent = articleIndex
      imageLoader.loadArray.push(imgItem)
      if index == targetArticles.length - 1
        imageLoader.loadImage()
  $('article').eq(articleIndex).addClass('loaded')

#Index Specific

if window.isIndex

  waypointCheck.footerWaypoint = ->
    $('body').waypoint
      triggerOnce: false
      offset: 'bottom-in-view'
      handler: (direction) ->
        fgColor = $('.checkout-feed').data('fgcolor')
        if direction is 'down'
          if window.isTouch && waypointCheck.nextProject != waypointCheck.lastProject
            return false
          else
            waypointCheck.endofline(fgColor)
            if !waypointCheck.footerOpen
              $('.checkout-feed').removeClass('slideUpFooter slideDownFooter').addClass('slideUpFooter')
              addFade = setTimeout ->
                $('.checkout-feed h3').addClass('fadeIn')
              , 200
              waypointCheck.footerOpen = true
        else
          waypointCheck.endofline(waypointCheck.lastFg)
          if waypointCheck.footerOpen
            $('.checkout-feed').removeClass('slideUpFooter slideDownFooter').addClass('slideDownFooter')
            $('.checkout-feed h3').removeClass('fadeIn')
            waypointCheck.footerOpen = false

  #Non Touch Handlers
  # CHANGE FOR TOUCH DEBUG - DONE
  if !window.isTouch

    waypointCheck.resetFilter = () ->
      $.each waypointCheck.filteredItems, (i) ->
        tarLi = waypointCheck.filteredItems[i].filteredLi
        tarArt = waypointCheck.filteredItems[i].filteredArticle
        tarID = waypointCheck.filteredItems[i].lastID
        if !tarID
          $(".navCounters ul li").eq(0).before(tarLi)
          $('article').eq(0).before(tarArt)
        else
          $('a[href="/' + tarID + '"]').parent().after(tarLi)
          $('article[id="' + tarID + '"]').after(tarArt)
      waypointCheck.filteredItems  = []
      $.waypoints('enable')
      $.waypoints('refresh')
      objectLoader.assignAnimationWaypoints()

    $('.filterMenu a').bind 'click', (event) ->
      event.preventDefault()

      if not $(this).parent().hasClass("eyeButton")
        if not $(this).parent().hasClass("active")
          $('.filterMenu li').removeClass('active')
          $(this).parent().addClass('active')

          tarFilter = $(this).data('filter')

          $('.navCounters').css('visibility','hidden')

          if waypointCheck.filteredItems.length isnt 0
            if tarFilter == 'all'
              $('html, body').stop().animate({
                scrollTop: 0
              }, 750, ->
                if this.nodeName == "BODY"
                  return
                waypointCheck.resetFilter()
                $.waypoints('refresh')
                $('.navCounters').css('visibility','visible')
              )
            else
              waypointCheck.resetFilter()

          if tarFilter isnt 'all'
            $('html, body').stop().animate({
              scrollTop: 0
            }, 750, ->
              if this.nodeName == "BODY"
                return
              historyController.scrollingBack = true
              $('article').each( ->
                if !$(this).attr('data-'+ tarFilter)
                  $(this).waypoint('disable')
                  tarFilterIndex = $(this).index()
                  tarLastId = $(this).prev().attr('id')
                  filteredItem =
                    lastID: tarLastId
                    filteredArticle: $(this).detach()
                    filteredLi: $(".navCounters ul li").eq(tarFilterIndex).removeClass('active').detach()
                  waypointCheck.filteredItems.push(filteredItem)
              )
              historyController.scrollingBack = false
              $.waypoints('refresh')
              $('.navCounters').css('visibility','visible')
            )

    ## Assign Waypoints
    waypointCheck.assignArticleWaypoints = ->

      $('article:gt(0)').waypoint
        triggerOnce: false
        offset: '100%'
        handler: (direction) ->
          if !historyController.scrollingBack
            articleIndex = ($('article').index($('#' + @id)))
            if direction is 'down'
              waypointCheck.updateTitle(@id)
              imageLoader.addImages(articleIndex)
            else
              waypointCheck.updateTitle($('article').eq(articleIndex-1).attr('id'))
              imageLoader.addImages(articleIndex-1)

    waypointCheck.updateTitle = (articleId, popped, navLiHit) -> 
      # Update page title
      if !historyController.scrollingBack
        currentArticle = $('#'+ articleId)
        currentIndex = currentArticle.index()
        waypointCheck.projectSlug = currentArticle.attr('id')
        waypointCheck.projectTitle = currentArticle.data('title')
        @.ogfg = waypointCheck.ogfg = currentArticle.data('foreground')
        @.ogbg = waypointCheck.ogbg = currentArticle.data('background')
        waypointCheck.updateColors(@.ogfg, @.ogbg)
        newTitle = 'Iota — ' + waypointCheck.projectTitle
        $('title').html(newTitle)
        $('.navCounters ul li').removeClass('active scaleIn slideIn')
        if waypointCheck.lastIndex != currentIndex
          $('.navCounters ul li').eq(waypointCheck.lastIndex).addClass('scaleIn')
          $('.navCounters ul li').eq(currentIndex).addClass('active slideIn')
        else
          $('.navCounters ul li').eq(currentIndex).addClass('active slideIn')
        if !navLiHit
          clearTimeout(waypointCheck.showArrow)
          clearTimeout(waypointCheck.hideArrow)
          clearTimeout(waypointCheck.resetArrow)
          targetArrow = $('.navCounters ul li').eq(currentIndex).find('.arrow-tab')
          $('.arrow-tab').css('visibility','hidden')
          targetArrow.css('visibility','visible')
          waypointCheck.showArrow = setTimeout(->
            targetArrow.removeClass('hideArrow').addClass('showArrow scaleIn')
            waypointCheck.hideArrow = setTimeout(->
              targetArrow.removeClass('scaleIn').addClass('scaleOut')
              waypointCheck.resetArrow = setTimeout(->
                $('.arrow-tab').removeClass('scaleOut showArrow').addClass('scaleIn hideArrow').css('visibility','visible')
              ,500)
            ,2000)
          ,1000)
        if not popped
          history.pushState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
        else
          history.replaceState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
        waypointCheck.lastIndex = currentIndex

  #Touch Handlers
  else

    $('.main article').css('background','transparent')

    window.addEventListener 'load', ->
      setTimeout ->
        window.scrollTo(0, 1)
      , 0

    waypointCheck.resetFilter = (isAll) ->
      if isAll
        $('.filterMenu li').removeClass('active')
        $('.filterMenu li').eq(1).addClass('active')

      $(".navCounters ul li").each( ->
        $(this).removeClass('scaleHide slideIn').addClass('scaleIn')
      )

    $('.filterMenu a').bind 'click', (event) ->
      event.preventDefault()

      if not $(this).parent().hasClass("eyeButton")
        if not $(this).parent().hasClass("active")
          $('.filterMenu li').removeClass('active')
          $(this).parent().addClass('active')

          tarFilter = $(this).data('filter')
          currentProject = $('.navCounters li.active').index()
          nextProject = $('article[data-' + tarFilter + '="true"]').first().index()

          if tarFilter == 'all'
            waypointCheck.resetFilter()
          else
            #Hide li
            isCurrentActive = $('article').eq(currentProject).attr('data-'+ tarFilter)

            $('article').each( () ->
              tarRemoveIndex = $(this).index()
              tarRemoveLi = $(".navCounters ul li").eq(tarRemoveIndex)
              if !$(this).attr('data-'+ tarFilter)
                tarRemoveLi.removeClass('active scaleIn slideIn').addClass('scaleHide')
              else
                if isCurrentActive and tarRemoveIndex is currentProject
                  tarRemoveLi.removeClass('slideIn scaleHide').addClass('scaleIn')
                else
                  tarRemoveLi.removeClass('active slideIn scaleHide').addClass('scaleIn')
            )

            #Is the current article being viewed in the filter? -> if not traverse
            if !isCurrentActive
              waypointCheck.currentProject = currentProject
              waypointCheck.nextProject = nextProject
              waypointCheck.traverseProject(false,true)
              $('.arrow-tab').addClass('hideArrow')

    waypointCheck.traverseProject = (goingBack, filterHit) ->
      waypointCheck.projectSlug = $('.main article').eq(@.nextProject).attr('id')
      waypointCheck.projectTitle = $('.main article').eq(@.nextProject).data('title')
      waypointCheck.ogfg = $('.main article').eq(@.nextProject).data('foreground')
      waypointCheck.ogbg = $('.main article').eq(@.nextProject).data('background')
      newTitle = 'Iota — ' + waypointCheck.projectTitle
      if filterHit
        $('.main article').removeClass()
        $('.main article').eq(waypointCheck.currentProject).addClass('fadeOut')
        $('.navCounters ul li').eq(waypointCheck.nextProject).addClass('active')
      else
        $('.main article').removeClass()
        $('.main article').eq(waypointCheck.currentProject).addClass('fadeOut')
        $('.navCounters ul li').removeClass('active scaleIn slideIn')
        $('.navCounters ul li').eq(waypointCheck.currentProject).addClass('scaleIn')
        $('.navCounters ul li').eq(waypointCheck.nextProject).addClass('active slideIn')

      $("nav, .indexNav .icon-info").delay(100).stop().animate({
        color: waypointCheck.ogfg
      }, 500, ->
        waypointCheck.lastFg = waypointCheck.ogfg
        $('html, body').stop().animate({
          scrollTop: 0
          backgroundColor: waypointCheck.ogbg
        }, 750, ->
          if this.nodeName == "BODY"
            return
          $('title').html(newTitle)
          $('.main article').eq(waypointCheck.currentProject).hide()
          $('.main article').eq(waypointCheck.nextProject).show().addClass('slideInProject')
          waypointCheck.updateCanvas()
          if !goingBack
            history.pushState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
          $.waypoints('refresh')
          removeSlide = setTimeout ->
            $('.main article').eq(waypointCheck.nextProject).removeClass('slideInProject')
            imageLoader.addImages(waypointCheck.nextProject)
          , 1000
        )
      )

    waypointCheck.killArrowHelper = (timer) ->
      if timer
        killArrow = setTimeout ->
          $('.arrow-tab').removeClass('scaleIn').addClass('scaleOut')
          removeInt = setTimeout ->
            $('.arrow-tab').removeClass('showArrow').addClass('scaleIn hideArrow')
          , 500
        , 3000
      else
        $('.arrow-tab').removeClass('scaleIn').addClass('scaleOut')
        removeInt = setTimeout ->
          $('.arrow-tab').removeClass('showArrow scaleOut').addClass('scaleIn hideArrow')
        , 500

    waypointCheck.touchWaypoints = ->
      $('body').waypoint
        triggerOnce: false
        offset: 'bottom-in-view'
        handler: (direction) ->
          if direction is 'down'
            targetLi = $('.navCounters li.active').next()
            targetLi.find('.arrow-tab').removeClass('hideArrow').addClass('0')
            clearTimeout(removeAni)
            removeAni = setTimeout ->
              waypointCheck.killArrowHelper(true)
              $('.arrow-tab').unbind('click')
              $('.arrow-tab').bind 'click', (event) ->
                event.preventDefault()
                waypointCheck.currentProject = $('.navCounters li.active').index()
                waypointCheck.nextProject = $(this).parent().index()
                waypointCheck.traverseProject()
                $('.arrow-tab').removeClass('showArrow').addClass('hideArrow')
            , 500

          else if direction is 'up'
            waypointCheck.killArrowHelper(false)

    $('ul.filterMenu li a').bind 'click', (event) ->
      #use toggle class
      $('li.eyeButton i.scaleInSevenFive').toggleClass('scaleOutSevenFive')
      $('ul.filterMenu li.scaleInMenu').toggle()

    waypointCheck.touchWaypoints()

#Blood specific functions
if window.isBlood
  BloodLoader = ->
    @bloogBG = 'images/blood.jpg'
    @teamShotz = []
    @testimonialTimer
    @lastClass
    @instyCounter = 0
    @teamCounter = 0
    @groupTracker = true
    @stateTracker = 0
    @iotaPics = []
    @retryLoad = false
    @iotaInstySpots = ['.iotaInsty1','.iotaInsty2','.iotaInsty2','.iotaInsty2','.iotaInsty3','.iotaInsty4','.iotaInsty4','.iotaInsty4','.iotaInsty5']
    @iotaInsty = 'https://api.instagram.com/v1/users/12427052/media/recent/?access_token=12427052.4e63227.ed7622088af644ffb3146a3f15b50063&count=9'

  bloodLoader = new BloodLoader()

  bloodLoader.instyAnimation = () ->
    if bloodLoader.groupTracker
      targetGroup = '.iotaInsty2'
      targetTeam = '.iotaTeam1'
      bloodLoader.groupTracker = false
    else
      targetGroup = '.iotaInsty4'
      targetTeam = '.iotaTeam2'
      bloodLoader.groupTracker = true

    switch bloodLoader.stateTracker
      when 0
        $(targetGroup + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideDown')
        $(targetGroup + ' .instyAni1').removeClass('slideLeft slideRight').addClass('slideRight')
        $(targetGroup + ' .instyAni2').removeClass('slideLeft slideRight').addClass('slideRight')
        $(targetTeam + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideUp')
        teamTimeout1 = setTimeout ->
          $(targetTeam + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideDown')
        ,1000
        teamTimeout2 = setTimeout ->
          $(targetTeam + ' .instyAni1').removeClass('slideLeft slideRight').addClass('slideRight')
        ,1000
      when 1
        $(targetGroup + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideUp')
        $(targetGroup + ' .instyAni2').removeClass('slideLeft slideRight').addClass('slideLeft')
        teamTimeout1 = setTimeout ->
          $(targetTeam + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideUp')
        ,1000
        teamTimeout2 = setTimeout ->
          $(targetTeam + ' .instyAni1').removeClass('slideLeft slideRight').addClass('slideLeft')
        ,1000
      else
        $(targetGroup + ' .instyAni1').removeClass('slideLeft slideRight').addClass('slideLeft')
        $(targetGroup + ' .instyAni2').removeClass('slideLeft slideRight').addClass('slideRight')


    if bloodLoader.groupTracker
      if bloodLoader.stateTracker < 2
        bloodLoader.stateTracker++
      else
        bloodLoader.stateTracker = 0

  bloodLoader.loadInstyImages = (feed) ->

    instySpots = bloodLoader.iotaInstySpots
    instyPics = bloodLoader.iotaPics

    if instyPics.length isnt 0
      
      imgItem = instyPics.shift()
      imgClass = instySpots.shift()
      
      if imgClass == bloodLoader.lastClass
        bloodLoader.instyCounter++
      else
        bloodLoader.instyCounter = 0

      bloodLoader.lastClass = imgClass

      img = new Image()
      timer = undefined

      img.src = imgItem
      img.title = img.alt = feed

      if img.complete or img.readyState is 4
        $(img).addClass('instagram-pic scaleIn instyAni' + bloodLoader.instyCounter)
        $(img).appendTo(imgClass)
        bloodLoader.loadInstyImages(feed)
      else
        # handle 404 using setTimeout set at 10 seconds, adjust as needed
        timer = setTimeout(->
          #bloodLoader.loadInstyImages()  if imgItem.length isnt 0
          $(img).unbind 'error load onreadystate'
        , 10000)
        $(img).bind 'error load onreadystatechange', (e) ->
          clearTimeout timer
          if e.type isnt 'error'
            #ADD IMAGE IN HERE
            $(img).addClass('instagram-pic scaleIn instyAni' + bloodLoader.instyCounter)
            $(img).appendTo(imgClass)
            bloodLoader.loadInstyImages(feed)
          else
            bloodLoader.loadInstyImages(feed)
    else
      animationInit = setInterval( ->
        bloodLoader.instyAnimation()
      , 4000)

  bloodLoader.loadTeamShotz = () ->
    if bloodLoader.teamShotz.length isnt 0
      teamImg = bloodLoader.teamShotz.shift()
      img = new Image()
      teamTimer = undefined
      
      # if !window.location.origin
      #   window.location.origin = window.location.protocol+"//"+window.location.host;

      # img.src = window.location.origin+'/'+teamImg.src
      img.src = teamImg.src
      img.title = img.alt = teamImg.title
      img.parentz = teamImg.parentz

      if img.complete or img.readyState is 4
        $(''+img.parentz+'').find('.team-instagram').append(img)
        $(img).addClass('instagram-pic team-pic scaleIn instyAni' + bloodLoader.teamCounter)
        (if bloodLoader.teamCounter is 0 then bloodLoader.teamCounter++ else bloodLoader.teamCounter = 0)
        bloodLoader.loadTeamShotz()
      else
        teamTimer = setTimeout ->
          if !bloodLoader.retryLoad
            bloodLoader.retryLoad = true
            bloodLoader.teamShotz.unshift(teamImg)
            bloodLoader.loadTeamShotz()
          else
            bloodLoader.retryLoad = false
            $(img).unbind 'error load onreadystate'
            bloodLoader.loadTeamShotz()  if teamImg.length isnt 0
        , 15000
        $(img).bind 'error load onreadystatechange', (e) ->
          clearTimeout teamTimer
          if e.type isnt 'error'
            $(''+img.parentz+'').find('.team-instagram').append(img)
            $(img).addClass('instagram-pic team-pic scaleIn instyAni' + bloodLoader.teamCounter)
            (if bloodLoader.teamCounter is 0 then bloodLoader.teamCounter++ else bloodLoader.teamCounter = 0)
            bloodLoader.loadTeamShotz()
          else
            bloodLoader.loadTeamShotz()

  bloodLoader.getInsty = () ->
    $.ajax
      url: bloodLoader.iotaInsty
      dataType: 'jsonp'
      cache: false
      success: (iotaImages) ->
        $.each(iotaImages.data, (index) ->
          bloodLoader.iotaPics.push(this.images.low_resolution.url)
        )
        bloodLoader.loadInstyImages('@oneiota_')
      error: ->
        console.log 'run backup pics'

  bloodLoader.getTeamShotz = () ->
    $('.team-member').each( ->
      shotOne = {src : $(this).data('shot1'), title : $(this).data('imgalt'), parentz : $(this).data('parent')}
      shotTwo = {src : $(this).data('shot2'), title : $(this).data('imgalt'), parentz : $(this).data('parent')}
      bloodLoader.teamShotz.push(shotOne,shotTwo)
    )
    bloodLoader.loadTeamShotz()

  bloodLoader.newsletterSignup = () ->
    $.ajax
      type: $('#newsletter-subscribe').attr('method')
      url: $('#newsletter-subscribe').attr('action')
      dataType: 'jsonp'
      data: $('#newsletter-subscribe').serialize()
      cache: false
      contentType: "application/json; charset=utf-8"
      error: (err) ->
        $('#newsletter-subscribe-email').attr("value","") 
        $('#newsletter-subscribe-email').attr("placeholder","*Sorry, please try again")
      success: (data) ->
        unless data.result is "success"
          $('#newsletter-subscribe-email').attr("value","") 
          $('#newsletter-subscribe-email').attr("placeholder",data.msg)
        else
          $('#newsletter-subscribe-email').attr("value","") 
          $('#newsletter-subscribe-email').attr("placeholder","Thanks, stay tuned!")

  bloodLoader.isValidEmailAddress = () ->
    emailAddress = $('#newsletter-subscribe-email').attr('value')
    pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i)
    pattern.test emailAddress

  #Load google map

  if !window.mapLoaded
    loadMap = setTimeout ->
      loadGoogleMaps()
    , 1000
  
  window.mapLoaded = true

  #Blood Binds

  $('.icon-right-arrow-bare').bind('click', (event) ->
    event.preventDefault()
    clearInterval(bloodLoader.testimonialTimer)
    if $('.current-testimonial').index() != ($('.client-testimonial').length - 1)
      nextTest = $('.current-testimonial').next()
    else 
      nextTest = $('.client-testimonial').eq(0)

    $('.current-testimonial').stop().animate({
        left: '-100%'
      }, 100, ->
        $(this).toggleClass('current-testimonial')
        nextTest.css({'left':'100%'}).toggleClass('current-testimonial').stop().animate({
          left: '0%'
        }, 100)
      )
    
  )

  $('.icon-left-arrow-bare').bind('click', (event) ->
    event.preventDefault()
    clearInterval(bloodLoader.testimonialTimer)
    if $('.current-testimonial').index() != 0
      nextTest = $('.current-testimonial').prev()
    else 
      nextTest = $('.client-testimonial').eq($('.client-testimonial').length - 1)

    $('.current-testimonial').stop().animate({
        left: '100%'
      }, 100, ->
        $(this).toggleClass('current-testimonial')
        nextTest.css({'left':'-100%'}).toggleClass('current-testimonial').stop().animate({
          left: '0%'
        }, 100)
      )
  )

  $("form input[type='email']").keypress (event) ->
      if event.which is 13
        $("form input[type='submit']").trigger('click')
        return false

  $("form input[type='submit']").bind('click', (event) ->
    event.preventDefault()  if event
    if bloodLoader.isValidEmailAddress() 
      bloodLoader.newsletterSignup()
    else
      $('#newsletter-subscribe-email').attr("value","") 
      $('#newsletter-subscribe-email').attr("placeholder","*Sorry, give it another go")
  )

  bloodLoader.testimonialTimer = setInterval ->
    $('.icon-right-arrow-bare').trigger('click')
  , 6000


#Elegant page object animation

objectLoader.randomFade = () ->
  getRandomFade = () ->
    randomFade = objectLoader.fadeArray[Math.floor(Math.random() * objectLoader.fadeArray.length)]
    if randomFade != objectLoader.lastFade
      objectLoader.lastFade = randomFade
      randomFade
    else
      getRandomFade()
  getRandomFade()

objectLoader.assignAnimationWaypoints = () ->
  
  if window.isBlood
    $(objectLoader.objectTarget).waypoint
      triggerOnce: true
      offset: '80%'
      handler: (direction) ->
        $(this).find(objectLoader.objectSubTarget).addClass('loaded')
        objectLoader.loadInternals($(this).index())

  else if window.isPortfolio
    $(objectLoader.objectSubTarget).children().each(->
      if $(this).hasClass('project-details')
        $(this).waypoint
          triggerOnce: true
          offset: '50%'
          handler: (direction) ->
            $(this).addClass('loaded')
            objectLoader.loadInternals($(this).parent().parent().index())
      else
        $(this).waypoint
          triggerOnce: true
          offset: '50%'
          handler: (direction) ->
            if $(this).index() == 0
              $(this).addClass('loaded fadeInSlide')
            else
              fadeInEffect = objectLoader.randomFade()
              $(this).addClass('loaded ' + fadeInEffect)
    )

objectLoader.loadInternals = (targetIndex) ->
  if window.isBlood
    targetContent = $(objectLoader.objectTarget).eq(targetIndex).find(objectLoader.objectSubTarget)
  else if window.isPortfolio
    targetContent = $(objectLoader.objectTarget).eq(targetIndex).find('.project-details')

  childArray = []
  targetContent.children().each( (index) ->
     childArray.push(index)
  )

  animateChildren = ->
    if childArray.length isnt 0
      currChild = childArray.shift()
      if targetContent.children().eq(currChild).get(0).tagName == 'UL'
        subChildArray = []
        parentTarget = targetContent.children().eq(currChild)
        parentTarget.children().each( (index) ->
          subChildArray.push(index)
        )
        animateSubChildren = ->
          if subChildArray.length isnt 0
            currSubChild = subChildArray.shift()
            parentTarget.children().eq(currSubChild).addClass('scaleIn')
            animateSubChildTimer = setTimeout ->
              animateSubChildren()
            , 150
          else
            animateChildren()
        animateSubChildren()
      else
        targetContent.children().eq(currChild).addClass('fadeInSlide')
        animateChildTimer = setTimeout ->
          animateChildren()
        , 150 
  
  animateChildren()

objectLoader.pageLoaded = () ->
  objectLoader.assignAnimationWaypoints()
  if !window.isPortfolio or window.isSingle
    $('nav').show()
  else
    # showMain = setTimeout ->
    $('.intro').removeClass('fadeIn').addClass('introOut')
    $('.main').addClass('scaleInBig')
    showNav = setTimeout ->
      $('nav').show()
      $('.intro').remove()
      $('.main').removeClass('scaleInBig')
      $('.checkout-feed').show()
      waypointCheck.makeCanvas()
    , 1200
  if window.isBlood
    bloodLoader.getInsty()
    bloodLoader.getTeamShotz()

#Binds

historyController.bindPopstate = () ->

  $('.main article').each( ->
    historyController.slugArray.push($(this).attr('id'))
  )

  $(window).bind 'popstate', () ->

    if historyController.popped

      historyController.prevSlug = window.location.pathname.slice(1)

      if historyController.prevSlug == 'bloodsweattears'
        if historyController.inMenu == true
          $('.icon-left-arrow').trigger('click')
        else
          $('.icon-info').trigger('click')
      else if historyController.prevSlug == 'contact'
        $('.icon-contact').trigger('click')
      else
        if historyController.inMenu == true
          $('.icon-close').trigger('click')
        else if window.isIndex
          #CHANGE FOR TOUCH DEBUG - DONE
          if window.isTouch
            if historyController.prevSlug == -1 || historyController.prevSlug == ''
              waypointCheck.nextProject = 0
            else  
              waypointCheck.nextProject = $.inArray(historyController.prevSlug,historyController.slugArray)
            waypointCheck.resetFilter(true)
            waypointCheck.currentProject = $('.navCounters li.active').index()
            waypointCheck.traverseProject(true)
          else
            if $('#' + historyController.prevSlug).length || historyController.prevSlug == ''
              if historyController.prevSlug != ''
                scrollTarget = $('#' + historyController.prevSlug).position().top
              else
                scrollTarget = 0
              historyController.scrollingBack = true
              $('html, body').stop().animate({
                scrollTop: scrollTarget
              }, 'slow', ->
                if this.nodeName == "BODY"
                  return
                historyController.scrollingBack = false
                if historyController.prevSlug == -1 || historyController.prevSlug == ''
                  waypointCheck.updateTitle($('article').eq(0).attr('id'), true)
                else
                  waypointCheck.updateTitle(historyController.prevSlug, true)
              )
            else
              window.location.href = '/' + historyController.prevSlug
        else
          window.location.href = '/'

    historyController.popped = true

#Doc deady
$ ->

  $('a.nav-item').bind 'click', (event) ->
    event.preventDefault()

    if !$(this).parent().hasClass('active')
      # CHANGE FOR TOUCH DEBUG - DONE
      if window.isTouch
        waypointCheck.currentProject = $('.navCounters li.active').index()
        waypointCheck.nextProject = $(this).parent().index()
        waypointCheck.traverseProject()
        $('.arrow-tab').addClass('hideArrow')
      else
        thisSlug = $(this).attr('href').slice(1)
        targetIndex = $(this).parent().index()
        scrollTarget = $('#' + thisSlug).position().top
        articleID = $('article').eq(targetIndex).attr('id')
        historyController.scrollingBack = true
        $('.arrow-tab').removeClass('showArrow').addClass('hideArrow').css('visibility','hidden')
        $('html, body').stop().animate({
          scrollTop: scrollTarget
        }, 'slow', ->
          if this.nodeName == "BODY"
            return
          historyController.scrollingBack = false
          imageLoader.addImages(targetIndex)
          waypointCheck.updateTitle(articleID, false, true)
          $('.arrow-tab').css('visibility','visible')
        )

  $('.description').one 'click', (event) ->
    $(this).toggleClass('expand')

  $('.icon-info').bind 'click', (event) ->
    event.preventDefault()
    historyController.inMenu = true
    history.pushState(null, 'iota &#8212; blood,sweat,tears', '')
    $('.main').addClass('openmenu')
    $('body').addClass('menu')
    $('.bottom-hud ul').removeClass('scaleIn')
    $('.menuNav').addClass('scaleIn')
    $('.overlay').removeClass('closemenu').addClass('openmenu')
    waypointCheck.updateColors('#ffffff','#262626')
    if window.isTouch
      hideMain = setTimeout ->
        $('.main').hide()
      , 500

  $('.icon-close').bind 'click', (event) ->
    event.preventDefault()
    historyController.inMenu = false
    history.replaceState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
    $('.main').show().removeClass('openmenu')
    $('body').removeClass('menu')
    $('.bottom-hud ul').removeClass('scaleIn')
    $('.indexNav').addClass('scaleIn')
    $('.overlay').removeClass('openmenu').addClass('closemenu')
    waypointCheck.updateColors(waypointCheck.ogfg,waypointCheck.ogbg)

  $('.icon-contact').bind 'click', (event) ->
    event.preventDefault()
    history.pushState(null, 'iota &#8212; contact', '')
    $('.contact, .mainmenu, body').removeClass('closecontact')
    $('.contact, .mainmenu, body').addClass('opencontact')
    $('.bottom-hud ul').removeClass('scaleIn')
    $('.infoNav').addClass('scaleIn')

    $('.icon-left-arrow').bind 'click', (event) ->
      event.preventDefault()
      history.replaceState(null, 'iota &#8212; blood,sweat,tears', '')
      $('.contact, .mainmenu, body').removeClass('opencontact')
      $('.contact, .mainmenu, body').addClass('closecontact')
      $('.bottom-hud ul').removeClass('scaleIn')
      $('.menuNav').addClass('scaleIn')

  $('.icon-down-arrow-bare').bind 'click', (event) ->
    event.preventDefault()
    $('.navCounters ul li').toggleClass('mobile-hide').addClass('scaleIn')
    $('.icon-up-arrow-bare').css('display','block')

  $('.icon-up-arrow-bare').bind 'click', (event) ->
    event.preventDefault()
    $('.navCounters ul li').toggleClass('mobile-hide').addClass('scaleIn')

  if !window.isTouch
    $('.menuItem').not('.active').hover (->
      foreground = $(this).data('foreground')
      background = $(this).data('background')
      $('.menuItem.active span').css('opacity','0.2')
      mainMenu.updateColors(foreground, background)
      $(this).find('.meaning').addClass('fadeIn')
    ), ->
      mainMenu.updateColors(mainMenu.ogfg, mainMenu.ogbg)
      $('.menuItem.active span').css('opacity','1')

  window.getItStarted = () ->
    ##Index specific startup functions
    if window.isPortfolio and !window.isTouch and !window.isSingle
      waypointCheck.assignArticleWaypoints()

    if window.isIndex
      waypointCheck.footerWaypoint()

    ##Site wide startup functions
    imageLoader.addImages(0)
    objectLoader.pageLoaded()
    historyController.bindPopstate()

  if !window.isPortfolio or window.isSingle
    window.getItStarted()