class FamilyTree

  constructor: (width, height, people, root) ->
    @width  = width
    @height = height
    @people = people
    @root   = root

    @initializeRenderer()
    @stage = new PIXI.Container()

    @initializeBackground()
    @initializeNodes()

    @bindScroll()

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

    @stage.addChild(@background)

  bindScroll: ->
    @background.interactive = true
    @background.on('mouseover', ->
      console.log("h world")
    )

  initializeNodes: ->
    for person in @people
      node = new PersonNode(@stage, person)

      if person == @root
        @rootNode = node

  animate: =>
    requestAnimationFrame(@animate)

    x = 500 if x == undefined
    y = 500 if y == undefined

    @rootNode.displayTree(x, y)
    @rootNode.update()

    @renderer.render(@stage)
