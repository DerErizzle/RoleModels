package jackboxgames.thewheel
{
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.model.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class Player extends JBGPlayer implements IHasPlayerWidget
   {
      public static const EVENT_CONTROLLER_STATE_UPDATE_REQUEST:String = "controllerStateUpdateRequest";
      
      private var _avatar:Avatar;
      
      private var _widget:IPlayerWidgetBehaviors;
      
      private var _question:String;
      
      private var _answer:String;
      
      private var _pendingScoreChanges:Array;
      
      private var _numPlaceableSlices:int;
      
      private var _isInWinnerMode:Boolean;
      
      private var _numSpins:int;
      
      private var _tiesBroken:int;
      
      private var _hasGottenPointsBefore:Boolean;
      
      public function Player()
      {
         super();
         this.reset();
      }
      
      public function get avatar() : Avatar
      {
         return this._avatar;
      }
      
      public function get widget() : IPlayerWidgetBehaviors
      {
         return this._widget;
      }
      
      public function get question() : String
      {
         return this._question;
      }
      
      public function set question(val:String) : void
      {
         this._question = val;
      }
      
      public function get answer() : String
      {
         return this._answer;
      }
      
      public function set answer(val:String) : void
      {
         this._answer = val;
      }
      
      public function get numPlaceableSlices() : int
      {
         return this._numPlaceableSlices;
      }
      
      public function get numSpins() : int
      {
         return this._numSpins;
      }
      
      public function get tiesBroken() : int
      {
         return this._tiesBroken;
      }
      
      public function get hasGottenPointsBefore() : Boolean
      {
         return this._hasGottenPointsBefore;
      }
      
      public function get scoreRank() : int
      {
         return GameState.instance.getRankOfPlayer(this);
      }
      
      public function setupForNewLobby(a:Avatar) : void
      {
         this._avatar = a;
      }
      
      override public function reset() : void
      {
         super.reset();
         this._question = null;
         this._answer = null;
         _score.val = 0;
         this._pendingScoreChanges = [];
         this._numPlaceableSlices = 0;
         this._isInWinnerMode = false;
         this._numSpins = 0;
         this._tiesBroken = 0;
         this._hasGottenPointsBefore = false;
         this._widget = new NullPlayerWidget();
      }
      
      public function requestToUpdateControllerState() : void
      {
         dispatchEvent(new EventWithData(EVENT_CONTROLLER_STATE_UPDATE_REQUEST,this));
      }
      
      public function linkWithWidget(w:IPlayerWidgetBehaviors) : void
      {
         Assert.assert(this._widget is NullPlayerWidget);
         this._widget = w;
      }
      
      public function unlinkFromWidget() : void
      {
         Assert.assert(!(this._widget is NullPlayerWidget));
         this._widget = new NullPlayerWidget();
      }
      
      public function addScoreChange(sc:ScoreChange) : void
      {
         this._pendingScoreChanges.push(sc);
      }
      
      public function get pendingScoreChanges() : Array
      {
         return this._pendingScoreChanges;
      }
      
      public function get pendingPointsFromScoreChanges() : int
      {
         var totalChange:int = 0;
         totalChange = 0;
         this._pendingScoreChanges.forEach(function(sc:ScoreChange, ... args):void
         {
            totalChange += sc.getAmount(true);
         });
         return totalChange;
      }
      
      public function distributePendingScoreChanges(canGiveTrophy:Boolean) : void
      {
         var totalChange:int = this.pendingPointsFromScoreChanges;
         score.val += totalChange;
         if(totalChange != 0)
         {
            this._hasGottenPointsBefore = true;
         }
         if(canGiveTrophy && totalChange >= GameConstants.NUM_POINTS_FOR_LOTS_OF_POINTS_TROPHY)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_LOTS_OF_POINTS_FROM_ONE_SLICE);
         }
         this._pendingScoreChanges = [];
      }
      
      public function clearSlices() : void
      {
         if(this._numPlaceableSlices == 0)
         {
            return;
         }
         this._numPlaceableSlices = 0;
         this.requestToUpdateControllerState();
      }
      
      public function changePlaceableSlices(change:int) : void
      {
         if(change == 0)
         {
            return;
         }
         this._numPlaceableSlices += change;
         this.requestToUpdateControllerState();
      }
      
      public function recordSpin() : void
      {
         ++this._numSpins;
      }
      
      public function recordBrokenTie() : void
      {
         ++this._tiesBroken;
      }
      
      public function get shouldBeInWinnerMode() : Boolean
      {
         var scoreIncludingPending:int = score.val + this.pendingPointsFromScoreChanges;
         return scoreIncludingPending >= (!GameState.instance.debug.victoryThresholdIsOverridden ? GameState.instance.jsonData.gameConfig.pointsRequiredToWinGame : GameState.instance.debug.victoryThresholdOverride);
      }
      
      public function get isInWinnerMode() : Boolean
      {
         return this._isInWinnerMode;
      }
      
      public function set isInWinnerMode(val:Boolean) : void
      {
         if(this._isInWinnerMode == val)
         {
            return;
         }
         this._isInWinnerMode = val;
         this.requestToUpdateControllerState();
      }
      
      public function generatePlayerControllerState() : Object
      {
         return {
            "isInWinnerMode":this._isInWinnerMode,
            "sliceCount":this._numPlaceableSlices
         };
      }
      
      public function get totalPendingScoreChanges() : int
      {
         return MapFold.process(this._pendingScoreChanges,function(sc:ScoreChange, ... args):int
         {
            return sc.getAmount(true);
         },MapFold.FOLD_SUM);
      }
      
      override public function toSimpleObject() : Object
      {
         return {
            "sessionId":this.sessionId.val,
            "name":this.name.val,
            "avatarId":this.avatar.id,
            "score":this.score.val,
            "question":this._question,
            "answer":this._answer
         };
      }
   }
}

