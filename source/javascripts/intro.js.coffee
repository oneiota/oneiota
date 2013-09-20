TrashGame = ->
  @oneiota = ['o','n','e','i','o','t','a']
  @hangmansList = 0
  @screenW = $(window).width()
  @screenH = $(window).height()


trashGame = new TrashGame()

#Doc deady
$ ->
  trashGame.init = () ->
    $('.main').hide()
    $('.intro').append('<div class="trashGame"><div class="bin-container"><div class="bin"><i class="icon icon-trash"/><i class="icon icon-trash-open"/>')
    $('.trashGame').append('<ul class="hangman">')

    $.each trashGame.oneiota, (i) ->
      fiftyfiftychance = Math.random() < .5
      if fiftyfiftychance && trashGame.hangmansList < 4
        trashGame.hangmansList++
        gameObject = $('<h1/>',
          id: i
          className: 'trashObject scaleIn'
          html: trashGame.oneiota[i]
        )
        $('.trashGame').append(gameObject)
        gameObject.draggable()
        $('.hangman').append('<li>&nbsp;')
      else 
        $('.hangman').append('<li>'+ trashGame.oneiota[i])

    $('.bin').droppable
      activeClass: 'active'
      hoverClass: 'scaleBig'
      drop: (event, ui) ->
        $(ui.draggable).remove()

  trashGame.init()
