package jackboxgames.talkshow.media
{
   import jackboxgames.utils.*;
   
   public final class MediaMetadataHelper
   {
       
      
      public function MediaMetadataHelper()
      {
         super();
      }
      
      public static function getMetadataWithStrippedText(text:String) : Object
      {
         var m:String = null;
         var splitMatch:Array = null;
         var key:String = null;
         var value:String = null;
         if(!text)
         {
            text = "";
         }
         var textMatches:Array = text.match(/\[.*?=.*?\]/g);
         var newText:String = text.replace(/\[.*?=.*?\]/g,"");
         newText = TextUtils.trim(newText);
         var metadata:Object = {};
         for each(m in textMatches)
         {
            m = m.replace(/[\[\]]/g,"");
            splitMatch = m.split("=");
            key = TextUtils.trim(splitMatch[0]);
            value = splitMatch.length > 1 ? TextUtils.trim(splitMatch[1]) : null;
            metadata[key] = value;
         }
         return {
            "text":newText,
            "metadata":metadata
         };
      }
   }
}
