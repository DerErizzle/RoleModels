package jackboxgames.thewheel.actionpackages
{
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import jackboxgames.logger.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.utils.*;
   
   public class Gameplay extends JBGActionPackage implements IPlayerControllerStateProvider
   {
      private var _extraLoaders:Array;
      
      private var _extraCancelers:Array;
      
      public function Gameplay(apRef:IActionPackageRef)
      {
         super(apRef);
         this._extraLoaders = [];
         this._extraCancelers = [];
      }
      
      override protected function get _sourceURL() : String
      {
         return "thewheel_gameplay.swf";
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            var c:Counter = null;
            c = new Counter(2,function():void
            {
               _onLoaded();
               ref.end();
            });
            JBGUtil.eventOnce(ContentManager.instance,ContentManager.EVENT_LOAD_RESULT,function(success:Boolean):void
            {
               if(success)
               {
                  c.tick();
               }
               else
               {
                  Logger.error("Failed to load content :(");
               }
            });
            ContentManager.instance.load();
            GameState.instance.jsonData.load().then(c.generateDoneFn(),function(... args):void
            {
               Logger.error("Failed to load json :(");
            });
         });
      }
      
      private function _onLoaded() : void
      {
         _ts.g.gameplay = this;
         GameState.instance.screenOrganizer.addChild(_mc,3);
      }
      
      private function _loadExtraSwf(url:String, doneFn:Function) : void
      {
         var context:LoaderContext;
         var l:Loader = null;
         var onLoadComplete:Function = null;
         var onLoadError:Function = null;
         onLoadComplete = function(evt:Event):void
         {
            doneFn();
         };
         onLoadError = function(evt:Event):void
         {
            doneFn();
         };
         if(BuildConfig.instance.hasConfigVal("swfRoot"))
         {
            url = BuildConfig.instance.configVal("swfRoot") + url;
         }
         l = new Loader();
         l.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
         l.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
         l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         this._extraCancelers.push(function():void
         {
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         });
         context = new LoaderContext();
         context.checkPolicyFile = true;
         context.applicationDomain = ApplicationDomain.currentDomain;
         l.load(new URLRequest(url),context);
         this._extraLoaders.push(l);
      }
      
      override protected function _loadExtraResources(doneFn:Function) : void
      {
         var c:Counter = new Counter(2,function():void
         {
            GameState.instance.loadContentActionPackages();
            doneFn();
         });
         this._loadExtraSwf("thewheel_triviatypes.swf",c.generateDoneFn());
         this._loadExtraSwf("thewheel_wheel.swf",c.generateDoneFn());
      }
      
      override protected function _unloadExtraResources(doneFn:Function) : void
      {
         this._extraCancelers.forEach(function(c:Function, ... args):void
         {
            c();
         });
         this._extraCancelers = [];
         this._extraLoaders.forEach(function(l:Loader, ... args):void
         {
            l.unloadAndStop(true);
         });
         this._extraLoaders = [];
         doneFn();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.reset();
         ref.end();
      }
      
      public function handleActionSetActive(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,Boolean(params.isActive) ? DisplayObjectOrganizer.STATE_ON : DisplayObjectOrganizer.STATE_OFF);
         ref.end();
      }
      
      public function handleActionSetupForNewLobby(ref:IActionRef, params:Object) : void
      {
         GameState.instance.setupForNewLobby();
         ref.end();
      }
      
      public function handleActionSetupNewGame(ref:IActionRef, params:Object) : void
      {
         GameState.instance.setupNewGame();
         if(GameState.instance.debug.skipEntireGame)
         {
            GameState.instance.setPlayerAsWinner(ArrayUtil.getRandomElement(GameState.instance.players));
         }
         ref.end();
      }
      
      public function handleActionGiveQuestionToPlayersThatDidntAsk(ref:IActionRef, params:Object) : void
      {
         GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return p.question == null;
         }).forEach(function(p:Player, ... args):void
         {
            var content:Object = ArrayUtil.first(ContentManager.instance.getRandomUnusedContent("TheWheelPlayerQuestion",1));
            p.question = content.text;
         });
         ref.end();
      }
      
      public function handleActionSetupNewRound(ref:IActionRef, params:Object) : void
      {
         GameState.instance.setupNewRound();
         GameState.instance.addPlayerControllerStateProvider(this);
         ref.end();
      }
      
      public function handleActionAdvanceToNextRound(ref:IActionRef, params:Object) : void
      {
         GameState.instance.advanceToNextRound();
         ref.end();
      }
      
      public function handleActionDistributePendingPoints(ref:IActionRef, params:Object) : void
      {
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            if(p.pendingPointsFromScoreChanges > 0)
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_POINTS",TheWheelTextUtil.formattedPlayerName(p),p.pendingPointsFromScoreChanges);
            }
            p.distributePendingScoreChanges(params.canGiveTrophy);
         });
         GameState.instance.textDescriptions.updateEntity();
         ref.end();
      }
      
      public function handleActionMovePlayersInOrOutOfWinnerMode(ref:IActionRef, params:Object) : void
      {
         var playersToMove:Array = GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return p.isInWinnerMode != p.shouldBeInWinnerMode;
         });
         playersToMove.forEach(function(p:Player, ... args):void
         {
            p.isInWinnerMode = p.shouldBeInWinnerMode;
         });
         ref.end();
      }
      
      public function handleActionFinishCurrentRound(ref:IActionRef, params:Object) : void
      {
         GameState.instance.finishRound();
         GameState.instance.removePlayerControllerStateProvider(this);
         ref.end();
      }
      
      public function mutateState(p:Player, state:Object) : void
      {
         state.hasPowerSlice = p == GameState.instance.currentRoundData.bonusPlayer;
      }
   }
}

