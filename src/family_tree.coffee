class FamilyTree

  constructor: (width, height, people = [], root = undefined, loadData = undefined, saveData = undefined) ->
    @width    = width
    @height   = height
    @people   = people
    @root     = root
    @loadData = loadData
    @saveData = saveData

    if $('#family-tree').length
      @initializeRenderer()

      if @people.length == 0
        @root = new Person('Me', 'M')
        @people.push(@root)

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
      partner = @rootNode.person.addPartner()
      @people.push(partner)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-parents"]', =>
      parents = @rootNode.person.addParents()
      @people.push(parents[0])
      @people.push(parents[1])
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-brother"]', =>
      brother = @rootNode.person.addBrother()
      @people.push(brother)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-sister"]', =>
      sister = @rootNode.person.addSister()
      @people.push(sister)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-son"]', (event) =>
      partnerUuid = $(event.target).data('with')
      partner     = _.findWhere(@people, { uuid: partnerUuid })
      sonName     = "Son of #{@rootNode.person.name}"

      son = @rootNode.person.relationWith(partner).addChild(sonName, 'M')
      @people.push(son)
      @refreshStage()
      @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'li[data-action="add-daughter"]', (event) =>
      partnerUuid  = $(event.target).data('with')
      partner      = _.findWhere(@people, { uuid: partnerUuid })
      daughterName = "Daughter of #{@rootNode.person.name}"

      daughter = @rootNode.person.relationWith(partner).addChild(daughterName, 'F')
      @people.push(daughter)
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
    @stage = new PIXI.Container()
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
      root:      @rootNode.person.uuid

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
