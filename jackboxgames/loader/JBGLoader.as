package jackboxgames.loader
{
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequestMethod;
   
   public class JBGLoader
   {
      protected static var _instance:JBGLoader;
      
      private static var GamePrefix:String = "";
      
      public function JBGLoader()
      {
         super();
      }
      
      public static function get instance() : JBGLoader
      {
         return Boolean(_instance) ? _instance : (_instance = new JBGLoader());
      }
      
      public static function setGamePrefix(value:String = "") : void
      {
         var fullpath:String = value.substring(0,value.lastIndexOf("/") + 1);
         var startindex:int = int(fullpath.indexOf("://"));
         startindex = startindex >= 0 ? startindex + 3 : 0;
         GamePrefix = fullpath.substring(startindex);
      }
      
      public function getMediaUrl(url:String, local:Boolean = true) : String
      {
         if(local && url.indexOf(GamePrefix) != 0)
         {
            url = GamePrefix + url;
         }
         return url;
      }
      
      public function getUrl(url:String, local:Boolean = true) : String
      {
         var output:String = this.getMediaUrl(url,local);
         return url;
      }
      
      public function getRequest(path:String, outgoingData:Object = null, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return this.loadRequest(path,URLLoaderDataFormat.TEXT,URLRequestMethod.GET,outgoingData,RequestLoader.OUTGOING_DATA_FORMAT_DEFAULT,callback,additionalHeaders);
      }
      
      public function postRequest(path:String, outgoingData:Object = null, outgoingDataFormat:String = null, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return this.loadRequest(path,URLLoaderDataFormat.TEXT,URLRequestMethod.POST,outgoingData,outgoingDataFormat,callback,additionalHeaders);
      }
      
      public function putRequest(path:String, outgoingData:Object = null, outgoingDataFormat:String = null, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return this.loadRequest(path,URLLoaderDataFormat.TEXT,URLRequestMethod.PUT,outgoingData,outgoingDataFormat,callback,additionalHeaders);
      }
      
      public function deleteRequest(path:String, outgoingData:Object = null, outgoingDataFormat:String = null, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return this.loadRequest(path,URLLoaderDataFormat.TEXT,URLRequestMethod.DELETE,outgoingData,outgoingDataFormat,callback,additionalHeaders);
      }
      
      public function loadFile(path:String, callback:Function = null, local:Boolean = true) : ILoader
      {
         path = this.getUrl(path,local);
         var ldr:ILoader = this.createLoadItemByExtension(path);
         ldr.load(callback);
         return ldr;
      }
      
      private function loadRequest(url:String, incomingDataFormat:String, methodType:String, outgoingData:Object, outgoingDataFormat:String, callback:Function, additionalHeaders:Array = null) : ILoader
      {
         var ldr:ILoader = new RequestLoader(url,incomingDataFormat,methodType,outgoingData,outgoingDataFormat,additionalHeaders);
         ldr.load(callback);
         return ldr;
      }
      
      private function createLoadItemByExtension(path:String) : ILoader
      {
         var ldr:ILoader = null;
         var pathParts:Array = path.split(".");
         var extension:String = "";
         if(pathParts.length > 0)
         {
            extension = pathParts[pathParts.length - 1];
         }
         switch(extension)
         {
            case "swf":
            case "png":
            case "jpg":
               ldr = new MediaLoader(path);
               break;
            case "ogg":
            case "mp3":
               ldr = new SoundLoader(path);
               break;
            default:
               ldr = new DataLoader(path);
         }
         return ldr;
      }
   }
}

