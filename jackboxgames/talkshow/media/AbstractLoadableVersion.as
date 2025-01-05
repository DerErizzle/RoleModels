package jackboxgames.talkshow.media
{
   import jackboxgames.talkshow.api.IConfigInfo;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ILoadableVersion;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.utils.BuildConfig;
   
   public class AbstractLoadableVersion extends AbstractVersion implements ILoadableVersion
   {
      
      public static const TYPE_NONE:String = "X";
      
      public static const TYPE_SWF:String = "S";
      
      public static const TYPE_JPG:String = "J";
      
      public static const TYPE_MP3:String = "M";
      
      public static const TYPE_GIF:String = "G";
      
      public static const TYPE_PNG:String = "P";
      
      public static const TYPE_FLV:String = "F";
       
      
      protected var _contentType:String;
      
      protected var _loadStatus:int;
      
      protected var _configInfo:IConfigInfo;
      
      protected var _url:String;
      
      protected var _defaultId:String;
      
      protected var _defaultFileType:String;
      
      public function AbstractLoadableVersion(idx:uint, id:uint, locale:String, tag:String, text:String, ftype:String, config:IConfigInfo)
      {
         super(idx,id,locale,tag,text);
         this._loadStatus = LoadStatus.STATUS_NONE;
         this._contentType = ftype;
         this._configInfo = config;
         this._defaultId = null;
         this._defaultFileType = null;
      }
      
      public function getFileExtension() : String
      {
         return this.getExtension(this._contentType);
      }
      
      public function getExtension(code:String) : String
      {
         var ext:String = "";
         switch(code)
         {
            case TYPE_GIF:
               ext = ".gif";
               break;
            case TYPE_JPG:
               ext = ".jpg";
               break;
            case TYPE_PNG:
               ext = ".png";
               break;
            case TYPE_SWF:
               ext = ".swf";
               break;
            case TYPE_MP3:
               ext = BuildConfig.instance.configVal("audio-extension");
               break;
            case TYPE_FLV:
               ext = ".flv";
               break;
            case TYPE_NONE:
               ext = "";
         }
         return ext;
      }
      
      public function isFilePresent() : Boolean
      {
         return String(this._contentType).length > 0 && this._contentType != TYPE_NONE;
      }
      
      public function setUrl(s:String) : void
      {
         this._url = s;
      }
      
      public function setDefaultId(id:String) : void
      {
         this._defaultId = id;
      }
      
      public function setDefaultFileType(t:String) : void
      {
         this._defaultFileType = t;
      }
      
      public function getFileType() : String
      {
         return this._contentType;
      }
      
      public function getConfigInfo() : IConfigInfo
      {
         return this._configInfo;
      }
      
      public function load(data:ILoadData = null) : void
      {
      }
      
      public function unload() : void
      {
      }
      
      public function isLoaded() : Boolean
      {
         return false;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
   }
}
