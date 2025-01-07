package jackboxgames.thewheel.data
{
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class RoundData
   {
      private var _roundIndex:int;
      
      private var _setup:RoundSetup;
      
      private var _triviaList:TriviaList;
      
      private var _triviaData:Array;
      
      private var _bonusPlayer:Player;
      
      private var _bonusSlice:SliceParameters;
      
      private var _playersInWinnerMode:Array;
      
      private var _lastRoundPlayersInWinnerMode:Array;
      
      private var _isFinished:Boolean;
      
      public function RoundData(ri:int, setup:RoundSetup, previousRound:RoundData)
      {
         super();
         this._roundIndex = ri;
         this._setup = setup;
         this._triviaList = this._setup.skeleton.skin();
         this._triviaData = new Array(this._triviaList.types.length);
         this._playersInWinnerMode = [];
         this._lastRoundPlayersInWinnerMode = Boolean(previousRound) ? previousRound.playersInWinnerMode : [];
      }
      
      public function get roundIndex() : int
      {
         return this._roundIndex;
      }
      
      public function get setup() : RoundSetup
      {
         return this._setup;
      }
      
      public function get triviaList() : TriviaList
      {
         return this._triviaList;
      }
      
      public function get triviaData() : Array
      {
         return this._triviaData;
      }
      
      public function get bonusPlayer() : Player
      {
         return this._bonusPlayer;
      }
      
      public function get bonusSlice() : SliceParameters
      {
         return this._bonusSlice;
      }
      
      public function get playersInWinnerMode() : Array
      {
         return this._playersInWinnerMode;
      }
      
      public function get playersNewToWinnerMode() : Array
      {
         return ArrayUtil.difference(this._playersInWinnerMode,this._lastRoundPlayersInWinnerMode);
      }
      
      public function get playersWhoLeftWinnerMode() : Array
      {
         return ArrayUtil.difference(this._lastRoundPlayersInWinnerMode,this._playersInWinnerMode);
      }
      
      public function get isFinished() : Boolean
      {
         return this._isFinished;
      }
      
      public function setupTrivia(index:int, content:ITriviaContent) : void
      {
         this._triviaData[index] = new RoundTriviaData(content);
      }
      
      public function setBonusSlice(player:Player, slice:SliceParameters) : void
      {
         this._bonusPlayer = player;
         this._bonusSlice = slice;
      }
      
      public function finishRound() : void
      {
         this._isFinished = true;
         this._playersInWinnerMode = GameState.instance.players.filter(function(p:Player, ... a):Boolean
         {
            return p.isInWinnerMode;
         });
      }
      
      public function playerIsNewToWinnerMode(p:Player) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this.playersNewToWinnerMode,p);
      }
   }
}

