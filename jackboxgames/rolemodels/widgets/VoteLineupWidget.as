package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class VoteLineupWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _avatarWidgets:Array;
      
      private var _activeAvatarWidgets:Array;
      
      public function VoteLineupWidget(mc:MovieClip)
      {
         var avatarMCs:Array;
         super();
         this._mc = mc;
         avatarMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"vote");
         this._avatarWidgets = avatarMCs.map(function(avatarMC:MovieClip, ... args):VoteAvatarWidget
         {
            return new VoteAvatarWidget(avatarMC);
         });
         this._activeAvatarWidgets = [];
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._avatarWidgets);
         this._activeAvatarWidgets = [];
      }
      
      public function setup(players:Array) : void
      {
         this.reset();
         players.forEach(function(p:Player, i:int, ... args):void
         {
            _avatarWidgets[i].setup(p);
            _activeAvatarWidgets.push(_avatarWidgets[i]);
         });
         JBGUtil.gotoFrame(this._mc,"VoteIs" + this._activeAvatarWidgets.length);
      }
      
      public function setVotesShown(isShown:Boolean, doneFn:Function) : void
      {
         var showers:Array = this._activeAvatarWidgets.map(function(widget:VoteAvatarWidget, ... args):MovieClipShower
         {
            return widget.shower;
         });
         MovieClipShower.setMultiple(showers,isShown,Duration.fromMs(30),doneFn);
      }
   }
}
