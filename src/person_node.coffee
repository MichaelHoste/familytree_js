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

  setPosition: (x, y, apply = true) ->
    @x = x
    @y = y

    if apply
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

  # leftmost node (in himself, relations or children)
  leftMostNode: ->
    if @person.partnerRelations.length
      xArray      = _.collect(@person.partnerRelations[0].children, (child) -> child.node.leftMostNode())
      partnerType = if @person.sex == 'M' then 'wife' else 'husband'
      partner     = @person.partnerRelations[0][partnerType]
      xArray.push(partner.node.x)
    else
      xArray = []

    xArray.push(@x)
    _.min(xArray)

  # leftmost node (in himself, relations or children)
  rightMostNode: ->
    if @person.partnerRelations.length
      xArray      = _.collect(@person.partnerRelations[0].children, (child) -> child.node.rightMostNode())
      partnerType = if @person.sex == 'M' then 'wife' else 'husband'
      partner     = @person.partnerRelations[0][partnerType]
      xArray.push(partner.node.x)
    else
      xArray = []

    xArray.push(@x)
    _.max(xArray)

  # size of himself, relations and children
  size: ->
    @rightMostNode() - @leftMostNode() + Constants.width

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
    @updateTopPeople()

  updateBottomPeople: ->
    @updatePartnerPositions()
    @drawRelationLines()
    @updateChildrenPositions()
    @drawHorizontalLineBetweenChildren()
    @drawRelationTopVerticalLine()

  updateTopPeople: ->
    if @person.parentRelation
      y  = @y - Constants.verticalMargin - Constants.height / 2

      @updateParentsPosition(y)
      @drawParentsHLine(y)
      @updateParentsVLinePosition()
      @updateSiblingsPositions()
      @drawSiblingsHLine(y)

      # if @person.parentRelation
      #   @person.father().node.updateTopPeople()
      #   @person.mother().node.updateTopPeople()

  updatePartnerPositions: ->
    distance = 0

    for partnerRelation, i in @person.partnerRelations
      if i == 0
        offset = Constants.width + Constants.margin

        if @person.sex == 'M'
          partnerRelation.wife.node.setPosition(@x + offset, @y)
        else if @person.sex == 'F'
          partnerRelation.husband.node.setPosition(@x - offset, @y)

  drawRelationLines: ->
    if @person.partnerRelations.length
      husbandsX = _.collect([@person.partnerRelations[0]], (p) -> p.husband.node.x)
      wivesX    = _.collect([@person.partnerRelations[0]], (p) -> p.wife.node.x)

      minX = _.min(husbandsX.concat(wivesX), (value) -> value)
      maxX = _.max(husbandsX.concat(wivesX), (value) -> value)

      for partnerRelation in @person.partnerRelations
        partnerRelation.node.setHLine(minX, maxX, @y)
        partnerRelation.node.drawHLine()

  updateChildrenPositions: ->
    for partnerRelation, i in @person.partnerRelations
      if i == 0
        husband  = partnerRelation.husband
        wife     = partnerRelation.wife
        children = partnerRelation.children

        start = (husband.node.x + wife.node.x) / 2

        if children.length > 1
          childrenSize = partnerRelation.node.globalWidth()
          start        = start - childrenSize / 2 + Constants.width / 2

        for child, i in children
          offset = child.node.x - child.node.leftMostNode()

          child.node.setPosition(start + offset, @y + Constants.height / 2 + Constants.verticalMargin)
          child.node.updateBottomPeople()

          if child.partnerRelations.length
            start = start + child.partnerRelations[0].node.globalWidth() + Constants.margin
          else
            start = start + Constants.width + Constants.margin

  drawHorizontalLineBetweenChildren: ->
    for partnerRelation, i in @person.partnerRelations
      if i == 0
        children = partnerRelation.children

        if children.length > 1
          partnerRelation.node.childrenHLineStartX = children[0].node.x
          partnerRelation.node.childrenHLineEndX   = _.last(children).node.x
          partnerRelation.node.childrenHLineY      = @y + Constants.verticalMargin / 2
          partnerRelation.node.drawChildrenHLine()

  drawRelationTopVerticalLine: ->
    for partnerRelation, i in @person.partnerRelations
      if i == 0
        children = partnerRelation.children

        if children.length
          startX = partnerRelation.husband.node.x
          endX   = partnerRelation.wife.node.x

          partnerRelation.node.vLine.position.x = (startX + endX) / 2
          partnerRelation.node.vLine.position.y = @y + Constants.verticalMargin / 4

  updateParentsPosition: (y) ->
    father = @person.parentRelation.husband
    mother = @person.parentRelation.wife

    father.node.setPosition(@x - Constants.margin / 2 - Constants.width / 2, y)
    mother.node.setPosition(@x + Constants.margin / 2 + Constants.width / 2, y)

  drawParentsHLine: (y) ->
    parentRelationNode = @person.parentRelation.node
    husband            = @person.parentRelation.husband
    wife               = @person.parentRelation.wife

    parentRelationNode.hLineStartX = husband.node.x + Constants.width / 2
    parentRelationNode.hLineEndX   = wife.node.x    - Constants.width / 2
    parentRelationNode.hLineY      = y
    parentRelationNode.drawHLine()

  updateParentsVLinePosition: ->
    husband            = @person.parentRelation.husband
    wife               = @person.parentRelation.wife
    parentRelationNode = @person.parentRelation.node

    parentRelationNode.vLine.position.x = (husband.node.x + wife.node.x) / 2
    parentRelationNode.vLine.position.y = @y - Constants.verticalMargin - Constants.lineWidth

  updateSiblingsPositions: ->
    children    = @person.parentRelation.children
    personIndex = _.findIndex(children, @person)

    # Update positions of sibblings (to know the global size of this part)
    for child, i in children
      if i != personIndex
        child.node.setPosition(@x - 1000, @y)
        child.node.updateBottomPeople()

    # Display left siblings and descendants
    leftDistance = @x - @leftMostNode()  + Constants.width / 2
    offset       = 0

    for i in [0..personIndex]
      if i != personIndex
        child = children[i]
        childrenRightDistance = child.node.rightMostNode() - child.node.x + Constants.width / 2
        child.node.setPosition(@x - (leftDistance + childrenRightDistance + Constants.margin + offset), @y)
        child.node.updateBottomPeople()
        offset = offset + child.node.size() + Constants.margin

    # Display right siblings and descendants
    rightDistance = @rightMostNode() - @x + Constants.width / 2
    offset        = 0

    for i in [personIndex..children.length-1]
      if i != personIndex
        child = children[i]
        childrenLeftDistance = child.node.x - child.node.leftMostNode() + Constants.width / 2
        child.node.setPosition(@x + (rightDistance + childrenLeftDistance + Constants.margin + offset), @y)
        child.node.updateBottomPeople()
        offset = offset + child.node.size() + Constants.margin

  drawSiblingsHLine: (y) ->
    parentRelationNode = @person.parentRelation.node
    children           = @person.parentRelation.children

    parentRelationNode.childrenHLineStartX = _.min(children, (child) -> child.node.x).node.x
    parentRelationNode.childrenHLineEndX   = _.max(children, (child) -> child.node.x).node.x
    parentRelationNode.childrenHLineY      = y + Constants.verticalMargin / 2
    parentRelationNode.drawChildrenHLine()
