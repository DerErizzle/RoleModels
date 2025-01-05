package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class WinnerScreenHandWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _handsAnimation:MovieClip;
      
      private var _player:MovieClip;
      
      private var _playerName:ExtendableTextField;
      
      private var _avatar:PlayerAvatarWidget;
      
      public function WinnerScreenHandWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._handsAnimation = this._mc.closedHands;
         this._player = this._mc.closedHands.avatar;
         this._playerName = new ExtendableTextField(this._handsAnimation.playerName,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._avatar = new PlayerAvatarWidget(this._player.avatar);
      }
      
      private function _parkEverything() : void
      {
         JBGUtil.arrayGotoFrame([this._mc,this._player,this._handsAnimation],"Park");
      }
      
      public function reset() : void
      {
         this._avatar.reset();
         this._parkEverything();
      }
      
      public function setup(player:Player) : void
      {
         this._playerName.text = player.name.val;
         this._avatar.setup(player);
      }
      
      public function showHands(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._handsAnimation,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            JBGUtil.gotoFrameWithFn(_mc,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
         });
      }
      
      public function revealWinner(doneFn:Function) : void
      {
         JBGUtil.gotoFrame(this._player,"Appear");
         JBGUtil.gotoFrameWithFn(this._handsAnimation,"RevealWinner",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
