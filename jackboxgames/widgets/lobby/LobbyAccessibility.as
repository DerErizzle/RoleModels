package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   import jackboxgames.widgets.*;
   
   public class LobbyAccessibility
   {
      private var _gameState:JBGGameState;
      
      private var _events:AudioSystemEventCollection;
      
      private var _eventPreambule:AudioEvent;
      
      private var _isActive:Boolean;
      
      private var _isPlaying:Boolean;
      
      private var _textToSpell:Array;
      
      private var _textToSpellProgress:Array;
      
      private var _button:MovieClipShower;
      
      private var _preambuleEvents:Array;
      
      public function LobbyAccessibility(mc:MovieClip, gameState:JBGGameState)
      {
         super();
         this._gameState = gameState;
         this._isActive = false;
         this._isPlaying = false;
         if(Boolean(mc))
         {
            this._button = new MovieClipShower(mc);
         }
      }
      
      public function dispose() : void
      {
         if(this._button == null)
         {
            return;
         }
         this.reset();
         this._button.dispose();
         this._button = null;
         this._textToSpell = null;
         this._gameState = null;
      }
      
      public function reset() : void
      {
         this._isActive = false;
         this._isPlaying = false;
         if(this._events != null)
         {
            this._events.dispose();
            this._events = null;
         }
         if(this._eventPreambule != null)
         {
            this._eventPreambule.dispose();
            this._eventPreambule = null;
         }
         if(this._button != null)
         {
            this._button.reset();
         }
      }
      
      private function _generateEventsList(text:Array, basePath:String) : Object
      {
         var eventsList:Object = null;
         eventsList = {};
         text.forEach(function(character:String, ... args):void
         {
            eventsList[character] = basePath + character;
         });
         return eventsList;
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         if(Boolean(this._button))
         {
            this._button.setShown(isShown,doneFn);
         }
      }
      
      public function setActive(doneFn:Function, params:Object) : void
      {
         if(this._isActive == params.isActive)
         {
            doneFn();
            return;
         }
         this._isActive = params.isActive;
         if(this._isActive)
         {
            this._textToSpell = params.textToSpell.toUpperCase().split("");
            this._preambuleEvents = ObjectUtil.getChildrenWithNameInOrder(params,"preambule");
            this._events = new AudioSystemEventCollection(this._generateEventsList(this._textToSpell,params.alphabet));
            this._events.setLoaded(true,function(success:Boolean):void
            {
               if(!_isActive)
               {
                  return;
               }
               setShown(true,Nullable.NULL_FUNCTION);
               doneFn();
            });
         }
         else
         {
            this.setShown(false,Nullable.NULL_FUNCTION);
            this._events.setLoaded(false,function(success:Boolean):void
            {
               _events.dispose();
               _events = null;
               doneFn();
            });
         }
      }
      
      private function _spellNextLetter() : void
      {
         var character:String;
         if(!this._isPlaying)
         {
            return;
         }
         if(this._textToSpellProgress.length == 0)
         {
            this._isPlaying = false;
            return;
         }
         character = this._textToSpellProgress.shift();
         this._events.play(character,function():void
         {
            _spellNextLetter();
         });
      }
      
      public function readRoomCode() : void
      {
         if(!this._isPlaying && this._isActive)
         {
            this._isPlaying = true;
            this._textToSpellProgress = this._textToSpell.concat();
            if(this._preambuleEvents.length > 0)
            {
               this._eventPreambule = new AudioEvent(ArrayUtil.getRandomElement(this._preambuleEvents));
               this._eventPreambule.addEventListener(AudioEvent.EVENT_PLAYBACK_DONE,function(evt:EventWithData):void
               {
                  _spellNextLetter();
                  _eventPreambule.dispose();
                  _eventPreambule = null;
               });
               this._eventPreambule.load(function(success:Boolean):void
               {
                  if(!success)
                  {
                     _spellNextLetter();
                     _eventPreambule.dispose();
                     _eventPreambule = null;
                     return;
                  }
                  _eventPreambule.play();
               });
            }
            else
            {
               this._spellNextLetter();
            }
         }
      }
   }
}

