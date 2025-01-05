package jackboxgames.engine.componenets
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.video.VideoPlayerFactory;
   
   public class VideoComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function VideoComponent(engine:GameEngine)
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
         VideoPlayerFactory.Parent = this._engine.activeGame.main;
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}
