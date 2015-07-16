class @PersonNode

  constructor: (stage, person) ->
    @stage  = stage
    @person = person

    @root           = false
    @dirtyRoot      = false
    @dirtyPosition  = true
    @dirtyIterator  = 0

    @initializeNodes()

    @initializeRectangle()
    @initializeText()
    @initializeVLine()

    @bindRectangle()

  initializeNodes: ->
    @person.node = this

    for partnerRelation in @person.partnerRelations
      if partnerRelation.node == undefined
        new RelationNode(@stage, partnerRelation)
      else
        partnerRelation.node.initializeLines()

  initializeRectangle: ->
    color = if @person.sex == 'M' then 0xB4D8E7 else 0xFFC0CB

    @graphics = new PIXI.Graphics()

    if @root
      @graphics.lineStyle(Constants.lineWidth, 0x999999, 1)
    else
      @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)

    @graphics.beginFill(color)

    if @person.sex == 'M'
      @graphics.drawRect(0, 0, 200, Constants.height)
    else
      @graphics.drawRoundedRect(0, 0, 200, Constants.height, Constants.height/5)

    @graphics.position.x = -1000
    @graphics.position.y = -1000

    @stage.addChild(@graphics)

  bindRectangle: ->
    @graphics.interactive = true

    @graphics.on('mouseover', => $('#family-tree').css('cursor', 'pointer'))

    @graphics.on('mouseout', => $('#family-tree').css('cursor', 'default'))

    @graphics.on('click', =>
      @stage.familyTree.rootNode.root      = false
      @stage.familyTree.rootNode.dirtyRoot = false
      @stage.familyTree.rootNode           = @
      @stage.familyTree.root               = @person
      @dirtyRoot                           = true

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

  width: ->
    @graphics.width

  partnersWidth: ->
    size = 0
    for partnerRelation in @person.partnerRelations
      size += partnerRelation.node.globalWidth() - @width()
    size

  position: ->
    @text.position

  setPosition: (x, y) ->
    @text.position.x = x
    @text.position.y = y
    @dirtyPosition   = true

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

  update: ->
    @updatePosition()

    if @dirtyRoot
      @updateBottomPeople()
      @updateTopPeople()

      if @dirtyIterator >= 10
        @dirtyRoot = false
      @dirtyIterator++

  updateBottomPeople: ->
    @updatePartnerPositions()
    @drawRelationLines()
    @updateChildrenPositions()
    @drawRelationTopVerticalLine()
    @drawHorizontalLineBetweenChildren()

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
    y = @text.position.y + Constants.baseLine + Constants.lineWidth

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
    for partnerRelation, i in @person.partnerRelations
      startX     = partnerRelation.node.hLineStartX
      endX       = partnerRelation.node.hLineEndX
      y          = @text.position.y + @graphics.height / 2 + Constants.verticalMargin
      lineStartX = if @person.sex == 'M' then startX else endX
      children   = partnerRelation.children

      if children.length > 1
        #size   = children[i].node.partnersWidth()
        startX = lineStartX - partnerRelation.husband.node.width() + children[0].node.width() / 2 #+ size
      else if children.length == 1
        if i == 0 # first (and only?) partner
          personPosition1 = partnerRelation.husband.node.text.position
          personPosition2 = partnerRelation.wife.node.text.position
        else      # many partners
          if @person.sex == 'M'
            personPosition1 = @person.partnerRelations[i-1].wife.node.text.position
            personPosition2 = partnerRelation.wife.node.text.position
          else if @person.sex == 'F'
            personPosition1 = @person.partnerRelations[i-1].husband.node.text.position
            personPosition2 = partnerRelation.husband.node.text.position

        startX = (personPosition1.x + personPosition2.x) / 2
      else
        startX = 0

      # update positions of children
      for child, j in partnerRelation.children
        child.node.setPosition(startX, y)
        child.node.update()
        child.node.updateBottomPeople()

        startX += Constants.margin + child.node.width()
        if child.sex == 'M'
          startX += child.node.partnersWidth()
        if j+1 < children.length && children[j+1].sex == 'F'
          startX += children[j+1].node.partnersWidth()

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
