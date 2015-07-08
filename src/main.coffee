$ ->
  renderer = new PIXI.autoDetectRenderer(1024, 768, {
    antialias: true,
    backgroundColor: 0xFFFFFF
  })

  $('#content')[0].appendChild(renderer.view)

  stage = new PIXI.Container()

  homer  = new Person('Homer', 'M')
  marge  = homer.addPartner('Marge Bouviers')
  bart   = homer.relationWith(marge).addChild('Bart',   'M')
  lisa   = homer.relationWith(marge).addChild('Lisa',   'F')
  maggie = homer.relationWith(marge).addChild('Maggie', 'F')
  aggie  = homer.relationWith(marge).addChild('Aggie', 'F')
  selma  = homer.addPartner('Selma Bouvier')

  homerNode  = new PersonNode(stage, homer)
  margeNode  = new PersonNode(stage, marge)
  selmaNode  = new PersonNode(stage, selma)
  bartNode   = new PersonNode(stage, bart)
  lisaNode   = new PersonNode(stage, lisa)
  maggieNode = new PersonNode(stage, maggie)
  aggieNode  = new PersonNode(stage, aggie)

  homerMargeNode = new RelationNode(stage, homer.relationWith(marge))
  homerSelmaNode = new RelationNode(stage, homer.relationWith(selma))

  rootNode = homerNode
  rootNode.displayTree(400, 384)

  animate = ->
    requestAnimationFrame(animate)

    rootNode.update()

    renderer.render(stage)

  animate()
