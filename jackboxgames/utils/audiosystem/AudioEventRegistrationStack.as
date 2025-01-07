package jackboxgames.utils.audiosystem
{
   import flash.geom.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class AudioEventRegistrationStack
   {
      private var _stack:Array;
      
      private var _playing:Array;
      
      public function AudioEventRegistrationStack()
      {
         super();
         this._stack = [];
         this._playing = [];
      }
      
      public function reset() : void
      {
         this._popAll();
      }
      
      private function _popAll() : void
      {
         while(this._stack.length > 0)
         {
            this.pop();
         }
      }
      
      public function push(dictionary:Object) : void
      {
         this._stack.push(new AudioEventRegistrationStackFrame(dictionary));
      }
      
      public function pop() : void
      {
         var frame:AudioEventRegistrationStackFrame = null;
         Assert.assert(this._stack.length > 0);
         frame = this._stack.pop();
         this._disposeOfPlayingEventsThatMeetDelegate(function(m:AudioEventRegistrationStackPlayingMetadata):Boolean
         {
            return m.frame == frame;
         });
      }
      
      public function play(key:String) : Promise
      {
         var i:int;
         var player:AudioSystemEventPlayer = null;
         var frame:AudioEventRegistrationStackFrame = null;
         var f:AudioEventRegistrationStackFrame = null;
         var p:Promise = null;
         var newMetadata:AudioEventRegistrationStackPlayingMetadata = null;
         for(i = this._stack.length - 1; i >= 0; i--)
         {
            f = this._stack[i];
            if(f.hasEventNameForKey(key))
            {
               player = new AudioSystemEventPlayer(f.getEventNameforKey(key));
               frame = f;
               break;
            }
         }
         if(Boolean(player))
         {
            p = new Promise();
            newMetadata = new AudioEventRegistrationStackPlayingMetadata(key,frame,player);
            this._playing.push(newMetadata);
            player.setLoaded(true,function(success:Boolean):void
            {
               if(success)
               {
                  player.play(function():void
                  {
                     _disposeOfPlayingEventsThatMeetDelegate(function(m:AudioEventRegistrationStackPlayingMetadata):Boolean
                     {
                        return m.player == player;
                     });
                  });
                  p.resolve(player);
               }
               else
               {
                  _disposeOfMetadata(newMetadata);
                  p.resolve(undefined);
               }
            });
            return p;
         }
         Logger.warning("Attempted to play audio from AudioEventRegistrationStack with non-existent key of " + key);
         return PromiseUtil.RESOLVED();
      }
      
      public function stop(key:String) : void
      {
         this._playing.filter(function(m:AudioEventRegistrationStackPlayingMetadata, ... args):Boolean
         {
            return m.key == key;
         }).forEach(function(m:AudioEventRegistrationStackPlayingMetadata, ... args):void
         {
            m.player.stop();
         });
      }
      
      private function _disposeOfMetadata(playingEvent:AudioEventRegistrationStackPlayingMetadata) : void
      {
         trace("Disposing of metadata for: " + playingEvent.key);
         playingEvent.player.dispose();
         ArrayUtil.removeElementFromArray(this._playing,playingEvent);
      }
      
      private function _disposeOfPlayingEventsThatMeetDelegate(delegateFn:Function) : void
      {
         var m:AudioEventRegistrationStackPlayingMetadata = null;
         var eventsToDisposeOf:Array = this._playing.filter(function(m:AudioEventRegistrationStackPlayingMetadata, ... args):Boolean
         {
            return delegateFn(m);
         });
         for each(m in eventsToDisposeOf)
         {
            this._disposeOfMetadata(m);
         }
      }
   }
}

import jackboxgames.nativeoverride.*;

class AudioEventRegistrationStackFrame
{
   private var _dictionary:Object;
   
   public function AudioEventRegistrationStackFrame(dictionary:Object)
   {
      super();
      this._dictionary = dictionary;
   }
   
   public function hasEventNameForKey(key:String) : Boolean
   {
      return key in this._dictionary;
   }
   
   public function getEventNameforKey(key:String) : String
   {
      return this._dictionary[key];
   }
}

class AudioEventRegistrationStackPlayingMetadata
{
   private var _key:String;
   
   private var _frame:AudioEventRegistrationStackFrame;
   
   private var _player:AudioSystemEventPlayer;
   
   public function AudioEventRegistrationStackPlayingMetadata(key:String, frame:AudioEventRegistrationStackFrame, player:AudioSystemEventPlayer)
   {
      super();
      this._key = key;
      this._frame = frame;
      this._player = player;
   }
   
   public function get key() : String
   {
      return this._key;
   }
   
   public function get frame() : AudioEventRegistrationStackFrame
   {
      return this._frame;
   }
   
   public function get player() : AudioSystemEventPlayer
   {
      return this._player;
   }
}

