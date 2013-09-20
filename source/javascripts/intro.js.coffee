TrashGame = ->
  @oneiota = ['o','n','e','i','o','t','a']
  @screenW = $(window).width()
  @screenH = $(window).height()
  @firstDropX = 10
  @firstDropY = 10
  @lastDropX = @firstDropX
  @lastDropY = @firstDropY


trashGame = new TrashGame()

#Doc deady
$ ->
  trashGame.init = () ->
    $('.main').hide()
    $('.intro').append('<div class="trashGame"><div class="bin-container"><div class="bin"><i class="icon icon-trash"/><i class="icon icon-trash-open"/>')
    $.each trashGame.oneiota, (i) ->
      gameObject = $('<h1/>',
        id: i
        className: 'trashObject scaleIn'
        html: trashGame.oneiota[i]
      )
      $('.trashGame').append(gameObject)
      gameObject.draggable()
      if i == 0
        gameObject.css({'top':trashGame.firstDropY + '%','left':trashGame.firstDropX + '%'})
      else if i == 3
        trashGame.firstDropY = trashGame.firstDropY + 35
        dropX = trashGame.firstDropX + (Math.floor(Math.random() * 15) + 10)
        dropY = trashGame.firstDropY + (Math.floor(Math.random() * 10) + 1)
        gameObject.css({'top':dropY + '%','left':dropX + '%'})
        trashGame.lastDropY = dropY
        trashGame.lastDropX = dropX
      else
        dropX = trashGame.lastDropX + (Math.floor(Math.random() * 15) + 10)
        dropY = trashGame.firstDropY + (Math.floor(Math.random() * 10) + 1)
        gameObject.css({'top':dropY + '%','left':dropX + '%'})
        trashGame.lastDropY = dropY
        trashGame.lastDropX = dropX

    $('.bin').droppable
      activeClass: 'active'
      hoverClass: 'scaleBig'
      drop: (event, ui) ->
        $(ui.draggable).remove()

  trashGame.init()
