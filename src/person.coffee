class @Person

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

  ancestors: ->
    parents = @parents()

    if _.isEmpty(parents)
      []
    else
      parents.concat(@father().ancestors()).concat(@mother().ancestors())

  descendants: ->
    children = @children()

    if _.isEmpty(children)
      []
    else
      children.concat(
        _.compact(
          _.flatten(
            _.map(children, (child) ->
              child.descendants()
            )
          )
        )
      )

  siblings: ->
    if @parentRelation
      _.difference(@parentRelation.children, [this])
    else
      []

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

  bloodRelatives: ->
    _.uniq(
      _.flatten(
        _.map(@ancestors(), (ancestor) ->
          ancestor.descendants().concat([ancestor])
        )
      )
    )

  isBloodRelativeOf: (otherPerson) ->
    _.includes(@bloodRelatives(), otherPerson)

  relationWith: (person) ->
    _.find(@partnerRelations, (relation) =>
      (@sex == 'M' && relation.wife == person) || (@sex == 'F' && relation.husband == person)
    )

  addParents: (fatherName = undefined, motherName = undefined) ->
    fatherName = if fatherName then fatherName else Constants.t("Father of #{@name}", "Père de #{@name}")
    motherName = if motherName then motherName else Constants.t("Mother of #{@name}", "Mère de #{@name}")

    @parentRelation = new Relation()
    @parentRelation.children.push(this)

    # Links from relation to people
    @parentRelation.husband = new Person(fatherName, 'M')
    @parentRelation.wife    = new Person(motherName, 'F')

    # link from people to relation
    @parentRelation.husband.partnerRelations.push(@parentRelation)
    @parentRelation.wife   .partnerRelations.push(@parentRelation)

    [@parentRelation.husband, @parentRelation.wife]

  addBrother: (name = undefined) ->
    name = if name then name else Constants.t("Brother of #{@name}", "Fère de #{@name}")

    if @parentRelation
      @parentRelation.addChild(name, 'M')
    else
      undefined

  addSister: (name = undefined) ->
    name = if name then name else Constants.t("Sister of #{@name}", "Soeur de #{@name}")

    if @parentRelation
      @parentRelation.addChild(name, 'F')
    else
      undefined

  addPartner: (name = undefined) ->
    relation = new Relation()

    if @sex == 'M'
      relation.husband = this
      wifeName         = if name then name else Constants.t("Wife of #{@name}", "Femme de #{@name}")
      relation.wife    = new Person(wifeName, 'F')
      relation.wife.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.wife
    else
      relation.wife    = this
      husbandName      = if name then name else Constants.t("Husband of #{@name}", "Mari du #{@name}")
      relation.husband = new Person(husbandName, 'M')
      relation.husband.partnerRelations.push(relation)
      @partnerRelations.push(relation)
      return relation.husband
