package jackboxgames.ui.settings
{
   import jackboxgames.audio.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   
   public class SettingsMenuAudio
   {
      public static const SFX_MENU_ON:String = "PAUSE/SETTINGS/MenuOn";
      
      public static const SFX_MENU_OFF:String = "PAUSE/SETTINGS/MenuOff";
      
      public static const SFX_MENU_SCROLL:String = "PAUSE/SETTINGS/MenuScroll";
      
      public static const SFX_MENU_SELECT:String = "PAUSE/SETTINGS/MenuSelect";
      
      public static const SFX_VOLUME_MASTER_CHANGED:String = "PAUSE/SETTINGS/VolumeMasterChanged";
      
      public static const SFX_VOLUME_HOST_CHANGED:String = "PAUSE/SETTINGS/VolumeHostChanged";
      
      public static const SFX_VOLUME_MUSIC_CHANGED:String = "PAUSE/SETTINGS/VolumeMusicChanged";
      
      public static const SFX_VOLUME_SFX_CHANGED:String = "PAUSE/SETTINGS/VolumeSFXChanged";
      
      public static const SFX_ITEM_HIGHLIGHT:String = "PAUSE/SETTINGS/ItemHighlight";
      
      public static const SFX_ITEM_TOGGLE:String = "PAUSE/SETTINGS/ItemToggle";
      
      public static const SFX_ITEM_WIDELIST_TOGGLE:String = "PAUSE/SETTINGS/WideListToggle";
      
      public static const SFX_ITEM_FULLSCREEN_TOGGLE:String = "PAUSE/SETTINGS/FullScreenToggle";
      
      public static const SFX_TAB_SELECT:String = "PAUSE/SETTINGS/TabSelect";
      
      private var _audioCollection:AudioSystemEventCollection;
      
      public function SettingsMenuAudio()
      {
         super();
         var collection:Object = {};
         collection[SFX_MENU_ON] = SFX_MENU_ON;
         collection[SFX_MENU_OFF] = SFX_MENU_OFF;
         collection[SFX_MENU_SCROLL] = SFX_MENU_SCROLL;
         collection[SFX_MENU_SELECT] = SFX_MENU_SELECT;
         collection[SFX_VOLUME_MASTER_CHANGED] = SFX_VOLUME_MASTER_CHANGED;
         collection[SFX_VOLUME_HOST_CHANGED] = SFX_VOLUME_HOST_CHANGED;
         collection[SFX_VOLUME_MUSIC_CHANGED] = SFX_VOLUME_MUSIC_CHANGED;
         collection[SFX_VOLUME_SFX_CHANGED] = SFX_VOLUME_SFX_CHANGED;
         collection[SFX_ITEM_HIGHLIGHT] = SFX_ITEM_HIGHLIGHT;
         collection[SFX_ITEM_TOGGLE] = SFX_ITEM_TOGGLE;
         collection[SFX_ITEM_WIDELIST_TOGGLE] = SFX_ITEM_WIDELIST_TOGGLE;
         collection[SFX_ITEM_FULLSCREEN_TOGGLE] = SFX_ITEM_FULLSCREEN_TOGGLE;
         collection[SFX_TAB_SELECT] = SFX_TAB_SELECT;
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

