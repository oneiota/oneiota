$ ->
  if window.isFeed

    FeedAPIHandler = ->
      @twitterUser = 'oneiota_'

    feedAPIHandler = new FeedAPIHandler()

    FeedImageLoader = ->
      @loadArray = []
      @loadTimer = null

    feedImageLoader = new FeedImageLoader()

    FeedDateKeeper = ->
      @cats

    feedDateKeeper = new FeedDateKeeper()

    feedImageLoader.imageLoaded = (img) ->
      targetArticle = $('article').eq(img.imgParent)
      $(img).addClass('fadeIn')
      targetPlaceholder = targetArticle.find('span.feed-img').eq(img.imgSpan)
      $(img).appendTo(targetPlaceholder)
      # targetPlaceholder.remove()
      feedImageLoader.loadImage()

    feedImageLoader.loadImage = ->
      if feedImageLoader.loadArray.length isnt 0

        imgItem = feedImageLoader.loadArray.shift()
        img = new Image()
        timer = undefined

        img.src = imgItem.imgSrc
        img.title = img.alt = imgItem.imgTitle
        img.imgParent = imgItem.imgParent
        img.imgSpan = imgItem.imgSpan

        if img.complete or img.readyState is 4
          feedImageLoader.imageLoaded(img)
        else
          # handle 404 using setTimeout set at 10 seconds, adjust as needed
          timer = setTimeout(->
            feedImageLoader.loadImage()  if imgItem.length isnt 0
            $(img).unbind 'error load onreadystate'
          , 10000)
          $(img).bind 'error load onreadystatechange', (e) ->
            clearTimeout timer
            if e.type isnt 'error'
              feedImageLoader.imageLoaded(img)
            else
              'put error handling code here!!!!!'
    
    feedImageLoader.addImages = (articleIndex) ->
      console.log articleIndex
      if !$('article').eq(articleIndex).hasClass('loaded')
        targetArticles = $('article').eq(articleIndex).find('span.feed-img')
        targetArticles.each (index) ->
          imgItem = {}
          imgItem.imgSrc = targetArticles.eq(index).data('img')
          imgItem.imgTitle = targetArticles.eq(index).data('alt')
          imgItem.imgParent = articleIndex
          imgItem.imgSpan = index
          feedImageLoader.loadArray.push(imgItem)
          if index == targetArticles.length - 1
            feedImageLoader.loadImage()
      $('article').eq(articleIndex).addClass('loaded')

    feedDateKeeper.loadDates = () ->
      $('.published').each () ->
        timeFromNow = moment($(this).data('published'), "YYYY-MM-DD HH:mm").fromNow()
        $(this).parent().append('<span>' + timeFromNow)

    feedAPIHandler.getTweets = () ->
      console.log 'getting tweets'

    $('article:gt(0)').waypoint
        triggerOnce: true
        offset: '100%'
        handler: (direction) ->
          articleIndex = $(@).index()
          if direction is 'down'
            feedImageLoader.addImages(articleIndex)
          # else
          #   feedImageLoader.addImages(articleIndex-1)

    feedAPIHandler.getTweets()
    feedImageLoader.addImages(0)
    feedDateKeeper.loadDates()
    # feedImageLoader.assignArticleWaypoints()