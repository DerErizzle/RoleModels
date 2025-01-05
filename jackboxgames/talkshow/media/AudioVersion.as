package jackboxgames.talkshow.media
{
   import flash.events.*;
   import flash.media.*;
   import flash.net.URLRequest;
   import jackboxgames.events.EventWithData;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.AudioEvent;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   
   public class AudioVersion extends AbstractLoadableVersion implements IAudioVersion, IPausable
   {
       
      
      protected var _request:URLRequest;
      
      protected var _event:AudioEvent;
      
      protected var _context:SoundLoaderContext;
      
      protected var _content:Sound;
      
      protected var _channels:Array;
      
      protected var _pauseTimes:Array;
      
      public function AudioVersion(idx:uint, id:uint, locale:String, tag:String, text:String, ftype:String, config:IConfigInfo)
      {
         super(idx,id,locale,tag,text,ftype,config);
         this._channels = [];
         Logger.debug("AudioVersion (" + this.toString() + ")");
      }
      
      override public function toString() : String
      {
         return "[AudioVersion idx=" + idx + " id=" + id + " locale=" + locale + " tag=" + tag + " txt=" + text + "]";
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(_loadStatus == LoadStatus.STATUS_NONE)
         {
            Logger.debug("AudioVersion::load (" + this.toString() + ")");
            _loadStatus = LoadStatus.STATUS_LOADING;
            if(this.isFilePresent())
            {
               this.loadFile();
            }
            else if(_defaultId !== null)
            {
               this.loadFile();
            }
            else
            {
               this._event = null;
               this._content = null;
               _loadStatus = LoadStatus.STATUS_FAILED;
            }
         }
      }
      
      private function _getPath() : String
      {
         if(_url != null)
         {
            return _url;
         }
         if(_defaultId != null)
         {
            if(_defaultId != "0.0")
            {
               return _configInfo.getValue(ConfigInfo.MEDIA_PATH) + _defaultId + getExtension(_defaultFileType);
            }
            return null;
         }
         return _configInfo.getValue(ConfigInfo.MEDIA_PATH) + _id + getFileExtension();
      }
      
      protected function loadFile() : void
      {
         var eventName:String;
         var event:AudioEvent;
         var _this:AudioVersion = null;
         _this = this;
         var path:String = this._getPath();
         if(!path)
         {
            _loadStatus = LoadStatus.STATUS_LOADED;
            _this.dispatchEvent(new Event(Event.COMPLETE));
            return;
         }
         eventName = _metadata.hasOwnProperty("EventName") ? String(_metadata["EventName"]) : "HOST/DummyHost";
         event = AudioSystem.instance.createEventFromPath(eventName,path);
         if(event.isValid)
         {
            this._event = event;
            this._event.addEventListener(AudioEvent.EVENT_PLAYBACK_DONE,this._onEventComplete);
            PlaybackEngine.getInstance().loadMonitor.registerItem(this);
            this._event.load(function(success:Boolean):void
            {
               if(success)
               {
                  _loadStatus = LoadStatus.STATUS_LOADED;
                  _this.dispatchEvent(new Event(Event.COMPLETE));
               }
               else
               {
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  _this.dispatchEvent(new Event(IOErrorEvent.IO_ERROR));
               }
            });
            return;
         }
         AudioSystem.instance.disposeEvent(event);
         this._context = new SoundLoaderContext();
         this._content = new Sound();
         this.registerListeners();
         if(!path)
         {
            this._content.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
            return;
         }
         this._request = new URLRequest(path);
         if(this._content != null && this._content.length > 0)
         {
            return;
         }
         try
         {
            this._content.load(this._request,this._context);
         }
         catch(err:Error)
         {
            Logger.error(TraceUtil.objectRecursive(err,"AudioVersion::load"));
         }
      }
      
      override public function unload() : void
      {
         Logger.debug("AudioVersion::unload (" + this.toString() + ")");
         this.stop();
         _loadStatus = LoadStatus.STATUS_NONE;
         if(Boolean(this._event))
         {
            PlaybackEngine.getInstance().loadMonitor.unRegisterItem(this);
            this._event.unload(Nullable.NULL_FUNCTION);
            AudioSystem.instance.disposeEvent(this._event);
            this._event = null;
         }
         if(Boolean(this._content))
         {
            PlaybackEngine.getInstance().loadMonitor.unRegisterItem(this._content);
            try
            {
               this._content.close();
            }
            catch(err:Error)
            {
            }
            this._content = null;
         }
         if(Boolean(this._context))
         {
            this._context = null;
         }
      }
      
      override public function isLoaded() : Boolean
      {
         return _loadStatus == LoadStatus.STATUS_LOADED || _loadStatus == LoadStatus.STATUS_FAILED;
      }
      
      public function get audio() : Sound
      {
         return this._content;
      }
      
      public function get category() : String
      {
         return _tag;
      }
      
      public function get isPlayable() : Boolean
      {
         return this._content != null || this._event != null;
      }
      
      public function play() : SoundChannel
      {
         var ch:SoundChannel = null;
         if(Boolean(this._event))
         {
            this._event.play();
            return null;
         }
         if(this._content == null)
         {
            Logger.error("AudioVersion: Skipping missing audio: " + this);
            dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,{"ch":null}));
            return null;
         }
         ch = this._content.play();
         if(ch == null)
         {
            Logger.error("AudioVersion: error creating new channel: " + this);
            dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,{"ch":null}));
            return null;
         }
         ch.addEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
         PlaybackEngine.getInstance().pauser.addItem(this);
         this._channels.push(ch);
         return ch;
      }
      
      public function stop() : void
      {
         var obj:Object = null;
         var ch:SoundChannel = null;
         Logger.debug("AudioVersion:stop (" + this.toString() + ")");
         PlaybackEngine.getInstance().pauser.removeItem(this);
         if(Boolean(this._event))
         {
            this._event.stop();
         }
         else
         {
            for each(obj in this._channels)
            {
               ch = SoundChannel(obj);
               ch.stop();
               ch.removeEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
            }
            this._channels = [];
         }
      }
      
      public function pause(type:int) : void
      {
         var i:uint = 0;
         Logger.debug("AudioVersion:pause (" + this.toString() + ")");
         if(Boolean(this._event))
         {
            this._event.paused = true;
         }
         else
         {
            this._pauseTimes = [];
            for(i = 0; i < this._channels.length; i++)
            {
               this._pauseTimes[i] = this._channels[i].position;
               this._channels[i].stop();
               this._channels[i].removeEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
            }
            this._channels = [];
         }
      }
      
      public function resume() : void
      {
         var i:uint = 0;
         var channel:SoundChannel = null;
         Logger.debug("AudioVersion:resume (" + this.toString() + ")");
         if(Boolean(this._event))
         {
            this._event.paused = false;
         }
         else
         {
            if(this._pauseTimes == null)
            {
               return;
            }
            this._channels = [];
            for(i = 0; i < this._pauseTimes.length; i++)
            {
               if(Boolean(this._content) && this._pauseTimes[i] > 0)
               {
                  channel = this._content.play(this._pauseTimes[i]);
                  channel.addEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
                  this._channels.push(channel);
               }
            }
            this._pauseTimes = [];
         }
      }
      
      private function handleSoundComplete(evt:Event) : void
      {
         for(var i:uint = 0; i < this._channels.length; i++)
         {
            if(this._channels[i] == evt.target)
            {
               this._channels.splice(i,1);
            }
         }
         PlaybackEngine.getInstance().pauser.removeItem(this);
         dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,{"ch":evt.target}));
      }
      
      private function _onEventComplete(evt:Event) : void
      {
         PlaybackEngine.getInstance().pauser.removeItem(this);
         dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,null));
      }
      
      protected function registerListeners() : void
      {
         this._content.addEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._content.addEventListener(IOErrorEvent.IO_ERROR,this.loadErrorHandler);
         PlaybackEngine.getInstance().loadMonitor.registerItem(this._content);
      }
      
      protected function unregisterListeners() : void
      {
         this._content.removeEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._content.removeEventListener(IOErrorEvent.IO_ERROR,this.loadErrorHandler);
      }
      
      protected function loadCompleteHandler(e:Event) : void
      {
         Logger.info("AudioVersion::loadCompleteHandler Loaded: " + this,"Load");
         this.unregisterListeners();
         _loadStatus = LoadStatus.STATUS_LOADED;
      }
      
      protected function loadErrorHandler(e:IOErrorEvent) : void
      {
         Logger.error("Error Loading: " + this,"Load");
         this.unregisterListeners();
         this._content = null;
         _loadStatus = LoadStatus.STATUS_FAILED;
      }
   }
}
