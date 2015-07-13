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

    @stage.familyTree = @
    @stage.background = @background
    @stage.addChild(@background)

  bindScroll: ->
    @background.interactive = true

    onDown = (mouseData) =>
      @isDown       = true
      @startX       = @x
      @startY       = @y
      @startOffsetX = mouseData.data.originalEvent.x
      @startOffsetY = mouseData.data.originalEvent.y

    onUp = =>
      @isDown = false

    onMove = (mouseData) =>
      if @isDown
        @x = @startX + mouseData.data.originalEvent.x - @startOffsetX
        @y = @startY + mouseData.data.originalEvent.y - @startOffsetY

    @background.on('mousedown',       onDown)
    @background.on('touchstart',      onDown)
    @background.on('mouseup',         onUp)
    @background.on('touchend',        onUp)
    @background.on('mouseupoutside',  onUp)
    @background.on('touchendoutside', onUp)
    @background.on('mousemove',       onMove)

  initializeNodes: ->
    for person in @people
      node = new PersonNode(@stage, person)

      if person == @root
        @rootNode = node
        @rootNode.dirtyRoot = true

  animate: =>
    requestAnimationFrame(@animate)

    @x = @width / 2  if @x == undefined
    @y = @height / 2 if @y == undefined

    @rootNode.displayTree(@x, @y)
    @rootNode.update()

    @renderer.render(@stage)
