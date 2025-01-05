package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class TextFieldShower
   {
       
      
      private var _shower:MovieClipShower;
      
      private var _tf:*;
      
      private var _localized:Boolean;
      
      public function TextFieldShower(mc:MovieClip, localized:Boolean = true, lines:int = 1)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._tf = new ExtendableTextField(mc.container,[],[PostEffectFactory.createDynamicResizerEffect(lines),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._localized = localized;
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
      
      public function dispose() : void
      {
         if(!this._shower)
         {
            return;
         }
         JBGUtil.dispose([this._shower,this._tf]);
         this._shower = null;
         this._tf = null;
      }
      
      public function setShown(shown:Boolean, text:String = null, doneFn:Function = null) : void
      {
         if(Boolean(text))
         {
            this._tf.text = this._localized ? LocalizationManager.instance.getText(text) : text;
         }
         this._shower.setShown(shown,doneFn != null ? doneFn : Nullable.NULL_FUNCTION);
      }
   }
}
