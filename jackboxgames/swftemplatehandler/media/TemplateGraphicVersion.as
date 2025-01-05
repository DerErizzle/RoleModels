package jackboxgames.swftemplatehandler.media
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import jackboxgames.loader.JBGLoader;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IEngineAPI;
   import jackboxgames.talkshow.api.IGraphicVersion;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ILoadableVersion;
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class TemplateGraphicVersion extends PausableEventDispatcher implements IGraphicVersion, ILoadableVersion, IMediaVersion
   {
       
      
      protected var _content:DisplayObject;
      
      protected var _loadStatus:int;
      
      protected var _graphicPath:String;
      
      protected var _ts:IEngineAPI;
      
      private var _templateName:String;
      
      private var _templateField:String;
      
      public function TemplateGraphicVersion(ts:IEngineAPI, templateName:String, templateField:String, graphicPath:String)
      {
         super();
         Logger.debug("Template graphic version with path : " + graphicPath);
         this._ts = ts;
         this._templateName = templateName;
         this._templateField = templateField;
         this._content = null;
         this._graphicPath = graphicPath;
         this._loadStatus = LoadStatus.STATUS_NONE;
      }
      
      override public function toString() : String
      {
         return "[TemplateGraphicVersion]";
      }
      
      public function get idx() : uint
      {
         return 0;
      }
      
      public function get id() : int
      {
         return -1;
      }
      
      public function get locale() : String
      {
         return "";
      }
      
      public function get tag() : String
      {
         return null;
      }
      
      public function get text() : String
      {
         return "";
      }
      
      public function get metadata() : Object
      {
         return {};
      }
      
      public function getFileType() : String
      {
         return null;
      }
      
      public function getFileExtension() : String
      {
         return null;
      }
      
      public function isFilePresent() : Boolean
      {
         return true;
      }
      
      public function load(data:ILoadData = null) : void
      {
         PlaybackEngine.getInstance().loadMonitor.registerItem(this);
         this._loadStatus = LoadStatus.STATUS_LOADING;
         JBGLoader.instance.loadFile(this._graphicPath,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               Logger.debug("[TemplateGraphicVersion] Loaded : " + _graphicPath);
               _content = result.contentAsBitmap;
               _loadStatus = LoadStatus.STATUS_LOADED;
               dispatchEvent(new Event(Event.COMPLETE));
            }
            else
            {
               Logger.debug("[TemplateGraphicVersion] Failed to Load : " + _graphicPath);
               _loadStatus = LoadStatus.STATUS_FAILED;
               dispatchEvent(new Event(IOErrorEvent.IO_ERROR));
            }
         });
      }
      
      public function unload() : void
      {
         this._graphicPath = null;
         this._content = null;
         this._ts = null;
         this._loadStatus = LoadStatus.STATUS_NONE;
      }
      
      public function isLoaded() : Boolean
      {
         return this._loadStatus == LoadStatus.STATUS_LOADED;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
      
      public function get graphic() : DisplayObject
      {
         return this._content;
      }
   }
}
