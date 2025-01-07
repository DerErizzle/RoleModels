package jackboxgames.ui.menu.components
{
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsValue;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.audiosystem.AudioSystemEventCollection;
   
   public class AudioEventMainMenuAudioHandler implements IMainMenuAudioHandler
   {
      protected var _events:AudioSystemEventCollection;
      
      public function AudioEventMainMenuAudioHandler()
      {
         super();
      }
      
      public function setup(data:Object) : void
      {
         if(Boolean(this._events))
         {
            this._events.dispose();
         }
         this._events = new AudioSystemEventCollection(data);
         this._events.setLoaded(true,function(success:Boolean):void
         {
         });
      }
      
      public function shutdown() : void
      {
         if(Boolean(this._events))
         {
            this._events.dispose();
            this._events = null;
         }
      }
      
      public function onMenuHighlightChanged(oldSelected:int, newSelected:int) : void
      {
         this._events.play("menuHighlight");
      }
      
      public function onMenuItemSelected(item:int, choice:String) : void
      {
         if(choice != "doPlayGame")
         {
            this._events.play("menuItemSelected");
         }
      }
      
      public function onSettingsMenuShownChanged(isShown:Boolean) : void
      {
         if(isShown)
         {
            this._events.play("settingsAppear");
         }
         else
         {
            this._events.play("settingsDisappear");
         }
      }
      
      public function onSettingsMenuHighlightChanged(oldSelected:int, newSelected:int) : void
      {
         this._events.play("settingsHighlight");
      }
      
      public function onSettingToggled(key:String, setting:SettingsValue) : void
      {
         switch(key)
         {
            case SettingsConstants.SETTING_FULL_SCREEN:
               if(setting.val)
               {
                  this._events.play("settingsFullscreenOn");
               }
               else
               {
                  this._events.play("settingsFullscreenOff");
               }
               break;
            case SettingsConstants.SETTING_VOLUME:
               this._events.play("settingsVolumeMain");
               break;
            case SettingsConstants.SETTING_VOLUME_HOST:
               this._events.play("settingsVolumeHost");
               break;
            case SettingsConstants.SETTING_VOLUME_SFX:
               this._events.play("settingsVolumeSfx");
               break;
            case SettingsConstants.SETTING_VOLUME_MUSIC:
               this._events.play("settingsVolumeMusic");
               break;
            case BuildConfig.instance.configVal("gameName") + SettingsConstants.SETTING_MAX_PLAYERS:
               this._events.play("settingsMaxPlayers");
               break;
            default:
               if(setting.val)
               {
                  this._events.play("settingsToggleOn");
               }
               else
               {
                  this._events.play("settingsToggleOff");
               }
         }
      }
   }
}

