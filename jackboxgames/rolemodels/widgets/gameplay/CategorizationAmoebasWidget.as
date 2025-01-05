package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class CategorizationAmoebasWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _backgroundBlobs:Array;
      
      private var _roleWidgets:Array;
      
      private var _categoryTF:ExtendableTextField;
      
      public function CategorizationAmoebasWidget(mc:MovieClip)
      {
         var labels:Array;
         super();
         this._mc = mc;
         this._categoryTF = new ExtendableTextField(this._mc.categoryTF,[],[PostEffectFactory.createDynamicResizerEffect(2,4,128,2,false),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._backgroundBlobs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"amoebasAre",GameConstants.MIN_PLAYERS);
         labels = JBGUtil.getPropertiesOfNameInOrder(this._mc,"labelTF");
         this._roleWidgets = labels.map(function(labelMC:MovieClip, ... args):AmoebaTextWidget
         {
            return new AmoebaTextWidget(labelMC);
         });
      }
      
      public function reset() : void
      {
         this._categoryTF.text = "";
         JBGUtil.reset(this._roleWidgets);
         JBGUtil.arrayGotoFrame(this._backgroundBlobs,"Park");
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function setup(categoryText:String, chosenCategoryIndex:int) : void
      {
         var blobs:MovieClip;
         var roles:Array = GameState.instance.currentRound.getRolesOfSource(RoleData.ROLE_SOURCE.INITIAL);
         JBGUtil.gotoFrame(this._mc,"BlobsAre" + roles.length);
         blobs = this._backgroundBlobs[roles.length - GameConstants.MIN_PLAYERS];
         JBGUtil.gotoFrame(blobs,"Loop" + String(chosenCategoryIndex));
         this._categoryTF.text = categoryText;
         roles.forEach(function(role:RoleData, i:int, ... args):void
         {
            _roleWidgets[i].setup(role.name.toUpperCase());
         });
      }
   }
}
