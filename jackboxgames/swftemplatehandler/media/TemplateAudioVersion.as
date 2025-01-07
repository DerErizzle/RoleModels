package jackboxgames.swftemplatehandler.media
{
   import flash.events.*;
   import flash.media.*;
   import flash.net.URLRequest;
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.AudioEvent;
   import jackboxgames.nativeoverride.AudioSystem;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.media.MediaMetadataHelper;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.utils.*;
   
   public class TemplateAudioVersion extends PausableEventDispatcher implements IAudioVersion, IPausable, ILoadableVersion, IMediaVersion
   {
      private var _ts:IEngineAPI;
      
      private var _url:String;
      
      private var _locale:String;
      
      private var _text:String;
      
      private var _templateName:String;
      
      private var _templateField:String;
      
      private var _metadata:Object;
      
      private var _event:AudioEvent;
      
      private var _context:SoundLoaderContext;
      
      private var _request:URLRequest;
      
      private var _content:Sound;
      
      private var _loadStatus:int;
      
      private var _channels:Array;
      
      private var _pauseTimes:Array;
      
      public function TemplateAudioVersion(ts:IEngineAPI, templateName:String, templateField:String, soundPath:String, text:String)
      {
         super();
         this._ts = ts;
         this._url = soundPath;
         this._locale = this.locale;
         this._templateName = templateName;
         this._templateField = templateField;
         var m:Object = MediaMetadataHelper.getMetadataWithStrippedText(text);
         this._text = m.text;
         this._metadata = m.metadata;
         this._loadStatus = LoadStatus.STATUS_NONE;
         this._channels = [];
         this._pauseTimes = [];
      }
      
      override public function toString() : String
      {
         return "[TemplateAudioVersion - " + this._url + ", text = " + this._text + "]";
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
         return this._locale;
      }
      
      public function get tag() : String
      {
         return null;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function get metadata() : Object
      {
         return this._metadata;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
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
         if(this._loadStatus == LoadStatus.STATUS_NONE)
         {
            this._loadStatus = LoadStatus.STATUS_LOADING;
            this.loadFile();
         }
      }
      
      protected function loadFile() : void
      {
         var _this:TemplateAudioVersion = null;
         _this = this;
         var eventName:String = !!this._metadata.hasOwnProperty("EventName") ? this._metadata["EventName"] : "HOST/DummyHost";
         var event:AudioEvent = AudioSystem.instance.createEventFromPath(eventName,this._url);
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
                  AudioSystem.instance.disposeEvent(_event);
                  _event = null;
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
         this._request = new URLRequest(this._url);
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
            Logger.error(TraceUtil.objectRecursive(err,"TemplateAudioVersion::load"));
         }
      }
      
      public function unload() : void
      {
         this.stop();
         this._loadStatus = LoadStatus.STATUS_NONE;
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
         this._context = null;
      }
      
      public function isLoaded() : Boolean
      {
         return this._loadStatus == LoadStatus.STATUS_LOADED || this._loadStatus == LoadStatus.STATUS_FAILED;
      }
      
      public function get audio() : Sound
      {
         return this._content;
      }
      
      public function get category() : String
      {
         return this._templateName + "/" + this._templateField;
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
            Logger.error("TemplateAudioVersion: Skipping missing audio: " + this);
            dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,{"ch":null}));
            return null;
         }
         ch = this._content.play();
         if(ch == null)
         {
            Logger.error("TemplateAudioVersion: error creating new channel: " + this);
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
               if(Boolean(this._content) && this._content.bytesTotal > 0)
               {
                  channel = this._content.play(this._pauseTimes[i]);
                  channel.addEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
                  this._channels.push(channel);
               }
            }
            this._pauseTimes = [];
         }
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
      
      private function _onEventComplete(evt:Event) : void
      {
         PlaybackEngine.getInstance().pauser.removeItem(this);
         dispatchEvent(new EventWithData(Event.SOUND_COMPLETE,null));
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
      
      protected function loadCompleteHandler(e:Event) : void
      {
         this.unregisterListeners();
         this._loadStatus = LoadStatus.STATUS_LOADED;
      }
      
      protected function loadErrorHandler(e:IOErrorEvent) : void
      {
         this.unregisterListeners();
         this._content = null;
         this._loadStatus = LoadStatus.STATUS_FAILED;
      }
   }
}

