package jackboxgames.ui.settings
{
   import jackboxgames.expressionparser.*;
   import jackboxgames.localizy.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuConfigItem implements ISettingsMenuElementData, IToSimpleObject
   {
      private var _data:Object;
      
      private var _isEnabled:IExpression;
      
      public function SettingsMenuConfigItem(data:Object)
      {
         var parser:ExpressionParser = null;
         var res:Result = null;
         super();
         this._data = data;
         if(this._data.hasOwnProperty("isEnabled"))
         {
            parser = new ExpressionParser();
            res = parser.parse(this._data.isEnabled);
            if(res.succeeded)
            {
               this._isEnabled = res.payload;
            }
            else
            {
               Assert.assert(false,res.payload);
            }
         }
      }
      
      public static function fromSimpleObject(o:Object) : SettingsMenuConfigItem
      {
         return new SettingsMenuConfigItem(o);
      }
      
      public function get type() : String
      {
         return this._data.type;
      }
      
      public function get source() : String
      {
         return this._data.source;
      }
      
      public function get title() : String
      {
         return LocalizationManager.instance.getValueForKey(this._data.title,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      public function get description() : String
      {
         return LocalizationManager.instance.getValueForKey(this._data.description,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE);
      }
      
      public function get options() : Array
      {
         return this._data.options;
      }
      
      public function get defaultValueIndex() : int
      {
         return this._data.defaultValueIndex;
      }
      
      public function getDescriptionForListItem(i:int) : String
      {
         return this._data.description is Array ? LocalizationManager.instance.getValueForKey(this._data.description[i],SettingsMenu.SETTINGS_LOCALIZATION_SOURCE) : this.description;
      }
      
      public function get password() : String
      {
         return this._data.password;
      }
      
      public function get step() : Number
      {
         return this._data.step;
      }
      
      public function get icons() : Array
      {
         return this._data.icons;
      }
      
      public function get values() : Array
      {
         return this._data.values;
      }
      
      public function getIsEnabled(del:IExpressionDataDelegate) : Boolean
      {
         if(Boolean(this._isEnabled))
         {
            return this._isEnabled.evaluate(del);
         }
         return true;
      }
      
      public function toSimpleObject() : Object
      {
         return this._data;
      }
   }
}

