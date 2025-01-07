package jackboxgames.utils
{
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.timer.*;
   import jackboxgames.video.*;
   import mx.graphics.codec.*;
   
   public class JBGUtil
   {
      private static var _runFunctionAfterTimers:Array = [];
      
      private static var eventOnceCancellers:Array = [];
      
      private static var _dPlayVideoCompleted:Dictionary = new Dictionary();
      
      private static var _mcVideoFrame:MovieClip = null;
      
      private static var _videoIsPlaying:Boolean = false;
      
      private static var _videoIsFullscreen:Boolean = false;
      
      private static var _isInBackground:Boolean = false;
      
      private static var _pauseRequestedCallback:Function = null;
      
      private static var _bitmapLoaders:Dictionary = new Dictionary();
      
      public function JBGUtil()
      {
         super();
      }
      
      public static function runFunctionAfterFrames(f:Function, frames:int, track:Boolean = true) : Function
      {
         var canceller:Function;
         var t:FrameTimer = null;
         var timerFn:Function = null;
         if(frames == 0)
         {
            f();
            return Nullable.NULL_FUNCTION;
         }
         t = new FrameTimer(frames);
         canceller = function():void
         {
            if(track && _runFunctionAfterTimers.indexOf(t) >= 0)
            {
               ArrayUtil.removeElementFromArray(_runFunctionAfterTimers,t);
            }
            t.stop();
            t.removeEventListener(TimerEvent.TIMER_COMPLETE,timerFn);
         };
         timerFn = function(evt:TimerEvent):void
         {
            f();
            canceller();
         };
         t.addEventListener(TimerEvent.TIMER_COMPLETE,timerFn);
         t.start();
         if(track)
         {
            _runFunctionAfterTimers.push(t);
         }
         return canceller;
      }
      
      public static function runFunctionAfter(f:Function, d:Duration, track:Boolean = true) : Function
      {
         var canceller:Function;
         var t:PausableTimer = null;
         var timerFn:Function = null;
         if(d.inMs == 0)
         {
            f();
            return Nullable.NULL_FUNCTION;
         }
         t = new PausableTimer(d.inMs,1);
         canceller = function():void
         {
            if(track && _runFunctionAfterTimers.indexOf(t) >= 0)
            {
               ArrayUtil.removeElementFromArray(_runFunctionAfterTimers,t);
            }
            t.stop();
            t.removeEventListener(TimerEvent.TIMER_COMPLETE,timerFn);
         };
         timerFn = function(evt:TimerEvent):void
         {
            f();
            canceller();
         };
         t.addEventListener(TimerEvent.TIMER_COMPLETE,timerFn);
         t.start();
         if(track)
         {
            _runFunctionAfterTimers.push(t);
         }
         return canceller;
      }
      
      public static function cancelAllRunFunctionAfter() : void
      {
         var t:* = undefined;
         for each(t in _runFunctionAfterTimers)
         {
            t.stop();
         }
         _runFunctionAfterTimers = [];
      }
      
      public static function eventOnce(dispatcher:IEventDispatcher, event:String, fn:Function, needsExactTarget:Boolean = false, priority:int = 0) : Function
      {
         var canceller:Function = null;
         var callback:Function = null;
         canceller = function():void
         {
            dispatcher.removeEventListener(event,callback);
            ArrayUtil.removeElementFromArray(eventOnceCancellers,canceller);
         };
         callback = function(evt:Event):void
         {
            if(needsExactTarget && evt.target != dispatcher)
            {
               return;
            }
            fn(evt);
            dispatcher.removeEventListener(event,callback);
            ArrayUtil.removeElementFromArray(eventOnceCancellers,canceller);
         };
         dispatcher.addEventListener(event,callback,false,priority);
         eventOnceCancellers.push(canceller);
         return canceller;
      }
      
      public static function cancelAllEventOnce() : void
      {
         var canceller:Function = null;
         var cancellers:Array = eventOnceCancellers.concat();
         eventOnceCancellers = [];
         for each(canceller in cancellers)
         {
            canceller();
         }
      }
      
      public static function arrayGotoFrameWithFn(array:Array, frame:String, event:String, fn:Function) : void
      {
         var numDone:int = 0;
         var mc:MovieClip = null;
         if(!array || array.length == 0)
         {
            if(fn != null)
            {
               fn();
            }
            return;
         }
         numDone = 0;
         for each(mc in array)
         {
            if(fn != null && event != null)
            {
               JBGUtil.eventOnce(mc,event,function(evt:Event):void
               {
                  ++numDone;
                  if(numDone == array.length)
                  {
                     fn();
                  }
               },true);
            }
            if(EnvUtil.isDebug())
            {
               if(mc == null)
               {
                  Logger.error("Trying to go to frame \"" + frame + "\" of null mc");
               }
               else if(!MovieClipUtil.frameExists(mc,frame))
               {
                  Logger.error("Trying to go to non existing frame \"" + frame + "\" on mc \"" + mc.name + "\"");
               }
            }
            mc.gotoAndPlay(frame);
         }
      }
      
      public static function arrayGotoFrame(array:Array, frame:String) : void
      {
         JBGUtil.arrayGotoFrameWithFn(array,frame,null,null);
      }
      
      public static function arrayGotoFrameWithFnAndDurationArray(array:Array, frame:String, event:String, fn:Function, durations:Array) : void
      {
         var createGotoFrameFn:Function;
         var i:int;
         if(!array || array.length == 0)
         {
            if(fn != null)
            {
               fn();
            }
            return;
         }
         if(array.length == 1)
         {
            JBGUtil.gotoFrameWithFn(array[0],frame,event,fn);
            return;
         }
         Assert.assert(array.length == durations.length);
         createGotoFrameFn = function(mc:MovieClip, frame:String):Function
         {
            return function():void
            {
               gotoFrame(mc,frame);
            };
         };
         for(i = 0; i < array.length - 1; i++)
         {
            runFunctionAfter(createGotoFrameFn(array[i],frame),durations[i]);
         }
         runFunctionAfter(function():void
         {
            JBGUtil.gotoFrameWithFn(array[array.length - 1],frame,event,fn);
         },durations[durations.length - 1]);
      }
      
      public static function arrayGotoFrameWithFnAndDuration(array:Array, frame:String, event:String, fn:Function, d:Duration) : void
      {
         var durations:Array = [];
         for(var i:int = 0; i < array.length; i++)
         {
            durations.push(Duration.scale(d,i));
         }
         JBGUtil.arrayGotoFrameWithFnAndDurationArray(array,frame,event,fn,durations);
      }
      
      public static function gotoFrameWithFnCancellable(mc:MovieClip, frame:String, event:String, fn:Function) : Function
      {
         var cancellor:Function = Nullable.NULL_FUNCTION;
         if(fn != null && event != null)
         {
            cancellor = JBGUtil.eventOnce(mc,event,function(evt:Event):void
            {
               fn();
            },true);
         }
         if(EnvUtil.isDebug())
         {
            if(mc == null)
            {
               Logger.error("Trying to go to frame \"" + frame + "\" of null mc");
            }
            else if(!MovieClipUtil.frameExists(mc,frame))
            {
               Logger.error("Trying to go to non existing frame \"" + frame + "\" on mc \"" + mc.name + "\"");
            }
         }
         mc.gotoAndPlay(frame);
         return cancellor;
      }
      
      public static function gotoFrameWithFn(mc:MovieClip, frame:String, event:String, fn:Function) : void
      {
         JBGUtil.arrayGotoFrameWithFn([mc],frame,event,fn);
      }
      
      public static function gotoFrame(mc:MovieClip, frame:String) : void
      {
         JBGUtil.arrayGotoFrame([mc],frame);
      }
      
      public static function sortDictionaryByValue(d:Dictionary) : Array
      {
         var dictionaryKey:Object = null;
         var a:Array = [];
         for(dictionaryKey in d)
         {
            a.push({
               "key":dictionaryKey,
               "value":d[dictionaryKey]
            });
         }
         a.sortOn("value",[Array.NUMERIC | Array.DESCENDING]);
         return a;
      }
      
      public static function distributeEvenly(elements:Array, startX:Number, width:Number) : void
      {
         var spaceBetween:Number = width / (elements.length + 1);
         for(var i:int = 0; i < elements.length; i++)
         {
            elements[i].x = startX + (i + 1) * spaceBetween - elements[i].width / 2;
         }
      }
      
      public static function getPropertiesOfNameInOrder(o:Object, name:String, startingIndex:int = 0) : Array
      {
         var returnMe:Array = new Array();
         var i:int = startingIndex;
         while(o.hasOwnProperty(name + i))
         {
            returnMe.push(o[name + i]);
            i++;
         }
         return returnMe;
      }
      
      public static function getPropertiesThatStartWithName(o:Object, name:String) : Array
      {
         var key:String = null;
         var returnMe:Array = new Array();
         for(key in o)
         {
            if(key.substr(0,name.length) == name)
            {
               returnMe.push(o[key]);
            }
         }
         return returnMe;
      }
      
      public static function doSwap(mc:MovieClip, frame:String, swapFn:Function) : void
      {
         JBGUtil.eventOnce(mc,MovieClipEvent.EVENT_TRIGGER,function(evt:MovieClipEvent):void
         {
            if(evt.data != "Swap")
            {
               return;
            }
            swapFn();
         });
         JBGUtil.gotoFrame(mc,frame);
      }
      
      public static function getClosest(thisArray:Array, toThis:*) : *
      {
         var distances:Array;
         var minDistance:*;
         var minIndex:int;
         var i:int;
         if(!thisArray || thisArray.length == 0)
         {
            return 0;
         }
         distances = thisArray.map(function(current:*, i:int, a:Array):int
         {
            return Math.abs(current - toThis);
         });
         minDistance = distances[0];
         minIndex = 0;
         for(i = 1; i < distances.length; i++)
         {
            if(distances[i] < minDistance)
            {
               minDistance = distances[i];
               minIndex = i;
            }
         }
         return thisArray[minIndex];
      }
      
      public static function roundToNearest(num:*, amount:int) : int
      {
         var n:Number = Number(num) / amount;
         n = Math.round(n);
         n *= amount;
         return int(n);
      }
      
      public static function getArrayElementsOfType(arr:Array, type:Class) : Array
      {
         return arr.filter(function(e:*, i:int, a:Array):Boolean
         {
            return e is type;
         });
      }
      
      public static function runNTimes(f:Function, times:int) : void
      {
         for(var i:int = 0; i < times; i++)
         {
            f(i);
         }
      }
      
      public static function runNTimesWithDuration(f:Function, times:int, dur:Duration) : void
      {
         for(var i:int = 0; i < times; i++)
         {
            JBGUtil.runFunctionAfter(f,new Duration(i * dur.inMs));
         }
      }
      
      public static function runNTimeswithResults(f:Function, times:int) : Array
      {
         var a:Array = [];
         for(var i:int = 0; i < times; i++)
         {
            a.push(f(i));
         }
         return a;
      }
      
      public static function get videoIsPlaying() : Boolean
      {
         return !_isInBackground && _videoIsFullscreen && _videoIsPlaying;
      }
      
      public static function set pauseRequestedCallback(callback:Function) : void
      {
         _pauseRequestedCallback = callback;
      }
      
      public static function PlayVideo(name:String, loop:Boolean = false, volume:Number = 0, callbackLoaded:Function = null, callbackComplete:Function = null, isInBackground:Boolean = false) : Function
      {
         var v:IVideoPlayer = null;
         var onErrorListener:Function = null;
         var onCompletedListener:Function = null;
         var onLoadedListener:Function = null;
         var onLoaded:Function = function(success:Boolean):void
         {
            if(callbackLoaded != null)
            {
               callbackLoaded(success);
               callbackLoaded = null;
            }
         };
         var onComplete:Function = function(success:Boolean, name:String):void
         {
            if(BuildConfig.instance.configVal("videoplayer"))
            {
               _dPlayVideoCompleted[name] = true;
            }
            v.removeEventListener("onError",onErrorListener);
            v.removeEventListener("VideoLoaded",onLoadedListener);
            v.removeEventListener(Event.COMPLETE,onCompletedListener);
            if(callbackComplete != null)
            {
               callbackComplete(success);
               callbackComplete = null;
            }
            if(BuildConfig.instance.configVal("delayVideoOnComplete"))
            {
               runFunctionAfter(function():void
               {
                  v.stop();
                  v.dispose();
                  if(_pauseRequestedCallback != null)
                  {
                     _pauseRequestedCallback();
                     _pauseRequestedCallback = null;
                  }
               },Duration.fromMs(200));
            }
            if(BuildConfig.instance.configVal("videoplayer"))
            {
               v.stop();
               v.dispose();
            }
            _videoIsPlaying = false;
            if(BuildConfig.instance.configVal("delayVideoOnComplete"))
            {
               return;
            }
            if(_pauseRequestedCallback != null)
            {
               _pauseRequestedCallback();
               _pauseRequestedCallback = null;
            }
         };
         onErrorListener = function(eventError:Event):void
         {
            onLoaded(false);
            onComplete(false,name);
         };
         onCompletedListener = function(event:Event):void
         {
            v.removeEventListener(Event.COMPLETE,onCompletedListener);
            v.removeEventListener("onError",onErrorListener);
            onComplete(true,name);
         };
         onLoadedListener = function(event:Event):void
         {
            v.removeEventListener("VideoLoaded",onLoadedListener);
            onLoaded(true);
            v.addEventListener(Event.COMPLETE,onCompletedListener);
            if(BuildConfig.instance.configVal("videoplayer"))
            {
               _dPlayVideoCompleted[name] = false;
               if(!loop)
               {
                  runFunctionAfter(function():void
                  {
                     if(!_dPlayVideoCompleted[name])
                     {
                        onComplete(false,name);
                     }
                     delete _dPlayVideoCompleted[name];
                  },Duration.fromMs(v.length + 500));
               }
            }
            _isInBackground = isInBackground;
            _videoIsPlaying = true;
            v.play(loop);
         };
         v = VideoPlayerFactory.videoPlayer(_mcVideoFrame);
         v.volume = isNaN(volume) ? 1 : volume;
         _videoIsFullscreen = _mcVideoFrame == null || _mcVideoFrame.x == 0 && _mcVideoFrame.y == 0 && _mcVideoFrame.width == StageRef.width && _mcVideoFrame.height == StageRef.height;
         _mcVideoFrame = null;
         v.addEventListener("onError",onErrorListener);
         v.addEventListener("VideoLoaded",onLoadedListener);
         v.autoPlay = false;
         v.load(name,loop,isInBackground);
         return function():void
         {
            if(BuildConfig.instance.configVal("videoplayer"))
            {
               _dPlayVideoCompleted[name] = true;
            }
            v.removeEventListener("onError",onErrorListener);
            v.removeEventListener("VideoLoaded",onLoadedListener);
            v.removeEventListener(Event.COMPLETE,onCompletedListener);
            v.stop();
            v.dispose();
            _videoIsPlaying = false;
         };
      }
      
      public static function PlayVideoFrame(name:String, videoframe:MovieClip = null, loop:Boolean = false, volume:Number = 0, callbackLoaded:Function = null, callbackComplete:Function = null, isInBackground:Boolean = false) : Function
      {
         _mcVideoFrame = videoframe;
         return PlayVideo(name,loop,volume,callbackLoaded,callbackComplete,isInBackground);
      }
      
      public static function unloadBitmapIds(ids:Array) : void
      {
         var id:String = null;
         for each(id in ids)
         {
            if(Boolean(_bitmapLoaders[id]))
            {
               Logger.debug("Unloading bitmap Id : " + id);
               try
               {
                  _bitmapLoaders[id].close();
               }
               catch(e:Error)
               {
               }
               try
               {
                  _bitmapLoaders[id].unloadAndStop();
               }
               catch(e:Error)
               {
               }
               delete _bitmapLoaders[id];
            }
         }
      }
      
      public static function loadBitmapDataFromByteArray(id:String, byteArray:ByteArray, complete:Function) : void
      {
         var l:Loader = null;
         unloadBitmapIds([id]);
         l = new Loader();
         l.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void
         {
            var c:Object = l.content;
            var bd:BitmapData = null;
            if(l.content is Bitmap)
            {
               bd = c.bitmapData;
            }
            complete(bd);
         });
         l.addEventListener(IOErrorEvent.IO_ERROR,function(e:Event):void
         {
            complete(null);
         });
         l.loadBytes(byteArray);
         _bitmapLoaders[id] = l;
      }
      
      public static function loadBitmapDataFromBase64(id:String, base64:String, complete:Function) : void
      {
         loadBitmapDataFromByteArray(id,Base64.decodeToByteArray(base64),complete);
      }
      
      public static function scaleBitmapData(bitmapData:BitmapData, scale:Number) : BitmapData
      {
         var matrix:Matrix = new Matrix();
         matrix.scale(scale,scale);
         var result:BitmapData = new BitmapData(bitmapData.width * scale,bitmapData.height * scale,bitmapData.transparent,0);
         result.draw(bitmapData,matrix);
         return result;
      }
      
      public static function encodeBitmapDataToBase64(bitmapData:BitmapData) : String
      {
         if("encode" in bitmapData)
         {
            return Base64.encodeByteArray(bitmapData.encode(bitmapData.rect,new PNGEncoderOptions()));
         }
         return Base64.encodeByteArray(new PNGEncoder().encode(bitmapData));
      }
      
      public static function safeRemoveChild(from:DisplayObjectContainer, d:DisplayObject) : void
      {
         if(from.contains(d))
         {
            from.removeChild(d);
         }
      }
      
      public static function reset(a:Array) : void
      {
         var i:* = undefined;
         for each(i in a)
         {
            if(i != null)
            {
               i.reset();
            }
         }
      }
      
      public static function dispose(a:Array) : void
      {
         var i:* = undefined;
         for each(i in a)
         {
            if(i != null)
            {
               i.dispose();
            }
         }
      }
      
      public static function destroy(a:Array) : void
      {
         var i:* = undefined;
         for each(i in a)
         {
            if(i != null)
            {
               i.destroy();
            }
         }
      }
      
      public static function levenshteinDistance(s:String, t:String, sLength:int = -1, tLength:int = -1) : int
      {
         var i:int = 0;
         var j:int = 0;
         var cost:int = 0;
         if(s == t)
         {
            return 0;
         }
         if(s.length == 0)
         {
            return t.length;
         }
         if(t.length == 0)
         {
            return s.length;
         }
         var v0:Array = new Array(t.length + 1);
         var v1:Array = new Array(t.length + 1);
         for(i = 0; i < v0.length; i++)
         {
            v0[i] = i;
         }
         for(i = 0; i < s.length; i++)
         {
            v1[0] = i + 1;
            for(j = 0; j < t.length; j++)
            {
               cost = s.charAt(i) == t.charAt(j) ? 0 : 1;
               v1[j + 1] = Math.min(v1[j] + 1,v0[j + 1] + 1,v0[j] + cost);
            }
            for(j = 0; j < v0.length; j++)
            {
               v0[j] = v1[j];
            }
         }
         return v1[t.length];
      }
      
      public static function primitiveDeepCopy(o:Object) : Object
      {
         var asJson:String = JSON.serialize(o);
         if(!asJson)
         {
            return null;
         }
         return JSON.deserialize(asJson);
      }
      
      public static function or(... args) : *
      {
         var o:* = undefined;
         for each(o in args)
         {
            if(o)
            {
               return o;
            }
         }
         return ArrayUtil.last(args);
      }
      
      public static function and(... args) : *
      {
         var o:* = undefined;
         for each(o in args)
         {
            if(!o)
            {
               return o;
            }
         }
         return ArrayUtil.last(args);
      }
      
      public static function combineRectangles(rectangles:Array) : Rectangle
      {
         var minX:Number = NaN;
         var minY:Number = NaN;
         var maxX:Number = NaN;
         var maxY:Number = NaN;
         rectangles.forEach(function(r:Rectangle, i:int, a:Array):void
         {
            if(i == 0)
            {
               minX = r.left;
               minY = r.top;
               maxX = r.right;
               maxY = r.bottom;
               return;
            }
            minX = Math.min(minX,r.left);
            minY = Math.min(minY,r.top);
            maxX = Math.max(maxX,r.right);
            maxY = Math.max(maxY,r.bottom);
         });
         return new Rectangle(minX,minY,maxX - minX,maxY - minY);
      }
      
      public static function waitForState(a:AudioEvent, state:String, fn:Function) : Function
      {
         var check:Function = null;
         check = function(evt:EventWithData):void
         {
            if(a.playbackState == state)
            {
               TickManager.instance.removeEventListener(TickManager.EVENT_TICK,check);
               fn();
            }
         };
         TickManager.instance.addEventListener(TickManager.EVENT_TICK,check);
         return function():void
         {
            TickManager.instance.removeEventListener(TickManager.EVENT_TICK,check);
         };
      }
   }
}

