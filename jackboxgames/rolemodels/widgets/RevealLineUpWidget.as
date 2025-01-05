package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class RevealLineUpWidget
   {
       
      
      private var _players:Array;
      
      private var _mc:MovieClip;
      
      private var _playerWidgets:Array;
      
      private var _playerWidgetsInPlay:Array;
      
      private var _answerWidgets:Array;
      
      private var _answerWidgetsInPlay:Array;
      
      private var _bucketedPlayers:Array;
      
      public function RevealLineUpWidget(mc:MovieClip)
      {
         var playerMCs:Array;
         var answerMCs:Array;
         super();
         this._mc = mc;
         playerMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatar");
         this._playerWidgets = playerMCs.map(function(playerMC:MovieClip, ... args):PlayerWidget
         {
            return new PlayerWidget(playerMC);
         });
         answerMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"answer");
         this._answerWidgets = answerMCs.map(function(answerMC:MovieClip, ... args):AnswerWidget
         {
            return new AnswerWidget(answerMC);
         });
         this.reset();
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._playerWidgets);
         JBGUtil.reset(this._answerWidgets);
         this._players = null;
         this._playerWidgetsInPlay = [];
         this._answerWidgetsInPlay = [];
         this._bucketedPlayers = [];
      }
      
      public function setup(players:Array) : void
      {
         this.reset();
         this._players = players;
         this._playerWidgetsInPlay = this._playerWidgets.filter(function(pw:PlayerWidget, i:int, a:Array):Boolean
         {
            return i < _players.length;
         });
         this._playerWidgetsInPlay.forEach(function(pw:PlayerWidget, i:int, a:Array):void
         {
            pw.setup(_players[i],i < a.length / 2 ? String(PlayerWidget.BUCKET_DISAPPEAR_DIRECTION.RIGHT) : String(PlayerWidget.BUCKET_DISAPPEAR_DIRECTION.LEFT));
         });
         this._answerWidgetsInPlay = this._answerWidgets.filter(function(aw:AnswerWidget, i:int, a:Array):Boolean
         {
            return i < _players.length;
         });
         this._answerWidgetsInPlay.forEach(function(aw:AnswerWidget, i:int, a:Array):void
         {
            aw.setup(_players[i]);
         });
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + this._players.length);
      }
      
      public function setPlayersShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._playerWidgetsInPlay.length,doneFn);
         this._playerWidgetsInPlay.forEach(function(pw:PlayerWidget, ... args):void
         {
            pw.setShown(isShown,c.generateDoneFn());
         });
      }
      
      public function setAnswersShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._answerWidgetsInPlay.length,doneFn);
         this._answerWidgetsInPlay.forEach(function(aw:AnswerWidget, ... args):void
         {
            aw.setShown(isShown,c.generateDoneFn());
         });
      }
      
      public function bucketPlayers(players:Array, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(players.length,doneFn);
         this._bucketedPlayers = players;
         this._playerWidgetsInPlay.forEach(function(pw:PlayerWidget, ... args):void
         {
            Assert.assert(pw.player != null);
            if(ArrayUtil.arrayContainsElement(players,pw.player))
            {
               pw.bucketAvatar(c.generateDoneFn());
            }
         });
      }
      
      public function showBucketedPlayersRoles(doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._bucketedPlayers.length,doneFn);
         this._answerWidgetsInPlay.forEach(function(aw:AnswerWidget, ... args):void
         {
            if(ArrayUtil.arrayContainsElement(_bucketedPlayers,aw.player))
            {
               aw.setText(GameState.instance.currentRound.getRoleAssignedToPlayer(aw.player).name.toUpperCase());
               aw.showPlayerName(Nullable.NULL_FUNCTION);
               aw.setShown(true,c.generateDoneFn());
            }
         });
      }
      
      public function setVotesShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._playerWidgetsInPlay.length,doneFn);
         this._playerWidgetsInPlay.forEach(function(pw:PlayerWidget, ... args):void
         {
            pw.setVotesShown(isShown,c.generateDoneFn());
         });
      }
   }
}
