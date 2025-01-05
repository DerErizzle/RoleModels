package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class SubmittedAvatarsWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _avatarWidgets:Array;
      
      public function SubmittedAvatarsWidget(mc:MovieClip)
      {
         var avatarMCs:Array;
         super();
         this._mc = mc;
         avatarMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatar");
         this._avatarWidgets = avatarMCs.map(function(avatarMC:MovieClip, ... args):VoteAvatarWidget
         {
            return new VoteAvatarWidget(avatarMC);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._avatarWidgets);
      }
      
      public function setup(players:Array) : void
      {
         this.reset();
         players.forEach(function(p:Player, i:int, ... args):void
         {
            _avatarWidgets[i].setup(p);
         });
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + players.length);
      }
      
      public function setAvatarShown(isShown:Boolean, playerIndex:int, doneFn:Function) : void
      {
         if(isShown && !this._avatarWidgets[playerIndex].shower.isShown)
         {
            GameState.instance.audioRegistrationStack.play("VoteIn",Nullable.NULL_FUNCTION);
            this._avatarWidgets[playerIndex].shower.setShown(isShown,function():void
            {
               doneFn();
               _avatarWidgets[playerIndex].shower.doAnimation("Idle",Nullable.NULL_FUNCTION);
            });
         }
         else
         {
            this._avatarWidgets[playerIndex].shower.setShown(isShown,doneFn);
         }
      }
   }
}
