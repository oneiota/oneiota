TrashGame = ->
  @rotateArray = ['rotatefive','rotatenegfive','rotateonefive','rotateonenegfive','rotatefourfive','rotatenegfourfive','rotateninezero','rotatenegninezero']
  @hangmansList = 0
  @screenW = $(window).width()
  @screenH = $(window).height()

trashGame = new TrashGame()

DragGame = ->
  @letterCount = 0
  @hangmansList = 0
  @lalalala

dragGame = new DragGame()

IntroGame = ->
  @oneiota = ['o','n','e','i','o','t','a']
  @interactionArray = [trashGame,dragGame]
  @lalalala

introGame = new IntroGame()

#Doc deady
$ ->
  if window.isPortfolio
    introGame.gameOver = () ->
      endGame = setTimeout ->
        #$('.intro').removeClass('fadeIn').addClass('scaleOutRotate')
        window.getItStarted()
      , 500

    introGame.animateIn = (gameType) ->
      animationArray = []

      $(gameType).children().each( (index) ->
        animationArray.push(index)
      )

      animateChildren = ->
        if animationArray.length isnt 0
          currChild = animationArray.shift()
          if $(gameType).children().eq(currChild).hasClass('rotated')
            rotateClass = $(gameType).children().eq(currChild).data('rotate')
            $(gameType).children().eq(currChild).addClass(rotateClass)
          else
            $(gameType).children().eq(currChild).addClass('scaleIn')
          animateChildTimer = setTimeout ->
            animateChildren()
          , 150
        else
          if gameType is '.drag-container ul'
            dragArray = []
            $('.dragObject').each( (arrI) ->
              dragArray.push(arrI)
            )
            animateDrag = ->
              if dragArray isnt 0
                currDrag = dragArray.shift()
                $('.dragObject').eq(currDrag).addClass('scaleIn')
                dragTimer = setTimeout ->
                  $('.dragObject').eq(currDrag).removeClass('scaleIn').addClass('shakeinfinte')
                  animateDrag()
                , 300
            animateDrag()

      animateChildren()

    trashGame.matchLetter = (matchedLetter) ->
      $('.hangman li').each(->
        if $(this).hasClass(matchedLetter)
          $(this).removeClass(matchedLetter).html(matchedLetter)
          trashGame.hangmansList++
          return false
      )
      if trashGame.hangmansList == 7
        $('.bin').removeClass('jump').addClass('jump')
        introGame.gameOver()
      else
        $('.bin').removeClass('jump').addClass('jump')

    trashGame.init = () ->
      $('.intro').append('<div class="trashGame"><div class="bin-container"><div class="bin"><i class="icon icon-trash"/><i class="icon icon-trash-open"/>')
      $('.trashGame').append('<ul class="hangman">')

      $.each introGame.oneiota, (i) ->
        fiftyfiftychance = Math.random() < .5
        if fiftyfiftychance && trashGame.hangmansList < 4
          trashGame.hangmansList++
          $('.hangman').append('<li>'+ introGame.oneiota[i])
        else
          gameObject = $('<h1/>',
            id: i
            className: 'trashObject'
            html: introGame.oneiota[i]
          )
          rotateObject = Math.random() < .5
          if rotateObject
            randomRotate = trashGame.rotateArray[Math.floor(Math.random() * trashGame.rotateArray.length)]
            gameObject.addClass('rotated')
            gameObject.data('rotate',randomRotate)

          $('.trashGame').append(gameObject)
          dropX = Math.random() * (80 - 15) + 15
          dropY = Math.random() * (50 - 15) + 15
          gameObject.css({'top':dropY + '%','left':dropX + '%'})
          gameObject.draggable()
          $('.hangman').append('<li class="'+introGame.oneiota[i]+'">&nbsp;')

      $('.bin').droppable
        activeClass: 'active'
        hoverClass: 'scaleBig'
        drop: (event, ui) ->
          dropedLetter = $(ui.draggable).html()
          trashGame.matchLetter(dropedLetter)
          $(ui.draggable).removeClass().css('visibility','visible').addClass('scaleOut')

      introGame.animateIn('.trashGame')

    dragGame.randomLocation = () ->
      randomX = Math.random() < .5
      randomY = Math.random() < .5
      if randomX
        dropX = Math.random() * (20 - 15) + 15
      else
        dropX = Math.random() * (80 - 70) + 70
      if randomY
        dropY = Math.random() * (20 - 15) + 15
      else
        dropY = Math.random() * (80 - 70) + 70
      return[dropX, dropY]

    dragGame.newletter = (liIndex) ->
      gameObject = $('<h1/>',
        html: introGame.oneiota[liIndex]
        class: 'dragObject '+introGame.oneiota[liIndex]
      )
      gameObject.draggable
        start: () ->
          $(this).removeClass('shakeinfinte scaleDown').addClass('scaleBig dragToggle')
        stop: () ->
          $(this).removeClass('scaleBig dragToggle').addClass('scaleDown')
          addShake = setTimeout ->
            $(this).addClass('shakeinfinte')
          ,301

        revert: 'invalid' 
        snap: ('.'+introGame.oneiota[liIndex])
        snapMode:'inner'
      randomLoc = dragGame.randomLocation()
      gameObject.css({'top':randomLoc[1]+'%','left':randomLoc[0]+'%'})
      $('.dragGame').append(gameObject)
      dragGame.letterCount++
      emptyLetter = $('<li/>',
        html: '<h1>' + introGame.oneiota[liIndex]
        class: 'hideLetter ' + introGame.oneiota[liIndex]
      )
      emptyLetter.droppable
        accept: '.'+introGame.oneiota[liIndex]
        drop: (event, ui) ->
          dragGame.hangmansList++
          $(this).droppable( 'disable' )
          $(ui.draggable).removeClass('scaleIn').css('visibility','visible').addClass('scaleOut')
          scaleOutTimer = setTimeout ->
            $(ui.draggable).remove()
            $(event.target).removeClass('hideLetter')
            if dragGame.hangmansList == dragGame.letterCount
              introGame.gameOver()
            else
              $(event.target).find('h1').addClass('scaleIn')
            
          , 700
      $('.drag-container ul').append(emptyLetter)

    dragGame.init = () ->
      $('.intro').append('<div class="dragGame"><div class="drag-container"><ul/>')
      $.each introGame.oneiota, (i) ->
        if dragGame.letterCount < 2
          if i == introGame.oneiota.length
            dragGame.newletter(i)
          else
            randomLetter = Math.random() < .5
            if randomLetter
              dragGame.newletter(i)
            else
              $('.drag-container ul').append('<li><h1>' + introGame.oneiota[i])
        else
          $('.drag-container ul').append('<li><h1>' + introGame.oneiota[i])

        if i == 2
          $('.drag-container ul li').eq(i).after('<hr/>')

      introGame.animateIn('.drag-container ul')

    introGame.init = () ->
      #whichInteraction = introGame.interactionArray[Math.floor(Math.random() * introGame.interactionArray.length)]
      #trashGame.init()
      dragGame.init()

    introGame.init()