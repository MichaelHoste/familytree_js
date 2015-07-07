class PersonNode

  constructor: (stage, person) ->
    @stage  = stage
    @person = person

    @root            = false
    @dirty_root      = false
    @dirty_position  = true
    @dirty_iterator  = 0

    @person.node = this

    @initializeRectangle()
    @initializeText()

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

  displayTree: (x, y) ->
    @root           = true
    @dirty_root     = true
    @dirty_iterator = 0
    @setPosition(x, y)

  width: ->
    @graphics.width

  position: ->
    @text.position

  setPosition: (x, y) ->
    @text.position.x = x
    @text.position.y = y
    @dirty_position  = true

  update: ->
    @updatePosition()

    if @dirty_root
      @updatePartnerPositions()
      @updateRelationPositions()

      if @dirty_iterator == 5
        @dirty_root = false
      @dirty_iterator++

  updatePosition: ->
    if @dirty_position
      @graphics.width      = @text.width + Constants.padding
      @graphics.position.x = @text.position.x - @text.width / 2 - Constants.padding / 2
      @graphics.position.y = @text.position.y - @text.height + 6
      @dirty_position = false

  updatePartnerPositions: ->
    distance     = 0
    lastBoxWidth = @width()
    for partner, i in @person.partners()
      if @person.sex == 'M'
        distance = distance + Constants.margin + lastBoxWidth/2 + partner.node.width()/2
      else
        distance = distance - Constants.margin - lastBoxWidth/2 - partner.node.width()/2

      lastBoxWidth = partner.node.width()

      partner.node.setPosition(@text.position.x + distance, @text.position.y)
      partner.node.update()

  updateRelationPositions: ->
    startY = endY = @graphics.position.y + Constants.height/2

    if @person.sex == 'M'
      distance = @text.position.x + @width() / 2 # right of the first box
    else if @person.sex == 'F'
      distance = @text.position.x - @width() / 2 # left of the first box

    for partnerRelation, i in @person.partnerRelations
      lineWidth = partnerRelation.node.lineWidth()

      if @person.sex == 'M'
        distance = distance + lineWidth + partnerRelation.wife.node.width() if i != 0
        startX   = distance - Constants.lineWidth/2
        endX     = distance + lineWidth
      else if @person.sex == 'F'
        distance = distance - lineWidth - partnerRelation.wife.node.width() if i != 0
        startX   = distance + Constants.lineWidth/2
        endX     = distance - lineWidth

      partnerRelation.node.drawLine({ x: startX, y: startY }, { x: endX,   y: endY })
