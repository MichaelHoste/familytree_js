$ ->
  renderer = new PIXI.autoDetectRenderer(1024, 768, {
    antialias: true,
    backgroundColor: 0xFFFFFF
  })

  $('#content')[0].appendChild(renderer.view)

  stage = new PIXI.Container()

  homer    = new Person('Homer', 'M')
  marge    = homer.addPartner('Marge Bouvier')
  lisa     = homer.relationWith(marge).addChild('Lisa',   'F')
  bart     = homer.relationWith(marge).addChild('Bart',   'M')
  maggie   = homer.relationWith(marge).addChild('Maggie', 'F')
  selma    = homer.addPartner('Selma Bouvier')
  milhouse = lisa.addPartner('Milhouse')

  homerNode    = new PersonNode(stage, homer)
  margeNode    = new PersonNode(stage, marge)
  selmaNode    = new PersonNode(stage, selma)
  lisaNode     = new PersonNode(stage, lisa)
  maggieNode   = new PersonNode(stage, maggie)
  bartNode     = new PersonNode(stage, bart)
  milhouseNode = new PersonNode(stage, milhouse)

  homerMargeNode   = new RelationNode(stage, homer.relationWith(marge))
  homerSelmaNode   = new RelationNode(stage, homer.relationWith(selma))
  lisaMilhouseNode = new RelationNode(stage, lisa.relationWith(milhouse))

  rootNode = homerNode
  rootNode.displayTree(300, 384)

  animate = ->
    requestAnimationFrame(animate)

    rootNode.update()

    renderer.render(stage)

  animate()
