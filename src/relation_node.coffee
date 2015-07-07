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
    Math.max(@relationWidth(), @childrenWidth())

  lineWidth: ->
    @globalWidth() - @relation.husband.node.width() - @relation.wife.node.width()

  relationWidth: ->
    size =  @relation.husband.node.width()
    size += @relation.wife.node.width()
    size += Constants.margin
    size

  childrenWidth: ->
    # add relations of children and take size into account
    size = 0
    for child in @relation.children
      size += child.node.width()
      size += Constants.margin

    size -= Constants.margin if @relation.children.length > 0
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
    @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)
    @graphics.moveTo(from.x, from.y)
    @graphics.lineTo(to.x, to.y)
    false
