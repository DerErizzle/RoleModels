package jackboxgames.thewheel.actionpackages
{
   import jackboxgames.talkshow.api.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.utils.*;
   
   public class Winner extends LibraryActionPackage
   {
      private var _winnerNameTf:ExtendableTextField;
      
      private var _winnerScoreTf:ExtendableTextField;
      
      public function Winner(apRef:IActionPackageRef)
      {
         super(apRef,GameState.instance);
      }
      
      override protected function get _linkage() : String
      {
         return "Winner";
      }
      
      override protected function get _displayIndex() : int
      {
         return 2;
      }
      
      override protected function get _propertyName() : String
      {
         return "winner";
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._winnerNameTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.player.playerName);
         this._winnerScoreTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.player.playerScore.amount);
      }
      
      override protected function _onReset() : void
      {
         super._onReset();
         JBGUtil.gotoFrame(_mc.player,"Park");
      }
      
      public function handleActionSetup(ref:IActionRef, params:Object) : void
      {
         this._winnerNameTf.text = TheWheelTextUtil.formattedPlayerName(GameState.instance.winner);
         this._winnerScoreTf.text = TheWheelTextUtil.formattedPlayerScore(GameState.instance.winner);
         JBGUtil.gotoFrame(_mc.player,"Appear");
         JBGUtil.gotoFrame(_mc.player.playerAvatar,GameState.instance.winner.avatar.frame);
         ref.end();
      }
   }
}

