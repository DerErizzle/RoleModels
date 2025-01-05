package jackboxgames.blobcast.model
{
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class RoomPasswordManager extends PausableEventDispatcher
   {
      
      public static const EVENT_PASSWORD_CHANGED:String = "PasswordChanged";
      
      private static const SAVE_KEY:String = "RoomPassword";
       
      
      private var _currentPasswordData:Object;
      
      public function RoomPasswordManager()
      {
         var savedPasswordData:Object;
         super();
         savedPasswordData = Save.instance.loadObject(SAVE_KEY);
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_PASSWORDED_ROOM).val)
         {
            if(Boolean(savedPasswordData))
            {
               this._currentPasswordData = savedPasswordData;
            }
            else
            {
               this._currentPasswordData = this._generatePasswordData();
               Save.instance.saveObject(SAVE_KEY,this._currentPasswordData);
               dispatchEvent(new EventWithData(EVENT_PASSWORD_CHANGED,this._currentPasswordData));
            }
         }
         else if(Boolean(savedPasswordData))
         {
            this._currentPasswordData = null;
            Save.instance.deleteObject(SAVE_KEY);
            dispatchEvent(new EventWithData(EVENT_PASSWORD_CHANGED,this._currentPasswordData));
         }
         else
         {
            this._currentPasswordData = null;
         }
         SettingsManager.instance.getValue(SettingsConstants.SETTING_PASSWORDED_ROOM).addEventListener(SettingsValue.EVENT_VALUE_CHANGED,function(evt:EventWithData):void
         {
            _onSettingChanged();
         });
      }
      
      private function _generatePassword() : String
      {
         var password:String = "";
         for(var i:int = 0; i < 5; i++)
         {
            password += int(Random.instance.roll(10,0));
         }
         return password;
      }
      
      private function _generatePasswordData() : Object
      {
         return {"password":this._generatePassword()};
      }
      
      private function _onSettingChanged() : void
      {
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_PASSWORDED_ROOM).val)
         {
            this._currentPasswordData = this._generatePasswordData();
            Save.instance.saveObject(SAVE_KEY,this._currentPasswordData);
         }
         else
         {
            this._currentPasswordData = null;
            Save.instance.deleteObject(SAVE_KEY);
         }
         dispatchEvent(new EventWithData(EVENT_PASSWORD_CHANGED,this._currentPasswordData));
      }
      
      public function get hasPassword() : Boolean
      {
         return this._currentPasswordData != null;
      }
      
      public function get password() : String
      {
         return this._currentPasswordData.password;
      }
   }
}
