class Person

  constructor: (name, sex) ->
    @name             = name
    @sex              = sex
    @parentRelation   = undefined
    @partnerRelations = []

  partners: ->
    _.collect(@partnerRelations, (relation) ->
      if @sex == 'M'
        relation.wife
      else
        relation.husband
    )

  children: ->
    _.flatten(_.collect(@partnerRelations, (partnerRelation) ->
      partnerRelation.children
    ))

  mother: ->
    @parentRelation.wife

  father: ->
    @parentRelation.husband

  parents: ->
    [@father(), @mother()]

  siblings: ->
    _.difference(@parentRelation.children, [this])

  parentsSiblings: ->
    @father().siblings().concat(@mother().siblings())

  cousins: ->
    _.flatten(_.collect(@parentsSiblings(), (sibling) ->
      sibling.children()
    ))

  relationWith: (name) ->
    _.find(@partnerRelations, (relation) =>
      (@sex == 'M' && relation.wife == name) || (@sex == 'F' && relation.husband == name)
    )

  addParents: (father_name = undefined, mother_name = undefined) ->
    father_name = if father_name then father_name else "Father of #{@name}"
    mother_name = if mother_name then mother_name else "Mother of #{@name}"

    @parentRelation = new Relation()
    @parentRelation.children.push(this)

    # Links from relation to people
    @parentRelation.husband = new Person(father_name, 'M')
    @parentRelation.wife    = new Person(mother_name, 'F')

    # link from people to relation
    @parentRelation.husband.partnerRelations.push(@parentRelation)
    @parentRelation.wife   .partnerRelations.push(@parentRelation)

    [@parentRelation.husband, @parentRelation.wife]

  addPartner: (name = undefined) ->
    relation = new Relation()

    if @sex == 'M'
      relation.husband = this
      wife_name        = if name then name else "Wife of #{@name}"
      relation.wife    = new Person(wife_name, 'F')
      relation.wife.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.wife
    else
      relation.wife    = this
      husband_name     = if name then name else "Husband of #{@name}"
      relation.husband = new Person(husband_name, 'M')
      relation.husband.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.husband
