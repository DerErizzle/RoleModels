package jackboxgames.talkshow.export
{
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.media.AbstractMedia;
   import jackboxgames.talkshow.media.AudioMedia;
   import jackboxgames.talkshow.media.GraphicMedia;
   import jackboxgames.talkshow.media.TextMedia;
   import jackboxgames.talkshow.utils.ExportDictionary;
   
   internal class MediaFactory
   {
      
      private static const DELIMITER_DEFINITION:String = "^";
      
      private static const DELIMITER_MEDIA_DATA:String = "|";
       
      
      public function MediaFactory()
      {
         super();
      }
      
      public static function buildMedia(export:Export, mediaData:String, dict:ExportDictionary, fl:Flowchart) : void
      {
         var def:String = null;
         var items:Array = null;
         var id:int = 0;
         var type:String = null;
         var count:int = 0;
         var media:AbstractMedia = null;
         var i:uint = 0;
         var defs:Array = mediaData.split(DELIMITER_DEFINITION);
         for each(def in defs)
         {
            items = def.split(DELIMITER_MEDIA_DATA);
            id = items.shift();
            type = items.shift();
            count = items.shift();
            if(type == "A")
            {
               media = new AudioMedia(id,export,fl);
            }
            else if(type == "G")
            {
               media = new GraphicMedia(id,export,fl);
            }
            else if(type == "T")
            {
               media = new TextMedia(id,export,fl);
            }
            if(media == null)
            {
               throw new ArgumentError("Invalid media type");
            }
            for(i = 0; i < count; i++)
            {
               media.addVersion(i,items.shift(),items.shift(),dict.lookup(items.shift()),dict.lookup(items.shift()),items.shift());
            }
            export.addMedia(media);
         }
         export.filterAllMediaForLocale(PlaybackEngine.getInstance().locale);
      }
   }
}
