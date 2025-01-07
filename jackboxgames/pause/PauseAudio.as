package jackboxgames.pause
{
   import jackboxgames.audio.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   
   public class PauseAudio
   {
      public static const SFX_CONFIRM_NO:String = "PAUSE/SFX/ConfirmNo";
      
      public static const SFX_CONFIRM_YES:String = "PAUSE/SFX/ConfirmYes";
      
      public static const SFX_MENU_ON:String = "PAUSE/SFX/MenuOn";
      
      public static const SFX_MENU_OFF:String = "PAUSE/SFX/MenuOff";
      
      public static const SFX_MENU_SCROLL:String = "PAUSE/SFX/MenuScroll";
      
      public static const SFX_MENU_SELECT:String = "PAUSE/SFX/MenuSelect";
      
      private var _audioCollection:AudioSystemEventCollection;
      
      public function PauseAudio()
      {
         super();
         var collection:Object = {};
         collection[SFX_CONFIRM_NO] = SFX_CONFIRM_NO;
         collection[SFX_CONFIRM_YES] = SFX_CONFIRM_YES;
         collection[SFX_MENU_ON] = SFX_MENU_ON;
         collection[SFX_MENU_OFF] = SFX_MENU_OFF;
         collection[SFX_MENU_SCROLL] = SFX_MENU_SCROLL;
         collection[SFX_MENU_SELECT] = SFX_MENU_SELECT;
         this._audioCollection = new AudioSystemEventCollection(collection);
      }
      
      public function dispose() : void
      {
         this._audioCollection.dispose();
      }
      
      public function reset() : void
      {
         this._audioCollection.setLoaded(false,Nullable.NULL_FUNCTION);
      }
      
      public function setLoaded(isLoaded:Boolean, doneFn:Function) : void
      {
         this._audioCollection.setLoaded(isLoaded,doneFn);
      }
      
      public function play(key:String, doneFn:Function) : void
      {
         this._audioCollection.play(key,doneFn);
      }
      
      public function stop(key:String) : void
      {
         this._audioCollection.stop(key);
      }
   }
}

