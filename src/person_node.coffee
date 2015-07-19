class @PersonNode

  constructor: (stage, person) ->
    @stage  = stage
    @person = person
    @root   = false
    @x      = 0
    @y      = 0

    @person.node = this

    @initializeVLine()
    @initializeRectangle()
    @initializeText()

    @bindRectangle()

  initializeRectangle: ->
    color = if @person.sex == 'M' then 0xB4D8E7 else 0xFFC0CB

    @graphics = new PIXI.Graphics()
    @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)
    @graphics.beginFill(color)

    if @person.sex == 'M'
      @drawRectangle()
    else
      @drawRoundRectangle()

    @stage.addChild(@graphics)

  initializeText: ->
    @text = new PIXI.Text(@person.name,
      font:          "#{Constants.fontSize}px Arial"
      fill:          0x222222
      align:         'center'
      wordWrap:      true
      wordWrapWidth: Constants.width - Constants.padding / 2
    )

    @text.anchor.x = 0.5
    @text.anchor.y = 0.5

    @stage.addChild(@text)

  initializeVLine: ->
    if @person.parentRelation
      @vLine = new PIXI.Graphics()
      @vLine.lineStyle(Constants.lineWidth, 0x333333, 1)
      @vLine.moveTo(0, 0)
      @vLine.lineTo(0, -Constants.verticalMargin / 2)
      @stage.addChild(@vLine)

  drawRectangle: ->
    @graphics.drawRect(
      -Constants.width  / 2,
      -Constants.height / 2,
      Constants.width,
      Constants.height
    )

  drawRoundRectangle: ->
    @graphics.drawRoundedRect(
      -Constants.width  / 2,
      -Constants.height / 2,
      Constants.width,
      Constants.height,
      Constants.height  / 4
    )

  bindRectangle: ->
    @graphics.interactive = true

    @graphics.on('mouseover', => $('#family-tree').css('cursor', 'pointer'))

    @graphics.on('mouseout', => $('#family-tree').css('cursor', 'default'))

    @graphics.on('click', =>
      @stage.familyTree.rootNode.root      = false
      @stage.familyTree.rootNode           = @
      @stage.familyTree.root               = @person

      @stage.familyTree.refreshMenu()

      @stage.familyTree.cleanTree()
      @stage.familyTree.x = @stage.familyTree.width  / 2
      @stage.familyTree.y = @stage.familyTree.height / 2
      @displayTree(@stage.familyTree.x, @stage.familyTree.y)
    )

    @graphics.on('mousedown',       @stage.background._events.mousedown.fn)
    @graphics.on('touchstart',      @stage.background._events.touchstart.fn)
    @graphics.on('mouseup',         @stage.background._events.mouseup.fn)
    @graphics.on('touchend',        @stage.background._events.touchend.fn)
    @graphics.on('mouseupoutside',  @stage.background._events.mouseupoutside.fn)
    @graphics.on('touchendoutside', @stage.background._events.touchendoutside.fn)

  partnersWidth: ->
    size = 0
    for partnerRelation in @person.partnerRelations
      size += partnerRelation.node.globalWidth() - @width()
    size

  position: ->
    @text.position

  setPosition: (x, y) ->
    @x = x
    @y = y

    # Rectangle
    @graphics.position.x = x
    @graphics.position.y = y

    # Text
    @text.position.x = x
    @text.position.y = y

    # Parent line
    if @person.parentRelation
      @vLine.position.x = x
      @vLine.position.y = y - Constants.height / 2

  hideRectangle: ->
    @graphics.position.x = -1000
    @graphics.position.y = -1000
    @text.position.x     = -1000
    @text.position.y     = -1000

  hideVLine: ->
    @vLine.position.x  = -1000 if @vLine
    @vLine.position.y  = -1000 if @vLine

  displayTree: (x, y) ->
    @root = true
    @setPosition(x, y)
    @updateBottomPeople()

  updateBottomPeople: ->
    @drawRelationLines()
    @updatePartnerPositions()
    @updateChildrenPositions()
    # @drawRelationTopVerticalLine()
    # @drawHorizontalLineBetweenChildren()

  updatePartnerPositions: ->
    distance = 0

    for partnerRelation, i in @person.partnerRelations
      if i == 0
        offset = Constants.width + Constants.margin

        if @person.sex == 'M'
          partnerRelation.wife.node.setPosition(@x + offset, @y)
        else if @person.sex == 'F'
          partnerRelation.husband.node.setPosition(@x - offset, @y)
      else
        previousHusband = @person.partnerRelations[i-1].husband
        previousWife    = @person.partnerRelations[i-1].wife
        previousCenterX = (previousHusband.node.x + previousWife.node.x) / 2

        children        = partnerRelation.children
        childrenSize    = if children.length > 1 then children.length * Constants.width + (children.length-1) * Constants.margin else 0
        distance        = @person.partnerRelations[i-1].node.globalWidth() / 2 + Constants.width / 2 + Constants.margin + childrenSize / 2

        if @person.sex == 'M'
          partnerRelation.wife.node.setPosition(previousCenterX + distance, @y)
        else if @person.sex == 'F'
          partnerRelation.husband.node.setPosition(previousCenterX - distance, @y)

  drawRelationLines: ->
    husbandsX = _.collect(@person.partnerRelations, (p) -> p.husband.node.x)
    wivesX    = _.collect(@person.partnerRelations, (p) -> p.wife.node.x)

    minX = _.min(husbandsX.concat(wivesX), (value) -> value)
    maxX = _.max(husbandsX.concat(wivesX), (value) -> value)

    for partnerRelation in @person.partnerRelations
      partnerRelation.node.setHLine(minX, maxX, @y)
      partnerRelation.node.drawHLine()

  updateChildrenPositions: ->
    for partnerRelation, i in @person.partnerRelations
      husband  = partnerRelation.husband
      wife     = partnerRelation.wife
      children = partnerRelation.children

      if i == 0
        start = (husband.node.x + wife.node.x) / 2
      else
        previousHusband = @person.partnerRelations[i-1].husband
        previousWife    = @person.partnerRelations[i-1].wife
        previousCenterX = (previousHusband.node.x + previousWife.node.x) / 2

        childrenSize    = if children.length > 1 then children.length * Constants.width + (children.length-1) * Constants.margin else 0

        distance = @person.partnerRelations[i-1].node.globalWidth() / 2 + Constants.width / 2 + Constants.margin + childrenSize / 2
        start    = previousCenterX - distance

      if children.length > 1
        childrenSize = children.length * Constants.width + (children.length-1) * Constants.margin
        start        = start + Constants.width / 2 - childrenSize / 2

      for child in children
        child.node.setPosition(start, @y + Constants.verticalMargin)
        start = start + Constants.width + Constants.margin

  drawHorizontalLineBetweenChildren: ->
    for partnerRelation in @person.partnerRelations
      children = partnerRelation.children

      if children.length > 1
        partnerRelation.node.childrenHLineStartX = children[0].node.text.position.x
        partnerRelation.node.childrenHLineEndX   = _.last(children).node.text.position.x
        partnerRelation.node.childrenHLineY      = @text.position.y + Constants.baseLine + Constants.verticalMargin / 2 + Constants.lineWidth
        partnerRelation.node.drawChildrenHLine()

  drawRelationTopVerticalLine: ->
    for partnerRelation in @person.partnerRelations
      children = partnerRelation.children
      if children.length
        startX   = children[0].node.text.position.x
        endX     = _.last(children).node.text.position.x
        y        = partnerRelation.node.hLineY

        partnerRelation.node.vLine.position.x = (startX + endX) / 2
        partnerRelation.node.vLine.position.y = y + Constants.verticalMargin / 4

  updateTopPeople: ->
    if @person.parentRelation
      y  = @text.position.y - @graphics.height / 2 - Constants.verticalMargin

      @updateParentsPosition(y)
      @drawParentsHLine(y)
      @updateParentsVLinePosition()
      @updateParentsChildrenPositions()
      @drawParentsChildrenHLine(y)

      if @person.parentRelation
        @person.father().node.updateTopPeople()
      #   @person.father().node.updatePartnerPositions()
      #   @person.father().node.drawRelationLines()
        @person.mother().node.updateTopPeople()
      #   @person.mother().node.updatePartnerPositions()
      #   @person.mother().node.drawRelationLines()
      #
      #   for partner in _.without(@person.mother().partners(), @person.father())
      #     partner.node.updateChildrenPositions()
      #     partner.node.drawRelationTopVerticalLine()
      #     partner.node.drawHorizontalLineBetweenChildren()
      #   for partner in _.without(@person.father().partners(), @person.mother())
      #     partner.node.updateChildrenPositions()
      #     partner.node.drawRelationTopVerticalLine()
      #     partner.node.drawHorizontalLineBetweenChildren()

  # si c'est un mec,    on met ses partenaires à droite et ses frères et soeurs à gauche
  # Si c'est une fille, on met ses partenaires à gauche et ses frères et soeurs à droite
  # le père est toujours en haut à gauche
  # la mère est toujours en haut à droite
  # Ajouter condition si la largeur des enfants est plus petite que celle des parents
  updateParentsPosition: (y) ->
    partnerRelations = @person.partnerRelations
    husband          = @person.parentRelation.husband
    wife             = @person.parentRelation.wife

    if @person.parentRelation.children.length == 1 && partnerRelations.length == 0
      husband.node.setPosition(@text.position.x - (wife.node.width() + husband.node.width() + Constants.margin) / 2 + husband.node.width() / 2, y)
      wife.node.setPosition(   @text.position.x + (wife.node.width() + husband.node.width() + Constants.margin) / 2 - wife.node.width()    / 2, y)
      husband.node.update()
      wife.node.update()
    else
      if @person.sex == 'M'
        # Siblings on left-side (and father on the edge)
        h_offset = 0
        for child, i in @person.parentRelation.children
          if child != @person
            h_offset += child.node.partnersWidth() + child.node.width() + Constants.margin

        h_offset = Math.max(h_offset, Constants.margin/2)
        h_offset = h_offset + @width() / 2 - husband.node.width() / 2
        husband.node.setPosition(@text.position.x - h_offset, y)
        husband.node.update()

        # Partners on right-side (and mother on the edge)
        w_offset = @partnersWidth()
        w_offset = Math.max(w_offset, Constants.margin/2)
        w_offset = w_offset + @width() / 2 - wife.node.width() / 2
        wife.node.setPosition(@text.position.x + w_offset, y)
        wife.node.update()
      else if @person.sex == 'F'
        # Siblings on right-side (and mother on the edge)
        w_offset = 0
        for child, i in @person.parentRelation.children
          if child != @person
            w_offset += child.node.partnersWidth() + child.node.width() + Constants.margin

        w_offset = Math.max(w_offset, Constants.margin/2)
        w_offset = w_offset + @width() / 2 - wife.node.width() / 2
        wife.node.setPosition(@text.position.x + w_offset, y)
        wife.node.update()

        # Partners on left-side (and father on the edge)
        h_offset = @partnersWidth()
        h_offset = Math.max(h_offset, Constants.margin/2)
        h_offset = h_offset + @width() / 2 - husband.node.width() / 2
        husband.node.setPosition(@text.position.x - h_offset, y)
        husband.node.update()

  drawParentsHLine: (y) ->
    parentRelationNode = @person.parentRelation.node
    husband            = @person.parentRelation.husband
    wife               = @person.parentRelation.wife

    parentRelationNode.hLineStartX = husband.node.text.x + husband.node.width() / 2
    parentRelationNode.hLineEndX   = wife.node.text.x    - wife.node.width() / 2
    parentRelationNode.hLineY      = y + Constants.baseLine
    parentRelationNode.drawHLine()

  updateParentsVLinePosition: ->
    parentRelationNode = @person.parentRelation.node

    if @person.parentRelation.children.length > 1
      if @person.sex == 'M' # man has siblings on the left
        parentLimit = @person.father()
      else if @person.sex == 'F' # woman has siblings on the right
        parentLimit = @person.mother()

      parentRelationNode.vLine.position.x = (@text.position.x + parentLimit.node.text.position.x) / 2
      parentRelationNode.vLine.position.y = @graphics.position.y - Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2
    else
      parentRelationNode.vLine.position.x = @vLine.position.x
      parentRelationNode.vLine.position.y = @graphics.position.y - Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2 + Constants.lineWidth

  updateParentsChildrenPositions: ->
    y = @text.position.y
    parentRelationNode      = @person.parentRelation.node
    children                = @person.parentRelation.children
    children_without_himself = _.without(children, @person)

    offset =  @width() / 2
    offset += children_without_himself[0].node.width() / 2 + Constants.margin if children_without_himself.length > 0

    for child, i in children_without_himself
      if @person.sex == 'F'
        if child.sex == 'M'
          child.node.setPosition(@text.position.x + offset, y)
        else if child.sex == 'F'
          child.node.setPosition(@text.position.x + child.node.partnersWidth() + offset, y)
      else if @person.sex == 'M'
        if child.sex == 'F'
          child.node.setPosition(@text.position.x - offset, y)
        else if child.sex == 'M'
          child.node.setPosition(@text.position.x - child.node.partnersWidth() - offset, y)

      child.node.updateBottomPeople()
      child.node.update()
      offset += child.node.partnersWidth() + child.node.width() + Constants.margin

  drawParentsChildrenHLine: (y) ->
    parentRelationNode = @person.parentRelation.node
    children           = @person.parentRelation.children

    parentRelationNode.childrenHLineStartX = _.min(children, (child) -> child.node.text.position.x).node.text.position.x
    parentRelationNode.childrenHLineEndX   = _.max(children, (child) -> child.node.text.position.x).node.text.position.x
    parentRelationNode.childrenHLineY      = y + Constants.baseLine + Constants.verticalMargin / 2
    parentRelationNode.drawChildrenHLine()
