package jackboxgames.engine.componenets
{
   import jackboxgames.audio.AudioNotifier;
   import jackboxgames.audio.JBGSoundPlayer;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioComponent extends PausableEventDispatcher implements IComponent
   {
      private var _engine:GameEngine;
      
      public function AudioComponent(engine:GameEngine)
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
         AudioSystem.Initialize();
         AudioNotifier.Initialize();
         doneFn();
      }
      
      public function dispose() : void
      {
         AudioSystem.instance.dispose();
         JBGSoundPlayer.instance.stop();
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}

