$ ->
  renderer = new PIXI.autoDetectRenderer(1024, 768, {
    antialias: true,
    backgroundColor: 0xFFFFFF
  })

  $('#content')[0].appendChild(renderer.view)

  stage = new PIXI.Container()

  homer    = new Person('Homer', 'M')
  marge    = homer.addPartner('Marge Bouvier')
  bart     = homer.relationWith(marge).addChild('Bart',   'M')
  lisa     = homer.relationWith(marge).addChild('Lisa',   'M')
  maggie   = homer.relationWith(marge).addChild('Maggie', 'F')
  selma    = homer.addPartner('Selma Bouvier')
  milhouse = lisa.addPartner('Milhouse')
  nelson   = lisa.addPartner('Nelson')
  kido     = lisa.relationWith(milhouse).addChild('Kido', 'F')
  kido2    = lisa.relationWith(milhouse).addChild('Kido2', 'M')
  kido3    = lisa.relationWith(milhouse).addChild('Kido2', 'M')
  nelsonJunior = lisa.relationWith(nelson).addChild('Nelson Junior', 'M')
  #nelsonBaby = lisa.relationWith(nelson).addChild('Nelson Baby', 'M')

  homerNode    = new PersonNode(stage, homer)
  margeNode    = new PersonNode(stage, marge)
  selmaNode    = new PersonNode(stage, selma)
  lisaNode     = new PersonNode(stage, lisa)
  maggieNode   = new PersonNode(stage, maggie)
  bartNode     = new PersonNode(stage, bart)
  milhouseNode = new PersonNode(stage, milhouse)
  nelsonNode   = new PersonNode(stage, nelson)
  kidoNode     = new PersonNode(stage, kido)
  kido2Node    = new PersonNode(stage, kido2)
  kido3Node    = new PersonNode(stage, kido3)
  nelsonJuniorNode    = new PersonNode(stage, nelsonJunior)
  #nelsonBabyNode    = new PersonNode(stage, nelsonBaby)

  homerMargeNode   = new RelationNode(stage, homer.relationWith(marge))
  homerSelmaNode   = new RelationNode(stage, homer.relationWith(selma))
  lisaMilhouseNode = new RelationNode(stage, lisa.relationWith(milhouse))
  lisaNelsonNode   = new RelationNode(stage, lisa.relationWith(nelson))

  rootNode = lisaNode
  rootNode.displayTree(600, 384)

  animate = ->
    requestAnimationFrame(animate)

    rootNode.update()

    renderer.render(stage)

  animate()
