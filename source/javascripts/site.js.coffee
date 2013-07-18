window.isTouch = if ($('html').hasClass('touch')) then true else false
window.isIndex = if $('.index').length then true else false
window.isBlood = if $('body').hasClass('blood') then true else false
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
  @articesLoaded = false
  @isLoading = false
  @currentProject = 0
  @nextProject
  @projectSlug = $('article:eq(0)').attr('id')
  @projectTitle = $('article:eq(0)').data('title')
  @ogfg = $('article:eq(0)').data('foreground')
  @ogbg = $('article:eq(0)').data('background')
  @projects
  @arrowTab = '<div class="arrow-tab"><a href="#"></a><span>'

waypointCheck = new WaypointCheck()

waypointCheck.updateColors = (foreground, background) ->
  $("nav").stop().animate({
    color: foreground
  }, 500 )

ImageLoader = ->
  @loadArray = []
  @screenSize = if (screen.width > 880) then 'desktop' else 'mobile'
  @loadTimer = null

imageLoader = new ImageLoader()

MainMenu = ->
  @ogbg = '#262626'
  @ogfg = '#ffffff'

mainMenu = new MainMenu()

window.initialiseMaps = () ->
  
  MY_MAPTYPE_ID = 'custom_style';

  mapOptions =
    zoom: 16
    center: new google.maps.LatLng(-27.45480, 153.03905)
    disableDefaultUI: true
    zoomControl: false
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

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

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
    timer = undefined

    img.src = imgItem.imgSrc
    img.title = img.alt = imgItem.imgTitle
    img.imgParent = imgItem.imgParent

    if img.complete or img.readyState is 4
      imageLoader.imageLoaded(img)
    else
      # handle 404 using setTimeout set at 10 seconds, adjust as needed
      timer = setTimeout(->
        imageLoader.loadImage()  if imgItem.length isnt 0
        $(img).unbind 'error load onreadystate'
      , 10000)
      $(img).bind 'error load onreadystatechange', (e) ->
        clearTimeout timer
        if e.type isnt 'error'
          imageLoader.imageLoaded(img)
        else
          'put error handling code here!!!!!'

imageLoader.addImages = (articleIndex) ->
  targetArticles = $('article').eq(articleIndex).find('span.placeholder-bg')
  targetArticles.each (index) ->
    imgItem = {}
    imgItem.imgSrc = targetArticles.eq(index).data(imageLoader.screenSize)
    imgItem.imgTitle = targetArticles.eq(index).attr('alt')
    imgItem.imgParent = articleIndex
    imageLoader.loadArray.push(imgItem)
    if index == targetArticles.length - 1
      imageLoader.loadImage()

#Index Specific

if window.isIndex 

  #Non Touch Handlers
  if !window.isTouch

    ## Assign Waypoints
    waypointCheck.assignArticleWaypoints = ->
      $('article:gt(0)').waypoint
        triggerOnce: false
        offset: '100%'
        handler: (direction) ->
          if !historyController.scrollingBack
            articleIndex = ($('article').index($('#' + @id)))
            imageLoader.addImages(articleIndex)
            if direction is 'down'
              waypointCheck.updateTitle(@id)
            else
              waypointCheck.updateTitle($('article').eq(articleIndex-1).attr('id'))

    waypointCheck.updateTitle = (articleId, popped) -> 
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
        $('.top-hud ul li').removeClass('active scaleIn slideIn')
        $('.top-hud ul li').eq(currentIndex-1).addClass('scaleIn')
        $('.top-hud ul li').eq(currentIndex).addClass('active slideIn')
        if not popped
          history.pushState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
        else
          history.replaceState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)

    #Index specific startup functions
    waypointCheck.assignArticleWaypoints()

  #Touch Handlers
  else

    $('.main article').css('background','transparent')

    #Could be good to add a loaded listener to whole site. show everything at once.
    window.addEventListener 'load', ->
      setTimeout ->
        window.scrollTo(0, 1)
      , 0

    waypointCheck.traverseProject = (goingBack) ->
      waypointCheck.projectSlug = $('.main article').eq(@.nextProject).attr('id')
      waypointCheck.projectTitle = $('.main article').eq(@.nextProject).data('title')
      @.ogfg = $('.main article').eq(@.nextProject).data('foreground')
      @.ogbg = $('.main article').eq(@.nextProject).data('background')
      newTitle = 'Iota — ' + waypointCheck.projectTitle
      $('.main article').removeClass()
      $('.main article').eq(waypointCheck.currentProject).addClass('fadeOut')
      $('.top-hud ul li, p.project-title span').removeClass('active scaleIn scaleOut')
      $('.top-hud ul li a.icon-circle').removeClass('scaleInFifty scaleOutFifty')
      $('p.project-title span').addClass('scaleOut')
      $('.top-hud ul li').eq(waypointCheck.nextProject).find('.icon-circle').addClass('scaleOutFifty')
      $("nav").delay(100).stop().animate({
        color: waypointCheck.ogfg
      }, 500, ->
        $('p.project-title span').html(waypointCheck.projectTitle)
        $('p.project-title').stop().animate({backgroundColor: waypointCheck.ogbg},750)
        $('html, body').stop().animate({
          scrollTop: 0
          backgroundColor: waypointCheck.ogbg
        }, 750, ->
          if this.nodeName == "BODY"
            return
          $('title').html(newTitle)
          $('p.project-title span').addClass('scaleIn')
          $('.top-hud ul li').eq(waypointCheck.nextProject).addClass('active')
          $('.top-hud ul li').eq(waypointCheck.nextProject).find('.icon-circle').addClass('scaleInFifty')
          $('.main article').eq(waypointCheck.currentProject).hide()
          $('.main article').eq(waypointCheck.nextProject).show().addClass('slideInProject')
          if !goingBack
            history.pushState(null, waypointCheck.projectTitle, waypointCheck.projectSlug)
          $.waypoints('refresh');
          removeSlide = setTimeout ->
            $('.main article').eq(waypointCheck.nextProject).removeClass('slideInProject')
            imageLoader.addImages(waypointCheck.nextProject)
          , 1000
        )
      )

    waypointCheck.touchWaypoints = ->
      $('body').waypoint
        triggerOnce: false
        offset: 'bottom-in-view'
        handler: (direction) ->
          if direction is 'down'
            if !$('.arrow-tab').length
              targetLi = $('li.active').next()
              targetLiTitle = targetLi.find('.project-title').text()
              targetLi.append(waypointCheck.arrowTab)
              $('.arrow-tab').css('background',waypointCheck.ogfg)
              $('.arrow-tab span').css('border-left-color',waypointCheck.ogfg)
              $('.arrow-tab a').text(targetLiTitle).css('color', waypointCheck.ogbg)
              $('.arrow-tab').addClass('scaleOutIn')
              removeAni = setTimeout ->
                waypointCheck.killArrowHelper(true)
                $('.arrow-tab').addClass('arrow-tab-show')
                $('.arrow-tab a').bind 'click', (event) ->
                  event.preventDefault()
                  waypointCheck.currentProject = $('li.active').index()
                  waypointCheck.nextProject = $(this).parent().parent().index()
                  waypointCheck.traverseProject()
                  if $('.arrow-tab-show').length
                    $('.arrow-tab').remove()
              , 500

          # else if direction is 'up'
          #   waypointCheck.killArrowHelper(false)

    waypointCheck.killArrowHelper = (timer) ->
      if timer
        killArrow = setTimeout ->
          if $('.arrow-tab-show').length
            $('.arrow-tab').removeClass('scaleOutIn arrow-tab-show').addClass('scaleOut')
            removeInt = setTimeout ->
              $('.arrow-tab').remove()
            , 500
        , 3000
      else
        if $('.arrow-tab-show').length
          $('.arrow-tab').removeClass('scaleOutIn arrow-tab-show').addClass('scaleOut')
          removeInt = setTimeout ->
            $('.arrow-tab').remove()
          , 500
      
    
    $('p.mobile.project-title').bind 'click', (event) ->
      $('html, body').stop().animate({
        scrollTop: 0
      }, 500)

    waypointCheck.touchWaypoints()

#Blood specific functions
if window.isBlood
  BloodLoader = ->
    @bloogBG = 'images/blood.jpg'
    @testimonialTimer
    @lastClass
    @allLoaded = 0
    @instyCounter = 0
    @groupTracker = true
    @stateTracker = 0
    @iotaPics = []
    @iotaInstySpots = ['.iotaInsty1','.iotaInsty2','.iotaInsty2','.iotaInsty2','.iotaInsty3','.iotaInsty4','.iotaInsty4','.iotaInsty4','.iotaInsty5']
    @iotaInsty = 'https://api.instagram.com/v1/users/12427052/media/recent/?access_token=12427052.4e63227.ed7622088af644ffb3146a3f15b50063&count=9'
    
  bloodLoader = new BloodLoader()

  bloodLoader.loadInternals = (sectionIndex) ->
    
    targetContent = $('section').eq(sectionIndex).find('.content')
    childArray = []

    targetContent.children().each( (index) ->
       childArray.push(index)
    )

    animateChildren = ->
      if childArray.length isnt 0
        currChild = childArray.shift()
        targetContent.children().eq(currChild).addClass('fadeInSlide')
        animateChildTimer = setTimeout ->
          animateChildren()
        , 50 
    
    animateChildren()  


  bloodLoader.assignSectionWaypoints = () ->
    $('section').waypoint
      triggerOnce: true
      offset: '80%'
      handler: (direction) ->
        $(this).find('.container').addClass('loaded')
        bloodLoader.loadInternals($(this).index())

  bloodLoader.instyAnimation = () ->

    if bloodLoader.groupTracker 
      targetGroup = '.iotaInsty2'
      bloodLoader.groupTracker = false
    else
      targetGroup = '.iotaInsty4'
      bloodLoader.groupTracker = true

    switch bloodLoader.stateTracker
      when 0
        $(targetGroup + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideDown')
        $(targetGroup + ' .instyAni1').removeClass('slideLeft slideRight').addClass('slideRight')
        $(targetGroup + ' .instyAni2').removeClass('slideLeft slideRight').addClass('slideRight')
      when 1
        $(targetGroup + ' .instyAni0').removeClass('slideDown slideUp').addClass('slideUp')
        $(targetGroup + ' .instyAni2').removeClass('slideLeft slideRight').addClass('slideLeft')
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

  bloodLoader.bloodPageLoaded = () ->
    $(window).load(->
      # $('.container').eq(0).addClass('loaded')
      bloodLoader.assignSectionWaypoints()
      bloodLoader.getInsty()
    )

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

  bloodLoader.testimonialTimer = setInterval ->
    $('.icon-right-arrow-bare').trigger('click')
  ,6000


  bloodLoader.bloodPageLoaded()

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
          if window.isTouch #touch traversing
            if historyController.prevSlug == -1 || historyController.prevSlug == ''
              waypointCheck.nextProject = 0
            else  
              waypointCheck.nextProject = $.inArray(historyController.prevSlug,historyController.slugArray)
              waypointCheck.currentProject = $('li.active').index()
            waypointCheck.traverseProject(true)
          else
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
          window.location.href = '/'

    historyController.popped = true

$('a.icon-circle').bind 'click', (event) ->
  event.preventDefault()

  if !$(this).parent().hasClass('active')
    if window.isTouch
      waypointCheck.currentProject = $('li.active').index()
      waypointCheck.nextProject = $(this).parent().index()
      waypointCheck.traverseProject()
      if $('.arrow-tab-show').length
        $('.arrow-tab').remove()
    else
      thisSlug = $(this).attr('href').slice(1)
      targetIndex = $(this).parent().index()
      scrollTarget = $('#' + thisSlug).position().top
      historyController.scrollingBack = true
      $('html, body').stop().animate({
        scrollTop: scrollTarget
      }, 'slow', ->
        if this.nodeName == "BODY"
          return
        historyController.scrollingBack = false
        articleID = $('article').eq(targetIndex).attr('id')
        waypointCheck.updateTitle(articleID)
        imageLoader.addImages(targetIndex)
      )

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
  if !window.mapLoaded
    loadMap = setTimeout ->
      loadGoogleMaps()
    , 1000
  window.mapLoaded = true

  $('.icon-left-arrow').bind 'click', (event) ->
    event.preventDefault()
    history.replaceState(null, 'iota &#8212; blood,sweat,tears', '')
    $('.contact, .mainmenu, body').removeClass('opencontact')
    $('.contact, .mainmenu, body').addClass('closecontact')
    $('.bottom-hud ul').removeClass('scaleIn')
    $('.menuNav').addClass('scaleIn')

$('.icon-down-arrow-bare').bind 'click', (event) ->
  event.preventDefault()
  $('.top-hud ul li').toggleClass('mobile-hide').addClass('scaleIn')
  $('.icon-up-arrow-bare').css('display','block')

$('.icon-up-arrow-bare').bind 'click', (event) ->
  event.preventDefault()
  $('.top-hud ul li').toggleClass('mobile-hide').addClass('scaleIn')

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

#Site wide startup functions
imageLoader.addImages(0)
historyController.bindPopstate()