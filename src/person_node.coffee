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
      @vLine.lineTo(0, -Constants.verticalMargin / 2)
      @stage.addChild(@vLine)

  displayTree: (x, y) ->
    @root           = true
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

  update: ->
    @updatePosition()

    if @dirtyRoot
      @updatePartnerPositions()
      @updateRelationPositions()
      #@updateRelationChildren()

      if @dirtyIterator == 20
        @dirtyRoot = false
      @dirtyIterator++

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

  updateRelationPositions: ->
    startY = endY = @graphics.position.y + Constants.height / 2

    if @person.sex == 'M'
      distance = @text.position.x + @width() / 2 # right of the first box
    else if @person.sex == 'F'
      distance = @text.position.x - @width() / 2 # left of the first box

    for partnerRelation, i in @person.partnerRelations
      lineWidth = partnerRelation.node.lineWidth()

      if @person.sex == 'M'
        distance          = distance + previousLineWidth + previousNodeWidth if i != 0
        startX            = distance - Constants.lineWidth / 2
        endX              = distance + lineWidth
        previousNodeWidth = partnerRelation.wife.node.width()
      else if @person.sex == 'F'
        distance          = distance - previousLineWidth - previousNodeWidth if i != 0
        startX            = distance + Constants.lineWidth / 2
        endX              = distance - lineWidth
        previousNodeWidth = partnerRelation.husband.node.width()

      previousLineWidth = lineWidth

      # Small horizontal line
      partnerRelation.node.drawHLine({ x: startX, y: startY }, { x: endX, y: endY })

      # Vertical line in the middle of relation
      if partnerRelation.children.length > 0
        middleX                               = (startX + endX) / 2
        partnerRelation.node.vLine.position.x = middleX
        partnerRelation.node.vLine.position.y = startY + Constants.verticalMargin / 4

        @updateRelationChildrenPositions(
          partnerRelation,
          startX,
          @text.position.y + @graphics.height / 2 + Constants.verticalMargin
        )

  updateRelationChildrenPositions: (partnerRelation, lineStartX, y) ->
    children = partnerRelation.children
    startX   = lineStartX - @width() + children[0].node.width() / 2 if children.length

    for child, i in partnerRelation.children
      child.node.setPosition(startX, y)
      startX += Constants.margin + child.node.width() / 2
      startX += children[i+1].node.width() / 2 if i+1 < children.length
      child.node.update()

    # display horizontal line between all children
    if children.length > 1
      startX = children[0].node.text.position.x
      endX   = _.last(children).node.text.position.x
      startY = endY = y + Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2

      partnerRelation.node.drawChildrenHLine({ x: startX, y: startY }, { x: endX, y: endY })

