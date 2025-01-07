package jackboxgames.thewheel.gameplay
{
   import jackboxgames.thewheel.GameState;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.SliceParameters;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.PerPlayerContainer;
   
   public class TriviaResult
   {
      private var _topHalfPlayers:Array;
      
      private var _bottomHalfPlayers:Array;
      
      private var _standOutPlayers:Array;
      
      private var _placeIndices:PerPlayerContainer;
      
      private var _topScore:int;
      
      private var _playersWithTopScore:Array;
      
      private var _everyoneTied:Boolean;
      
      private var _bonusPlayer:Player;
      
      private var _bonusSlice:SliceParameters;
      
      private var _bonusSliceWasFromBrokenTie:Boolean;
      
      private var _bonusSliceTiedPlayers:Array;
      
      public function TriviaResult(topHalfPlayers:Array, bottomHalfPlayers:Array, standOutPlayers:Array, placeIndices:PerPlayerContainer, topScore:int, playersWithTopScore:Array, everyoneTied:Boolean, bonusPlayer:Player, bonusSlice:SliceParameters, bonusSliceWasFromBrokenTie:Boolean, bonusSliceTiedPlayers:Array)
      {
         super();
         this._topHalfPlayers = topHalfPlayers;
         this._bottomHalfPlayers = bottomHalfPlayers;
         this._standOutPlayers = standOutPlayers;
         this._placeIndices = placeIndices;
         this._playersWithTopScore = playersWithTopScore;
         this._topScore = topScore;
         this._everyoneTied = everyoneTied;
         this._bonusPlayer = bonusPlayer;
         this._bonusSlice = bonusSlice;
         this._bonusSliceWasFromBrokenTie = bonusSliceWasFromBrokenTie;
         this._bonusSliceTiedPlayers = bonusSliceTiedPlayers;
      }
      
      public function get topHalfPlayers() : Array
      {
         return this._topHalfPlayers;
      }
      
      public function get bottomHalfPlayers() : Array
      {
         return this._bottomHalfPlayers;
      }
      
      public function get standoutPlayers() : Array
      {
         return this._standOutPlayers;
      }
      
      public function get topHalfPlayersNotStandingOut() : Array
      {
         return ArrayUtil.difference(this._topHalfPlayers,this._standOutPlayers);
      }
      
      public function get placeIndices() : PerPlayerContainer
      {
         return this._placeIndices;
      }
      
      public function get topScore() : int
      {
         return this._topScore;
      }
      
      public function get playersWithTopScore() : Array
      {
         return this._playersWithTopScore;
      }
      
      public function get everyoneTied() : Boolean
      {
         return this._everyoneTied;
      }
      
      public function get bonusPlayer() : Player
      {
         return this._bonusPlayer;
      }
      
      public function get bonusSlice() : SliceParameters
      {
         return this._bonusSlice;
      }
      
      public function get bonusSliceWasFromBrokenTie() : Boolean
      {
         return this._bonusSliceWasFromBrokenTie;
      }
      
      public function get bonusSliceTiedPlayers() : Array
      {
         return this._bonusSliceTiedPlayers;
      }
      
      public function get bonusPlayerScoreIsInBottomHalf() : Boolean
      {
         return Boolean(this._bonusPlayer) && this._bonusPlayer.scoreRank > Math.ceil(GameState.instance.numPlayers / 2);
      }
   }
}

