package jackboxgames.utils
{
   public class TuneableValues
   {
      
      private static var _instance:TuneableValues;
       
      
      private var _values:Object;
      
      public function TuneableValues()
      {
         super();
         this._values = {};
      }
      
      public static function get instance() : TuneableValues
      {
         if(!_instance)
         {
            _instance = new TuneableValues();
         }
         return _instance;
      }
      
      public function setDefaults(defaultValues:Object) : void
      {
         var k:String = null;
         for(k in defaultValues)
         {
            this.getValue(k).val = defaultValues[k];
         }
      }
      
      public function hasValue(key:String) : Boolean
      {
         return this._values.hasOwnProperty(key);
      }
      
      public function getValue(key:String) : WatchableValue
      {
         if(!this._values.hasOwnProperty(key))
         {
            this._values[key] = new WatchableValue(0,this,null,null);
         }
         return this._values[key];
      }
      
      public function clearValue(key:String) : void
      {
         if(!this._values.hasOwnProperty(key))
         {
            return;
         }
         delete this._values[key];
      }
   }
}
