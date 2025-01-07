package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   
   public interface IAudioVersion extends ILoadableVersion, IEventDispatcher
   {
      function get audio() : Sound;
      
      function get category() : String;
      
      function play() : SoundChannel;
      
      function stop() : void;
      
      function get isPlayable() : Boolean;
   }
}

