IntroGame = ->
  @lalalala

introGame = new IntroGame()

TrashGame = ->
  @oneiota = ['o','n','e','i','o','t','a']
  @rotateArray = ['rotatefive','rotatenegfive','rotateonefive','rotateonenegfive','rotatefourfive','rotatenegfourfive','rotateninezero','rotatenegninezero']
  @hangmansList = 0
  @screenW = $(window).width()
  @screenH = $(window).height()

trashGame = new TrashGame()

#Doc deady
$ ->
  if window.isPortfolio
    introGame.gameOver = () ->
      endGame = setTimeout ->
        #$('.intro').removeClass('fadeIn').addClass('scaleOutRotate')
        window.getItStarted()
      , 500

    introGame.animateIn = () ->
      animationArray = []

      $('.trashGame').children().each( (index) ->
        animationArray.push(index)
      )

      animateChildren = ->
        if animationArray.length isnt 0
          currChild = animationArray.shift()
          if $('.trashGame').children().eq(currChild).hasClass('rotated')
            rotateClass = $('.trashGame').children().eq(currChild).data('rotate')
            $('.trashGame').children().eq(currChild).addClass(rotateClass)
          else
            $('.trashGame').children().eq(currChild).addClass('scaleIn')
          animateChildTimer = setTimeout ->
            animateChildren()
          , 150

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

      $.each trashGame.oneiota, (i) ->
        fiftyfiftychance = Math.random() < .5
        if fiftyfiftychance && trashGame.hangmansList < 4
          trashGame.hangmansList++
          $('.hangman').append('<li>'+ trashGame.oneiota[i])
        else
          gameObject = $('<h1/>',
            id: i
            className: 'trashObject'
            html: trashGame.oneiota[i]
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
          $('.hangman').append('<li class="'+trashGame.oneiota[i]+'">&nbsp;')

      $('.bin').droppable
        activeClass: 'active'
        hoverClass: 'scaleBig'
        drop: (event, ui) ->
          dropedLetter = $(ui.draggable).html()
          trashGame.matchLetter(dropedLetter)
          $(ui.draggable).removeClass().css('visibility','visible').addClass('scaleOut')

      introGame.animateIn()

    introGame.init = () ->
      trashGame.init()

    introGame.init()