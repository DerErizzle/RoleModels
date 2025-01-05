package jackboxgames.talkshow.media
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IConfigInfo;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class GraphicVersion extends AbstractLoadableVersion
   {
       
      
      protected var _content:Loader;
      
      public function GraphicVersion(idx:uint, id:uint, locale:String, tag:String, text:String, ftype:String, config:IConfigInfo)
      {
         super(idx,id,locale,tag,"",ftype,config);
         this._content = null;
      }
      
      override public function toString() : String
      {
         return "[GraphicVersion idx=" + idx + " id=" + id + " tag=" + tag + " txt=" + text + "]";
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(_loadStatus == LoadStatus.STATUS_NONE)
         {
            _loadStatus = LoadStatus.STATUS_LOADING;
            this.loadFile();
         }
      }
      
      override public function unload() : void
      {
         _loadStatus = LoadStatus.STATUS_NONE;
         if(Boolean(this._content))
         {
            this._content.unloadAndStop(true);
            this._content = null;
         }
      }
      
      override public function isLoaded() : Boolean
      {
         return _loadStatus == LoadStatus.STATUS_LOADED || _loadStatus == LoadStatus.STATUS_FAILED;
      }
      
      public function get graphic() : DisplayObject
      {
         if(this._content != null)
         {
            return this._content.content;
         }
         return null;
      }
      
      protected function loadFile() : void
      {
         var u:URLRequest = new URLRequest(_url != null ? _url : _configInfo.getValue(ConfigInfo.MEDIA_PATH) + _id + getFileExtension());
         this._content = new Loader();
         this.registerListeners();
         this._content.load(u);
      }
      
      protected function registerListeners() : void
      {
         this._content.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._content.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadErrorHandler);
         this._content.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.loadSecurityHandler);
         PlaybackEngine.getInstance().loadMonitor.registerItem(this._content.contentLoaderInfo);
      }
      
      protected function unregisterListeners() : void
      {
         this._content.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._content.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.loadErrorHandler);
         this._content.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.loadSecurityHandler);
      }
      
      protected function loadCompleteHandler(e:Event) : void
      {
         Logger.info("Loaded: " + this,"Load");
         this.unregisterListeners();
         _loadStatus = LoadStatus.STATUS_LOADED;
      }
      
      protected function loadErrorHandler(e:IOErrorEvent) : void
      {
         Logger.error("Error Loading: " + this + " url=" + _configInfo.getValue(ConfigInfo.MEDIA_PATH) + _id + getFileExtension(),"Load");
         this.unregisterListeners();
         this._content = null;
         _loadStatus = LoadStatus.STATUS_FAILED;
      }
      
      protected function loadSecurityHandler(e:SecurityErrorEvent) : void
      {
         Logger.error("Security Error Loading: " + this + " url=" + _configInfo.getValue(ConfigInfo.MEDIA_PATH) + _id + getFileExtension() + " - " + e,"Load");
         this.unregisterListeners();
         this._content = null;
         _loadStatus = LoadStatus.STATUS_FAILED;
      }
   }
}
