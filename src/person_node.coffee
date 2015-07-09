class PersonNode

  constructor: (stage, person) ->
    @stage  = stage
    @person = person

    @root           = false
    @dirtyRoot      = false
    @dirtyPosition  = true
    @dirtyIterator  = 0

    @person.node = this

    @initializeRectangle()
    @initializeText()
    @initializeVLine()

  initializeRectangle: ->
    color = if @person.sex == 'M' then 0xB4D8E7 else 0xFFC0CB

    @graphics = new PIXI.Graphics()
    @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)
    @graphics.beginFill(color)

    if @person.sex == 'M'
      @graphics.drawRect(0, 0, 200, Constants.height)
    else
      @graphics.drawRoundedRect(0, 0, 200, Constants.height, Constants.height/5)

    @graphics.position.x = -1000
    @graphics.position.y = -1000

    @stage.addChild(@graphics)

  initializeText: ->
    @text = new PIXI.Text(@person.name, { font : "#{Constants.fontSize}px Arial", fill : 0x222222 })
    @text.position.x = -1000
    @text.position.y = -1000
    @text.anchor.x   = 0.5

    @stage.addChild(@text)

  initializeVLine: ->
    if @person.parentRelation
      @vLine = new PIXI.Graphics()
      @vLine.lineStyle(Constants.lineWidth, 0x333333, 1)
      @vLine.moveTo(0, 0)
      @vLine.lineTo(0, -Constants.verticalMargin / 2 - Constants.lineWidth)
      @stage.addChild(@vLine)

  displayTree: (x, y) ->
    @root          = true
    @dirtyRoot     = true
    @dirtyIterator = 0
    @setPosition(x, y)

  width: ->
    @graphics.width

  position: ->
    @text.position

  setPosition: (x, y) ->
    @text.position.x = x
    @text.position.y = y
    @dirtyPosition   = true

  partnersWidth: ->
    size = 0
    for partnerRelation in @person.partnerRelations
      size += partnerRelation.node.globalWidth() - @width()
    size

  update: ->
    @updatePosition()

    if @dirtyRoot
      @display()

      #if @dirtyIterator == 10
      #  @dirtyRoot = false
      #@dirtyIterator++

  display: ->
    @updatePartnerPositions()
    @drawRelationLines()
    @updateChildrenPositions()
    @displayRelationTopVerticalLine()
    @displayHorizontalLineBetweenChildren()

  updatePosition: ->
    if @dirtyPosition
      # Adapt graphics to to text and position it
      @graphics.width      = @text.width + Constants.padding
      @graphics.position.x = @text.position.x - @text.width / 2 - Constants.padding / 2
      @graphics.position.y = @text.position.y - @text.height + Constants.baseLine

      # Position vLine on top of graphics
      if @person.parentRelation
        @vLine.position.x = @text.x
        @vLine.position.y = @graphics.position.y

      @dirtyPosition = false

  updatePartnerPositions: ->
    distance     = 0
    lastBoxWidth = @width()

    for partnerRelation, i in @person.partnerRelations
      if @person.sex == 'M'
        partnerNode  = partnerRelation.wife.node
        distance     = distance + partnerRelation.node.lineWidth() + lastBoxWidth/2 + partnerNode.width()/2
      else
        partnerNode  = partnerRelation.husband.node
        distance     = distance - partnerRelation.node.lineWidth() - lastBoxWidth/2 - partnerNode.width()/2

      lastBoxWidth = partnerNode.width()
      partnerNode.setPosition(@text.position.x + distance, @text.position.y)
      partnerNode.update()

  drawRelationLines: ->
    # y position of line
    y = @graphics.position.y + Constants.height / 2

    # x position to start the line
    if @person.sex == 'M'
      position = @text.position.x + @width() / 2 # right of the first box
    else if @person.sex == 'F'
      position = @text.position.x - @width() / 2 # left of the first box

    previousLineWidth = 0
    previousNodeWidth = 0

    for partnerRelation in @person.partnerRelations
      lineWidth = partnerRelation.node.lineWidth()

      if @person.sex == 'M'
        position          = position + previousLineWidth + previousNodeWidth
        startX            = position
        endX              = position + lineWidth
        previousNodeWidth = partnerRelation.wife.node.width()
      else if @person.sex == 'F'
        position          = position - previousLineWidth - previousNodeWidth
        startX            = position
        endX              = position - lineWidth
        previousNodeWidth = partnerRelation.husband.node.width()

      previousLineWidth = lineWidth

      # Small horizontal line
      partnerRelation.node.setHLine(startX, endX, y)
      partnerRelation.node.drawHLine()

  updateChildrenPositions: ->
    for partnerRelation in @person.partnerRelations
      startX     = partnerRelation.node.hLineStartX
      endX       = partnerRelation.node.hLineEndX
      y          = @text.position.y + @graphics.height / 2 + Constants.verticalMargin
      children   = partnerRelation.children
      lineStartX = if @person.sex == 'M' then startX else endX

      if children.length
        size   = children[0].node.partnersWidth()
        startX = lineStartX - partnerRelation.husband.node.width() + children[0].node.width() / 2 + size
      else
        startX = 0

      # update positions of children
      for child, i in partnerRelation.children
        child.node.setPosition(startX, y)
        child.node.display()

        startX += Constants.margin + child.node.width()
        startX += children[i+1].node.partnersWidth() if i+1 < children.length
        child.node.update()

  displayHorizontalLineBetweenChildren: ->
    for partnerRelation in @person.partnerRelations
      children = partnerRelation.children

      if children.length > 1
        partnerRelation.node.childrenHLineStartX = children[0].node.text.position.x
        partnerRelation.node.childrenHLineEndX   = _.last(children).node.text.position.x
        partnerRelation.node.childrenHLineY      = @text.position.y + Constants.baseLine + Constants.verticalMargin / 2 + Constants.lineWidth
        partnerRelation.node.drawChildrenHLine()

  displayRelationTopVerticalLine: ->
    for partnerRelation in @person.partnerRelations
      children = partnerRelation.children
      startX   = children[0].node.text.position.x
      endX     = _.last(children).node.text.position.x
      y        = partnerRelation.node.hLineY

      partnerRelation.node.vLine.position.x = (startX + endX) / 2
      partnerRelation.node.vLine.position.y = y + Constants.verticalMargin / 4
