class FamilyTree

  constructor: (width, height, people = [], root = undefined, loadData = undefined, saveData = undefined) ->
    @width    = width
    @height   = height
    @people   = people
    @root     = root
    @loadData = loadData
    @saveData = saveData

    if @people.length == 0
      name  = prompt("What's the first person's name?", 'Me')
      @root = new Person(name, 'M')

      @people.push(@root)

    if $('#family-tree').length
      @initializeRenderer()

      if @loadData
        @loadData()

      @refreshStage()
      @refreshMenu()
      @bindMenu()

      @animate()

  initializeRenderer: ->
    @renderer = new PIXI.autoDetectRenderer(@width, @height, {
      antialias:       true,
      backgroundColor: 0xFFFFFF
    })

    $('#family-tree')[0].appendChild(@renderer.view)

  initializeBackground: ->
    @background        = PIXI.Sprite.fromImage('images/pixel.gif');
    @background.width  = @width
    @background.height = @height

    @stage.familyTree = @
    @stage.background = @background
    @stage.addChild(@background)

  bindScroll: ->
    @background.interactive = true

    onDown = (mouseData) =>
      @isDown       = true
      @startX       = @x
      @startY       = @y
      @startOffsetX = mouseData.data.originalEvent.x
      @startOffsetY = mouseData.data.originalEvent.y

    onUp = =>
      @isDown = false

    onMove = (mouseData) =>
      if @isDown
        @x = @startX + mouseData.data.originalEvent.x - @startOffsetX
        @y = @startY + mouseData.data.originalEvent.y - @startOffsetY
        @rootNode.dirtyRoot = true

    @background.on('mousedown',       onDown)
    @background.on('touchstart',      onDown)
    @background.on('mouseup',         onUp)
    @background.on('touchend',        onUp)
    @background.on('mouseupoutside',  onUp)
    @background.on('touchendoutside', onUp)
    @background.on('mousemove',       onMove)

  bindMenu: ->
    $('#family-tree-panel').on('click', 'li[data-action="add-partner"]', =>
      if @root.sex == 'M'
        suggestion = "Wife of #{@root.name}"
      else if @root.sex == 'F'
        suggestion = "Husband of #{@root.name}"

      name = prompt("What's the partner's name?", suggestion)

      @cleanTree()
      partner = @root.addPartner(name)
      @people.push(partner)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-parents"]', =>
      father_suggestion = "Father of #{@root.name}"
      father_name       = prompt("What's the father's name?", father_suggestion)

      mother_suggestion = "Mother of #{@root.name}"
      mother_name       = prompt("What's the mother's name?", mother_suggestion)

      @cleanTree()
      parents = @root.addParents(father_name, mother_name)
      @people.push(parents[0])
      @people.push(parents[1])
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-brother"]', =>
      suggestion = "Brother of #{@root.name}"
      name       = prompt("What's the brother's name?", suggestion)

      @cleanTree()
      brother = @root.addBrother(name)
      @people.push(brother)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-sister"]', =>
      suggestion = "Sister of #{@root.name}"
      name       = prompt("What's the sister's name?", suggestion)

      @cleanTree()
      sister = @root.addSister(name)
      @people.push(sister)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-son"]', (event) =>
      suggestion = "Son of #{@root.name}"
      name       = prompt("What's the son's name?", suggestion)

      @cleanTree()

      partnerUuid = $(event.target).data('with')
      partner     = _.findWhere(@people, { uuid: partnerUuid })
      son         = @root.relationWith(partner).addChild(name, 'M')

      @people.push(son)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-daughter"]', (event) =>
      suggestion = "Daughter of #{@root.name}"
      name       = prompt("What's the daughter's name?", suggestion)

      @cleanTree()

      partnerUuid  = $(event.target).data('with')
      partner      = _.findWhere(@people, { uuid: partnerUuid })
      daughter     = @root.relationWith(partner).addChild(name, 'F')

      @people.push(daughter)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="remove"]', (event) =>
      @cleanTree()

      @people = _.without(@people, @root)

      # remove person without parents
      if !@root.partnerRelations.length
        @root.parentRelation.children = _.without(@root.parentRelation.children, @root)
      # remove person without children
      else if @root.children().length == 0
        for partnerRelation in @root.partnerRelations
          if @root.sex == 'F'
            partnerRelation.husband.partnerRelations = _.without(partnerRelation.husband.partnerRelations, partnerRelation)
          else if @root.sex == 'M'
            partnerRelation.wife.partnerRelations = _.without(partnerRelation.wife.partnerRelations, partnerRelation)

      # new root
      if @people.length
        if @root.parentRelation
          @root = @root.father()
        else
          if @root.sex == 'M'
            @root = @root.partnerRelations[0].wife
          else if @root.sex == 'F'
            @root = @root.partnerRelations[0].husband
      else
        name  = prompt("What's the first person's name?", 'Me')
        @root = new Person(name, 'M')
        @people.push(@root)

      @refreshStage()
      @refreshMenu()
    )

  initializeNodes: ->
    for person in @people
      node = new PersonNode(@stage, person)

      if person.uuid == @root.uuid
        @root     = person
        @rootNode = node
        @rootNode.dirtyRoot = true

  refreshStage: ->
    @stage = new PIXI.Container() if !@stage
    @initializeBackground()
    @bindScroll()
    @initializeNodes()

  refreshMenu: ->
    $("#family-tree-panel ul").empty()

    $('#family-tree-panel ul').append('<li data-action="add-partner">Add Partner</li>')

    if @root.parentRelation
      $('#family-tree-panel ul').append('<li data-action="add-brother">Add Brother</li>')
      $('#family-tree-panel ul').append('<li data-action="add-sister">Add Sister</li>')

    if !@root.parentRelation
      $('#family-tree-panel ul').append('<li data-action="add-parents">Add Parents</li>')

    for partner in @root.partners()
      $('#family-tree-panel ul').append("<li data-action=\"add-son\"      data-with=\"#{partner.uuid}\">Add son with #{partner.name}</li>")
      $('#family-tree-panel ul').append("<li data-action=\"add-daughter\" data-with=\"#{partner.uuid}\">Add daughter with #{partner.name}</li>")

    if !@root.partnerRelations.length || @root.children().length == 0
      $('#family-tree-panel ul').append("<li data-action=\"remove\">Remove</li>")

  cleanTree: ->
    for person in @people
      person.node.hideRectangle()
      person.node.hideVLine()

      for partnerRelation in person.partnerRelations
        partnerRelation.node.hideLines()

  serialize: ->
    people    = []
    relations = []

    for person in @people
      people.push({
        uuid: person.uuid
        name: person.name
        sex:  person.sex
      })

      for partnerRelation in person.partnerRelations
        relations.push({
          uuid:     partnerRelation.uuid
          children: _.map(partnerRelation.children, (child) -> child.uuid)
          husband:  partnerRelation.husband.uuid
          wife:     partnerRelation.wife.uuid
        })

    serialization =
      people:    people
      relations: _.uniq(relations, (relation) -> relation.uuid)
      root:      @root.uuid

  deserialize: (serialization) ->
    for child in @stage.children
      @stage.removeChild(child)

    serialized_people    = serialization.people
    serialized_relations = serialization.relations
    serialized_root      = serialization.root

    @people = []

    # create people
    for s_p in serialized_people
      person = new Person(s_p.name, s_p.sex, s_p.uuid)
      @people.push(person)

    # create and link relations
    for s_r in serialized_relations
      relation = new Relation(s_r.uuid)

      # create husband
      husband          = _.findWhere(@people, { uuid: s_r.husband })
      relation.husband = husband
      husband.partnerRelations.push(relation)

      # create wife
      wife          = _.findWhere(@people, { uuid: s_r.wife })
      relation.wife = wife
      wife.partnerRelations.push(relation)

      # create children
      for s_c in s_r.children
        child = _.findWhere(@people, { uuid: s_c })
        child.parentRelation = relation
        relation.children.push(child)

    # Create root
    @root = _.findWhere(@people, { uuid: serialized_root })

    # Reinitialize screen
    @refreshStage()

  animate: =>
    requestAnimationFrame(@animate)

    @x = @width  / 2 if @x == undefined
    @y = @height / 2 if @y == undefined

    @rootNode.displayTree(@x, @y)
    @rootNode.update()

    @renderer.render(@stage)
