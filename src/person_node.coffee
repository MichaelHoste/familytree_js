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
    @graphics = new PIXI.Graphics()
    @drawGraphics()
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

  drawGraphics: ->
    @graphics.lineStyle(Constants.lineWidth, 0x333333, 1)

    if @root
      color = 0xF1F1F1
    else
      if @person.sex == 'M'
        color = 0xB4D8E7
      else
        color = 0xFFC0CB

    @graphics.beginFill(color)

    if @person.sex == 'M'
      @drawRectangle()
    else
      @drawRoundRectangle()

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

    @graphics.on('mousedown',       @stage.background._events.mousedown.fn)
    @graphics.on('touchstart',      @stage.background._events.touchstart.fn)
    @graphics.on('mouseup',         @stage.background._events.mouseup.fn)
    @graphics.on('touchend',        @stage.background._events.touchend.fn)
    #@graphics.on('mouseupoutside',  @stage.background._events.mouseupoutside.fn)
    #@graphics.on('touchendoutside', @stage.background._events.touchendoutside.fn)

    @graphics.on('click', (mouseData) =>
      event      = mouseData.data.originalEvent
      familyTree = @stage.familyTree

      moveX = Math.abs(familyTree.startOffsetX - event.x)
      moveY = Math.abs(familyTree.startOffsetY - event.y)

      if moveX + moveY < 10
        familyTree.oldRootNode = familyTree.rootNode

        familyTree.rootNode.root = false
        familyTree.rootNode      = @
        familyTree.root          = @person

        familyTree.refreshMenu()

        familyTree.cleanTree()
        familyTree.x = familyTree.width  / 2
        familyTree.y = familyTree.height / 2
        @displayTree(familyTree.x, familyTree.y)
        familyTree.animate()
    )

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

      # Parent line (only if parent is displayed)
      if @person.parentRelation
        @vLine.position.x = x
        @vLine.position.y = y - Constants.height / 2

  # leftmost node (in himself, relations or children)
  leftMostNodeX: ->
    if @person.partnerRelations.length
      xArray      = _.collect(@person.partnerRelations[0].children, (child) -> child.node.leftMostNodeX())
      partnerType = if @person.sex == 'M' then 'wife' else 'husband'
      partner     = @person.partnerRelations[0][partnerType]
      xArray.push(partner.node.x)
    else
      xArray = []

    xArray.push(@x)
    _.min(xArray)

  # leftmost node (in himself, relations or children)
  rightMostNodeX: ->
    if @person.partnerRelations.length
      xArray      = _.collect(@person.partnerRelations[0].children, (child) -> child.node.rightMostNodeX())
      partnerType = if @person.sex == 'M' then 'wife' else 'husband'
      partner     = @person.partnerRelations[0][partnerType]
      xArray.push(partner.node.x)
    else
      xArray = []

    xArray.push(@x)
    _.max(xArray)

  # leftmost node (in parent's nodes)
  leftMostParentNodeX: ->
    peopleX = []

    for parent in @person.parents()
      peopleX.concat(_.collect(parent.siblings(), (person) -> person.node.x))

    if @person.parentRelation
      father = @person.parentRelation.husband
      mother = @person.parentRelation.wife

      peopleX.push(father.node.x) if father
      peopleX.push(mother.node.x) if mother

      peopleX.push(father.node.leftMostParentNodeX()) if father
      peopleX.push(mother.node.leftMostParentNodeX()) if mother

    _.min(peopleX)

  # rightmost node (in parent's nodes)
  rightMostParentNodeX: ->
    peopleX = []

    for parent in @person.parents()
      peopleX.concat(_.collect(parent.siblings(), (person) -> person.node.x))

    if @person.parentRelation
      father = @person.parentRelation.husband
      mother = @person.parentRelation.wife

      peopleX.push(father.node.x) if father
      peopleX.push(mother.node.x) if mother

      peopleX.push(father.node.rightMostParentNodeX()) if father
      peopleX.push(mother.node.rightMostParentNodeX()) if mother

    _.max(peopleX)

  # size of himself, relations and children
  size: ->
    @rightMostNodeX() - @leftMostNodeX() + Constants.width

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

    # Redraw this person with highlight
    @graphics.clear
    @drawGraphics()

    # Redraw old selected person to remove highlight
    if @stage.familyTree.oldRootNode
      @stage.familyTree.oldRootNode.graphics.clear()
      @stage.familyTree.oldRootNode.drawGraphics()

    @stage.familyTree.renderer.render(@stage)

    @setPosition(x, y)
    @updateBottomPeople()
    @updateTopPeople()

  updateBottomPeople: ->
    @updatePartnerPositions()
    @drawRelationLines()
    @updateChildrenPositions()
    @drawHorizontalLineBetweenChildren()
    @drawRelationTopVerticalLine()

  updateTopPeople: (align = 'center') ->
    if @person.parentRelation
      y  = @y - Constants.verticalMargin - Constants.height / 2

      @updateSiblingsPositions(align)
      @updateParentsPosition(y, align)
      @drawParentsHLine(y)
      @updateParentsVLinePosition()
      @drawSiblingsHLine(y)

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

        if children.length == 1
          start = start + Constants.width / 2 + Constants.margin / 2

        childrenSize = partnerRelation.node.globalWidth()
        start        = start - childrenSize / 2 + Constants.width / 2

        for child, i in children
          offset = child.node.x - child.node.leftMostNodeX()

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

  updateSiblingsPositions: (align = 'center') ->
    children    = @person.parentRelation.children
    personIndex = _.findIndex(children, @person)

    # Update positions of sibblings (to know the global size of this part)
    for child, i in children
      if i != personIndex
        child.node.setPosition(@x - 1000, @y, false)
        child.node.updateBottomPeople()

    # Display left siblings and descendants
    if align == 'center' || align == 'left'
      leftDistance = @x - @leftMostNodeX() + Constants.width / 2
      offset       = 0

      startIndex = if align == 'center' then personIndex else children.length-1

      for i in [startIndex..0]
        if i != personIndex
          child = children[i]
          childrenRightDistance = child.node.rightMostNodeX() - child.node.x + Constants.width / 2
          child.node.setPosition(@x - (leftDistance + childrenRightDistance + Constants.margin + offset), @y)
          child.node.updateBottomPeople()
          offset = offset + child.node.size() + Constants.margin

    # Display right siblings and descendants
    if align == 'center' || align == 'right'
      rightDistance = @rightMostNodeX() - @x + Constants.width / 2
      offset        = 0

      startIndex = if align == 'center' then personIndex else 0

      for i in [startIndex..children.length-1]
        if i != personIndex
          child = children[i]
          childrenLeftDistance = child.node.x - child.node.leftMostNodeX() + Constants.width / 2
          child.node.setPosition(@x + (rightDistance + childrenLeftDistance + Constants.margin + offset), @y)
          child.node.updateBottomPeople()
          offset = offset + child.node.size() + Constants.margin

  updateParentsPosition: (y, align = 'center') ->
    father = @person.parentRelation.husband
    mother = @person.parentRelation.wife

    if @person.siblings().length == 0
      parentsCenter = @x
    else
      right         = mother.node.rightMostNodeX()
      left          = father.node.leftMostNodeX()
      parentsCenter = left + (right - left) / 2

    ##
    if align == 'left' || align == 'right'
      # Update positions of top people (to know the global size of this part)
      # father.node.setPosition(@x - Constants.margin / 2, @y)
      # mother.node.setPosition(@x + Constants.margin / 2, @y)
      if father.parentRelation && mother.parentRelation
        father.node.updateTopPeople('left')
        mother.node.updateTopPeople('right')
      # If only 1 parent (or 0), align him/her on the center
      else
        father.node.updateTopPeople('center')
        mother.node.updateTopPeople('center')

      a = @leftMostParentNodeX()  - Constants.width / 2
      b = @rightMostParentNodeX() + Constants.width / 2

      # TODO : trouver offset et le mettre à la main sur chaque noeud montant

      if align == 'left'
        v = b  - parentsCenter
        w = @x - parentsCenter + Constants.width / 2

        offset = if Math.abs(v - w) > 1 then v - w else 0
        console.log offset
        parentsCenter = Math.min(@x + Constants.width / 2 - (b-a) / 2 - offset / 2, parentsCenter)
      else if align == 'right'
        v = parentsCenter - a
        w = parentsCenter - @x - Constants.width / 2

        offset = if Math.abs(w-v) > 1 then v - w else 0
        console.log offset
        parentsCenter = Math.max(@x - Constants.width / 2 + (b-a) / 2 + offset /2, parentsCenter)

    father.node.setPosition(parentsCenter - Constants.margin / 2 - Constants.width / 2, y)
    mother.node.setPosition(parentsCenter + Constants.margin / 2 + Constants.width / 2, y)

    # If got 2 parents, align all father/mother sibings on the left/right to make sense
    if father.parentRelation && mother.parentRelation
      father.node.updateTopPeople('left')
      mother.node.updateTopPeople('right')
    # If only 1 parent (or 0), align him/her on the center
    else
      father.node.updateTopPeople('center')
      mother.node.updateTopPeople('center')

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
    parentRelationNode.vLine.position.y = husband.node.y + Constants.verticalMargin / 4

  drawSiblingsHLine: (y) ->
    parentRelationNode = @person.parentRelation.node
    children           = @person.parentRelation.children

    parentRelationNode.childrenHLineY      = y + Constants.verticalMargin / 2
    parentRelationNode.childrenHLineStartX = _.min(children, (child) -> child.node.x).node.x
    parentRelationNode.childrenHLineEndX   = _.max(children, (child) -> child.node.x).node.x

    if @person.sex == 'F'
      parentRelationNode.childrenHLineEndX = Math.max(
        parentRelationNode.childrenHLineEndX,
        parentRelationNode.vLine.position.x
      )
    else if @person.sex == 'M'
      parentRelationNode.childrenHLineStartX = Math.min(
        parentRelationNode.childrenHLineStartX,
        parentRelationNode.vLine.position.x
      )

    parentRelationNode.drawChildrenHLine()
