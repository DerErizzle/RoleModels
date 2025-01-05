package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class VoteResultCategoryRoleWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _categoryTF:ExtendableTextField;
      
      private var _roleTF:ExtendableTextField;
      
      public function VoteResultCategoryRoleWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._shower.behaviorTranslator = function(s:String):String
         {
            if(s == "Disappear")
            {
               if(GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.justPlaying)
               {
                  return "DisappearRight";
               }
               return "DisappearLeft";
            }
            return s;
         };
         this._categoryTF = new ExtendableTextField(this._mc.roleAndCategory.categoryTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._roleTF = new ExtendableTextField(this._mc.roleAndCategory.roleTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.gotoFrame(this._mc.bg,"Park");
      }
      
      public function setup(categoryText:String, role:RoleData) : void
      {
         JBGUtil.gotoFrame(this._mc.roleAndCategory,"LinesAre2");
         this._categoryTF.text = categoryText;
         this._roleTF.text = role.name.toUpperCase();
         JBGUtil.gotoFrame(this._mc.bg,"Loop");
      }
      
      public function setupNoRole(categoryTFText:String) : void
      {
         JBGUtil.gotoFrame(this._mc.roleAndCategory,"LinesAre1");
         this._categoryTF.text = "";
         this._roleTF.text = categoryTFText;
         JBGUtil.gotoFrame(this._mc.bg,"Loop");
      }
   }
}
