class Relation

  constructor: (uuid = undefined) ->
    @husband  = undefined
    @wife     = undefined
    @children = []

    @uuid = window.uuid() if !uuid

  addChild: (name, sex) ->
    child = new Person(name, sex)
    child.parentRelation = this
    @children.push(child)
    return child
