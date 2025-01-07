package jackboxgames.talkshow.media
{
   import jackboxgames.logger.Logger;
   
   public class TextVersion extends AbstractVersion
   {
      public function TextVersion(idx:uint, id:uint, locale:String, tag:String, text:String)
      {
         super(idx,id,locale,tag,text);
         Logger.debug("TextVersion (" + this.toString() + ")");
      }
      
      override public function toString() : String
      {
         return "[TextVersion idx=" + idx + " id=" + id + " locale=" + locale + " tag=\"" + tag + "\" txt=\"" + text + "\"]";
      }
   }
}

