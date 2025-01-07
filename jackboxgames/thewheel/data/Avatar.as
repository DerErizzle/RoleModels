package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.utils.*;
   
   public class Avatar implements IJsonData
   {
      private var _data:Object;
      
      public function Avatar()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         this._data = data;
         return PromiseUtil.RESOLVED();
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get frame() : String
      {
         return this._data.frame;
      }
      
      public function get index() : int
      {
         return this._data.index;
      }
   }
}

