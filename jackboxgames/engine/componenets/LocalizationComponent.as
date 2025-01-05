package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.EventWithData;
   import jackboxgames.localizy.LocalizationManager;
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
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         var onLocalizationLoaded:Function = null;
         onLocalizationLoaded = function(evt:EventWithData):void
         {
            LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,onLocalizationLoaded);
            doneFn();
         };
         LocalizationManager.GameSource = this._engine.activeGame.gameName;
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,onLocalizationLoaded);
         LocalizationManager.instance.load(LocalizationManager.LOCALIZATION_FILE);
      }
      
      public function disposeGame() : void
      {
         LocalizationManager.GameSource = "";
      }
   }
}
