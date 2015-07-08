class RelationNode

  constructor: (stage, relation) ->
    @stage    = stage
    @relation = relation
    @dirty    = true

    @relation.node = this

    @initializeHLine()
    @initializeVLine()
    @initializeChildrenHLine()

  initializeHLine: ->
    @hLine = new PIXI.Graphics()
    @stage.addChild(@hLine)

  initializeVLine: ->
    @vLine = new PIXI.Graphics()
    @vLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @vLine.moveTo(0, -Constants.verticalMargin / 4)
    @vLine.lineTo(0,  Constants.verticalMargin / 4)
    @stage.addChild(@vLine)

  initializeChildrenHLine: ->
    @childrenHLine = new PIXI.Graphics()
    @stage.addChild(@childrenHLine)

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
      if child.partnerRelations.length > 0
        size += child.node.width()

        for partnerRelation in child.partnerRelations
          size += partnerRelation.node.globalWidth() - child.node.width()
      else
        size += child.node.width()
      size += Constants.margin

    size -= Constants.margin if @relation.children.length > 0

    size

  drawHLine: (from, to) ->
    @hLine.clear()
    @hLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @hLine.moveTo(from.x, from.y)
    @hLine.lineTo(to.x, to.y)
    false

  drawChildrenHLine: (from, to) ->
    @childrenHLine.clear()
    @childrenHLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @childrenHLine.moveTo(from.x, from.y)
    @childrenHLine.lineTo(to.x, to.y)
    false
