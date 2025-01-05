package jackboxgames.engine
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actionpackages.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.talkshow.events.*;
   import jackboxgames.talkshow.export.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.talkshow.stub.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   
   public class TalkshowGame extends Sprite implements IGame
   {
       
      
      private var _root:MovieClip;
      
      private var _engine:GameEngine;
      
      protected var _ts:PlaybackEngine;
      
      protected var _config:ConfigInfo;
      
      protected var _playbackFactory:PlaybackFactory;
      
      protected var _registeredActionPackages:Array;
      
      private var _useAudioSystem:Boolean;
      
      public function TalkshowGame(rootMC:MovieClip, useAudioSystem:Boolean = true)
      {
         super();
         this._root = rootMC;
         this._root.addChild(this);
         this._registeredActionPackages = [];
         this._useAudioSystem = useAudioSystem;
      }
      
      public function get gameName() : String
      {
         return BuildConfig.instance.configVal("gameName");
      }
      
      public function get gameSavePrefix() : String
      {
         return this.gameName + "_";
      }
      
      public function get gamePath() : String
      {
         return BuildConfig.instance.configVal("isBundle") ? "games/" + this.gameName + "/" : "";
      }
      
      public function get gameId() : String
      {
         return BuildConfig.instance.configVal("gameId");
      }
      
      public function get serverUrl() : String
      {
         return BuildConfig.instance.configVal("serverUrl");
      }
      
      public function get protocol() : String
      {
         return BuildConfig.instance.configVal("protocol");
      }
      
      public function get preventDispose() : Boolean
      {
         return BuildConfig.instance.configVal("preventDispose");
      }
      
      public function get main() : MovieClip
      {
         return this._root;
      }
      
      public function get ts() : PlaybackEngine
      {
         return this._ts;
      }
      
      public function onSetupFromNative(gameName:String, isDemo:Boolean = false) : void
      {
      }
      
      public function init() : void
      {
         this._engine = GameEngine.instance;
      }
      
      public function start() : void
      {
         this._playbackFactory = new PlaybackFactory(this);
         this.addChild(this._playbackFactory);
      }
      
      public function exit() : void
      {
         if(BuildConfig.instance.configVal("isBundle"))
         {
            this._engine.launchGame("Picker","Picker.swf",this.gameName);
         }
         else
         {
            this._engine.exit();
         }
      }
      
      public function doReset() : void
      {
         this.restart();
      }
      
      public function setVisibility(visible:Boolean) : void
      {
         this._root.visible = visible;
      }
      
      public function restart() : void
      {
      }
      
      public function dispose() : void
      {
         if(this._ts != null)
         {
            LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this.onLocaleChanged);
            this._ts.stopAllActions();
            this._registeredActionPackages.forEach(function(ap:Object, i:int, arr:Array):void
            {
               var actionPackage:IActionPackage;
               var apRef:IActionPackageRef = (function():IActionPackageRef
               {
                  var p:* = undefined;
                  var apPath:* = undefined;
                  var currentAp:* = undefined;
                  for each(p in _ts.activeExport.getAllProjects())
                  {
                     apPath = p.getName() + ":" + ap.name;
                     currentAp = _ts.getActionPackage(apPath);
                     if(currentAp)
                     {
                        return IActionPackageRef(currentAp);
                     }
                  }
                  return null;
               })();
               Assert.assert(apRef != null);
               actionPackage = apRef.actionPackage;
               actionPackage.handleAction(new StubActionRef("Reset"),ActionPackageClassManager.instance.getResetData(apRef.name));
            });
            this._ts.activeExport.destroy();
            this._ts = null;
         }
         JBGUtil.safeRemoveChild(this,this._playbackFactory);
         JBGUtil.safeRemoveChild(this._root,this);
      }
      
      public function get initialSettings() : Object
      {
         var gameName:String = BuildConfig.instance.configVal("gameName");
         var initialValues:Object = {};
         initialValues[gameName + SettingsConstants.SETTING_AUDIENCE_ON] = true;
         initialValues[gameName + SettingsConstants.SETTING_FAMILY_FRIENDLY] = false;
         initialValues[gameName + SettingsConstants.SETTING_EXTENDED_TIMERS] = false;
         initialValues[gameName + SettingsConstants.SETTING_REQUIRE_TWITCH] = false;
         initialValues[gameName + SettingsConstants.SETTING_CENSORABLE] = false;
         initialValues[gameName + SettingsConstants.SETTING_SKIP_TUTORIAL] = false;
         initialValues[gameName + SettingsConstants.SETTING_GAMEPAD_START] = false;
         initialValues[gameName + SettingsConstants.SETTING_HIDE_ROOMCODE] = false;
         initialValues[gameName + SettingsConstants.SETTING_SUBTITLES] = false;
         initialValues[gameName + SettingsConstants.SETTING_POST_GAME_SHARING] = true;
         initialValues[gameName + SettingsConstants.SETTING_PASSWORDED_ROOM] = false;
         initialValues[gameName + SettingsConstants.SETTING_FILTER_US_CENTRIC_CONTENT] = false;
         return initialValues;
      }
      
      public function initEngine() : void
      {
         PlaybackEngine.addAuthorizedClass(TalkshowGame);
         this._ts = PlaybackEngine.getInstance();
         this._ts.locale = LocalizationManager.instance.currentLocale;
         this._config = null;
         InternalActionPackage.STOP_AUDIO_ON_INPUT = true;
         if(this._useAudioSystem)
         {
            this._registeredActionPackages = this._registeredActionPackages.concat([{
               "project":"Common",
               "name":"AudioSystem",
               "c":AudioSystem,
               "resetData":{
                  "unloadEvents":true,
                  "unloadBanks":true
               }
            }]);
         }
         this._registeredActionPackages.forEach(function(ap:Object, i:int, arr:Array):void
         {
            ActionPackageClassManager.instance.registerClass(ap.name,ap.c,Boolean(ap.resetData) ? ap.resetData : {});
         });
         TSValue.setEngine(this._ts);
         TSUtil.setup(this._ts);
         TSInputHandler.initialize(this._ts);
         this._ts.g.settings = SettingsManager.instance;
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this.onLocaleChanged);
      }
      
      public function initConfig(cfg:Object) : void
      {
         cfg[ConfigInfo.SCRIPT_BASE] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.SCRIPT_BASE]);
         cfg[ConfigInfo.EXPORT_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.EXPORT_PATH]);
         cfg[ConfigInfo.DATA_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.DATA_PATH]);
         cfg[ConfigInfo.MEDIA_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.MEDIA_PATH]);
         cfg[ConfigInfo.ACTION_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.ACTION_PATH]);
         cfg[ConfigInfo.TEMPLATE_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.TEMPLATE_PATH]);
         cfg[ConfigInfo.PLUGIN_PATH] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.PLUGIN_PATH]);
         cfg[ConfigInfo.START_FILE] = JBGLoader.instance.getUrl("TalkshowExport/" + ConfigInfo.DEFAULTS[ConfigInfo.START_FILE]);
         this._config = new ConfigInfo(cfg);
         this.configFinished();
      }
      
      protected function configFinished() : void
      {
         this.dispatchEvent(new PlaybackEngineEvent(PlaybackEngineEvent.CONFIG_FINISHED,this._ts.uptime,"config vars loaded and set"));
      }
      
      public function startEngine() : void
      {
         var key:Namespace = this._ts.getPrivateNamespace(this);
         if(key is Namespace)
         {
            this._ts.ignitionOn(this,this._config);
         }
      }
      
      public function onLocaleChanged(event:EventWithData) : void
      {
         this._ts.locale = event.data.locale;
      }
   }
}
