$ ->
  if window.isFeed

    FeedImageLoader = ->
      @loadArray = []
      @loadTimer = null

    feedImageLoader = new FeedImageLoader()

    feedImageLoader.imageLoaded = (img) ->
      targetArticle = $('article').eq(img.imgParent)
      $(img).addClass('fadeIn')
      targetPlaceholder = targetArticle.find('span.feed-img').eq(0)
      targetPlaceholder.after($(img))
      targetPlaceholder.remove()
      feedImageLoader.loadImage()

    feedImageLoader.loadImage = ->
      if feedImageLoader.loadArray.length isnt 0

        imgItem = feedImageLoader.loadArray.shift()
        img = new Image()
        timer = undefined

        img.src = imgItem.imgSrc
        img.title = img.alt = imgItem.imgTitle
        img.imgParent = imgItem.imgParent

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
        targetArticles = $('article').eq(articleIndex).find('span.feed-img')
        targetArticles.each (index) ->
          imgItem = {}
          imgItem.imgSrc = targetArticles.eq(index).data('img')
          imgItem.imgTitle = targetArticles.eq(index).data('alt')
          imgItem.imgParent = articleIndex
          feedImageLoader.loadArray.push(imgItem)
          console.log feedImageLoader.loadArray[index]
          if index == targetArticles.length - 1
            feedImageLoader.loadImage()
      $('article').eq(articleIndex).addClass('loaded')

    feedImageLoader.addImages(0)