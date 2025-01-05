package jackboxgames.talkshow.actionpackages
{
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class AudioSystem extends JBGActionPackage
   {
       
      
      private var _loadedBankMetadata:Array;
      
      private var _loadedEventMetadata:Array;
      
      public function AudioSystem(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         this._loadedBankMetadata = [];
         this._loadedEventMetadata = [];
         ref.end();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         var em:EventMetadata = null;
         var bm:BankMetadata = null;
         if(Boolean(params.unloadEvents))
         {
            for each(em in this._loadedEventMetadata)
            {
               em.dispose();
            }
            this._loadedEventMetadata = [];
         }
         if(Boolean(params.unloadBanks))
         {
            for each(bm in this._loadedBankMetadata)
            {
               bm.dispose();
            }
            this._loadedBankMetadata = [];
         }
         ref.end();
      }
      
      private function _getBankMetadataByName(name:String) : BankMetadata
      {
         var m:BankMetadata = null;
         for each(m in this._loadedBankMetadata)
         {
            if(m.name == name)
            {
               return m;
            }
         }
         return null;
      }
      
      private function _loadBank(name:String, resultFn:Function) : void
      {
         var bank:AudioBank = null;
         if(Boolean(this._getBankMetadataByName(name)))
         {
            resultFn(false);
            return;
         }
         bank = AudioSystem.instance.createBank(name);
         bank.load(function(success:Boolean):void
         {
            if(!success)
            {
               AudioSystem.instance.disposeBank(bank);
               resultFn(success);
               return;
            }
            var metadata:BankMetadata = new BankMetadata(name,bank);
            _loadedBankMetadata.push(metadata);
            resultFn(success);
         });
      }
      
      private function _unloadBank(name:String, resultFn:Function) : void
      {
         var metadata:BankMetadata = null;
         metadata = this._getBankMetadataByName(name);
         if(!metadata)
         {
            resultFn(false);
            return;
         }
         ArrayUtil.removeElementFromArray(this._loadedBankMetadata,metadata);
         metadata.bank.unload(function(success:Boolean):void
         {
            metadata.dispose();
            resultFn(success);
         });
      }
      
      public function handleActionLoadBank(ref:IActionRef, params:Object) : void
      {
         this._loadBank(params.name,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionUnloadBank(ref:IActionRef, params:Object) : void
      {
         this._unloadBank(params.name,TSUtil.createRefEndFn(ref));
      }
      
      private function _getEventMetadataById(id:String) : EventMetadata
      {
         var m:EventMetadata = null;
         for each(m in this._loadedEventMetadata)
         {
            if(m.id == id)
            {
               return m;
            }
         }
         return null;
      }
      
      private function _loadEvent(id:String, name:String, resultFn:Function) : void
      {
         var e:AudioEvent = null;
         if(Boolean(this._getEventMetadataById(id)))
         {
            resultFn(false);
            return;
         }
         e = AudioSystem.instance.createEventFromName(name);
         e.load(function(success:Boolean):void
         {
            if(!success)
            {
               AudioSystem.instance.disposeEvent(e);
               resultFn(false);
               return;
            }
            var metadata:EventMetadata = new EventMetadata(id,name,e);
            _loadedEventMetadata.push(metadata);
            resultFn(success);
         });
      }
      
      private function _unloadEvent(id:String, resultFn:Function) : void
      {
         var metadata:EventMetadata = null;
         metadata = this._getEventMetadataById(id);
         if(!metadata)
         {
            resultFn(false);
            return;
         }
         ArrayUtil.removeElementFromArray(this._loadedEventMetadata,metadata);
         metadata.event.unload(function(success:Boolean):void
         {
            metadata.dispose();
            resultFn(success);
         });
      }
      
      private function _listenForEventToComplete(m:EventMetadata, doneFn:Function) : void
      {
         if(m.isDisposed || m.event.playbackState == AudioEvent.PLAYBACK_STATE_STOPPED)
         {
            doneFn();
            return;
         }
         JBGUtil.eventOnce(m,AudioEvent.EVENT_PLAYBACK_DONE,function(evt:EventWithData):void
         {
            doneFn();
         });
      }
      
      private function _listenForTimelineMarker(m:EventMetadata, marker:String, useHistory:Boolean, doneFn:Function) : void
      {
         var listenForMarker:Function = null;
         listenForMarker = function(evt:EventWithData):void
         {
            if(evt.data.name != marker)
            {
               return;
            }
            m.removeEventListener(AudioEvent.EVENT_TIMELINE_MARKER,listenForMarker);
            doneFn();
         };
         if(m.isDisposed || useHistory && ArrayUtil.arrayContainsElement(m.timelineMarkerNamesSeen,marker))
         {
            doneFn();
            return;
         }
         m.addEventListener(AudioEvent.EVENT_TIMELINE_MARKER,listenForMarker);
      }
      
      private function _loadAndPlayEvent(id:String, name:String, readyFn:Function, errorFn:Function) : void
      {
         if(Boolean(this._getEventMetadataById(id)))
         {
            Logger.warning("Warning: Tried to play event with id: " + id + " but one is already playing!");
            errorFn();
            return;
         }
         this._loadEvent(id,name,function(success:Boolean):void
         {
            var m:EventMetadata = null;
            if(!success)
            {
               Logger.warning("Warning: failed to load event: " + name);
               errorFn();
               return;
            }
            m = _getEventMetadataById(id);
            JBGUtil.eventOnce(m,AudioEvent.EVENT_PLAYBACK_DONE,function(evt:EventWithData):void
            {
               Logger.info("Finished playing: " + m.id);
               _unloadEvent(id,Nullable.NULL_FUNCTION);
            });
            m.event.play();
            readyFn(m);
         });
      }
      
      public function handleActionPlayEvent(ref:IActionRef, params:Object) : void
      {
         this._loadAndPlayEvent(params.id,params.name,TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionPlayEventAndWaitForCompletion(ref:IActionRef, params:Object) : void
      {
         this._loadAndPlayEvent(params.id,params.name,function(m:EventMetadata):void
         {
            _listenForEventToComplete(m,TSUtil.createRefEndFn(ref));
         },TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionPlayEventAndWaitForTimelineMarker(ref:IActionRef, params:Object) : void
      {
         this._loadAndPlayEvent(params.id,params.name,function(m:EventMetadata):void
         {
            _listenForTimelineMarker(m,params.timelineMarker,params.useHistory,TSUtil.createRefEndFn(ref));
         },TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionStopEvent(ref:IActionRef, params:Object) : void
      {
         var m:EventMetadata = this._getEventMetadataById(params.id);
         if(!m)
         {
            ref.end();
            return;
         }
         m.event.stop();
         ref.end();
      }
      
      public function handleActionWaitForEventToComplete(ref:IActionRef, params:Object) : void
      {
         var m:EventMetadata = this._getEventMetadataById(params.id);
         if(!m)
         {
            ref.end();
            return;
         }
         this._listenForEventToComplete(m,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionWaitForTimelineMarker(ref:IActionRef, params:Object) : void
      {
         var m:EventMetadata = this._getEventMetadataById(params.id);
         if(!m)
         {
            ref.end();
            return;
         }
         this._listenForTimelineMarker(m,params.timelineMarker,params.useHistory,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetEventParameter(ref:IActionRef, params:Object) : void
      {
         var m:EventMetadata = this._getEventMetadataById(params.id);
         if(!m)
         {
            ref.end();
            return;
         }
         m.event.setParameterValue(params.parameterName,params.parameterValue);
         ref.end();
      }
      
      public function handleActionSetEventDucked(ref:IActionRef, params:Object) : void
      {
         var m:EventMetadata = this._getEventMetadataById(params.id);
         if(!m)
         {
            ref.end();
            return;
         }
         m.event.setParameterValue("Ducking",Boolean(params.isDucked) ? 1 : 0);
         ref.end();
      }
   }
}

import jackboxgames.nativeoverride.AudioBank;
import jackboxgames.nativeoverride.AudioSystem;

class BankMetadata
{
    
   
   private var _name:String;
   
   private var _bank:AudioBank;
   
   public function BankMetadata(name:String, bank:AudioBank)
   {
      super();
      this._name = name;
      this._bank = bank;
   }
   
   public function get name() : String
   {
      return this._name;
   }
   
   public function get bank() : AudioBank
   {
      return this._bank;
   }
   
   public function get isDisposed() : Boolean
   {
      return this._bank == null;
   }
   
   public function dispose() : void
   {
      AudioSystem.instance.disposeBank(this._bank);
      this._bank = null;
   }
}

import jackboxgames.events.*;
import jackboxgames.nativeoverride.*;
import jackboxgames.utils.*;

class EventMetadata extends PausableEventDispatcher
{
    
   
   private var _id:String;
   
   private var _name:String;
   
   private var _event:AudioEvent;
   
   private var _timelineMarkerNamesSeen:Array;
   
   public function EventMetadata(id:String, name:String, event:AudioEvent)
   {
      super();
      this._id = id;
      this._name = name;
      this._event = event;
      this._timelineMarkerNamesSeen = [];
      this._event.addEventListener(AudioEvent.EVENT_PLAYBACK_DONE,this._onPlaybackDone);
      this._event.addEventListener(AudioEvent.EVENT_TIMELINE_MARKER,this._onTimelineMarker);
   }
   
   public function get id() : String
   {
      return this._id;
   }
   
   public function get name() : String
   {
      return this._name;
   }
   
   public function get event() : AudioEvent
   {
      return this._event;
   }
   
   public function get timelineMarkerNamesSeen() : Array
   {
      return this._timelineMarkerNamesSeen;
   }
   
   public function get isDisposed() : Boolean
   {
      return this._event == null;
   }
   
   public function dispose() : void
   {
      this._event.removeEventListener(AudioEvent.EVENT_PLAYBACK_DONE,this._onPlaybackDone);
      this._event.removeEventListener(AudioEvent.EVENT_TIMELINE_MARKER,this._onTimelineMarker);
      AudioSystem.instance.disposeEvent(this._event);
      this._event = null;
   }
   
   private function _onPlaybackDone(evt:EventWithData) : void
   {
      dispatchEvent(new EventWithData(AudioEvent.EVENT_PLAYBACK_DONE,evt.data));
   }
   
   private function _onTimelineMarker(evt:EventWithData) : void
   {
      if(!ArrayUtil.arrayContainsElement(this._timelineMarkerNamesSeen,evt.data.name))
      {
         this._timelineMarkerNamesSeen.push(evt.data.name);
      }
      dispatchEvent(new EventWithData(AudioEvent.EVENT_TIMELINE_MARKER,evt.data));
   }
}
