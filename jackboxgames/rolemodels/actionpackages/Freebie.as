package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class Freebie extends JBGActionPackage
   {
       
      
      private var _revealData:FreebieData;
      
      public function Freebie(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function get winningPlayerUserID() : String
      {
         return this._revealData.receivingPlayer.userId.val;
      }
      
      public function get role() : RoleData
      {
         return this._revealData.roleData;
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         _ts.g.freebie = this;
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.reset([]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         this._revealData = FreebieData(GameState.instance.currentReveal);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         this._revealData.receivingPlayer.score.val += this._revealData.revealConstants.getProperty("points");
         this._revealData.roleData.playerAssignedRole = this._revealData.receivingPlayer;
         ref.end();
      }
   }
}
