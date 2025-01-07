package jackboxgames.utils
{
   import jackboxgames.events.EventWithData;
   
   public class WatchableValue extends PausableEventDispatcher
   {
      public static const EVENT_VALUE_CHANGED:String = "WatchableValue.ValueChanged";
      
      private var _initial:*;
      
      private var _val:*;
      
      private var _metadata:*;
      
      private var _saveValue:SavedValue;
      
      private var _tsValue:TSValue;
      
      public function WatchableValue(initial:*, metadata:* = undefined, saveId:String = null, tsName:String = null)
      {
         super();
         this._metadata = metadata;
         this._saveValue = Boolean(saveId) ? new SavedValue(saveId,initial) : null;
         this._initial = Boolean(this._saveValue) ? this._saveValue.val : initial;
         this._tsValue = Boolean(tsName) ? new TSValue(tsName,this._initial) : null;
         this._val = this._initial;
      }
      
      public function reset() : void
      {
         this.val = this._initial;
      }
      
      public function get val() : *
      {
         return this._val;
      }
      
      public function set val(newVal:*) : void
      {
         if(this._val === newVal)
         {
            return;
         }
         var oldVal:* = this._val;
         this._val = newVal;
         if(Boolean(this._saveValue))
         {
            this._saveValue.val = this._val;
         }
         if(Boolean(this._tsValue))
         {
            this._tsValue.val = this._val;
         }
         dispatchEvent(new EventWithData(EVENT_VALUE_CHANGED,{
            "watchableValue":this,
            "oldValue":oldVal,
            "newValue":this._val,
            "metadata":this._metadata
         }));
      }
      
      public function save() : void
      {
         if(Boolean(this._saveValue))
         {
            this._saveValue.save();
         }
      }
   }
}

