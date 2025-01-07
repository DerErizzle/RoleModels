package jackboxgames.engine
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.pause.*;
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
   import jackboxgames.ui.settings.*;
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
      
      public function init(doneFn:Function) : void
      {
         this._engine = GameEngine.instance;
         doneFn();
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
            SettingsMenu.instance.reset();
            this._engine.launchGame("Picker","Picker.swf",this.gameName);
         }
         else
         {
            this._engine.exit();
         }
      }
      
      public function doReset(error:String = "") : void
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
      
      public function get settings() : Array
      {
         return [new SettingConfig(SettingsConstants.SETTING_VOLUME,1,false),new SettingConfig(SettingsConstants.SETTING_VOLUME_HOST,1,false),new SettingConfig(SettingsConstants.SETTING_VOLUME_SFX,1,false),new SettingConfig(SettingsConstants.SETTING_VOLUME_MUSIC,1,false),new SettingConfig(SettingsConstants.SETTING_FULL_SCREEN,true,false),new SettingConfig(SettingsConstants.SETTING_AUDIENCE_ON,true,false),new SettingConfig(SettingsConstants.SETTING_FAMILY_FRIENDLY,false,false),new SettingConfig(SettingsConstants.SETTING_EXTENDED_TIMERS,false,false),new SettingConfig(SettingsConstants.SETTING_NO_TIMERS,false,false),new SettingConfig(SettingsConstants.SETTING_REQUIRE_TWITCH,false,false),new SettingConfig(SettingsConstants.SETTING_CENSORABLE,false,false),new SettingConfig(SettingsConstants.SETTING_SKIP_TUTORIAL,false,false),new SettingConfig(SettingsConstants.SETTING_GAMEPAD_START,false,false),new SettingConfig(SettingsConstants.SETTING_HIDE_ROOMCODE,false,false),new SettingConfig(SettingsConstants.SETTING_SUBTITLES,false,false),new SettingConfig(SettingsConstants.SETTING_POST_GAME_SHARING,true,false),new SettingConfig(SettingsConstants.SETTING_PASSWORDED_ROOM,false,false),new SettingConfig(SettingsConstants.SETTING_FILTER_US_CENTRIC_CONTENT,false,false),new SettingConfig(SettingsConstants.SETTING_FILTER_PLAYERNAME,false,false),new SettingConfig(SettingsConstants.SETTING_MODERATED_ROOM,false,false),new SettingConfig(SettingsConstants.SETTING_PLAYER_CONTENT_FILTERING,SettingsConstants.PLAYER_CONTENT_FILTERING_HATE_SPEECH,false),new SettingConfig(SettingsConstants.SETTING_MOTION_SENSITIVITY,false,false),new SettingConfig(LocalizationManager.SETTING_LOCALE,LocalizationManager.DEFAULT_LOCALE,false)];
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
         PauseMenuManager.instance.loadMenuData(JBGLoader.instance.getMediaUrl(PauseMenuManager.PAUSE_MENU_DATA_FILE),Nullable.NULL_FUNCTION);
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this.onLocaleChanged);
      }
      
      public function initConfig(cfg:Object) : void
      {
         var root:String = BuildConfig.instance.hasConfigVal("tsRoot") ? BuildConfig.instance.configVal("tsRoot") : "TalkshowExport";
         cfg[ConfigInfo.SCRIPT_BASE] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.SCRIPT_BASE]);
         cfg[ConfigInfo.EXPORT_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.EXPORT_PATH]);
         cfg[ConfigInfo.DATA_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.DATA_PATH]);
         cfg[ConfigInfo.MEDIA_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.MEDIA_PATH]);
         cfg[ConfigInfo.ACTION_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.ACTION_PATH]);
         cfg[ConfigInfo.TEMPLATE_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.TEMPLATE_PATH]);
         cfg[ConfigInfo.PLUGIN_PATH] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.PLUGIN_PATH]);
         cfg[ConfigInfo.START_FILE] = JBGLoader.instance.getUrl(root + "/" + ConfigInfo.DEFAULTS[ConfigInfo.START_FILE]);
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

