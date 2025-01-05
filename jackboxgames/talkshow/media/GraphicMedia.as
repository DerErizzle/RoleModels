package jackboxgames.talkshow.media
{
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.IFlowchart;
   
   public class GraphicMedia extends AbstractMedia
   {
       
      
      public function GraphicMedia(id:int, container:IExport, fl:IFlowchart)
      {
         super(id,container,fl);
      }
      
      override public function get type() : String
      {
         return "graphic";
      }
      
      override public function addVersion(idx:uint, id:int, locale:String, tag:String, script:String, ... vinfo) : void
      {
         var v:GraphicVersion = new GraphicVersion(idx,id,locale,tag,script,vinfo[0] as String,_container.configInfo);
         _allVersions.push(v);
      }
   }
}
