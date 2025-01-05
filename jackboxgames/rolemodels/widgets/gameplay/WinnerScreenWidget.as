package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class WinnerScreenWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _winnerTextShower:MovieClipShower;
      
      private var _leadupMC:MovieClip;
      
      private var _hands:WinnerScreenHandWidget;
      
      private var _finalRole:WinnerScreenFinalRoleWidget;
      
      private var _playerContainer:WinnerScreenPlayerContainer;
      
      private var _backgroundShower:MovieClipShower;
      
      public function WinnerScreenWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._winnerTextShower = new MovieClipShower(this._mc.winnerTF);
         this._leadupMC = this._mc.leadup;
         this._hands = new WinnerScreenHandWidget(this._mc.hands);
         this._finalRole = new WinnerScreenFinalRoleWidget(this._mc.finalRole);
         this._playerContainer = new WinnerScreenPlayerContainer(this._mc.playerSummaryContainer);
         this._backgroundShower = new MovieClipShower(this._mc.bg);
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._hands,this._finalRole,this._playerContainer,this._backgroundShower,this._winnerTextShower]);
         JBGUtil.gotoFrame(this._leadupMC,"Park");
      }
      
      public function setup() : void
      {
         var sortedPlayers:Array = GameState.instance.getPlayersSorted(Player.PROPERTY_FUNCTION_SCORE,GameState.SORT_TYPE_DESCENDING);
         this._hands.setup(sortedPlayers[0]);
         this._finalRole.setup(sortedPlayers[0]);
         this._playerContainer.setup(sortedPlayers);
      }
      
      public function setNonWinnersShown(isShown:Boolean, timeBetweenAppears:Duration, timeAfterAppearUntilShrink:Duration, doneFn:Function) : void
      {
         this._playerContainer.setShown(isShown,timeBetweenAppears,timeAfterAppearUntilShrink,doneFn);
      }
      
      public function revealWinner(doneFn:Function) : void
      {
         this._winnerTextShower.setShown(true,Nullable.NULL_FUNCTION);
         this._hands.revealWinner(doneFn);
      }
      
      public function hideHands() : void
      {
         this._hands.reset();
      }
      
      public function revealFinalRole(doneFn:Function) : void
      {
         this._finalRole.setShown(true,doneFn);
      }
      
      public function showHands(doneFn:Function) : void
      {
         this._hands.showHands(doneFn);
      }
      
      public function showBackground(doneFn:Function) : void
      {
         this._backgroundShower.setShown(true,doneFn);
      }
      
      public function hideWinnerAndFinalRole(doneFn:Function) : void
      {
         this._winnerTextShower.setShown(false,Nullable.NULL_FUNCTION);
         this._finalRole.setShown(false,Nullable.NULL_FUNCTION);
         doneFn();
      }
      
      public function doLeadupAnimation(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._leadupMC,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
   }
}
