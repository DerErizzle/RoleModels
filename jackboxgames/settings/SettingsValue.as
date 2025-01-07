package jackboxgames.settings
{
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class SettingsValue extends PausableEventDispatcher
   {
      public static const EVENT_VALUE_CHANGED:String = "SettingsValue.Changed";
      
      private var _getFn:Function;
      
      private var _setFn:Function;
      
      private var _getInitialFn:Function;
      
      public function SettingsValue(getFn:Function, setFn:Function, getInitialFn:Function)
      {
         super();
         this._getFn = getFn;
         this._setFn = setFn;
         this._getInitialFn = getInitialFn;
      }
      
      public function get val() : *
      {
         return this._getFn();
      }
      
      public function set val(newVal:*) : void
      {
         this._setFn(newVal);
      }
      
      public function get isSetToDefault() : Boolean
      {
         return this.val == this._getInitialFn();
      }
      
      public function setToDefault() : void
      {
         this.val = this._getInitialFn();
      }
   }
}

