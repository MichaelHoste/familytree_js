class @FamilyTree

  constructor: (options = {}) ->
    @options  = options
    @width    = options.width
    @height   = options.height
    @people   = options.people || []
    @root     = options.root
    @stage    = new PIXI.Container()
    @t        = Constants.t

    @onCreate = (person) =>
      if options.onCreate
        options.onCreate(person, @serialize())

    @onEdit   = (person) =>
      if options.onEdit
        options.onEdit(person, @serialize())

    @onDelete = (person) =>
      if options.onDelete
          options.onDelete(person, @serialize())

    if options.serializedData
      @deserialize(options.serializedData)

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
      @startOffsetX = mouseData.data.global.x
      @startOffsetY = mouseData.data.global.y

    onUp = (mouseData) =>
      @isDown = false

    onMove = (mouseData) =>
      if @isDown
        @x = @startX + mouseData.data.global.x - @startOffsetX
        @y = @startY + mouseData.data.global.y - @startOffsetY
        @animate()

    @background.on('mousedown',       onDown)
    @background.on('touchstart',      onDown)
    @background.on('mouseup',         onUp)
    @background.on('touchend',        onUp)
    #@background.on('mouseupoutside',  onUp)
    #@background.on('touchendoutside', onUp)
    @background.on('mousemove',       onMove)
    @background.on('touchmove',       onMove)

  bindMenu: ->
    createFirstPerson = (name, sex) =>
      @root = new Person(name, sex)
      @people.push(@root)
      @onCreate(@root)

      @refreshStage()
      @refreshMenu()
      @save()

    $('#family-tree-panel').on('click', 'button[data-action="add-man"]', =>
      name  = prompt(@t("What's the first man's name?", "Quel est le nom du premier homme ?"), @t("Me", "Moi"))
      createFirstPerson(name, 'M') if name
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-woman"]', =>
      name  = prompt(@t("What's the first man's name?", "Quel est le nom de la première femme ?"), @t("Me", "Moi"))
      createFirstPerson(name, 'F') if name
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-partner"]', =>
      if @root.sex == 'M'
        suggestion = @t("Wife of #{@root.name}", "Femme de #{@root.name}")
      else if @root.sex == 'F'
        suggestion = @t("Husband of #{@root.name}", "Mari de #{@root.name}")

      name = prompt(@t("What's the partner's name?", "Quel est le nom du partenaire ?"), suggestion)

      if name
        @cleanTree()
        partner = @root.addPartner(name)
        @people.push(partner)
        @onCreate(partner)
        @refreshStage()
        @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-parents"]', =>
      fatherSuggestion = @t("Father of #{@root.name}", "Père de #{@root.name}")
      fatherName       = prompt(@t("What's the father's name?", "Quel est le nom du père ?"), fatherSuggestion)

      if fatherName
        motherSuggestion = @t("Mother of #{@root.name}", "Mère de #{@root.name}")
        motherName       = prompt(@t("What's the mother's name?", "Quel est le nom de la mère ?"), motherSuggestion)

        if fatherName && motherName
          @cleanTree()
          parents = @root.addParents(fatherName, motherName)
          @people.push(parents[0])
          @onCreate(parents[0])
          @people.push(parents[1])
          @onCreate(parents[1])
          @refreshStage()
          @refreshMenu()

    )

    $('#family-tree-panel').on('click', 'button[data-action="add-brother"]', =>
      suggestion = @t("Brother of #{@root.name}", "Frère de #{@root.name}")
      name       = prompt(@t("What's the brother's name?", "Quel est le nom du frère ?"), suggestion)

      if name
        @cleanTree()
        brother = @root.addBrother(name)
        @people.push(brother)
        @onCreate(brother)
        @refreshStage()
        @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-sister"]', =>
      suggestion = @t("Sister of #{@root.name}", "Soeur de #{@root.name}")
      name       = prompt(@t("What's the sister's name?", "Quel est le nom de la soeur ?"), suggestion)

      if name
        @cleanTree()
        sister = @root.addSister(name)
        @people.push(sister)
        @onCreate(sister)
        @refreshStage()
        @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-son"]', (event) =>
      suggestion = @t("Son of #{@root.name}", "Fils de #{@root.name}")
      name       = prompt(@t("What's the son's name?", "Quel est le nom du fils ?"), suggestion)

      if name
        @cleanTree()

        partnerUuid = $(event.target).data('with')
        partner     = _.findWhere(@people, { uuid: partnerUuid })
        son         = @root.relationWith(partner).addChild(name, 'M')

        @people.push(son)
        @onCreate(son)
        @refreshStage()
        @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'button[data-action="add-daughter"]', (event) =>
      suggestion = @t("Daughter of #{@root.name}", "Fille de #{@root.name}")
      name       = prompt(@t("What's the daughter's name?", "Quel est le nom de la fille ?"), suggestion)

      if name
        @cleanTree()

        partnerUuid  = $(event.target).data('with')
        partner      = _.findWhere(@people, { uuid: partnerUuid })
        daughter     = @root.relationWith(partner).addChild(name, 'F')

        @people.push(daughter)
        @onCreate(daughter)
        @refreshStage()
        @refreshMenu()
    )

    $('#family-tree-panel').on('click', 'button[data-action="edit"]', (event) =>
      @onEdit(@root)
    )

    $('#family-tree-panel').on('click', 'button[data-action="remove"]', (event) =>
      if confirm(@t("Remove #{@root.name}?", "Supprimer #{@root.name} ?"))
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

        @onDelete(@root)

        # new root
        if @people.length
          if @root.parentRelation
            @root = @root.father()
          else
            if @root.sex == 'M'
              @root = @root.partnerRelations[0].wife
            else if @root.sex == 'F'
              @root = @root.partnerRelations[0].husband

        @refreshStage()
        @refreshMenu()
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
    while @stage.children.length > 0
      @stage.removeChild(@stage.children[0])

    @initializeBackground()
    @bindScroll()
    @initializeNodesAndRelations()

    for num in [0..10]
      @animate()

  refreshMenu: ->
    $("#family-tree-panel div").empty()

    if @people.length == 0
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-man">'   + @t("Add Man",   "Ajouter un homme")  + '</button>')
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-woman">' + @t("Add Woman", "Ajouter une femme") + '</button>')
    else
      if !@root.partnerRelations.length
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-partner">' + @t("Add Partner", "Ajouter un partenaire") + '</button>')

      if @root.parentRelation
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-brother">' + @t("Add Brother", "Ajouter un frère") + '</button>')
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-sister">' + @t("Add Sister", "Ajouter une soeur") + '</button>')

      if !@root.parentRelation
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-parents">' + @t("Add Parents", "Ajouter les parents") + '</button>')

      for partner in @root.partners()
        sonCaption      = @t("Add son with #{partner.name}", "Ajouter un fils avec #{partner.name}")
        daughterCaption = @t("Add daughter with #{partner.name}", "Aouter une fille avec #{partner.name}")
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-son\"      data-with=\"#{partner.uuid}\">#{sonCaption}</button>")
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-daughter\" data-with=\"#{partner.uuid}\">#{daughterCaption}</button>")

      if @options.onEdit
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"edit\">" + @t("Edit", "Modifier") + "</button>")

      if !@root.partnerRelations.length || @root.children().length == 0
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"remove\">" + @t("Delete", "Supprimer") + "</button>")

  cleanTree: ->
    for person in @people
      person.node.hideRectangle()
      person.node.hideVLines()

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
    @refreshStage() if @renderer

  loadData: (data) ->
    @deserialize(serializedData)

  animate: =>
    #requestAnimationFrame(@animate)

    @x = @width  / 2 if @x == undefined
    @y = @height / 2 if @y == undefined

    @rootNode.displayTree(@x, @y) if @rootNode

    @renderer.render(@stage)
