package jackboxgames.talkshow.actions
{
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import jackboxgames.audio.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.ActionPackage;
   import jackboxgames.talkshow.api.ActionPackageType;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.talkshow.api.IAudioVersion;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.api.events.InputEvent;
   import jackboxgames.utils.TraceUtil;
   
   public final class InternalActionPackage extends ActionPackage
   {
      
      public static var STOP_AUDIO_ON_INPUT:Boolean = true;
      
      public static var STOP_AUDIO_ON_JUMP:Boolean = true;
       
      
      private var _playing:Array;
      
      public function InternalActionPackage()
      {
         super();
         this._playing = [];
      }
      
      override protected function handleJump(evt:CellEvent) : void
      {
         if(STOP_AUDIO_ON_JUMP)
         {
            this.stopAllAudio();
         }
      }
      
      override protected function doInit() : void
      {
         (_ts as IEventDispatcher).addEventListener(InputEvent.INPUT,this.handleInput);
         _ts.g.sfxManager = this;
      }
      
      override public function get type() : String
      {
         return ActionPackageType.TYPE_INTERNAL;
      }
      
      override public function handleAction(ref:IActionRef, params:Object) : void
      {
         var version:IAudioVersion = null;
         if(ref.action.name == "Play Audio")
         {
            version = params.Audio as IAudioVersion;
            if(version == null)
            {
               Logger.error("InternalActionPackage: Skipping missing version: " + params.Audio,"Media");
               ref.end();
               return;
            }
            if(!version.isPlayable)
            {
               ref.end();
               return;
            }
            Logger.info("InternalActionPackage: Start Audio " + version,"Media");
            version.play();
            version.addEventListener(Event.SOUND_COMPLETE,this.handleSoundComplete);
            AudioNotifier.instance.notifyStartAudio(String(version.id),version.category,version.text,version.metadata);
            this._playing.push({
               "ref":ref,
               "v":version
            });
         }
         else if(ref.action.name == "Pause")
         {
            _ts.pauser.userPause();
         }
      }
      
      public function widgetOn(ref:IActionRef) : void
      {
      }
      
      private function handleInput(event:InputEvent) : void
      {
         if(STOP_AUDIO_ON_INPUT)
         {
            this.stopAllAudio();
         }
      }
      
      private function handleSoundComplete(evt:EventWithData) : void
      {
         var obj:Object = null;
         for(var i:uint = 0; i < this._playing.length; i++)
         {
            if(this._playing[i].v == evt.currentTarget)
            {
               obj = this._playing[i];
               this._playing.splice(i,1);
               AudioNotifier.instance.notifyEndAudio(obj.v.id);
               ActionRef(obj.ref).end();
               break;
            }
         }
      }
      
      public function stopAllAudio() : void
      {
         var obj:Object = null;
         for each(obj in this._playing)
         {
            if(obj.hasOwnProperty("v") && obj.v is IAudioVersion)
            {
               try
               {
                  AudioNotifier.instance.notifyEndAudio(obj.v.id);
                  (obj.v as IAudioVersion).stop();
               }
               catch(err:Error)
               {
                  Logger.error("Failed attempting to stop an IAudioVersion => " + TraceUtil.objectRecursive(obj.v,"IAudioVersion") + "\n" + err.getStackTrace());
               }
            }
         }
         this._playing = [];
      }
   }
}
