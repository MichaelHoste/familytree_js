class Relation

  constructor: ->
    @husband  = undefined
    @wife     = undefined
    @children = []

  addChild: (name, sex) ->
    child = new Person(name, sex)
    child.parentRelation = this
    @children.push(child)
    return child
