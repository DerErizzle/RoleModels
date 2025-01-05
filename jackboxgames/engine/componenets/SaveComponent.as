package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.nativeoverride.Save;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class SaveComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function SaveComponent(engine:GameEngine)
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
         Save.Initialize();
         if(Save.instance.needsPrepare && BuildConfig.instance.configVal("supportsFullScreen"))
         {
            Save.instance.prepare("",function(success:Boolean):void
            {
               doneFn();
            });
         }
         else
         {
            doneFn();
         }
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         Save.GamePrefix = this._engine.activeGame.gameSavePrefix;
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}
