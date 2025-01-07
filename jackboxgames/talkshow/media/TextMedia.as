package jackboxgames.talkshow.media
{
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.IFlowchart;
   
   public class TextMedia extends AbstractMedia
   {
      public function TextMedia(id:int, container:IExport, fl:IFlowchart)
      {
         super(id,container,fl);
      }
      
      override public function get type() : String
      {
         return "text";
      }
      
      override public function addVersion(idx:uint, id:int, locale:String, tag:String, script:String, ... vinfo) : void
      {
         _allVersions.push(new TextVersion(idx,id,locale,tag,script));
      }
   }
}

