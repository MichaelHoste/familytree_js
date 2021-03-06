class @RelationNode

  constructor: (stage, relation) ->
    @stage    = stage
    @relation = relation

    @relation.node = this

    @initializeLines()

  initializeLines: ->
    @initializeHLine()
    @initializeVLine()
    @initializeChildrenHLine()

  initializeHLine: ->
    @hLineStartX = 0
    @hLineEndX   = 0
    @hLineY      = 0

    @hLine = new PIXI.Graphics()
    @stage.addChild(@hLine)

  initializeChildrenHLine: ->
    @childrenHLineStartX = 0
    @childrenHLineEndX   = 0
    @childrenHLineY      = 0

    @childrenHLine = new PIXI.Graphics()
    @stage.addChild(@childrenHLine)

  initializeVLine: ->
    @vLine = new PIXI.Graphics()
    @vLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @vLine.moveTo(0, -Constants.verticalMargin / 4)
    @vLine.lineTo(0,  Constants.verticalMargin / 4)
    @stage.addChild(@vLine)

  globalWidth: ->
    Math.max(@relationWidth(), @childrenWidth())

  relationWidth: ->
    2 * Constants.width + Constants.margin

  childrenWidth: ->
    # add relations of children and take size into account
    size = 0
    for child in @relation.children
      if child.partnerRelations.length > 0
        size += Constants.width

        for partnerRelation in child.partnerRelations
          size += partnerRelation.node.globalWidth() - Constants.width
      else
        size += Constants.width
      size += Constants.margin

    size -= Constants.margin if @relation.children.length > 0

    size

  hideLines: ->
    @hLineStartX = 0
    @hLineEndX   = 0
    @drawHLine()
    @childrenHLineStartX = 0
    @childrenHLineEndX   = 0
    @drawChildrenHLine()
    @vLine.position.x = -1000
    @vLine.position.y = -1000

  setHLine: (startX, endX, y) ->
    @hLineStartX = startX
    @hLineEndX   = endX
    @hLineY      = y

  drawHLine: ->
    @hLine.clear()
    @hLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @hLine.moveTo(@hLineStartX, @hLineY)
    @hLine.lineTo(@hLineEndX,   @hLineY)
    false

  drawChildrenHLine: ->
    @childrenHLine.clear()
    @childrenHLine.lineStyle(Constants.lineWidth, 0x333333, 1)
    @childrenHLine.moveTo(@childrenHLineStartX, @childrenHLineY)
    @childrenHLine.lineTo(@childrenHLineEndX,   @childrenHLineY)
    false
