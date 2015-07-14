class Person

  constructor: (name, sex, uuid = undefined) ->
    @name             = name
    @sex              = sex
    @parentRelation   = undefined
    @partnerRelations = []

    @uuid = if uuid then uuid else window.uuid()

  partners: ->
    _.collect(@partnerRelations, (relation) =>
      relation[if @sex == 'M' then 'wife' else 'husband']
    )

  children: ->
    _.flatten(_.collect(@partnerRelations, (partnerRelation) ->
      partnerRelation.children
    ))

  mother: ->
    if @parentRelation then @parentRelation.wife

  father: ->
    if @parentRelation then @parentRelation.husband

  parents: ->
    _.compact([@father(), @mother()])

  grandparents: ->
    @father().parents().concat(@mother().parents())

  siblings: ->
    _.difference(@parentRelation.children, [this])

  niblings: ->
    _.flatten(_.collect(@siblings(), (sibling) ->
      sibling.children()
    ))

  parentsSiblings: ->
    @father().siblings().concat(@mother().siblings())

  cousins: ->
    _.flatten(_.collect(@parentsSiblings(), (sibling) ->
      sibling.children()
    ))

  relationWith: (person) ->
    _.find(@partnerRelations, (relation) =>
      (@sex == 'M' && relation.wife == person) || (@sex == 'F' && relation.husband == person)
    )

  addParents: (fatherName = undefined, motherName = undefined) ->
    fatherName = if fatherName then fatherName else "Father of #{@name}"
    motherName = if motherName then motherName else "Mother of #{@name}"

    @parentRelation = new Relation()
    @parentRelation.children.push(this)

    # Links from relation to people
    @parentRelation.husband = new Person(fatherName, 'M')
    @parentRelation.wife    = new Person(motherName, 'F')

    # link from people to relation
    @parentRelation.husband.partnerRelations.push(@parentRelation)
    @parentRelation.wife   .partnerRelations.push(@parentRelation)

    [@parentRelation.husband, @parentRelation.wife]

  addPartner: (name = undefined) ->
    relation = new Relation()

    if @sex == 'M'
      relation.husband = this
      wifeName         = if name then name else "Wife of #{@name}"
      relation.wife    = new Person(wifeName, 'F')
      relation.wife.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.wife
    else
      relation.wife    = this
      husbandName      = if name then name else "Husband of #{@name}"
      relation.husband = new Person(husbandName, 'M')
      relation.husband.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.husband
