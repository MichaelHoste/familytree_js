// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Constants = (function() {
    function Constants() {}

    Constants.width = 90;

    Constants.height = 50;

    Constants.padding = 20;

    Constants.margin = 60;

    Constants.fontSize = 15;

    Constants.lineWidth = 2;

    Constants.verticalMargin = Constants.margin * 1.5;

    Constants.effectiveWidth = Constants.width + Constants.lineWidth;

    return Constants;

  })();

  this.FamilyTree = (function() {
    function FamilyTree(width, height, people, root, saveData) {
      var name;
      if (people == null) {
        people = [];
      }
      if (root == null) {
        root = void 0;
      }
      if (saveData == null) {
        saveData = void 0;
      }
      this.animate = __bind(this.animate, this);
      this.width = width;
      this.height = height;
      this.people = people;
      this.root = root;
      this.saveData = saveData;
      if (this.people.length === 0) {
        name = prompt("What's the first person's name?", 'Me');
        this.root = new Person(name, 'M');
        this.people.push(this.root);
      }
      if ($('#family-tree').length) {
        this.initializeRenderer();
        this.refreshStage();
        this.refreshMenu();
        this.bindMenu();
        this.animate();
      }
    }

    FamilyTree.prototype.initializeRenderer = function() {
      this.renderer = new PIXI.autoDetectRenderer(this.width, this.height, {
        antialias: true,
        backgroundColor: 0xFFFFFF
      });
      return $('#family-tree')[0].appendChild(this.renderer.view);
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
          return _this.y = _this.startY + mouseData.data.originalEvent.y - _this.startOffsetY;
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

    FamilyTree.prototype.bindMenu = function() {
      var _this = this;
      $('#family-tree-panel').on('click', 'button[data-action="add-partner"]', function() {
        var name, partner, suggestion;
        if (_this.root.sex === 'M') {
          suggestion = "Wife of " + _this.root.name;
        } else if (_this.root.sex === 'F') {
          suggestion = "Husband of " + _this.root.name;
        }
        name = prompt("What's the partner's name?", suggestion);
        _this.cleanTree();
        partner = _this.root.addPartner(name);
        _this.people.push(partner);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      $('#family-tree-panel').on('click', 'button[data-action="add-parents"]', function() {
        var father_name, father_suggestion, mother_name, mother_suggestion, parents;
        father_suggestion = "Father of " + _this.root.name;
        father_name = prompt("What's the father's name?", father_suggestion);
        mother_suggestion = "Mother of " + _this.root.name;
        mother_name = prompt("What's the mother's name?", mother_suggestion);
        _this.cleanTree();
        parents = _this.root.addParents(father_name, mother_name);
        _this.people.push(parents[0]);
        _this.people.push(parents[1]);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      $('#family-tree-panel').on('click', 'button[data-action="add-brother"]', function() {
        var brother, name, suggestion;
        suggestion = "Brother of " + _this.root.name;
        name = prompt("What's the brother's name?", suggestion);
        _this.cleanTree();
        brother = _this.root.addBrother(name);
        _this.people.push(brother);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      $('#family-tree-panel').on('click', 'button[data-action="add-sister"]', function() {
        var name, sister, suggestion;
        suggestion = "Sister of " + _this.root.name;
        name = prompt("What's the sister's name?", suggestion);
        _this.cleanTree();
        sister = _this.root.addSister(name);
        _this.people.push(sister);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      $('#family-tree-panel').on('click', 'button[data-action="add-son"]', function(event) {
        var name, partner, partnerUuid, son, suggestion;
        suggestion = "Son of " + _this.root.name;
        name = prompt("What's the son's name?", suggestion);
        _this.cleanTree();
        partnerUuid = $(event.target).data('with');
        partner = _.findWhere(_this.people, {
          uuid: partnerUuid
        });
        son = _this.root.relationWith(partner).addChild(name, 'M');
        _this.people.push(son);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      $('#family-tree-panel').on('click', 'button[data-action="add-daughter"]', function(event) {
        var daughter, name, partner, partnerUuid, suggestion;
        suggestion = "Daughter of " + _this.root.name;
        name = prompt("What's the daughter's name?", suggestion);
        _this.cleanTree();
        partnerUuid = $(event.target).data('with');
        partner = _.findWhere(_this.people, {
          uuid: partnerUuid
        });
        daughter = _this.root.relationWith(partner).addChild(name, 'F');
        _this.people.push(daughter);
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
      return $('#family-tree-panel').on('click', 'button[data-action="remove"]', function(event) {
        var name, partnerRelation, _i, _len, _ref;
        _this.cleanTree();
        _this.people = _.without(_this.people, _this.root);
        if (_this.root.parents().length === 0) {
          _ref = _this.root.partnerRelations;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            partnerRelation = _ref[_i];
            if (_this.root.sex === 'F') {
              partnerRelation.husband.partnerRelations = _.without(partnerRelation.husband.partnerRelations, partnerRelation);
            } else if (_this.root.sex === 'M') {
              partnerRelation.wife.partnerRelations = _.without(partnerRelation.wife.partnerRelations, partnerRelation);
            }
          }
        } else if (_this.root.children().length === 0) {
          _this.root.parentRelation.children = _.without(_this.root.parentRelation.children, _this.root);
        }
        if (_this.people.length) {
          if (_this.root.parentRelation) {
            _this.root = _this.root.father();
          } else {
            if (_this.root.sex === 'M') {
              _this.root = _this.root.partnerRelations[0].wife;
            } else if (_this.root.sex === 'F') {
              _this.root = _this.root.partnerRelations[0].husband;
            }
          }
        } else {
          name = prompt("What's the first person's name?", 'Me');
          _this.root = new Person(name, 'M');
          _this.people.push(_this.root);
        }
        _this.refreshStage();
        _this.refreshMenu();
        return _this.save();
      });
    };

    FamilyTree.prototype.relations = function() {
      var partnerRelation, person, relations, _i, _j, _len, _len1, _ref, _ref1;
      relations = [];
      _ref = this.people;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        _ref1 = person.partnerRelations;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          partnerRelation = _ref1[_j];
          relations.push(partnerRelation);
        }
      }
      return _.uniq(relations, function(relation) {
        return relation.uuid;
      });
    };

    FamilyTree.prototype.initializeNodesAndRelations = function() {
      var node, person, relation, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.relations();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        relation = _ref[_i];
        if (relation.node === void 0) {
          new RelationNode(this.stage, relation);
        } else {
          relation.node.initializeLines();
        }
      }
      _ref1 = this.people;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        person = _ref1[_j];
        node = new PersonNode(this.stage, person);
        if (person.uuid === this.root.uuid) {
          this.root = person;
          _results.push(this.rootNode = node);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    FamilyTree.prototype.refreshStage = function() {
      if (!this.stage) {
        this.stage = new PIXI.Container();
      }
      console.log(this.stage.children.length);
      while (this.stage.children.length > 0) {
        this.stage.removeChild(this.stage.children[0]);
      }
      console.log(this.stage.children.length);
      this.initializeBackground();
      this.bindScroll();
      return this.initializeNodesAndRelations();
    };

    FamilyTree.prototype.refreshMenu = function() {
      var partner, _i, _len, _ref;
      $("#family-tree-panel div").empty();
      $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-partner">Add Partner</button>');
      if (this.root.parentRelation) {
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-brother">Add Brother</button>');
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-sister">Add Sister</button>');
      }
      if (!this.root.parentRelation) {
        $('#family-tree-panel div').append('<button type="button" class="btn btn-default" data-action="add-parents">Add Parents</button>');
      }
      _ref = this.root.partners();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partner = _ref[_i];
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-son\"      data-with=\"" + partner.uuid + "\">Add son with " + partner.name + "</button>");
        $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"add-daughter\" data-with=\"" + partner.uuid + "\">Add daughter with " + partner.name + "</button>");
      }
      if (!this.root.partnerRelations.length || this.root.children().length === 0) {
        return $('#family-tree-panel div').append("<button type=\"button\" class=\"btn btn-default\" data-action=\"remove\">Remove</button>");
      }
    };

    FamilyTree.prototype.cleanTree = function() {
      var partnerRelation, person, _i, _len, _ref, _results;
      _ref = this.people;
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

    FamilyTree.prototype.serialize = function() {
      var partnerRelation, people, person, relations, serialization, _i, _j, _len, _len1, _ref, _ref1;
      people = [];
      relations = [];
      _ref = this.people;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        person = _ref[_i];
        people.push({
          uuid: person.uuid,
          name: person.name,
          sex: person.sex
        });
        _ref1 = person.partnerRelations;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          partnerRelation = _ref1[_j];
          relations.push({
            uuid: partnerRelation.uuid,
            children: _.map(partnerRelation.children, function(child) {
              return child.uuid;
            }),
            husband: partnerRelation.husband.uuid,
            wife: partnerRelation.wife.uuid
          });
        }
      }
      return serialization = {
        people: people,
        relations: _.uniq(relations, function(relation) {
          return relation.uuid;
        }),
        root: this.root.uuid
      };
    };

    FamilyTree.prototype.deserialize = function(serialization) {
      var child, husband, person, relation, sC, sP, sR, serializedPeople, serializedRelations, serializedRoot, wife, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1;
      _ref = this.stage.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        this.stage.removeChild(child);
      }
      serializedPeople = serialization.people;
      serializedRelations = serialization.relations;
      serializedRoot = serialization.root;
      this.people = [];
      for (_j = 0, _len1 = serializedPeople.length; _j < _len1; _j++) {
        sP = serializedPeople[_j];
        person = new Person(sP.name, sP.sex, sP.uuid);
        this.people.push(person);
      }
      for (_k = 0, _len2 = serializedRelations.length; _k < _len2; _k++) {
        sR = serializedRelations[_k];
        relation = new Relation(sR.uuid);
        husband = _.findWhere(this.people, {
          uuid: sR.husband
        });
        relation.husband = husband;
        husband.partnerRelations.push(relation);
        wife = _.findWhere(this.people, {
          uuid: sR.wife
        });
        relation.wife = wife;
        wife.partnerRelations.push(relation);
        _ref1 = sR.children;
        for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
          sC = _ref1[_l];
          child = _.findWhere(this.people, {
            uuid: sC
          });
          child.parentRelation = relation;
          relation.children.push(child);
        }
      }
      this.root = _.findWhere(this.people, {
        uuid: serializedRoot
      });
      return this.refreshStage();
    };

    FamilyTree.prototype.save = function() {
      if (this.saveData) {
        return this.saveData(this.serialize());
      }
    };

    FamilyTree.prototype.loadData = function(data) {
      return this.deserialize(serializedData);
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
      return this.renderer.render(this.stage);
    };

    return FamilyTree;

  })();

  this.Person = (function() {
    function Person(name, sex, uuid) {
      if (uuid == null) {
        uuid = void 0;
      }
      this.name = name;
      this.sex = sex;
      this.parentRelation = void 0;
      this.partnerRelations = [];
      this.uuid = uuid ? uuid : window.uuid();
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

    Person.prototype.addBrother = function(name) {
      if (name == null) {
        name = void 0;
      }
      name = name ? name : "Brother of " + this.name;
      if (this.parentRelation) {
        return this.parentRelation.addChild(name, 'M');
      } else {
        return void 0;
      }
    };

    Person.prototype.addSister = function(name) {
      if (name == null) {
        name = void 0;
      }
      name = name ? name : "Sister of " + this.name;
      if (this.parentRelation) {
        return this.parentRelation.addChild(name, 'F');
      } else {
        return void 0;
      }
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

  this.PersonNode = (function() {
    function PersonNode(stage, person) {
      this.stage = stage;
      this.person = person;
      this.root = false;
      this.x = 0;
      this.y = 0;
      this.person.node = this;
      this.initializeVLine();
      this.initializeRectangle();
      this.initializeText();
      this.bindRectangle();
    }

    PersonNode.prototype.initializeRectangle = function() {
      var color;
      color = this.person.sex === 'M' ? 0xB4D8E7 : 0xFFC0CB;
      this.graphics = new PIXI.Graphics();
      this.graphics.lineStyle(Constants.lineWidth, 0x333333, 1);
      this.graphics.beginFill(color);
      if (this.person.sex === 'M') {
        this.drawRectangle();
      } else {
        this.drawRoundRectangle();
      }
      return this.stage.addChild(this.graphics);
    };

    PersonNode.prototype.initializeText = function() {
      this.text = new PIXI.Text(this.person.name, {
        font: "" + Constants.fontSize + "px Arial",
        fill: 0x222222,
        align: 'center',
        wordWrap: true,
        wordWrapWidth: Constants.width - Constants.padding / 2
      });
      this.text.anchor.x = 0.5;
      this.text.anchor.y = 0.5;
      return this.stage.addChild(this.text);
    };

    PersonNode.prototype.initializeVLine = function() {
      if (this.person.parentRelation) {
        this.vLine = new PIXI.Graphics();
        this.vLine.lineStyle(Constants.lineWidth, 0x333333, 1);
        this.vLine.moveTo(0, 0);
        this.vLine.lineTo(0, -Constants.verticalMargin / 2);
        return this.stage.addChild(this.vLine);
      }
    };

    PersonNode.prototype.drawRectangle = function() {
      return this.graphics.drawRect(-Constants.width / 2, -Constants.height / 2, Constants.width, Constants.height);
    };

    PersonNode.prototype.drawRoundRectangle = function() {
      return this.graphics.drawRoundedRect(-Constants.width / 2, -Constants.height / 2, Constants.width, Constants.height, Constants.height / 4);
    };

    PersonNode.prototype.bindRectangle = function() {
      var _this = this;
      this.graphics.interactive = true;
      this.graphics.on('mouseover', function() {
        return $('#family-tree').css('cursor', 'pointer');
      });
      this.graphics.on('mouseout', function() {
        return $('#family-tree').css('cursor', 'default');
      });
      this.graphics.on('click', function() {
        _this.stage.familyTree.rootNode.root = false;
        _this.stage.familyTree.rootNode = _this;
        _this.stage.familyTree.root = _this.person;
        _this.stage.familyTree.refreshMenu();
        _this.stage.familyTree.cleanTree();
        _this.stage.familyTree.x = _this.stage.familyTree.width / 2;
        _this.stage.familyTree.y = _this.stage.familyTree.height / 2;
        return _this.displayTree(_this.stage.familyTree.x, _this.stage.familyTree.y);
      });
      this.graphics.on('mousedown', this.stage.background._events.mousedown.fn);
      this.graphics.on('touchstart', this.stage.background._events.touchstart.fn);
      this.graphics.on('mouseup', this.stage.background._events.mouseup.fn);
      this.graphics.on('touchend', this.stage.background._events.touchend.fn);
      this.graphics.on('mouseupoutside', this.stage.background._events.mouseupoutside.fn);
      return this.graphics.on('touchendoutside', this.stage.background._events.touchendoutside.fn);
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
      this.x = x;
      this.y = y;
      this.graphics.position.x = x;
      this.graphics.position.y = y;
      this.text.position.x = x;
      this.text.position.y = y;
      if (this.person.parentRelation) {
        this.vLine.position.x = x;
        return this.vLine.position.y = y - Constants.height / 2;
      }
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

    PersonNode.prototype.displayTree = function(x, y) {
      this.root = true;
      this.setPosition(x, y);
      this.updateBottomPeople();
      return this.updateTopPeople();
    };

    PersonNode.prototype.updateBottomPeople = function() {
      this.drawRelationLines();
      this.updatePartnerPositions();
      this.updateChildrenPositions();
      this.drawHorizontalLineBetweenChildren();
      return this.drawRelationTopVerticalLine();
    };

    PersonNode.prototype.updateTopPeople = function() {
      var y;
      if (this.person.parentRelation) {
        y = this.y - Constants.verticalMargin;
        return this.updateParentsPosition(y);
      }
    };

    PersonNode.prototype.updatePartnerPositions = function() {
      var distance, i, offset, partnerRelation, _i, _len, _ref, _results;
      distance = 0;
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        if (i === 0) {
          offset = Constants.width + Constants.margin;
          if (this.person.sex === 'M') {
            _results.push(partnerRelation.wife.node.setPosition(this.x + offset, this.y));
          } else if (this.person.sex === 'F') {
            _results.push(partnerRelation.husband.node.setPosition(this.x - offset, this.y));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.drawRelationLines = function() {
      var husbandsX, maxX, minX, partnerRelation, wivesX, _i, _len, _ref, _results;
      husbandsX = _.collect([this.person.partnerRelations[0]], function(p) {
        return p.husband.node.x;
      });
      wivesX = _.collect([this.person.partnerRelations[0]], function(p) {
        return p.wife.node.x;
      });
      minX = _.min(husbandsX.concat(wivesX), function(value) {
        return value;
      });
      maxX = _.max(husbandsX.concat(wivesX), function(value) {
        return value;
      });
      _ref = this.person.partnerRelations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        partnerRelation = _ref[_i];
        partnerRelation.node.setHLine(minX, maxX, this.y);
        _results.push(partnerRelation.node.drawHLine());
      }
      return _results;
    };

    PersonNode.prototype.updateChildrenPositions = function() {
      var child, children, childrenSize, husband, i, partnerRelation, start, wife, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        if (i === 0) {
          husband = partnerRelation.husband;
          wife = partnerRelation.wife;
          children = partnerRelation.children;
          start = (husband.node.x + wife.node.x) / 2;
          if (children.length > 1) {
            childrenSize = children.length * Constants.width + (children.length - 1) * Constants.margin;
            start = start + Constants.width / 2 - childrenSize / 2;
          }
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = children.length; _j < _len1; _j++) {
              child = children[_j];
              child.node.setPosition(start, this.y + Constants.height / 2 + Constants.verticalMargin);
              _results1.push(start = start + Constants.width + Constants.margin);
            }
            return _results1;
          }).call(this));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.drawHorizontalLineBetweenChildren = function() {
      var children, i, partnerRelation, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        if (i === 0) {
          children = partnerRelation.children;
          if (children.length > 1) {
            partnerRelation.node.childrenHLineStartX = children[0].node.x;
            partnerRelation.node.childrenHLineEndX = _.last(children).node.x;
            partnerRelation.node.childrenHLineY = this.y + Constants.verticalMargin / 2;
            _results.push(partnerRelation.node.drawChildrenHLine());
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.drawRelationTopVerticalLine = function() {
      var children, endX, i, partnerRelation, startX, _i, _len, _ref, _results;
      _ref = this.person.partnerRelations;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        partnerRelation = _ref[i];
        if (i === 0) {
          children = partnerRelation.children;
          if (children.length) {
            startX = children[0].node.x;
            endX = _.last(children).node.x;
            partnerRelation.node.vLine.position.x = (startX + endX) / 2;
            _results.push(partnerRelation.node.vLine.position.y = this.y + Constants.verticalMargin / 4);
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PersonNode.prototype.updateParentsPosition = function(y) {
      var husband, partnerRelations, wife;
      partnerRelations = this.person.partnerRelations;
      husband = this.person.parentRelation.husband;
      return wife = this.person.parentRelation.wife;
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
      if (this.person.parentRelation.children.length > 1) {
        if (this.person.sex === 'M') {
          parentLimit = this.person.father();
        } else if (this.person.sex === 'F') {
          parentLimit = this.person.mother();
        }
        parentRelationNode.vLine.position.x = (this.text.position.x + parentLimit.node.text.position.x) / 2;
        return parentRelationNode.vLine.position.y = this.graphics.position.y - Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2;
      } else {
        parentRelationNode.vLine.position.x = this.vLine.position.x;
        return parentRelationNode.vLine.position.y = this.graphics.position.y - Constants.baseLine - Constants.height / 2 - Constants.verticalMargin / 2 + Constants.lineWidth;
      }
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

  this.Relation = (function() {
    function Relation(uuid) {
      if (uuid == null) {
        uuid = void 0;
      }
      this.husband = void 0;
      this.wife = void 0;
      this.children = [];
      this.uuid = uuid ? uuid : window.uuid();
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

  this.RelationNode = (function() {
    function RelationNode(stage, relation) {
      this.stage = stage;
      this.relation = relation;
      this.relation.node = this;
      this.initializeLines();
    }

    RelationNode.prototype.initializeLines = function() {
      this.initializeHLine();
      this.initializeVLine();
      return this.initializeChildrenHLine();
    };

    RelationNode.prototype.initializeHLine = function() {
      console.log('initializeHLine');
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

    RelationNode.prototype.relationWidth = function() {
      return 2 * Constants.width + Constants.margin;
    };

    RelationNode.prototype.childrenWidth = function() {
      var child, partnerRelation, size, _i, _j, _len, _len1, _ref, _ref1;
      size = 0;
      _ref = this.relation.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        if (child.partnerRelations.length > 0) {
          size += Constants.width;
          _ref1 = child.partnerRelations;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            partnerRelation = _ref1[_j];
            size += partnerRelation.node.globalWidth() - Constants.width;
          }
        } else {
          size += Constants.width;
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

  window.uuid = function() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r, v;
      r = Math.random() * 16 | 0;
      v = c === 'x' ? r : r & 0x3 | 0x8;
      return v.toString(16);
    });
  };

}).call(this);
