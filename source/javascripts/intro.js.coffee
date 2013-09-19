TrashGame = ->
  @oneiota = ['o','n','e','i','o','t','a']


trashGame = new TrashGame()

#Doc deady
$ ->
  trashGame.init = () ->
    $('.main').hide()
    $.each trashGame.oneiota, (i) ->
      gameObject = $('<h1/>',
        id: i
        className: 'trashObject'
        html: content
      )
      console.log gameObject
      $('.intro').append(gameObject)

  trashGame.init()

  console.log 'pop break'