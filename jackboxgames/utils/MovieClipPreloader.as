package jackboxgames.utils
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import jackboxgames.logger.*;
   
   public class MovieClipPreloader
   {
       
      
      private var _mc:MovieClip;
      
      private var _preloaderMcs:Object;
      
      public function MovieClipPreloader(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._preloaderMcs = [];
         this._getPreloaderMcs(this._mc,"");
      }
      
      private function _getPreloaderMcs(fromMc:MovieClip, currentPath:String) : void
      {
         var child:* = undefined;
         var childAsMc:MovieClip = null;
         var path:String = null;
         if(!fromMc)
         {
            return;
         }
         for(var i:int = 0; i < fromMc.numChildren; i++)
         {
            child = fromMc.getChildAt(i);
            if(child is MovieClip)
            {
               childAsMc = MovieClip(child);
               path = currentPath + childAsMc.name;
               if(MovieClipUtil.framesExist(childAsMc,["Load","Unload"]))
               {
                  this._preloaderMcs[path] = childAsMc;
               }
               this._getPreloaderMcs(childAsMc,path + ".");
            }
         }
      }
      
      public function reset() : void
      {
         var key:String = null;
         for(key in this._preloaderMcs)
         {
            JBGUtil.gotoFrame(this._preloaderMcs[key],"Unload");
         }
      }
      
      public function dispose() : void
      {
         this._mc = null;
         this._preloaderMcs = null;
      }
      
      public function setPreloaded(name:String, preloaded:Boolean, doneFn:Function) : void
      {
         if(EnvUtil.isAIR())
         {
            doneFn();
            return;
         }
         if(!this._preloaderMcs.hasOwnProperty(name))
         {
            Logger.error("Cannot find preloader: " + name);
            doneFn();
            return;
         }
         JBGUtil.gotoFrameWithFn(this._preloaderMcs[name],preloaded ? "Load" : "Unload",Event.COMPLETE,doneFn);
      }
      
      public function setAllPreloaded(preloaded:Boolean, doneFn:Function) : void
      {
         var k:String = null;
         var keys:Array = ObjectUtil.getProperties(this._preloaderMcs);
         if(keys.length == 0)
         {
            doneFn();
            return;
         }
         var c:Counter = new Counter(keys.length,doneFn);
         for each(k in keys)
         {
            this.setPreloaded(k,preloaded,c.generateDoneFn());
         }
      }
   }
}
