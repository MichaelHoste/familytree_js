$ ->
  homer = new Person('Homer', 'M')
  marge = homer.addPartner('Marge')

  bart   = homer.relationWith(marge).addChild('Bart',   'M')
  lisa   = homer.relationWith(marge).addChild('Lisa',   'F')
  maggie = homer.relationWith(marge).addChild('Maggie', 'F')

  [abraham, mona]  = homer.addParents('Abraham', 'Mona')
  [clancy, jackie] = marge.addParents('Clancy',  'Jackie')

  herb  = abraham.relationWith(mona)  .addChild('Herb',  'M')
  patty = clancy .relationWith(jackie).addChild('Patty', 'F')
  selma = clancy .relationWith(jackie).addChild('Selma', 'F')

  fatherOfLing = selma.addPartner('Father of Ling')
  ling         = selma.relationWith(fatherOfLing).addChild('Ling', 'F')

  # console.log(bart)
  # console.log(bart.cousins())         # => ling
  # console.log(bart.parentsSiblings()) # => herb, patty, selma
  # console.log(homer.partners())       # => marge
  # console.log(patty.niblings())       # => bart, lisa, maggie, ling
  # console.log(selma.niblings())       # => bart, lisa, maggie
  # console.log(ling.grandparents())    # => clancy, jackie
