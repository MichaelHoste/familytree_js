$ ->
  renderer = new PIXI.autoDetectRenderer(1024, 768, {
    antialias: true,
    backgroundColor: 0xFFFFFF
  })

  $('#content')[0].appendChild(renderer.view)

  stage = new PIXI.Container()

  homer = new Person('Homer', 'M')
  marge = homer.addPartner('Marge Bouvier')
  selma = homer.addPartner('Selma Bouvier')

  homerNode  = new PersonNode(stage, homer)
  margeNode  = new PersonNode(stage, marge)
  selmaNode  = new PersonNode(stage, selma)

  homerMargeNode = new RelationNode(stage, homer.relationWith(marge))
  homerSelmaNode = new RelationNode(stage, homer.relationWith(selma))

  rootNode = homerNode
  rootNode.displayTree(400, 384)

  animate = ->
    requestAnimationFrame(animate)

    rootNode.update()

    renderer.render(stage)

  animate()
