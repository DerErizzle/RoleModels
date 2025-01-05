package jackboxgames.talkshow.media
{
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AbstractVersion extends PausableEventDispatcher implements IMediaVersion
   {
       
      
      protected var _idx:uint;
      
      protected var _id:int;
      
      protected var _locale:String;
      
      protected var _tag:String;
      
      protected var _text:String;
      
      protected var _metadata:Object;
      
      public function AbstractVersion(idx:uint, id:uint, locale:String, tag:String, text:String)
      {
         super();
         this._idx = idx;
         this._id = id;
         this._locale = locale;
         this._tag = tag;
         var m:Object = MediaMetadataHelper.getMetadataWithStrippedText(text);
         this._text = m.text;
         this._metadata = m.metadata;
      }
      
      public function get idx() : uint
      {
         return this._idx;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get locale() : String
      {
         return this._locale;
      }
      
      public function get tag() : String
      {
         return this._tag;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function get metadata() : Object
      {
         return this._metadata;
      }
   }
}
