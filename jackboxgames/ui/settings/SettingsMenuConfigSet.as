package jackboxgames.ui.settings
{
   import jackboxgames.algorithm.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuConfigSet implements IToSimpleObject
   {
      private var _configs:Object;
      
      public function SettingsMenuConfigSet()
      {
         super();
         this._configs = {};
      }
      
      public static function fromSimpleObject(o:Object) : SettingsMenuConfigSet
      {
         var cs:SettingsMenuConfigSet = new SettingsMenuConfigSet();
         cs._configs = o;
         return cs;
      }
      
      public function getConfigNames() : Array
      {
         return ObjectUtil.getProperties(this._configs);
      }
      
      public function add(name:String, file:String) : Promise
      {
         this._configs[name] = new SettingsMenuConfig();
         return this._configs[name].load(file);
      }
      
      public function getConfig(name:String) : SettingsMenuConfig
      {
         return this._configs[name];
      }
      
      public function toSimpleObject() : Object
      {
         return this._configs;
      }
   }
}

