package jackboxgames.talkshow.api
{
   public interface ILoadableVersion extends ILoadable, IMediaVersion
   {
      function getFileExtension() : String;
      
      function getFileType() : String;
      
      function isFilePresent() : Boolean;
      
      function unload() : void;
   }
}

