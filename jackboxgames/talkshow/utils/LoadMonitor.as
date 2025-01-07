package jackboxgames.talkshow.utils
{
   import flash.display.LoaderInfo;
   import flash.events.*;
   import flash.media.Sound;
   import flash.utils.*;
   import jackboxgames.logger.Logger;
   import jackboxgames.utils.*;
   
   public class LoadMonitor extends PausableEventDispatcher
   {
      protected static var _items:Dictionary;
      
      public static const STATE_NONE:int = 0;
      
      public static const STATE_PENDING:int = 1;
      
      public static const STATE_LOADING:int = 2;
      
      public static const STATE_LOADED:int = 3;
      
      public static const STATE_FAILED:int = -1;
      
      public static const STATE_REMOVED:int = -2;
      
      public var _bytesLoaded:uint = 0;
      
      public function LoadMonitor()
      {
         super();
         _items = new Dictionary();
      }
      
      public static function getItemState(obj:IEventDispatcher) : int
      {
         if(_items[obj] == null)
         {
            return STATE_NONE;
         }
         return _items[obj].state;
      }
      
      public function get bytesLoaded() : uint
      {
         return this._bytesLoaded;
      }
      
      public function addLoadedBytes(bytes:uint) : void
      {
         this._bytesLoaded += bytes;
      }
      
      public function registerItem(obj:IEventDispatcher) : void
      {
         _items[obj] = {"state":STATE_PENDING};
         obj.addEventListener(IOErrorEvent.IO_ERROR,this.loadEventHandler);
         obj.addEventListener(Event.COMPLETE,this.loadEventHandler);
         obj.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
      }
      
      public function unRegisterItem(obj:IEventDispatcher) : void
      {
         if(_items[obj] != null && _items[obj].state != STATE_REMOVED)
         {
            obj.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
            obj.removeEventListener(IOErrorEvent.IO_ERROR,this.loadEventHandler);
            obj.removeEventListener(Event.COMPLETE,this.loadEventHandler);
            if(_items[obj].state != STATE_LOADED && _items[obj].state != STATE_FAILED)
            {
               _items[obj].state = STATE_REMOVED;
               this._checkQueue();
            }
         }
      }
      
      protected function loadEventHandler(e:Event) : void
      {
         var target:Object = null;
         if(e.type == Event.COMPLETE)
         {
            target = e.target;
            if(Boolean(_items[e.target]))
            {
               _items[e.target].state = STATE_LOADED;
            }
            else
            {
               Logger.info("Load Monitor loadEventHandler LOADED " + e.target + " not in _items.","Load");
            }
            if(e.target is Sound)
            {
               this._bytesLoaded += (e.target as Sound).bytesTotal;
            }
            else if(e.target is LoaderInfo)
            {
               this._bytesLoaded += (e.target as LoaderInfo).bytesTotal;
            }
         }
         else if(e.type == IOErrorEvent.IO_ERROR)
         {
            if(_items.hasOwnProperty(e.target))
            {
               _items[e.target].state = STATE_FAILED;
            }
            else
            {
               Logger.info("Load Monitor loadEventHandler FAILED " + e.target + " not in _items.","Load");
            }
         }
         if(hasEventListener(Event.COMPLETE) || hasEventListener(IOErrorEvent.IO_ERROR))
         {
            this._checkQueue();
         }
         else if(Boolean(_items[e.target]))
         {
            delete _items[e.target];
         }
         this.unRegisterItem(e.target as IEventDispatcher);
      }
      
      public function _checkQueue() : void
      {
         var key:Object = null;
         var url:String = null;
         var itemCount:uint = 0;
         var doneCount:uint = 0;
         for(key in _items)
         {
            itemCount++;
            url = _items[key].url;
            if(_items[key].state == STATE_LOADED || _items[key].state == STATE_FAILED || _items[key].state == STATE_REMOVED)
            {
               doneCount++;
            }
         }
         if(itemCount == doneCount)
         {
            JBGUtil.runFunctionAfter(function():void
            {
               dispatchEvent(new Event(Event.COMPLETE));
            },Duration.fromMs(100));
         }
      }
      
      protected function progressHandler(e:ProgressEvent) : void
      {
         if(Boolean(_items[e.target]))
         {
            _items[e.target].state = STATE_LOADING;
         }
         if(hasEventListener(ProgressEvent.PROGRESS))
         {
            this.update();
         }
      }
      
      private function countItems() : int
      {
         var key:Object = null;
         var count:int = 0;
         for(key in _items)
         {
            count++;
         }
         return count;
      }
      
      private function update() : void
      {
         var key:Object = null;
         var loaded:uint = 0;
         var total:uint = 0;
         var s:Sound = null;
         var li:LoaderInfo = null;
         var itemCount:uint = 0;
         var percent:Number = 0;
         for(key in _items)
         {
            itemCount++;
            if(key is Sound)
            {
               s = Sound(key);
               loaded = s.bytesLoaded;
               total = uint(s.bytesTotal);
            }
            else if(key is LoaderInfo)
            {
               li = LoaderInfo(key);
               loaded = li.bytesLoaded;
               total = li.bytesTotal;
            }
            if(total > 0)
            {
               percent += loaded / total;
            }
         }
         percent /= itemCount;
         dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,percent * 100000,100000));
      }
      
      public function purge() : void
      {
         var key:Object = null;
         var newDict:Dictionary = new Dictionary();
         for(key in _items)
         {
            switch(_items[key].state)
            {
               case STATE_LOADING:
               case STATE_PENDING:
               case STATE_NONE:
                  newDict[key] = _items[key];
                  break;
            }
         }
         _items = newDict;
         this.update();
      }
   }
}

