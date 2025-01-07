package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.EventWithData;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class LocalizationComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      public function LocalizationComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function init(doneFn:Function) : void
      {
         var file:String;
         var onLocalizationLoaded:Function = null;
         onLocalizationLoaded = function(evt:EventWithData):void
         {
            LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,onLocalizationLoaded);
            if(LocalizationManager.instance.currentLocale == LocalizationManager.DEFAULT_LOCALE)
            {
               LocalizationManager.instance.currentLocale = Platform.instance.PlatformLocale;
            }
            doneFn();
         };
         LocalizationManager.GameSource = BuildConfig.instance.configVal("gameName");
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,onLocalizationLoaded);
         file = LocalizationManager.LOCALIZATION_FILE;
         if(BuildConfig.instance.hasConfigVal("localizationFile"))
         {
            file = BuildConfig.instance.configVal("localizationFile");
         }
         LocalizationManager.instance.load(file,BuildConfig.instance.configVal("gameName"));
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         if(EnvUtil.isAIR() && !LocalizationManager.instance.hasDataFor(BuildConfig.instance.configVal("gameName")))
         {
            this.init(doneFn);
         }
         else
         {
            LocalizationManager.GameSource = BuildConfig.instance.configVal("gameName");
            doneFn();
         }
      }
      
      public function disposeGame() : void
      {
         LocalizationManager.GameSource = "";
      }
   }
}

