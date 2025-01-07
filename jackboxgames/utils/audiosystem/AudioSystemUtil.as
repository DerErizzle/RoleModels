package jackboxgames.utils.audiosystem
{
   import flash.geom.Point;
   import jackboxgames.nativeoverride.AudioEvent;
   import jackboxgames.nativeoverride.AudioFaderGroup;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.StageRef;
   
   public class AudioSystemUtil
   {
      public static const FADER_GROUP_NAME_HOST:String = "HOST";
      
      public static const FADER_GROUP_NAME_SFX:String = "SFX";
      
      public static const FADER_GROUP_NAME_MUSIC:String = "MUSIC";
      
      public function AudioSystemUtil()
      {
         super();
      }
      
      public static function setLocation(e:AudioEvent, flashLocation:Point) : void
      {
         var halfWidth:Number = StageRef.stageWidth / 2;
         var halfHeight:Number = StageRef.stageHeight / 2;
         e.setParameterValue("location-x",(flashLocation.x - halfWidth) / halfWidth);
         e.setParameterValue("location-y",(halfHeight - flashLocation.y) / halfHeight);
      }
      
      public static function setFaderGroupVolume(name:String, vol:Number) : void
      {
         var faderGroup:AudioFaderGroup = AudioSystem.instance.createFaderGroup(name);
         faderGroup.load(Nullable.NULL_FUNCTION);
         faderGroup.volume = vol;
         AudioSystem.instance.disposeFaderGroup(faderGroup);
      }
      
      public static function setCommonFaderGroupVolumes() : void
      {
         setFaderGroupVolume(FADER_GROUP_NAME_HOST,SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME_HOST).val);
         setFaderGroupVolume(FADER_GROUP_NAME_SFX,SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME_SFX).val);
         setFaderGroupVolume(FADER_GROUP_NAME_MUSIC,SettingsManager.instance.getValue(SettingsConstants.SETTING_VOLUME_MUSIC).val);
      }
   }
}

