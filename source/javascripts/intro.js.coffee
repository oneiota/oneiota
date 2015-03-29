TrashGame = ->
  @rotateArray = ['rotatefive','rotatenegfive','rotateonefive','rotateonenegfive','rotatefourfive','rotatenegfourfive','rotateninezero','rotatenegninezero']
  @hangmansList = 0
  @totalTrashObjs = 0
  @screenW = $(window).width()
  @screenH = $(window).height()
  @gamehelpTimer

trashGame = new TrashGame()

DragGame = ->
  @letterCount = 0
  @hangmansList = 0
  @lastX = false
  @lastY = false

dragGame = new DragGame()

IntroGame = ->
  @oneiota = ['o','n','e','i','o','t','a']
  @interactionArray = ['trashGame','dragGame']
  @playedArray = []
  @lalalala

introGame = new IntroGame()

#Doc deady
$ ->
  introGame.gameOver = () ->
    endGame = setTimeout ->
      window.getItStarted()
      sessionStorage.playedAlready = 'true'
    , 500

  introGame.gameOver()

  # introGame.skipThis = (selectedGame) ->
  #   $(selectedGame).append('<div class="skipBtn"><a href="#" title="I don&#39;t like fun &#58;&#40;">skip this <span class="icon-door icon">')
  #   $('.skipBtn').bind 'click', (event) ->
  #     event.preventDefault()
  #     introGame.gameOver()

  # introGame.animateIn = (gameType) ->
  #   animationArray = []

  #   $(gameType).children().each( (index) ->
  #     animationArray.push(index)
  #   )

  #   animateChildren = ->
  #     if animationArray.length isnt 0
  #       currChild = animationArray.shift()
  #       if $(gameType).children().eq(currChild).hasClass('rotated')
  #         rotateClass = $(gameType).children().eq(currChild).data('rotate')
  #         $(gameType).children().eq(currChild).addClass(rotateClass)
  #       else
  #         $(gameType).children().eq(currChild).addClass('scaleIn')
  #       animateChildTimer = setTimeout ->
  #         animateChildren()
  #       , 150
  #     else
  #       if gameType is '.drag-container ul'
  #         dragArray = []
  #         $('.dragObject').each( (arrI) ->
  #           dragArray.push(arrI)
  #         )
  #         animateDrag = ->
  #           if dragArray isnt 0
  #             currDrag = dragArray.shift()
  #             $('.dragObject').eq(currDrag).addClass('scaleIn')
  #             dragTimer = setTimeout ->
  #               $('.dragObject').eq(currDrag).removeClass('scaleIn').addClass('shakeinfinte')
  #               animateDrag()
  #             , 300
  #         animateDrag()
  #       $('.skipBtn').addClass('scaleIn')

  #   animateChildren()

  # trashGame.matchLetter = (matchedLetter) ->
  #   $('.hangman li').each(->
  #     if $(this).hasClass(matchedLetter)
  #       $(this).removeClass(matchedLetter).html(matchedLetter)
  #       trashGame.totalTrashObjs++
  #       return false
  #   )
  #   if trashGame.hangmansList == trashGame.totalTrashObjs
  #     $('.bin').removeClass('jump').addClass('jump')
  #     introGame.gameOver()
  #   else
  #     $('.bin').removeClass('jump').addClass('jump')

  # trashGame.newletter = (liIndex) ->
  #   trashGame.hangmansList++
  #   gameObject = $('<h1/>',
  #     id: liIndex
  #     className: 'trashObject'
  #     html: introGame.oneiota[liIndex]
  #   )
  #   rotateObject = Math.random() < .5
  #   if rotateObject
  #     randomRotate = trashGame.rotateArray[Math.floor(Math.random() * trashGame.rotateArray.length)]
  #     gameObject.addClass('rotated')
  #     gameObject.data('rotate',randomRotate)

  #   $('.trashGame').append(gameObject)
  #   dropX = Math.random() * (80 - 15) + 15
  #   dropY = Math.random() * (50 - 15) + 15
  #   gameObject.css({'top':dropY + '%','left':dropX + '%'})
  #   gameObject.draggable()
  #   $('.hangman').append('<li class="'+introGame.oneiota[liIndex]+'">&nbsp;')


  # trashGame.init = () ->
  #   $('.intro').append('<div class="trashGame"><div class="bin-container"><div class="bin"><p>feed me</p><i class="icon hide-arrow icon-down-arrow-bare"/><i class="icon icon-trash"/><i class="icon icon-trash-open"/>')
  #   $('.trashGame').append('<ul class="hangman">')
  #   $.each introGame.oneiota, (i) ->
  #     if trashGame.hangmansList < 3
  #       if i == introGame.oneiota.length
  #         trashGame.newletter(i)
  #       else
  #         randomLetter = Math.random() < .5
  #         if randomLetter
  #           trashGame.newletter(i)
  #         else
  #           $('.hangman').append('<li>'+ introGame.oneiota[i])
  #     else
  #        $('.hangman').append('<li>'+ introGame.oneiota[i])

  #   $('.bin').droppable
  #     activeClass: 'active'
  #     hoverClass: 'scaleBig'
  #     tolerance: 'touch'
  #     drop: (event, ui) ->
  #       clearTimeout(trashGame.gamehelpTimer)
  #       $('.icon-down-arrow-bare').remove()
  #       dropedLetter = $(ui.draggable).html()
  #       trashGame.matchLetter(dropedLetter)
  #       $(ui.draggable).removeClass().css('visibility','visible').addClass('scaleOut')

  #   trashGame.gamehelpTimer = setTimeout ->
  #     $('.icon-down-arrow-bare').removeClass('hide-arrow').addClass('jumpy')
  #   , 10000

  #   introGame.animateIn('.trashGame')
  #   introGame.skipThis('.trashGame')

  # dragGame.randomLocation = () ->
  #   randomX = Math.random() < .5
  #   randomY = Math.random() < .5
  #   if randomX and !dragGame.lastX
  #     dragGame.lastX = true
  #     dropX = Math.random() * (20 - 5) + 5
  #   else
  #     dragGame.lastX = false
  #     dropX = Math.random() * (80 - 75) + 75
  #   if randomY and !dragGame.lastY
  #     dragGame.lastY = true
  #     dropY = Math.random() * (20 - 5) + 5
  #   else
  #     dragGame.lastY = false
  #     dropY = Math.random() * (80 - 75) + 75
  #   return[dropX, dropY]

  # dragGame.addShake = (shakeIndex) ->
  #   setTimeout ->
  #     $('.dragObject').eq(shakeIndex).removeClass('scaleDown').addClass('shakeinfinte')
  #   ,301

  # dragGame.newletter = (liIndex) ->
  #   gameObject = $('<h1/>',
  #     html: introGame.oneiota[liIndex]
  #     class: 'dragObject '+introGame.oneiota[liIndex]
  #   )
  #   gameObject.draggable
  #     start: () ->
  #       $(this).removeClass('shakeinfinte scaleSmall').addClass('scaleBig dragToggle')
  #     stop: () ->
  #       $(this).removeClass('scaleBig dragToggle').addClass('scaleSmall')
  #     revert: 'invalid' 
  #     snap: ('.'+introGame.oneiota[liIndex])
  #     snapMode:'inner'
  #   randomLoc = dragGame.randomLocation()
  #   gameObject.css({'top':randomLoc[1]+'%','left':randomLoc[0]+'%'})
  #   $('.dragGame').append(gameObject)
  #   dragGame.letterCount++
  #   emptyLetter = $('<li/>',
  #     html: '<h1>' + introGame.oneiota[liIndex]
  #     class: 'hideLetter ' + introGame.oneiota[liIndex]
  #   )
  #   emptyLetter.droppable
  #     accept: '.'+introGame.oneiota[liIndex]
  #     drop: (event, ui) ->
  #       $(ui.draggable).remove()
  #       dragGame.hangmansList++
  #       $(this).droppable( 'disable')
  #       $(event.target).removeClass('hideLetter')
  #       if dragGame.hangmansList == dragGame.letterCount
  #         introGame.gameOver()
  #   $('.drag-container ul').append(emptyLetter)

  # dragGame.init = () ->
  #   $('.intro').append('<div class="dragGame"><div class="drag-container"><ul/>')
  #   $.each introGame.oneiota, (i) ->
  #     if dragGame.letterCount < 2
  #       if i == introGame.oneiota.length
  #         dragGame.newletter(i)
  #       else
  #         randomLetter = Math.random() < .5
  #         if randomLetter
  #           dragGame.newletter(i)
  #         else
  #           $('.drag-container ul').append('<li><h1>' + introGame.oneiota[i])
  #     else
  #       $('.drag-container ul').append('<li><h1>' + introGame.oneiota[i])

  #     if i == 2
  #       $('.drag-container ul li').eq(i).after('<hr/>')

  #   introGame.animateIn('.drag-container ul')
  #   introGame.skipThis('.dragGame')

  # Old script to start minigames
  # window.loadGame = () ->

  #   if !Modernizr.localstorage or sessionStorage.playedAlready == 'true' or window.cantanimate
  #     window.getItStarted()
  #     return false
  #   else
  #     $('.intro').show().addClass('fadeIn')
  #     randomGame = Math.floor(Math.random() * introGame.interactionArray.length)
  #     whichInteraction = introGame.interactionArray[randomGame]
  #     eval(whichInteraction).init()


