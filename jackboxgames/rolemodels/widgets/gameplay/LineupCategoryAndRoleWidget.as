package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class LineupCategoryAndRoleWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _container:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _background:MovieClip;
      
      private var _bottomTF:ExtendableTextField;
      
      private var _topTF:ExtendableTextField;
      
      public function LineupCategoryAndRoleWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._container = this._mc.tf;
         this._shower = new MovieClipShower(this._mc);
         this._background = this._mc.bg;
         this._topTF = new ExtendableTextField(this._container.categoryTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._bottomTF = new ExtendableTextField(this._container.roleTF,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.gotoFrame(this._background,"Park");
      }
      
      public function setup(bottomLineText:String, topLineText:String = null) : void
      {
         JBGUtil.gotoFrame(this._background,"Loop");
         this._bottomTF.text = bottomLineText.toUpperCase();
         if(Boolean(topLineText) && topLineText.length > 0)
         {
            JBGUtil.gotoFrame(this._container,"LinesAre2");
            this._topTF.text = topLineText.toUpperCase();
         }
         else
         {
            JBGUtil.gotoFrame(this._container,"LinesAre1");
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}
