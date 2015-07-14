$ ->
  people = [
    homer         = new Person('Homer', 'M')
    marge         = homer.addPartner('Marge Bouvier')
    bart          = homer.relationWith(marge).addChild('Bart',   'M')
    lisa          = homer.relationWith(marge).addChild('Lisa',   'F')
    maggie        = homer.relationWith(marge).addChild('Maggie', 'F')
    jessica       = bart.addPartner('Jessica', 'F')
    selma         = homer.addPartner('Selma Bouvier')
    milhouse      = lisa.addPartner('Milhouse')
    nelson        = lisa.addPartner('Nelson')
    kido          = lisa.relationWith(milhouse).addChild('Kido1', 'F')
    kido2         = lisa.relationWith(milhouse).addChild('Kido2', 'M')
    kido3         = lisa.relationWith(milhouse).addChild('Kido3', 'M')
    nelsonJunior  = lisa.relationWith(nelson).addChild('Nelson Junior', 'M')
    love          = bart.relationWith(jessica).addChild('love', 'F')
    #nelsonBaby   = lisa.relationWith(nelson).addChild('Nelson Baby', 'M')
  ]

  # bob_marlaine  = jessica.addParents('Bob', 'Marlaine')

  # people.push(bob_marlaine[0])
  # people.push(bob_marlaine[1])

  new FamilyTree(
    window.innerWidth,
    window.innerHeight,
    people,
    lisa
  )

