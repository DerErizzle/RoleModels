package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class MinigamePlayerVoteLineupWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _playerWidgets:Array;
      
      private var _activePlayerWidgets:Array;
      
      public function MinigamePlayerVoteLineupWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._playerWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"player").map(function(playerMC:MovieClip, ... args):MinigamePlayerVoteWidget
         {
            return new MinigamePlayerVoteWidget(playerMC);
         });
         this._activePlayerWidgets = [];
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._playerWidgets);
         this._activePlayerWidgets = [];
      }
      
      public function setup(players:Array, playerAnswersWillBeOnscreen:Boolean) : void
      {
         this.reset();
         if(playerAnswersWillBeOnscreen)
         {
            JBGUtil.gotoFrame(this._mc,"AnswerVotesAre" + players.length);
         }
         else
         {
            JBGUtil.gotoFrame(this._mc,"VotesAre" + players.length);
         }
         this._activePlayerWidgets = this._playerWidgets.slice(0,players.length);
         players.forEach(function(player:Player, index:int, ... args):void
         {
            MinigamePlayerVoteWidget(_activePlayerWidgets[index]).setup(player);
         });
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._activePlayerWidgets.length,doneFn);
         this._activePlayerWidgets.forEach(function(widget:MinigamePlayerVoteWidget, ... args):void
         {
            widget.setShown(isShown,c.generateDoneFn());
         });
      }
   }
}
