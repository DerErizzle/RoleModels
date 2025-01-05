package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class MinigameTextWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _titleTF:ExtendableTextField;
      
      private var _colorAgainst:String;
      
      public function MinigameTextWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._shower.behaviorTranslator = function(frame:String):String
         {
            if(MovieClipUtil.frameExists(_mc,frame + _colorAgainst))
            {
               return frame + _colorAgainst;
            }
            return frame;
         };
         this._titleTF = new ExtendableTextField(this._mc.tf,[],[PostEffectFactory.createDynamicResizerEffect(2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function disappearVertical(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"DisappearDataAnalysis",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            _shower.reset();
            doneFn();
         });
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
      
      public function setup(text:String, colorAgainst:String) : void
      {
         this._titleTF.text = text;
         this._colorAgainst = colorAgainst;
      }
   }
}
