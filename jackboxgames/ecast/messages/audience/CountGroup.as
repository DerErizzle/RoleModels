package jackboxgames.ecast.messages.audience
{
   public class CountGroup
   {
      private var _key:String;
      
      private var _choices:Object;
      
      public function CountGroup(key:String, choices:Object)
      {
         super();
         this._key = key;
         this._choices = choices;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get choices() : Object
      {
         return this._choices;
      }
   }
}

