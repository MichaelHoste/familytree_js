// Generated by CoffeeScript 1.6.3
(function() {
  var Constants, FamilyTree, Person, PersonNode, Relation, RelationNode,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Constants = (function() {
    function Constants() {}

    Constants.height = 40;

    Constants.padding = 20;

    Constants.margin = 60;

    Constants.fontSize = 15;

    Constants.baseLine = 6;

    Constants.lineWidth = 2;

    Constants.verticalMargin = Constants.margin * 1.5;

    return Constants;

  })();

  FamilyTree = (function() {
    function FamilyTree(width, height, people, root) {
      this.animate = __bind(this.animate, this);
      this.width = width;
      this.height = height;
      this.people = people;
      this.root = root;
      this.initializeRenderer();
      this.stage = new PIXI.Container();
      this.initializeBackground();
      this.bindScroll();
      this.initializeNodes();
      this.animate();
    }

    FamilyTree.prototype.initializeRenderer = function() {
      this.renderer = new PIXI.autoDetectRenderer(this.width, this.height, {
        antialias: true,
        backgroundColor: 0xFFFFFF
      });
      return $('#family_tree')[0].appendChild(this.renderer.view);
    };

    FamilyTree.prototype.initializeBackground = function() {
      this.background = PIXI.Sprite.fromImage('images/pixel.gif');
      this.background.width = this.width;
      this.background.height = this.height;
      this.stage.familyTree = this;
      this.stage.background = this.background;
      return this.stage.addChild(this.background);
    };

    FamilyTree.prototype.bindScroll = function() {
      var onDown, onMove, onUp,
        _this = this;
      this.background.interactive = true;
      onDown = function(mouseData) {
        _this.isDown = true;
        _this.startX = _this.x;
        _this.startY = _this.y;
        _this.startOffsetX = mouseData.data.originalEvent.x;
        return _this.startOffsetY = mouseData.data.originalEvent.y;
      };
      onUp = function() {
        return _this.isDown = false;
      };
      onMove = function(mouseData) {
        if (_this.isDown) {
          _this.x = _this.startX + mouseData.data.originalEvent.x - _this.startOffsetX;
          _this.y = _this.startY + mouseData.data.originalEvent.y - _this.startOffsetY;
          return _this.rootNode.dirtyRoot = true;
        }
      };
      this.background.on('mousedown', onDown);
      this.background.on('touchstart', onDown);
      this.background.on('mouseup', onUp);
      this.background.on('touchend', onUp);
      this.background.on('mouseupoutside', onUp);
      this.background.on('touchendoutside', onUp);
      return this.background.on('mousemove', onMove);
    };

    FamilyTree.prototype.initializeNodes = function() {
      var node, person, _i, _len, _ref, _results;
      _ref = this.people;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        node = new PersonNode(this.stage, person);
        if (person === this.root) {
          this.rootNode = node;
          _results.push(this.rootNode.dirtyRoot = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    FamilyTree.prototype.animate = function() {
      requestAnimationFrame(this.animate);
      if (this.x === void 0) {
        this.x = this.width / 2;
      }
      if (this.y === void 0) {
        this.y = this.height / 2;
      }
      this.rootNode.displayTree(this.x, this.y);
      this.rootNode.update();
      return this.renderer.render(this.stage);
    };

    return FamilyTree;

  })();

  $(function() {
    var bart, homer, jessica, kido, kido2, kido3, lisa, love, maggie, marge, milhouse, nelson, nelsonJunior, people, selma;
    people = [homer = new Person('Homer', 'M'), marge = homer.addPartner('Marge Bouvier'), bart = homer.relationWith(marge).addChild('Bart', 'M'), lisa = homer.relationWith(marge).addChild('Lisa', 'F'), maggie = homer.relationWith(marge).addChild('Maggie', 'F'), jessica = bart.addPartner('Jessica', 'F'), selma = homer.addPartner('Selma Bouvier'), milhouse = lisa.addPartner('Milhouse'), nelson = lisa.addPartner('Nelson'), kido = lisa.relationWith(milhouse).addChild('Kido1', 'F'), kido2 = lisa.relationWith(milhouse).addChild('Kido2', 'M'), kido3 = lisa.relationWith(milhouse).addChild('Kido3', 'M'), nelsonJunior = lisa.relationWith(nelson).addChild('Nelson Junior', 'M'), love = bart.relationWith(jessica).addChild('love', 'F')];
    return new FamilyTree(window.innerWidth, window.innerHeight, people, lisa);
  });

  Person = (function() {
    function Person(name, sex) {
      this.name = name;
      this.sex = sex;
      this.parentRelation = void 0;
      this.partnerRelations = [];
    }

    Person.prototype.partners = function() {
      var _this = this;
      return _.collect(this.partnerRelations, function(relation) {
        return relation[_this.sex === 'M' ? 'wife' : 'husband'];
      });
    };

    Person.prototype.children = function() {
      return _.flatten(_.collect(this.partnerRelations, function(partnerRelation) {
        return partnerRelation.children;
      }));
    };

    Person.prototype.mother = function() {
      if (this.parentRelation) {
        return this.parentRelation.wife;
      }
    };

    Person.prototype.father = function() {
      if (this.parentRelation) {
        return this.parentRelation.husband;
      }
    };

    Person.prototype.parents = function() {
      return _.compact([this.father(), this.mother()]);
    };

    Person.prototype.grandparents = function() {
      return this.father().parents().concat(this.mother().parents());
    };

    Person.prototype.siblings = function() {
      return _.difference(this.parentRelation.children, [this]);
    };

    Person.prototype.niblings = function() {
      return _.flatten(_.collect(this.siblings(), function(sibling) {
        return sibling.children();
      }));
    };

    Person.prototype.parentsSiblings = function() {
      return this.father().siblings().concat(this.mother().siblings());
    };

    Person.prototype.cousins = function() {
      return _.flatten(_.collect(this.parentsSiblings(), function(sibling) {
        return sibling.children();
      }));
    };

    Person.prototype.relationWith = function(person) {
      var _this = this;
      return _.find(this.partnerRelations, function(relation) {
        return (_this.sex === 'M' && relation.wife === person) || (_this.sex === 'F' && relation.husband === person);
      });
    };

    Person.prototype.addParents = function(fatherName, motherName) {
      if (fatherName == null) {
        fatherName = void 0;
      }
      if (motherName == null) {
        motherName = void 0;
      }
      fatherName = fatherName ? fatherName : "Father of " + this.name;
      motherName = motherName ? motherName : "Mother of " + this.name;
      this.parentRelation = new Relation();
      this.parentRelation.children.push(this);
      this.parentRelation.husband = new Person(fatherName, 'M');
      this.parentRelation.wife = new Person(motherName, 'F');
      this.parentRelation.husband.partnerRelations.push(this.parentRelation);
      this.parentRelation.wife.partnerRelations.push(this.parentRelation);
      return [this.parentRelation.husband, this.parentRelation.wife];
    };

    Person.prototype.addPartner = function(name) {
      var husbandName, relation, wifeName;
      if (name == null) {
        name = void 0;
      }
      relation = new Relation();
      if (this.sex === 'M') {
        relation.husband = this;
        wifeName = name ? name : "Wife of " + this.name;
        relation.wife = new Person(wifeName, 'F');
        relation.wife.partnerRelations.push(relation);
        this.partnerRelations.push(relation);
        return relation.wife;
      } else {
        relation.wife = this;
        husbandName = name ? name : "Husband of " + this.name;
        relation.husband = new Person(husbandName, 'M');
        relation.husband.partnerRelations.push(relation);
        this.partnerRelations.push(relation);
        return relation.husband;
      }
    };

    return Person;

  })();

  PersonNode = (function() {
    function PersonNode(stage, person) {
      this.stage = stage;
      this.person = person;
      this.root = false;
      this.dirtyRoot = false;
      this.dirtyPosition = true;
      this.dirtyIterator = 0;
      this.initializeNodes();
      this.initializeRectangle();
      this.initializeText();
      this.initializeVLine();
      this.bindRectangle();
    }

    PersonNode.prototype.initializeNodes = function() {
      var partnerRelation, _i, _len, _ref, _results;
      this.person.node = this;
      _ref = this.person.partnerRelations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        if (partnerRelation.node === void 0) {
          _results.push(new RelationNode(this.stage, partnerRelation));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.initializeRectangle = function() {
      var color;
      color = this.person.sex === 'M' ? 0xB4D8E7 : 0xFFC0CB;
      this.graphics = new PIXI.Graphics();
      if (this.root) {
        this.graphics.lineStyle(Constants.lineWidth, 0x999999, 1);
      } else {
        this.graphics.lineStyle(Constants.lineWidth, 0x333333, 1);
      }
      this.graphics.beginFill(color);
      if (this.person.sex === 'M') {
        this.graphics.drawRect(0, 0, 200, Constants.height);
      } else {
        this.graphics.drawRoundedRect(0, 0, 200, Constants.height, Constants.height / 5);
      }
      this.graphics.position.x = -1000;
      this.graphics.position.y = -1000;
      return this.stage.addChild(this.graphics);
    };

    PersonNode.prototype.bindRectangle = function() {
      var _this = this;
      this.graphics.interactive = true;
      this.graphics.on('mouseover', function() {
        return $('#family_tree').css('cursor', 'pointer');
      });
      this.graphics.on('mouseout', function() {
        return $('#family_tree').css('cursor', 'default');
      });
      this.graphics.on('click', function() {
        _this.stage.familyTree.rootNode.root = false;
        _this.stage.familyTree.rootNode.dirtyRoot = false;
        _this.stage.familyTree.rootNode = _this;
        _this.dirtyRoot = true;
        _this.cleanTree();
        return _this.displayTree(_this.stage.familyTree.x, _this.stage.familyTree.y);
      });
      this.graphics.on('mousedown', this.stage.background._events.mousedown.fn);
      this.graphics.on('touchstart', this.stage.background._events.touchstart.fn);
      this.graphics.on('mouseup', this.stage.background._events.mouseup.fn);
      this.graphics.on('touchend', this.stage.background._events.touchend.fn);
      this.graphics.on('mouseupoutside', this.stage.background._events.mouseupoutside.fn);
      return this.graphics.on('touchendoutside', this.stage.background._events.touchendoutside.fn);
    };

    PersonNode.prototype.initializeText = function() {
      this.text = new PIXI.Text(this.person.name, {
        font: "" + Constants.fontSize + "px Arial",
        fill: 0x222222
      });
      this.text.position.x = -1000;
      this.text.position.y = -1000;
      this.text.anchor.x = 0.5;
      return this.stage.addChild(this.text);
    };

    PersonNode.prototype.initializeVLine = function() {
      if (this.person.parentRelation) {
        this.vLine = new PIXI.Graphics();
        this.vLine.lineStyle(Constants.lineWidth, 0x333333, 1);
        this.vLine.moveTo(0, 0);
        this.vLine.lineTo(0, -Constants.verticalMargin / 2 - Constants.lineWidth);
        return this.stage.addChild(this.vLine);
      }
    };

    PersonNode.prototype.width = function() {
      return this.graphics.width;
    };

    PersonNode.prototype.partnersWidth = function() {
      var partnerRelation, size, _i, _len, _ref;
      size = 0;
      _ref = this.person.partnerRelations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        size += partnerRelation.node.globalWidth() - this.width();
      }
      return size;
    };

    PersonNode.prototype.position = function() {
      return this.text.position;
    };

    PersonNode.prototype.setPosition = function(x, y) {
      this.text.position.x = x;
      this.text.position.y = y;
      return this.dirtyPosition = true;
    };

    PersonNode.prototype.hideRectangle = function() {
      this.graphics.position.x = -1000;
      this.graphics.position.y = -1000;
      this.text.position.x = -1000;
      return this.text.position.y = -1000;
    };

    PersonNode.prototype.hideVLine = function() {
      if (this.vLine) {
        this.vLine.position.x = -1000;
      }
      if (this.vLine) {
        return this.vLine.position.y = -1000;
      }
    };

    PersonNode.prototype.cleanTree = function() {
      var partnerRelation, person, _i, _len, _ref, _results;
      _ref = this.stage.familyTree.people;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        person.node.hideRectangle();
        person.node.hideVLine();
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = person.partnerRelations;
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            partnerRelation = _ref1[_j];
            _results1.push(partnerRelation.node.hideLines());
          }
          return _results1;
        })());
      }
      return _results;
    };

    PersonNode.prototype.displayTree = function(x, y) {
      this.root = true;
      return this.setPosition(x, y);
    };

    PersonNode.prototype.update = function() {
      this.updatePosition();
      if (this.dirtyRoot) {
        this.updateBottomPeople();
        this.updateTopPeople();
        if (this.dirtyIterator >= 10) {
          this.dirtyRoot = false;
        }
        return this.dirtyIterator++;
      }
    };

    PersonNode.prototype.updateBottomPeople = function() {
      this.updatePartnerPositions();
      this.drawRelationLines();
      this.updateChildrenPositions();
      this.drawRelationTopVerticalLine();
      return this.drawHorizontalLineBetweenChildren();
    };

    PersonNode.prototype.updatePosition = function() {
      if (this.dirtyPosition) {
        this.graphics.width = this.text.width + Constants.padding;
        this.graphics.position.x = this.text.position.x - this.text.width / 2 - Constants.padding / 2;
        this.graphics.position.y = this.text.position.y - this.text.height + Constants.baseLine;
        if (this.person.parentRelation) {
          this.vLine.position.x = this.text.x;
          this.vLine.position.y = this.graphics.position.y;
        }
        return this.dirtyPosition = false;
      }
    };

    PersonNode.prototype.updatePartnerPositions = function() {
      var distance, i, lastBoxWidth, partnerNode, partnerRelation, _i, _len, _ref, _results;
      distance = 0;
      lastBoxWidth = this.width();
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        if (this.person.sex === 'M') {
          partnerNode = partnerRelation.wife.node;
          distance = distance + partnerRelation.node.lineWidth() + lastBoxWidth / 2 + partnerNode.width() / 2;
        } else {
          partnerNode = partnerRelation.husband.node;
          distance = distance - partnerRelation.node.lineWidth() - lastBoxWidth / 2 - partnerNode.width() / 2;
        }
        lastBoxWidth = partnerNode.width();
        partnerNode.setPosition(this.text.position.x + distance, this.text.position.y);
        _results.push(partnerNode.update());
      }
      return _results;
    };

    PersonNode.prototype.drawRelationLines = function() {
      var endX, lineWidth, partnerRelation, position, previousLineWidth, previousNodeWidth, startX, y, _i, _len, _ref, _results;
      y = this.text.position.y + Constants.baseLine + Constants.lineWidth;
      if (this.person.sex === 'M') {
        position = this.text.position.x + this.width() / 2;
      } else if (this.person.sex === 'F') {
        position = this.text.position.x - this.width() / 2;
      }
      previousLineWidth = 0;
      previousNodeWidth = 0;
      _ref = this.person.partnerRelations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        lineWidth = partnerRelation.node.lineWidth();
        if (this.person.sex === 'M') {
          position = position + previousLineWidth + previousNodeWidth;
          startX = position;
          endX = position + lineWidth;
          previousNodeWidth = partnerRelation.wife.node.width();
        } else if (this.person.sex === 'F') {
          position = position - previousLineWidth - previousNodeWidth;
          startX = position;
          endX = position - lineWidth;
          previousNodeWidth = partnerRelation.husband.node.width();
        }
        previousLineWidth = lineWidth;
        partnerRelation.node.setHLine(startX, endX, y);
        _results.push(partnerRelation.node.drawHLine());
      }
      return _results;
    };

    PersonNode.prototype.updateChildrenPositions = function() {
      var child, children, endX, i, lineStartX, partnerRelation, personPosition1, personPosition2, size, startX, y, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        startX = partnerRelation.node.hLineStartX;
        endX = partnerRelation.node.hLineEndX;
        y = this.text.position.y + this.graphics.height / 2 + Constants.verticalMargin;
        children = partnerRelation.children;
        lineStartX = this.person.sex === 'M' ? startX : endX;
        if (children.length > 1) {
          size = children[0].node.partnersWidth();
          startX = lineStartX - partnerRelation.husband.node.width() + children[0].node.width() / 2 + size;
        } else if (children.length === 1) {
          if (i === 0) {
            personPosition1 = partnerRelation.husband.node.text.position;
            personPosition2 = partnerRelation.wife.node.text.position;
          } else {
            if (this.person.sex === 'M') {
              personPosition1 = this.person.partnerRelations[i - 1].wife.node.text.position;
              personPosition2 = partnerRelation.wife.node.text.position;
            } else if (this.person.sex === 'F') {
              personPosition1 = this.person.partnerRelations[i - 1].husband.node.text.position;
              personPosition2 = partnerRelation.husband.node.text.position;
            }
          }
          startX = (personPosition1.x + personPosition2.x) / 2;
        } else {
          startX = 0;
        }
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = partnerRelation.children;
          _results1 = [];
          for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
            child = _ref1[i];
            child.node.setPosition(startX, y);
            child.node.update();
            child.node.updateBottomPeople();
            startX += Constants.margin + child.node.width();
            if (i + 1 < children.length) {
              _results1.push(startX += children[i + 1].node.partnersWidth());
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };

    PersonNode.prototype.drawHorizontalLineBetweenChildren = function() {
      var children, partnerRelation, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        children = partnerRelation.children;
        if (children.length > 1) {
          partnerRelation.node.childrenHLineStartX = children[0].node.text.position.x;
          partnerRelation.node.childrenHLineEndX = _.last(children).node.text.position.x;
          partnerRelation.node.childrenHLineY = this.text.position.y + Constants.baseLine + Constants.verticalMargin / 2 + Constants.lineWidth;
          _results.push(partnerRelation.node.drawChildrenHLine());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.drawRelationTopVerticalLine = function() {
      var children, endX, partnerRelation, startX, y, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        children = partnerRelation.children;
        if (children.length) {
          startX = children[0].node.text.position.x;
          endX = _.last(children).node.text.position.x;
          y = partnerRelation.node.hLineY;
          partnerRelation.node.vLine.position.x = (startX + endX) / 2;
          _results.push(partnerRelation.node.vLine.position.y = y + Constants.verticalMargin / 4);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.updateTopPeople = function() {
      var y;
      if (this.person.parentRelation) {
        y = this.text.position.y - this.graphics.height / 2 - Constants.verticalMargin;
        this.updateParentsPosition(y);
        this.drawParentsHLine(y);
        this.updateParentsVLinePosition();
        this.updateParentsChildrenPositions();
        return this.drawParentsChildrenHLine(y);
      }
    };

    PersonNode.prototype.updateParentsPosition = function(y) {
      var child, h_offset, husband, i, partnerRelations, w_offset, wife, _i, _j, _len, _len1, _ref, _ref1;
      partnerRelations = this.person.partnerRelations;
      husband = this.person.parentRelation.husband;
      wife = this.person.parentRelation.wife;
      if (this.person.sex === 'M') {
        h_offset = 0;
        _ref = this.person.parentRelation.children;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          child = _ref[i];
          if (child !== this.person) {
            h_offset += child.node.partnersWidth() + child.node.width() + Constants.margin;
          }
        }
        h_offset = h_offset + this.width() / 2 - husband.node.width() / 2;
        h_offset = Math.max(h_offset, Constants.margin);
        husband.node.setPosition(this.text.position.x - h_offset, y);
        husband.node.update();
        w_offset = this.partnersWidth();
        w_offset = w_offset + this.width() / 2 - wife.node.width() / 2;
        w_offset = Math.max(w_offset, Constants.margin);
        wife.node.setPosition(this.text.position.x + w_offset, y);
        return wife.node.update();
      } else if (this.person.sex === 'F') {
        w_offset = 0;
        _ref1 = this.person.parentRelation.children;
        for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
          child = _ref1[i];
          if (child !== this.person) {
            w_offset += child.node.partnersWidth() + child.node.width() + Constants.margin;
          }
        }
        w_offset = w_offset + this.width() / 2 - wife.node.width() / 2;
        w_offset = Math.max(w_offset, Constants.margin);
        wife.node.setPosition(this.text.position.x + w_offset, y);
        wife.node.update();
        h_offset = this.partnersWidth();
        h_offset = h_offset + this.width() / 2 - husband.node.width() / 2;
        h_offset = Math.max(h_offset, Constants.margin);
        husband.node.setPosition(this.text.position.x - h_offset, y);
        return husband.node.update();
      }
    };

    PersonNode.prototype.drawParentsHLine = function(y) {
      var husband, parentRelationNode, wife;
      parentRelationNode = this.person.parentRelation.node;
      husband = this.person.parentRelation.husband;
      wife = this.person.parentRelation.wife;
      parentRelationNode.hLineStartX = husband.node.text.x + husband.node.width() / 2;
      parentRelationNode.hLineEndX = wife.node.text.x - wife.node.width() / 2;
      parentRelationNode.hLineY = y + Constants.baseLine;
      return parentRelationNode.drawHLine();
    };

    PersonNode.prototype.updateParentsVLinePosition = function() {
      var parentLimit, parentRelationNode;
      parentRelationNode = this.person.parentRelation.node;
      if (this.person.sex === 'M') {
        parentLimit = this.person.father();
      } else if (this.person.sex === 'F') {
        parentLimit = this.person.mother();
      }
      parentRelationNode.vLine.position.x = (this.text.position.x + parentLimit.node.text.position.x) / 2;
      return parentRelationNode.vLine.position.y = this.graphics.position.y - Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2;
    };

    PersonNode.prototype.updateParentsChildrenPositions = function() {
      var child, children, children_without_himself, i, offset, parentRelationNode, y, _i, _len, _results;
      y = this.text.position.y;
      parentRelationNode = this.person.parentRelation.node;
      children = this.person.parentRelation.children;
      children_without_himself = _.without(children, this.person);
      offset = this.width() / 2;
      if (children_without_himself.length > 0) {
        offset += children_without_himself[0].node.width() / 2 + Constants.margin;
      }
      _results = [];
      for (i = _i = 0, _len = children_without_himself.length; _i < _len; i = ++_i) {
        child = children_without_himself[i];
        if (this.person.sex === 'F') {
          if (child.sex === 'M') {
            child.node.setPosition(this.text.position.x + offset, y);
          } else if (child.sex === 'F') {
            child.node.setPosition(this.text.position.x + child.node.partnersWidth() + offset, y);
          }
        } else if (this.person.sex === 'M') {
          if (child.sex === 'F') {
            child.node.setPosition(this.text.position.x - offset, y);
          } else if (child.sex === 'M') {
            child.node.setPosition(this.text.position.x - child.node.partnersWidth() - offset, y);
          }
        }
        child.node.updateBottomPeople();
        child.node.update();
        _results.push(offset += child.node.partnersWidth() + child.node.width() + Constants.margin);
      }
      return _results;
    };

    PersonNode.prototype.drawParentsChildrenHLine = function(y) {
      var children, parentRelationNode;
      parentRelationNode = this.person.parentRelation.node;
      children = this.person.parentRelation.children;
      parentRelationNode.childrenHLineStartX = _.min(children, function(child) {
        return child.node.text.position.x;
      }).node.text.position.x;
      parentRelationNode.childrenHLineEndX = _.max(children, function(child) {
        return child.node.text.position.x;
      }).node.text.position.x;
      parentRelationNode.childrenHLineY = y + Constants.baseLine + Constants.verticalMargin / 2;
      return parentRelationNode.drawChildrenHLine();
    };

    return PersonNode;

  })();

  Relation = (function() {
    function Relation() {
      this.husband = void 0;
      this.wife = void 0;
      this.children = [];
    }

    Relation.prototype.addChild = function(name, sex) {
      var child;
      child = new Person(name, sex);
      child.parentRelation = this;
      this.children.push(child);
      return child;
    };

    return Relation;

  })();

  RelationNode = (function() {
    function RelationNode(stage, relation) {
      this.stage = stage;
      this.relation = relation;
      this.relation.node = this;
      this.initializeHLine();
      this.initializeVLine();
      this.initializeChildrenHLine();
    }

    RelationNode.prototype.initializeHLine = function() {
      this.hLineStartX = 0;
      this.hLineEndX = 0;
      this.hLineY = 0;
      this.hLine = new PIXI.Graphics();
      return this.stage.addChild(this.hLine);
    };

    RelationNode.prototype.initializeChildrenHLine = function() {
      this.childrenHLineStartX = 0;
      this.childrenHLineEndX = 0;
      this.childrenHLineY = 0;
      this.childrenHLine = new PIXI.Graphics();
      return this.stage.addChild(this.childrenHLine);
    };

    RelationNode.prototype.initializeVLine = function() {
      this.vLine = new PIXI.Graphics();
      this.vLine.lineStyle(Constants.lineWidth, 0x333333, 1);
      this.vLine.moveTo(0, -Constants.verticalMargin / 4);
      this.vLine.lineTo(0, Constants.verticalMargin / 4);
      return this.stage.addChild(this.vLine);
    };

    RelationNode.prototype.globalWidth = function() {
      return Math.max(this.relationWidth(), this.childrenWidth());
    };

    RelationNode.prototype.lineWidth = function() {
      return this.globalWidth() - this.relation.husband.node.width() - this.relation.wife.node.width();
    };

    RelationNode.prototype.relationWidth = function() {
      var size;
      size = this.relation.husband.node.width();
      size += this.relation.wife.node.width();
      size += Constants.margin;
      return size;
    };

    RelationNode.prototype.childrenWidth = function() {
      var child, partnerRelation, size, _i, _j, _len, _len1, _ref, _ref1;
      size = 0;
      _ref = this.relation.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child.partnerRelations.length > 0) {
          size += child.node.width();
          _ref1 = child.partnerRelations;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            partnerRelation = _ref1[_j];
            size += partnerRelation.node.globalWidth() - child.node.width();
          }
        } else {
          size += child.node.width();
        }
        size += Constants.margin;
      }
      if (this.relation.children.length > 0) {
        size -= Constants.margin;
      }
      return size;
    };

    RelationNode.prototype.hideLines = function() {
      this.hLineStartX = 0;
      this.hLineEndX = 0;
      this.drawHLine();
      this.childrenHLineStartX = 0;
      this.childrenHLineEndX = 0;
      this.drawChildrenHLine();
      this.vLine.position.x = -1000;
      return this.vLine.position.y = -1000;
    };

    RelationNode.prototype.setHLine = function(startX, endX, y) {
      this.hLineStartX = startX;
      this.hLineEndX = endX;
      return this.hLineY = y;
    };

    RelationNode.prototype.drawHLine = function() {
      this.hLine.clear();
      this.hLine.lineStyle(Constants.lineWidth, 0x333333, 1);
      this.hLine.moveTo(this.hLineStartX, this.hLineY);
      this.hLine.lineTo(this.hLineEndX, this.hLineY);
      return false;
    };

    RelationNode.prototype.drawChildrenHLine = function() {
      this.childrenHLine.clear();
      this.childrenHLine.lineStyle(Constants.lineWidth, 0x333333, 1);
      this.childrenHLine.moveTo(this.childrenHLineStartX, this.childrenHLineY);
      this.childrenHLine.lineTo(this.childrenHLineEndX, this.childrenHLineY);
      return false;
    };

    return RelationNode;

  })();

  $(function() {
    var abraham, bart, clancy, fatherOfLing, herb, homer, jackie, ling, lisa, maggie, marge, mona, patty, selma, _ref, _ref1;
    homer = new Person('Homer', 'M');
    marge = homer.addPartner('Marge');
    bart = homer.relationWith(marge).addChild('Bart', 'M');
    lisa = homer.relationWith(marge).addChild('Lisa', 'F');
    maggie = homer.relationWith(marge).addChild('Maggie', 'F');
    _ref = homer.addParents('Abraham', 'Mona'), abraham = _ref[0], mona = _ref[1];
    _ref1 = marge.addParents('Clancy', 'Jackie'), clancy = _ref1[0], jackie = _ref1[1];
    herb = abraham.relationWith(mona).addChild('Herb', 'M');
    patty = clancy.relationWith(jackie).addChild('Patty', 'F');
    selma = clancy.relationWith(jackie).addChild('Selma', 'F');
    fatherOfLing = selma.addPartner('Father of Ling');
    return ling = selma.relationWith(fatherOfLing).addChild('Ling', 'F');
  });

}).call(this);
