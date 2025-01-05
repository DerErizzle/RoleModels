package jackboxgames.talkshow.api
{
   public interface IMedia
   {
       
      
      function get id() : int;
      
      function get type() : String;
      
      function get container() : IExport;
      
      function get numVersions() : uint;
      
      function getVersionByIndex(param1:*) : IMediaVersion;
      
      function getNextRandomVersion(param1:Boolean = false) : IMediaVersion;
      
      function getNextOrderedVersion(param1:Boolean = false, param2:Boolean = true) : IMediaVersion;
      
      function getVersionByTag(param1:String, param2:Boolean = false) : IMediaVersion;
      
      function versionIsInMedia(param1:IMediaVersion) : Boolean;
      
      function onMediaLoaded(param1:IFlowchart = null) : void;
   }
}
