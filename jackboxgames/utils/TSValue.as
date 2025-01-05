package jackboxgames.utils
{
   import flash.utils.Dictionary;
   import jackboxgames.talkshow.api.IEngineAPI;
   
   public class TSValue
   {
      
      protected static var _ts:IEngineAPI;
      
      protected static var _values:Dictionary;
       
      
      private var _tsName:String;
      
      public function TSValue(tsName:String, initial:* = null)
      {
         super();
         this._tsName = tsName;
         if(initial != null)
         {
            this.val = initial;
         }
         else if(_ts.g[this._tsName] != null)
         {
            this.val = _ts.g[this._tsName];
         }
      }
      
      public static function setEngine(ts:IEngineAPI) : void
      {
         _ts = ts;
         _values = new Dictionary();
      }
      
      public static function getValue(tsName:String, initial:* = null) : *
      {
         if(_values[tsName] == null)
         {
            _values[tsName] = new TSValue(tsName,initial);
         }
         return _values[tsName].val;
      }
      
      public static function setValue(tsName:String, value:* = null) : *
      {
         if(_values[tsName] == null)
         {
            _values[tsName] = new TSValue(tsName,value);
         }
         else
         {
            _values[tsName].val = value;
         }
         return _values[tsName].val;
      }
      
      public function get val() : *
      {
         return _ts.g[this._tsName];
      }
      
      public function set val(val:*) : void
      {
         _ts.g[this._tsName] = val;
      }
   }
}
