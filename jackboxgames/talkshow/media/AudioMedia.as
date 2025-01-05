package jackboxgames.talkshow.media
{
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.IFlowchart;
   
   public class AudioMedia extends AbstractMedia
   {
      
      public static const FILE_INFO_DELIM:String = ",";
       
      
      public function AudioMedia(id:int, container:IExport, fl:IFlowchart)
      {
         super(id,container,fl);
      }
      
      override public function get type() : String
      {
         return "audio";
      }
      
      override public function addVersion(idx:uint, id:int, locale:String, tag:String, script:String, ... vinfo) : void
      {
         var info:String = vinfo[0] as String;
         var fdata:Array = info.split(FILE_INFO_DELIM);
         var v:AudioVersion = new AudioVersion(idx,id,locale,tag,script,fdata[0],_container.configInfo);
         if(fdata.length > 1 && fdata[0] == AbstractLoadableVersion.TYPE_NONE)
         {
            v.setDefaultId(fdata[1]);
            v.setDefaultFileType(fdata[2]);
         }
         _allVersions.push(v);
      }
   }
}
