package jackboxgames.settings
{
   import jackboxgames.utils.*;
   
   public class SettingConfig implements IToSimpleObject
   {
      private var _key:String;
      
      private var _gameName:String;
      
      private var _defaultVal:*;
      
      private var _isSpecificToGame:Boolean;
      
      public function SettingConfig(key:String, defaultVal:*, isSpecificToGame:Boolean)
      {
         super();
         this._key = key;
         this._gameName = BuildConfig.instance.configVal("gameName");
         this._defaultVal = defaultVal;
         this._isSpecificToGame = isSpecificToGame;
      }
      
      public static function fromSimpleObject(o:Object) : SettingConfig
      {
         var c:SettingConfig = new SettingConfig(o.key,o.defaultVal,o.isSpecificToGame);
         c._gameName = o.gameName;
         return c;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get defaultVal() : *
      {
         return this._defaultVal;
      }
      
      public function get isSpecificToGame() : Boolean
      {
         return this._isSpecificToGame;
      }
      
      public function get saveKey() : String
      {
         return this.isSpecificToGame ? this._gameName + this._key : this._key;
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "key":this._key,
            "gameName":this._gameName,
            "defaultVal":this._defaultVal,
            "isSpecificToGame":this._isSpecificToGame
         };
      }
   }
}

