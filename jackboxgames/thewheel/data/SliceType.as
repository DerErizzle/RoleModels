package jackboxgames.thewheel.data
{
   import jackboxgames.thewheel.wheel.effects.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.thewheel.wheel.subwidgets.*;
   import jackboxgames.utils.*;
   
   public class SliceType
   {
      private var _data:Object;
      
      private var _dataClass:Class;
      
      private var _subWidgetClass:Class;
      
      private var _potentialEffects:Array;
      
      public function SliceType(data:Object)
      {
         super();
         this._data = data;
         this._dataClass = !!this._data.hasOwnProperty("dataClass") ? this._data.dataClass : NullSliceData;
         this._subWidgetClass = !!this._data.hasOwnProperty("subWidgetClass") ? this._data.subWidgetClass : NullSliceSubWidget;
         if(this._data.hasOwnProperty("potentialEffects"))
         {
            this._potentialEffects = this._data.potentialEffects.map(function(potentialEffectData:Object, ... args):SliceTypePotentialEffect
            {
               return new SliceTypePotentialEffect(potentialEffectData);
            });
         }
         else
         {
            this._potentialEffects = [new SliceTypePotentialEffect({"effectClass":NullSliceEffect})];
         }
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get baseSymbolName() : String
      {
         return this._data.baseSymbolName;
      }
      
      public function get dataClass() : Class
      {
         return this._dataClass;
      }
      
      public function get subWidgetClass() : Class
      {
         return this._subWidgetClass;
      }
      
      public function get potentialEffects() : Array
      {
         return this._potentialEffects;
      }
   }
}

