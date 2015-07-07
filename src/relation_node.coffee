class RelationNode

  LINE_WIDTH = 2

  constructor: (stage, relation) ->
    @stage    = stage
    @relation = relation
    @dirty    = true

    @relation.node = this

    @initializeLine()

  initializeLine: ->
    @graphics = new PIXI.Graphics()
    @stage.addChild(@graphics)

  globalWidth: ->
    size =  0
    size += @relation.husband.node.width()
    size += @relation.wife.node.width()
    size += @relation.husband.node.MARGIN
    size += # chaque enfant + partenaires + globalWidth des relations
    size

  # width: ->
  #   @graphics.width

  # height: ->
  #   @graphics.height

  # position: ->
  #   @text.position

  # setPosition: (x, y) ->
  #   @text.position.x = x
  #   @text.position.y = y
  #   @dirty = true

  drawLine: (from, to) ->
    @graphics.clear
    @graphics.lineStyle(LINE_WIDTH, 0x333333, 1)
    @graphics.moveTo(from.x, from.y)
    @graphics.lineTo(to.x, to.y)
    false
