package jackboxgames.engine.componenets.air
{
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componenets.IComponent;
   import jackboxgames.engine.componenets.IVolumeComponent;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AirAudioComponent extends PausableEventDispatcher implements IVolumeComponent, IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function AirAudioComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 1;
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
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      public function setVolume(percent:Number) : void
      {
         SoundMixer.soundTransform = new SoundTransform(percent);
      }
   }
}
