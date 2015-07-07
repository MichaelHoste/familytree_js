class PersonNode

  HEIGHT     = 40
  FONT_SIZE  = 15
  PADDING    = 20
  MARGIN     = 40
  LINE_WIDTH = 2

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
    @graphics.lineStyle(LINE_WIDTH, 0x333333, 1)
    @graphics.beginFill(color)

    if @person.sex == 'M'
      @graphics.drawRect(0, 0, 200, HEIGHT)
    else
      @graphics.drawRoundedRect(0, 0, 200, HEIGHT, HEIGHT/5)

    @graphics.position.x = -1000
    @graphics.position.y = -1000

    @stage.addChild(@graphics)

  initializeText: ->
    @text = new PIXI.Text(@person.name, { font : "#{FONT_SIZE}px Arial", fill : 0x222222 })
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
    @update_position()

    if @dirty_root
      @update_partner_positions()
      @update_relation_positions()

      if @dirty_iterator == 5
        @dirty_root = false
      @dirty_iterator++

  update_position: ->
    if @dirty_position
      @graphics.width      = @text.width + PADDING
      @graphics.position.x = @text.position.x - @text.width / 2 - PADDING / 2
      @graphics.position.y = @text.position.y - @text.height + 6
      @dirty_position = false

  update_partner_positions: ->
    distance     = 0
    lastBoxWidth = @width()
    for partner in @person.partners()
      if @person.sex == 'M'
        distance = distance + MARGIN + lastBoxWidth/2 + partner.node.width()/2
      else
        distance = distance - MARGIN - lastBoxWidth/2 - partner.node.width()/2

      lastBoxWidth = partner.node.width()

      partner.node.setPosition(@text.position.x + distance, @text.position.y)
      partner.node.update()

  update_relation_positions: ->
    startY = endY = @graphics.position.y + HEIGHT/2
    distance      = -MARGIN - @width()/2
    lastBoxWidth  = @width()

    for partnerRelation in @person.partnerRelations
      distance = distance + lastBoxWidth + MARGIN

      if @person.sex == 'M'
        lastBoxWidth = partnerRelation.wife.node.width()
        startX = @text.position.x + distance - LINE_WIDTH/2
        endX   = @text.position.x + distance + MARGIN
      else
        lastBoxWidth = partnerRelation.husband.node.width()
        startX = @text.position.x - distance + LINE_WIDTH/2
        endX   = @text.position.x - distance - MARGIN

      partnerRelation.node.drawLine({ x: startX, y: startY }, { x: endX,   y: endY })
