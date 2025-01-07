package jackboxgames.ecast.messages.audience
{
   public class PositiveNegativeCounter
   {
      private var _key:String;
      
      private var _count:int;
      
      public function PositiveNegativeCounter(key:String, count:int)
      {
         super();
         this._key = key;
         this._count = count;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get count() : int
      {
         return this._count;
      }
   }
}

