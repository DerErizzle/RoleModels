package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class LobbyPlayer
   {
      protected var _mc:MovieClip;
      
      protected var _avatarMC:MovieClip;
      
      protected var _maxPlayerMC:MovieClip;
      
      protected var _nameTf:ExtendableTextField;
      
      protected var _vipShower:MovieClipShower;
      
      public function LobbyPlayer(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._avatarMC = this._getAvatarMC();
         this._maxPlayerMC = this._getMaxPlayerMC();
         this._nameTf = this._createNameTf();
         this._vipShower = this._createVipShower();
      }
      
      public function dispose() : void
      {
         this._mc = null;
         this._avatarMC = null;
         this._maxPlayerMC = null;
         this._nameTf.dispose();
         this._nameTf = null;
         this._vipShower.dispose();
         this._vipShower = null;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._getAnimationContainer(),"Park");
         JBGUtil.reset([this._vipShower]);
      }
      
      protected function _getAnimationContainer() : MovieClip
      {
         return this._mc;
      }
      
      protected function _getAvatarMC() : MovieClip
      {
         return this._mc.avatar;
      }
      
      protected function _getMaxPlayerMC() : MovieClip
      {
         return this._mc.maxPlayer;
      }
      
      protected function _createNameTf() : ExtendableTextField
      {
         return ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerName);
      }
      
      protected function _createVipShower() : MovieClipShower
      {
         return new MovieClipShower(this._mc.vip);
      }
      
      protected function _getAvatarFrameForPlayer(slotIndex:int, p:JBGPlayer) : String
      {
         return "Avatar" + slotIndex;
      }
      
      public function setupForNewLobby(i:int) : void
      {
      }
      
      public function setupForPlayer(i:int, p:JBGPlayer) : void
      {
         this._nameTf.text = p.name.val;
         JBGUtil.gotoFrame(this._getAnimationContainer(),"AppearPlayer");
         JBGUtil.gotoFrame(this._avatarMC,this._getAvatarFrameForPlayer(i,p));
         this._vipShower.setShown(p.isVIP,Nullable.NULL_FUNCTION);
      }
      
      public function doAnim(anim:String, doneFn:Function) : void
      {
         if(!MovieClipUtil.frameExists(this._mc,anim))
         {
            doneFn();
            return;
         }
         JBGUtil.gotoFrameWithFn(this._getAnimationContainer(),anim,MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}

