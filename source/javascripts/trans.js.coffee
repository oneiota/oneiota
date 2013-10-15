FlipSquare = ->
  @colArr = ['#d83b65','#e55d87','#e55d87','#5fc3e4','#5ec4e5','#50d97a','#edde5d','#f09819','#ff512f','#dd2476','#1b0109']
  @sqrArr = []
  @hozDivs = 4
  @screenW = $(window).width()
  @screenH = $(window).height()
  @squareW = @screenW / @hozDivs
  @squareH = $(window).height() / Math.floor($(window).height() / @squareW)
  @numSq = @hozDivs * ($(window).height() / @squareH)
  @tester = true
  @tester2 = true

flipSquare = new FlipSquare()

flipSquare.flipit = () ->
  if flipSquare.sqrArr.length isnt 0
    sqrItem = flipSquare.sqrArr.shift()
    randCol = flipSquare.colArr[Math.floor(Math.random() * flipSquare.colArr.length)]
    sqrItem.find('.back').css('background',randCol)
    $('.main').append(sqrItem)
    sqrTimer = setTimeout ->
      sqrItem.find('.flipobject').addClass('flipit')
      fadeTimer = setTimeout ->
        sqrItem.removeClass('fadeIn').addClass('fadeOut')
      , 250
      flipSquare.flipit()
    , 75

flipSquare.populate = ->
  n = 0 
  while n < flipSquare.numSq
    ++ n
    flipper = $('<div class="flipsquare fadeIn"><div class="flipobject"><div class="front face"/><div class="back face"/>')
    flipper.css
      'width': flipSquare.squareW + 'px'
      'height': flipSquare.squareH + 'px'
    flipSquare.sqrArr.push(flipper)

  flipSquare.flipit()

$ ->
  flipSquare.populate()
