package jackboxgames.thewheel.wheel
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class SliceCatchMeWidget
   {
      private var _mc:MovieClip;
      
      private var _jailShower:MovieClipShower;
      
      private var _avatarShower:MovieClipShower;
      
      private var _darkenShower:MovieClipShower;
      
      public function SliceCatchMeWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._jailShower = new MovieClipShower(this._mc.jail);
         this._avatarShower = new MovieClipShower(this._mc.avatar);
         this._darkenShower = new MovieClipShower(this._mc.darken);
      }
      
      public function dispose() : void
      {
         this._jailShower.dispose();
         this._avatarShower.dispose();
         this._darkenShower.dispose();
         this._mc = null;
      }
      
      public function revealPlayerChecked() : void
      {
         this._darkenShower.setShown(true,Nullable.NULL_FUNCTION);
         MovieClipShower.setMultiple([this._jailShower],true,Duration.ZERO,Nullable.NULL_FUNCTION);
      }
      
      public function revealHidingPlayer(p:Player, wasCaught:Boolean) : void
      {
         JBGUtil.gotoFrame(this._mc.avatar.behaviors.color,p.avatar.id);
         MovieClipShower.setMultiple([this._darkenShower,this._avatarShower],true,Duration.ZERO,Nullable.NULL_FUNCTION);
         if(!wasCaught)
         {
            JBGUtil.gotoFrame(this._mc.avatar.behaviors,"Win");
         }
      }
      
      public function revealNoPlayer() : void
      {
      }
      
      public function dismiss() : void
      {
         MovieClipShower.setMultiple([this._jailShower,this._avatarShower,this._darkenShower],false,Duration.ZERO,Nullable.NULL_FUNCTION);
      }
   }
}

