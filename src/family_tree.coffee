class @FamilyTree

  constructor: (width, height, people = [], root = undefined, saveData = undefined) ->
    @width    = width
    @height   = height
    @people   = people
    @root     = root
    @saveData = saveData

    if @people.length == 0
      name  = prompt("What's the first person's name?", 'Me')
      @root = new Person(name, 'M')

      @people.push(@root)

    if $('#family-tree').length
      @initializeRenderer()

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
        @animate()

    @background.on('mousedown',       onDown)
    @background.on('touchstart',      onDown)
    @background.on('mouseup',         onUp)
    @background.on('touchend',        onUp)
    #@background.on('mouseupoutside',  onUp)
    #@background.on('touchendoutside', onUp)
    @background.on('mousemove',       onMove)

  bindMenu: ->
    $('#family-tree-panel').on('click', 'button[data-action="add-partner"]', =>
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
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-parents"]', =>
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
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-brother"]', =>
      suggestion = "Brother of #{@root.name}"
      name       = prompt("What's the brother's name?", suggestion)

      @cleanTree()
      brother = @root.addBrother(name)
      @people.push(brother)
      @refreshStage()
      @refreshMenu()
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-sister"]', =>
      suggestion = "Sister of #{@root.name}"
      name       = prompt("What's the sister's name?", suggestion)

      @cleanTree()
      sister = @root.addSister(name)
      @people.push(sister)
      @refreshStage()
      @refreshMenu()
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-son"]', (event) =>
      suggestion = "Son of #{@root.name}"
      name       = prompt("What's the son's name?", suggestion)

      @cleanTree()

      partnerUuid = $(event.target).data('with')
      partner     = _.findWhere(@people, { uuid: partnerUuid })
      son         = @root.relationWith(partner).addChild(name, 'M')

      @people.push(son)
      @refreshStage()
      @refreshMenu()
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-daughter"]', (event) =>
      suggestion = "Daughter of #{@root.name}"
      name       = prompt("What's the daughter's name?", suggestion)

      @cleanTree()

      partnerUuid  = $(event.target).data('with')
      partner      = _.findWhere(@people, { uuid: partnerUuid })
      daughter     = @root.relationWith(partner).addChild(name, 'F')

      @people.push(daughter)
      @refreshStage()
      @refreshMenu()
      @save()
    )

    $('#family-tree-panel').on('click', 'button[data-action="remove"]', (event) =>
      @cleanTree()

      @people = _.without(@people, @root)

      # remove person without parent
      if @root.parents().length == 0
        for partnerRelation in @root.partnerRelations
          if @root.sex == 'F'
            partnerRelation.husband.partnerRelations = _.without(partnerRelation.husband.partnerRelations, partnerRelation)
          else if @root.sex == 'M'
            partnerRelation.wife.partnerRelations = _.without(partnerRelation.wife.partnerRelations, partnerRelation)
      # remove person without children
      else if @root.children().length == 0
        @root.parentRelation.children = _.without(@root.parentRelation.children, @root)

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
      @save()
    )

  relations: ->
    relations = []

    for person in @people
      for partnerRelation in person.partnerRelations
        relations.push(partnerRelation)

    _.uniq(relations, (relation) -> relation.uuid)

  initializeNodesAndRelations: ->
    for relation in @relations()
      if relation.node == undefined
        new RelationNode(@stage, relation)
      else
        relation.node.initializeLines()

    for person in @people
      node = new PersonNode(@stage, person)

      if person.uuid == @root.uuid
        @root     = person
        @rootNode = node

  refreshStage: ->
    @stage = new PIXI.Container() if !@stage

    console.log @stage.children.length

    while @stage.children.length > 0
      @stage.removeChild(@stage.children[0])

    console.log @stage.children.length

    @initializeBackground()
    @bindScroll()
    @initializeNodesAndRelations()
    @animate()

  refreshMenu: ->
    $("#family-tree-panel div").empty()
    $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-partner">Add Partner</button>')

    if @root.parentRelation
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-brother">Add Brother</button>')
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-sister">Add Sister</button>')

    if !@root.parentRelation
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-parents">Add Parents</button>')

    for partner in @root.partners()
      $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-son\"      data-with=\"#{partner.uuid}\">Add son with #{partner.name}</button>")
      $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-daughter\" data-with=\"#{partner.uuid}\">Add daughter with #{partner.name}</button>")

    if !@root.partnerRelations.length || @root.children().length == 0
      $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"remove\">Remove</button>")

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

    serializedPeople    = serialization.people
    serializedRelations = serialization.relations
    serializedRoot      = serialization.root

    @people = []

    # create people
    for sP in serializedPeople
      person = new Person(sP.name, sP.sex, sP.uuid)
      @people.push(person)

    # create and link relations
    for sR in serializedRelations
      relation = new Relation(sR.uuid)

      # create husband
      husband          = _.findWhere(@people, { uuid: sR.husband })
      relation.husband = husband
      husband.partnerRelations.push(relation)

      # create wife
      wife          = _.findWhere(@people, { uuid: sR.wife })
      relation.wife = wife
      wife.partnerRelations.push(relation)

      # create children
      for sC in sR.children
        child = _.findWhere(@people, { uuid: sC })
        child.parentRelation = relation
        relation.children.push(child)

    # Create root
    @root = _.findWhere(@people, { uuid: serializedRoot })

    # Reinitialize screen
    @refreshStage()

  save: ->
    @saveData(@serialize()) if @saveData

  loadData: (data) ->
    @deserialize(serializedData)

  animate: =>
    #requestAnimationFrame(@animate)

    @x = @width  / 2 if @x == undefined
    @y = @height / 2 if @y == undefined

    @rootNode.displayTree(@x, @y)

    @renderer.render(@stage)
