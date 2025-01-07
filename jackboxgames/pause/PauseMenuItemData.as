package jackboxgames.pause
{
   import jackboxgames.utils.*;
   
   public class PauseMenuItemData implements IToSimpleObject
   {
      private var _data:Object;
      
      private var _isHiddenByBuildConfig:Boolean;
      
      private var _tsValue:TSValue;
      
      private var _isHiddenByTSValueFn:Function;
      
      public function PauseMenuItemData(data:Object)
      {
         super();
         this._data = data;
         this._isHiddenByBuildConfig = this._isItemHiddenByBuildConfig();
         this._isHiddenByTSValueFn = this._createHiddenByTSValueFunction();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get title() : String
      {
         return this._data.title;
      }
      
      public function get action() : String
      {
         return this._data.action;
      }
      
      public function get description() : String
      {
         return this._data.description;
      }
      
      public function get value() : int
      {
         return this._data.value;
      }
      
      public function get isVisible() : Boolean
      {
         return !(this._isHiddenByBuildConfig || this._isHiddenByTSValueFn());
      }
      
      public function get confirmation() : String
      {
         return !!this._data.hasOwnProperty("confirmation") ? this._data.confirmation : null;
      }
      
      private function _isItemHiddenByBuildConfig() : Boolean
      {
         var hideFlag:Object = !!this._data.hasOwnProperty("hideWhenBuildConfigIs") ? this._data.hideWhenBuildConfigIs : null;
         if(!hideFlag || !hideFlag.hasOwnProperty("id") || !hideFlag.hasOwnProperty("value"))
         {
            return false;
         }
         return BuildConfig.instance.configVal(hideFlag.id) == hideFlag.value;
      }
      
      public function _createHiddenByTSValueFunction() : Function
      {
         var hideFlag:Object = !!this._data.hasOwnProperty("hideWhenTSValueIs") ? this._data.hideWhenTSValueIs : null;
         if(!hideFlag || !hideFlag.hasOwnProperty("id") || !hideFlag.hasOwnProperty("value"))
         {
            return function():Boolean
            {
               return false;
            };
         }
         this._tsValue = new TSValue(hideFlag.id);
         return function():Boolean
         {
            return _tsValue.val == _data.hideWhenTSValueIs.value;
         };
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "title":this.title,
            "action":this.action,
            "description":this.description,
            "value":this.value,
            "isVisible":this.isVisible,
            "confirmation":this.confirmation,
            "isValid":this._data.isValid
         };
      }
   }
}

