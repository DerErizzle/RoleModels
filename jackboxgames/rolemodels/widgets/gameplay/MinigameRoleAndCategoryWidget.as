package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class MinigameRoleAndCategoryWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _background:MovieClip;
      
      private var _categoryTF:ExtendableTextField;
      
      private var _roleTF:ExtendableTextField;
      
      public function MinigameRoleAndCategoryWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._shower.behaviorTranslator = function(s:String):String
         {
            if(s == "Appear")
            {
               if(GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.justPlaying)
               {
                  return "AppearYellowToRed";
               }
               return "AppearYellowToBlue";
            }
            return s;
         };
         this._background = this._mc.categoryAndRoleTF.bg;
         this._categoryTF = new ExtendableTextField(this._mc.categoryAndRoleTF.categoryTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._roleTF = new ExtendableTextField(this._mc.categoryAndRoleTF.roleTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.gotoFrame(this._background,"Park");
      }
      
      public function setup() : void
      {
         JBGUtil.gotoFrame(this._background,"Loop");
         this._categoryTF.text = "";
         if(GameState.instance.currentReveal.roleData == null)
         {
            JBGUtil.gotoFrame(this._mc.categoryAndRoleTF,"LinesAre1");
            this._roleTF.text = GameState.instance.currentRound.category.toUpperCase();
            return;
         }
         JBGUtil.gotoFrame(this._mc.categoryAndRoleTF,"LinesAre2");
         this._categoryTF.text = GameState.instance.currentRound.category.toUpperCase();
         this._roleTF.text = GameState.instance.currentReveal.roleData.name.toUpperCase();
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}
