package jackboxgames.talkshow.api
{
   public interface IMediaParamValue
   {
      function get selType() : uint;
      
      function get selValue() : *;
      
      function get media() : IMedia;
      
      function get mediaId() : uint;
      
      function getCurrentVersion(param1:Boolean = false) : IMediaVersion;
      
      function get previous() : IMediaVersion;
   }
}

