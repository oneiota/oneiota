$ ->
  if window.isFeed

    FeedAPIHandler = ->
      @apiArray = []
      @blacklist = []
      @montez

    feedAPIHandler = new FeedAPIHandler()

    FeedImageLoader = ->
      @loadArray = []
      @loadTimer = null

    feedImageLoader = new FeedImageLoader()

    FeedDateKeeper = ->
      @firstRun = true

    feedDateKeeper = new FeedDateKeeper()

    FeedWaypoints = ->
      @currentPage = 1
      @gettingContent = false

    feedWaypoints = new FeedWaypoints()

    feedWaypoints.addImageWaypoints = ->
      $('article').waypoint
        triggerOnce: true
        offset: '100%'
        handler: (direction) ->
          articleIndex = $(@).index()
          if direction is 'down'
            feedImageLoader.addImages(articleIndex)

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

    feedWaypoints.addEndPageWaypoint = ->
      $('body').waypoint
        triggerOnce: false
        offset: 'bottom-in-view'
        handler: (direction) ->
          if feedWaypoints.currentPage < $('.maxpages').data('maxpages') and !feedWaypoints.gettingContent
            $('.paginate').show()
            $('.paginate .post h2').addClass('twinkle')
            feedWaypoints.gettingContent = true
            nextPage = feedWaypoints.currentPage + 1
            $.get 'feed/page/'+nextPage+'/', (data) ->
              $('.paginate').before($(data).find('article.post'))
              feedWaypoints.currentPage++
              feedWaypoints.gettingContent = false
              $('.paginate').hide()
              feedAPIHandler.appendArticles()
              $.waypoints('refresh')
          else if feedWaypoints.currentPage >= $('.maxpages').data('maxpages') and !feedWaypoints.gettingContent
            $('.paginate').show()
            $('.paginate .post h2').text('End of the line')
            $('.paginate .post i').hide()
            killTwinkle = setTimeout(->
              $('.paginate .post h2').removeClass('twinkle')
            ,6000)

    feedDateKeeper.loadDates = () ->
      $('.published').each (index) ->
        if !$(this).parent().find('.timefromnow').length
          timeFromNow = moment($(this).data('published'), "YYYY-MM-DD HH:mm").fromNow()
          $(this).parent().append('<span class="timefromnow">' + timeFromNow)
      if feedDateKeeper.firstRun
        feedWaypoints.addEndPageWaypoint()
        feedWaypoints.addImageWaypoints()
        feedDateKeeper.firstRun = false

    feedAPIHandler.appendArticles = () ->
      $('article').each( ->
        if $(this).hasClass 'post'
          postDate = $(this).find('.post-date span').data('published')
          articlePost = $(this)
          $.each feedAPIHandler.apiArray, (i) ->
            if moment(feedAPIHandler.apiArray[i].published).isAfter(postDate)
              if $.inArray(i, feedAPIHandler.blacklist) == -1
                  postIndex = articlePost.index()
                  feedAPIHandler.blacklist.push(i)
                  $('article').eq(postIndex).before(feedAPIHandler.apiArray[i].item)
        )
      feedDateKeeper.loadDates()

    feedAPIHandler.sortArticles = () ->
      sortByDate = (date1, date2) ->
        if date1.published < date2.published
          return 1
        if date1.published > date2.published
          return -1
        return 0

      feedAPIHandler.apiArray.sort(sortByDate)

      # $.each feedAPIHandler.apiArray, (i) ->
      #   console.log feedAPIHandler.apiArray[i].published

      feedAPIHandler.appendArticles()

    feedAPIHandler.collectArticles = () ->
      $('article.api').each((index)->
        apiArrayItem =
          item: $(this).detach()
          published: $(this).find('.post-date span').data('published')
        feedAPIHandler.apiArray.push(apiArrayItem)
      )
      feedAPIHandler.sortArticles()

    $('.icon-expand-arrow').bind 'click', () ->
      $(this).hide()
      parentArticle = $(this).parent('article')
      if parentArticle.find('.more-text').length
        parentArticle.find('.article-text').hide()
      parentArticle.find('.more-content > *').show()

    feedAPIHandler.collectArticles()
    # feedImageLoader.addImages(0)
    #feedDateKeeper.loadDates()