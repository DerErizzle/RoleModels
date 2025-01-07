package jackboxgames.widgets.postgame.audio
{
   public interface IPostGameAudioHandler
   {
      function setup(param1:Object) : void;
      
      function playCountdownAudio(param1:Function) : void;
      
      function stopCountdownAudio() : void;
      
      function playChoiceMadeAudio(param1:Function) : void;
      
      function playBackAudio(param1:Function) : void;
      
      function playSettingsPopUpAudio(param1:Function) : void;
   }
}

