package jackboxgames.ecast.messages
{
   public class TextElement
   {
      private var _key:String;
      
      private var _text:String;
      
      private var _version:int;
      
      public function TextElement(key:String, text:String, version:int)
      {
         super();
         this._key = key;
         this._text = text;
         this._version = version;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function get version() : int
      {
         return this._version;
      }
      
      public function toString() : String
      {
         return "TextElement{\n\tkey:" + this._key + "\n\ttext: " + this._text + "\n}";
      }
   }
}

