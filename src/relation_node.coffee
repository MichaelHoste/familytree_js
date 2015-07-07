class RelationNode

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
    Math.min(@relationWidth(), @childrenWidth())

  lineWidth: ->
    @globalWidth() - @relation.husband.node.width() - @relation.wife.node.width()

  relationWidth: ->
    size = 0
    size += @relation.husband.node.width()
    size += @relation.wife.node.width()
    size += Constants.margin
    size

  childrenWidth: ->
    #size += # chaque enfant + partenaires + globalWidth des relations
    #size
    10000

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
    @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)
    @graphics.moveTo(from.x, from.y)
    @graphics.lineTo(to.x, to.y)
    false
