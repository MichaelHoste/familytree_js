class FamilyTree

  constructor: (width, height, people, root) ->
    @width  = width
    @height = height
    @people = people
    @root   = root

    @initializeRenderer()
    @stage = new PIXI.Container()

    @initializeBackground()

    @bindScroll()

    @initializeNodes()

    @animate()

  initializeRenderer: ->
    @renderer = new PIXI.autoDetectRenderer(@width, @height, {
      antialias:       true,
      backgroundColor: 0xFFFFFF
    })

    $('#family_tree')[0].appendChild(@renderer.view)

  initializeBackground: ->
    @background        = PIXI.Sprite.fromImage('images/pixel.gif');
    @background.width  = @width
    @background.height = @height

    @stage.background = @background
    @stage.addChild(@background)

  bindScroll: ->
    @background.interactive = true

    onDown = =>
      @isDown = true

    onUp = =>
      @isDown = false

    onMove = (mouseData) =>
      if @isDown
        @x += mouseData.data.originalEvent.movementX
        @y += mouseData.data.originalEvent.movementY

    @background.on('mousedown',  onDown)
    @background.on('touchstart', onDown)

    @background.on('mouseup',         onUp)
    @background.on('touchend',        onUp)
    @background.on('mouseupoutside',  onUp)
    @background.on('touchendoutside', onUp)

    @background.on('mousemove', onMove)

    console.log @background

  initializeNodes: ->
    for person in @people
      node = new PersonNode(@stage, person)

      if person == @root
        @rootNode = node

  animate: =>
    requestAnimationFrame(@animate)

    @x = 500 if @x == undefined
    @y = 500 if @y == undefined

    @rootNode.displayTree(@x, @y)
    @rootNode.update()

    @renderer.render(@stage)
