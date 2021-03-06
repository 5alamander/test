/**
 * copy form cc.LoaderScene
 */
var MyLoaderScene = cc.Scene.extend({
    _interval : null,
    _length : 0,
    _count : 0,
    _label : null,
    _className:"MyLoaderScene",
    init : function(){
        var self = this;

        //logo
        var logoWidth = 160;
        var logoHeight = 200;

        // bg
        var bgLayer = self._bgLayer = cc.LayerColor.create(cc.color(32, 32, 32, 255));
        bgLayer.setPosition(cc.visibleRect.bottomLeft);
        self.addChild(bgLayer, 0);

        //image move to CCSceneFile.js
        var fontSize = 24, lblHeight =  -logoHeight / 2 + 100;
//        if(cc.local_loaderImage){
//            //loading logo
//            cc.loader.loadImg(cc.local_loaderImage, {isCrossOrigin : false }, function(err, img){
//                logoWidth = img.width;
//                logoHeight = img.height;
//                self._initStage(img, cc.visibleRect.center);
//            });
//            fontSize = 14;
//            lblHeight = -logoHeight / 2 - 10;
//        }
        //loading percent
        var label = self._label = cc.LabelTTF.create("Loading... 0%", "Arial", fontSize);
        label.setPosition(cc.pAdd(cc.visibleRect.center, cc.p(0, lblHeight)));
        label.setColor(cc.color(180, 180, 180));

        var n = gs.random(this.loadingWord.length);
        var wordLabel = self.wordLabel = cc.LabelTTF.create(this.loadingWord[n], "Arial", 24);
        wordLabel.setPosition(cc.pAdd(cc.visibleRect.center, cc.p(0, lblHeight - 36)));

        bgLayer.addChild(this._label, 10);
        bgLayer.addChild(this.wordLabel, 10);
        return true;
    },

    _initStage: function (img, centerPos) {
        var self = this;
        var texture2d = self._texture2d = new cc.Texture2D();
        texture2d.initWithElement(img);
        texture2d.handleLoadedTexture();
        var logo = self._logo = cc.Sprite.create(texture2d);
        logo.setScale(cc.contentScaleFactor());
        logo.x = centerPos.x;
        logo.y = centerPos.y;
        self._bgLayer.addChild(logo, 10);
    },

    onEnter: function () {
        var self = this;
        cc.Node.prototype.onEnter.call(self);
        self.schedule(self._startLoading, 0.3);
    },

    onExit: function () {
        cc.Node.prototype.onExit.call(this);
        var tmpStr = "Loading... 0%";
        this._label.setString(tmpStr);
    },

    /**
     * init with resources
     * @param {Array} resources
     * @param {Function|String} cb
     */
    initWithResources: function (resources, cb) {
        if(typeof resources == "string") resources = [resources];
        this.resources = resources || [];
        this.cb = cb;
    },

    _startLoading: function () {
        var self = this;
        self.unschedule(self._startLoading);
        var res = self.resources;
        self._length = res.length;
        self._count = 0;
        cc.loader.load(res, function(result, count, loadedCount){
            var percent = (loadedCount / count * 100) | 0;
            percent = Math.min(percent, 100);
            self._label.setString("Loading... " + percent + "%");
        }, function(){
            if(self.cb)
                self.cb();
        });
        //self.schedule(self._updatePercent);
    },

    loadingWord: [
        "day1,回话制还是即时呢o(╯□╰)o",
        "day2,cocos的坑好多(￣ヘ￣＃)",
        "day3,去看看地图",
        "day4,昨天写成了2014，穿越了？",
        "day5,走路的样子好抽搐",
        "day6,研究研究战斗",
        "day7,要吧敏捷值用上呢",
        "day8,好久没发牢骚了",
        "day9,和day8同一天写的"
    ]
});

MyLoaderScene.preload = function(resources, cb){
    var _myLoaderScene = null;
    if(!_myLoaderScene) {
        _myLoaderScene = new MyLoaderScene();
        _myLoaderScene.init();
    }
    _myLoaderScene.initWithResources(resources, cb);

    //var s = new cc.TransitionFade(1, _myLoaderScene);
    cc.director.runScene(_myLoaderScene);
    return _myLoaderScene;
};