package jackboxgames.talkshow.core
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IEngineAPI;
   import jackboxgames.talkshow.utils.ConfigInfo;
   
   public class PluginManager
   {
       
      
      private var _ts:IEngineAPI;
      
      private var _loaders:Dictionary;
      
      public function PluginManager(engine:IEngineAPI)
      {
         super();
         this._ts = engine;
         this._loaders = new Dictionary();
      }
      
      public function loadPlugin(p:String) : void
      {
         var loader:Loader = new Loader();
         this._loaders[loader.contentLoaderInfo] = {
            "loader":loader,
            "name":p
         };
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.pluginComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.pluginError);
         loader.load(new URLRequest(this._ts.getConfigInfo().getValue(ConfigInfo.PLUGIN_PATH) + p + ".swf"));
         PlaybackEngine.getInstance().loadMonitor.registerItem(loader.contentLoaderInfo);
         Logger.debug("Start loading plugins");
      }
      
      private function pluginComplete(evt:Event) : void
      {
         this._ts.registerPlugin(this._loaders[evt.target].name,this._loaders[evt.target].loader.content);
         Logger.info("Loaded: Plugin: " + this._loaders[evt.target].name,"Load");
      }
      
      private function pluginError(evt:IOErrorEvent) : void
      {
         Logger.warning("PluginManager: " + evt.text);
      }
   }
}
