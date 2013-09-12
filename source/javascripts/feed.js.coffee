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
      
      targetPlaceholder = targetArticle.find('.feed-img').eq(img.imgSpan)
      $(img).appendTo(targetPlaceholder)
      imgHeight = parseInt($(img).css('height'))
      imgWidth = parseInt($(img).css('width'))
      if imgWidth > imgHeight
        imgDiff = (imgWidth - imgHeight) / 2
        imgRatio = (imgDiff / imgHeight) * 100
        imgStyle = '-' + imgRatio + '%'
        $(img).addClass('landscape-image')
        $(img).css('left',imgStyle)
      else
        imgDiff = (imgHeight - imgWidth) / 2
        imgRatio = (imgDiff / imgWidth) * 100
        imgStyle = '-' + imgRatio + '%'
        $(img).addClass('portrait-image')
        $(img).css('top',imgStyle)
      $(img).addClass('fadeIn')
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
      if !$('article').eq(articleIndex).hasClass('loaded')
        targetArticles = $('article').eq(articleIndex).find('.feed-img')
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

    $('article:gt(0)').waypoint
        triggerOnce: true
        offset: '100%'
        handler: (direction) ->
          articleIndex = $(@).index()
          if direction is 'down'
            feedImageLoader.addImages(articleIndex)
          # else
          #   feedImageLoader.addImages(articleIndex-1)

    $('.icon-expand-arrow').bind 'click', () ->
      $(this).hide()
      parentArticle = $(this).parent('article')
      if parentArticle.find('.more-text').length
        parentArticle.find('.article-text').hide()
      parentArticle.find('.more-content > *').show()

    feedImageLoader.addImages(0)
    feedDateKeeper.loadDates()