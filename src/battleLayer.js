// Generated by CoffeeScript 1.9.2
(function() {
  var BattleLayer, root;

  BattleLayer = cc.Layer.extend({
    sprite: null,
    ctor: function() {
      var closeItem, eventListener, helloLabel, menu, mouseCheck, size, that;
      this._super();
      that = this;
      this._initBattleTimer();
      this._loadRes();
      this._create6Position();
      size = cc.winSize;
      closeItem = new cc.MenuItemImage(res.CloseNormal_png, res.CloseSelected_png, function() {
        return myDirector.battle();
      }, this);
      closeItem.attr({
        x: size.width - 20,
        y: 20,
        anchorX: 0.5,
        anchorY: 0.5
      });
      menu = new cc.Menu(closeItem);
      menu.x = 0;
      menu.y = 0;
      this.addChild(menu, 1);
      helloLabel = new cc.LabelTTF("妙蛙草藏在哪(⊙_⊙)？", "Arial", 30);
      helloLabel.x = size.width / 2;
      helloLabel.y = 0;
      this.addChild(helloLabel, 5);
      this.getScheduler().setTimeScale(1);
      gs(helloLabel).bindTimer();
      this.xy = new cc.LabelTTF("单击鼠标扔球", "arial", 16);
      this.addChild(this.xy, 100);
      this.stage = new cc.Sprite(res.stage);
      this.stage.attr({
        x: size.width / 2,
        y: size.height / 2
      });
      this.addPokemon = function(n) {
        var t, temp;
        if (pokemonDataArray[n - 1] != null) {
          t = pokemonDataArray[n - 1];
        } else {
          t = {
            id: n
          };
        }
        temp = new PokemonCard(t, 1);
        that.addChild(temp, 5);
        gs.playerArray.push(temp);
        gs.battleArray.push(temp);
        return temp;
      };
      this.addPokemon(14);
      this.addPokemon(15);
      this.particle = new cc.ParticleSystem("res/particles_effect/attack_fire.plist");
      gs(this.particle).bindTimer(true);
      this.particle.stopSystem();
      this.addChild(this.particle, 10);
      mouseCheck = cc.EventListener.create({
        event: cc.EventListener.MOUSE,
        onMouseMove: function(event) {
          var p, x, y;
          p = event.getLocation();
          x = p.x | 0;
          y = p.y | 0;
          that.xy.setString(x + " " + y);
          that.xy.x = p.x;
          return that.xy.y = p.y;
        }
      });
      cc.eventManager.addListener(mouseCheck, this);
      eventListener = cc.EventListener.create({
        event: cc.EventListener.TOUCH_ONE_BY_ONE,
        onTouchBegan: function(event) {
          var box, i, len, ref, t, temp, touch;
          that.particle.setPosition(event.getLocation());
          that.particle.resetSystem();
          touch = event.getLocation();
          console.log("battleLayer.coffee onTouchBegan (#78): " + "touch");
          ref = gs.battleArray;
          for (i = 0, len = ref.length; i < len; i++) {
            t = ref[i];
            box = t.getBoundingBox();
            if (cc.rectContainsPoint(box, touch)) {
              that.xy.setString('hit' + touch.x);
              return;
            }
          }
          temp = gs.playerArray[0];
          gs.playerArray = gs.playerArray.slice(1);
          if (temp != null) {
            return temp.testBallAction(event.getLocation());
          }
        }
      });
      cc.eventManager.addListener(eventListener, this);
      helloLabel.runAction(cc.spawn(cc.moveBy(2.5, cc.p(0, size.height - 40)), cc.tintTo(2.5, 255, 125, 0)));

      /*  auto cast ball
      		@schedule(
      			() ->
      				r1 = Math.random() * 170 - 85
      				r2 = Math.random() * 170 - 85
      				temp = gs.playerArray[0]
      				gs.playerArray = gs.playerArray[1...]
      				if temp? then temp.testBallAction(cc.p(size.width/2 + r1, size.height/2 + r2))
      			,5,20,2
      		)
       */
      this.schedule(function() {
        var r, rect1, rect2;
        rect1 = that.stage.getBoundingBox();
        rect2 = that.particle.getBoundingBox();
        r = cc.rectIntersection(rect1, rect2);
        if (r.width === 0 && r.height === 0) {
          return;
        }
        console.log("To Watch: battleLayer.coffee (#123):");
        return console.log(r);
      }, 0.02);
      return true;
    },
    _initBattleTimer: function() {
      var defaultSchedule;
      gs.battleLayer = this;
      defaultSchedule = cc.director.getScheduler();
      this._scheduler = new cc.Scheduler();
      defaultSchedule.scheduleUpdate(this._scheduler, 0, false);
      this._actionManager = new cc.ActionManager();
      return this._scheduler.scheduleUpdate(this._actionManager, 0, false);
    },
    _loadRes: function() {
      cc.spriteFrameCache.addSpriteFrames(res.res_plist);
      return cc.textureCache.addImage(res.res_png);
    },
    _create6Position: function() {
      var height, r, size, width;
      size = cc.winSize;
      width = size.width;
      height = size.height;
      r = 0.414;
      gs.uLoc = [cc.p(-0.5 * width * r + width / 2, 0.5 * height * r + height / 2), cc.p(width / 2, 0.5 * height * r + height / 2), cc.p(0.5 * width * r + width / 2, 0.5 * height * r + height / 2)];
      gs.dLoc = [cc.p(-0.5 * width * r + width / 2, -0.5 * height * r + height / 2), cc.p(width / 2, -0.5 * height * r + height / 2), cc.p(0.5 * width * r + width / 2, -0.5 * height * r + height / 2)];
      gs.uhLoc = cc.p(width / 2, height + 100);
      return gs.dhLoc = cc.p(width / 2, -100);
    },
    showDamage: function(loc, n, size) {
      var label, that;
      console.log("battleLayer.coffee showDamage (#181): " + "show");
      that = this;
      label = new cc.LabelTTF(n.toString(), "Arial", 40);
      if (size != null) {
        label.setFontSize(size);
      }
      label.setPosition(loc);
      label.setColor(cc.color(255, 240, 0));
      this.addChild(label, 100);
      return label.runAction(cc.sequence(cc.spawn(cc.moveBy(0.5, 0, 70).easing(cc.easeSineOut()), cc.scaleTo(0.5, 1.3).easing(cc.easeElasticIn())), cc.callFunc(function() {
        return that.removeChild(label, true);
      })));
    }
  });

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.BattleLayer = BattleLayer;

}).call(this);

//# sourceMappingURL=battleLayer.js.map
