package jackboxgames.settings
{
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.intermoviecommunication.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class RoomPasswordManager extends IMCModule
   {
      private static var _instance:RoomPasswordManager;
      
      public static const EVENT_PASSWORD_CHANGED:String = "PasswordChanged";
      
      private static const SAVE_KEY:String = "RoomPasswords";
      
      private var _settingsWithPassword:Array;
      
      private var _passwords:Array;
      
      public function RoomPasswordManager()
      {
         super("RoomPasswordManager",IMCModule.MOVIE_ID_MANAGER);
      }
      
      public static function initialize() : void
      {
         trace("Initializing data store: " + _instance);
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new RoomPasswordManager();
      }
      
      public static function get instance() : RoomPasswordManager
      {
         return _instance;
      }
      
      public function init(settingsWithPassword:Array) : void
      {
         _doFunctionBehavior("init",function(settingsWithPassword:Array):void
         {
            _settingsWithPassword = settingsWithPassword;
            SettingsManager.instance.addEventListener(SettingsManager.EVENT_SETTING_CHANGED,_onSettingChanged);
         },settingsWithPassword);
      }
      
      public function reloadFromSave() : void
      {
         _doFunctionBehavior("reloadFromSave",function():void
         {
            var savedPasswordData:Object = null;
            _passwords = [];
            savedPasswordData = Save.instance.loadGlobalObject(SAVE_KEY);
            _settingsWithPassword.forEach(function(setting:String, ... args):void
            {
               var key:* = undefined;
               var data:Object = null;
               var passwordData:PasswordData = null;
               if(savedPasswordData != null)
               {
                  for(key in savedPasswordData)
                  {
                     data = savedPasswordData[key];
                     if(data.setting == setting)
                     {
                        passwordData = PasswordData.fromSimpleObject(data);
                        break;
                     }
                  }
               }
               if(passwordData == null)
               {
                  passwordData = new PasswordData(setting,null);
               }
               _passwords.push(passwordData);
               _updatePasswordForSetting(passwordData.setting);
            });
         });
      }
      
      private function _getPasswordDataForSetting(setting:String) : PasswordData
      {
         return ArrayUtil.first(this._passwords.filter(function(password:PasswordData, ... args):Boolean
         {
            return password.setting == setting;
         }));
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
      
      private function _onSettingChanged(evt:EventWithData) : void
      {
         this._updatePasswordForSetting(evt.data.settingName);
      }
      
      private function _updatePasswordForSetting(setting:String) : void
      {
         var passwordData:PasswordData = this._getPasswordDataForSetting(setting);
         if(passwordData == null)
         {
            return;
         }
         var passwordWasChanged:Boolean = false;
         if(SettingsManager.instance.getValue(passwordData.setting).val)
         {
            if(passwordData.password == null)
            {
               passwordWasChanged = true;
               passwordData.password = this._generatePassword();
            }
         }
         else
         {
            passwordWasChanged = passwordData.password != null;
            passwordData.password = null;
         }
         if(passwordWasChanged)
         {
            Save.instance.saveGlobalObject(SAVE_KEY,SimpleObjectUtil.deepCopyWithSimpleObjectReplacement(this._passwords));
            dispatchEvent(new EventWithData(EVENT_PASSWORD_CHANGED,{
               "source":passwordData.setting,
               "password":passwordData.password
            }));
         }
      }
      
      public function hasPasswordForSetting(setting:String) : Boolean
      {
         return _doFunctionBehavior("hasPasswordForSetting",function(setting:String):Boolean
         {
            var passwordData:* = _getPasswordDataForSetting(setting);
            if(passwordData == null)
            {
               return false;
            }
            return passwordData.password != null;
         },setting);
      }
      
      public function getPasswordForSetting(setting:String) : String
      {
         return _doFunctionBehavior("getPasswordForSetting",function(setting:String):String
         {
            var passwordData:* = _getPasswordDataForSetting(setting);
            if(passwordData == null)
            {
               return null;
            }
            return passwordData.password;
         },setting);
      }
   }
}

import jackboxgames.utils.*;

class PasswordData implements IToSimpleObject
{
   private var _setting:String;
   
   private var _password:String;
   
   public function PasswordData(setting:String, password:String)
   {
      super();
      this._setting = setting;
      this._password = password;
   }
   
   public static function fromSimpleObject(o:Object) : PasswordData
   {
      return new PasswordData(o.setting,o.password);
   }
   
   public function get setting() : String
   {
      return this._setting;
   }
   
   public function get password() : String
   {
      return this._password;
   }
   
   public function set password(value:String) : void
   {
      this._password = value;
   }
   
   public function toSimpleObject() : Object
   {
      return {
         "setting":this._setting,
         "password":this._password
      };
   }
}

