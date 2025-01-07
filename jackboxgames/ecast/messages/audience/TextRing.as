package jackboxgames.ecast.messages.audience
{
   public class TextRing
   {
      private var _key:String;
      
      private var _elements:Object;
      
      public function TextRing(key:String, elements:Object)
      {
         super();
         this._key = key;
         this._elements = elements;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get elements() : Object
      {
         return this._elements;
      }
   }
}

