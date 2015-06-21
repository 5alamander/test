// Generated by CoffeeScript 1.9.2
(function() {
  var Character, MapLayer, root;

  Character = cc.Sprite.extend({
    isWalk: false,
    ctor: function() {
      var frames, walkAnim;
      this._super();
      frames = gs.spliteFrame("res/map/player.png", 4, 4);
      walkAnim = function(frames) {
        var anim;
        anim = new cc.Animation(frames, 1 / 4);
        return cc.repeatForever(cc.animate(anim));
      };
      this.walkDown = walkAnim(frames[0]);
      this.walkLeft = walkAnim(frames[1]);
      this.walkRight = walkAnim(frames[2]);
      return this.walkUp = walkAnim(frames[3]);
    }
  });

  MapLayer = cc.Layer.extend({
    ctor: function(mapPath) {
      var that, tileCoordForPosition;
      this._super();
      cc.FIX_ARTIFACTS_BY_STRECHING_TEXEL = 1;
      this.map = new cc.TMXTiledMap(mapPath);
      this.addChild(this.map, 0);
      this.mapInit();
      console.log("To Watch: MapLayer.coffee (#7):");
      console.log(this.map);
      this.createPlayer();
      that = this;
      tileCoordForPosition = function(p) {
        var x, y;
        x = (p.x - that.x) / this.map.getTileSize().width;
        y = ((this.map.getMapSize().height * this.map.getTileSize().height) - p.y + that.y) / this.map.getTileSize().height;
        return cc.p(x | 0, y | 0);
      };
      return gs(this.map).click(function(event) {
        myDirector.battle();
      });
    },
    playerMove: function(x, y) {
      this.map.runAction(cc.moveBy(0.5, -x, -y).easing(cc.easeSineInOut()));
      return this.player.runAction(cc.moveBy(0.5, x, y).easing(cc.easeSineInOut()));
    },
    createPlayer: function() {
      this.player = new Character();
      this.map.addChild(this.player, 10);
      this.player.attr({
        x: 400,
        y: 200
      });
      return this.player.runAction(this.player.walkLeft);
    },
    mapInit: function() {},
    createButton: function() {
      var btna, btnb, padb, padf, that;
      that = this;
      padb = new cc.Sprite("res/map/padb.png");
      padb.setPosition(padb.width / 2 + 30, padb.height / 2 + 30);
      padb.setOpacity(100);
      this.addChild(padb, 50);
      gs(padb).click(function(event) {
        var dx, dy, loc, loc0;
        loc = event.getLocation();
        loc0 = this.getPosition();
        dx = loc.x - loc0.x;
        dy = loc.y - loc0.y;
        if (Math.abs(dx) > Math.abs(dy)) {
          if (dx > 0) {
            that.player.stopAllActions();
            that.playerMove(32, 0);
            return that.player.runAction(that.player.walkRight);
          } else {
            that.player.stopAllActions();
            that.playerMove(-32, 0);
            return that.player.runAction(that.player.walkLeft);
          }
        } else {
          if (dy > 0) {
            that.player.stopAllActions();
            that.playerMove(0, 32);
            return that.player.runAction(that.player.walkUp);
          } else {
            that.player.stopAllActions();
            that.playerMove(0, -32);
            return that.player.runAction(that.player.walkDown);
          }
        }
      });
      padf = new cc.Sprite("res/map/padf.png");
      padf.setPosition(padb.width / 2 + 30, padb.height / 2 + 30);
      padf.setOpacity(100);
      this.addChild(padf, 51);
      btna = new cc.Sprite("res/map/btna.png");
      btna.setPosition(800 - btna.width * 0.682 - 20, btna.height * 1.618 + 20);
      btna.setOpacity(100);
      this.addChild(btna, 50);
      btnb = new cc.Sprite("res/map/btnb.png");
      btnb.setPosition(800 - btnb.width * 1.618 - 20, btnb.height * 0.618 + 20);
      btnb.setOpacity(100);
      this.addChild(btnb, 50);
      return gs(btnb).click(function() {
        return myDirector.welcome();
      });
    }
  });

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.MapLayer = MapLayer;

}).call(this);

//# sourceMappingURL=MapLayer.js.map