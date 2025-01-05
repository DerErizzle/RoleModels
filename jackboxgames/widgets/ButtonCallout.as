package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class ButtonCallout
   {
       
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      private var _button:PlatformButton;
      
      public function ButtonCallout(mc:MovieClip, buttons:Array, forceSkin:String = null)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._tf = new ExtendableTextField(mc.container,[],[]);
         this._button = new PlatformButton(mc,mc.container.button,buttons,true,true,true,forceSkin);
      }
      
      public function dispose() : void
      {
         if(!this._shower)
         {
            return;
         }
         this._shower.dispose();
         this._shower = null;
         this._tf.dispose();
         this._tf = null;
         this._button.dispose();
         this._button = null;
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
      
      public function setShown(shown:Boolean, text:String = null, doneFn:Function = null) : void
      {
         if(Boolean(text))
         {
            this._tf.text = LocalizationManager.instance.getText(text);
         }
         this._shower.setShown(shown,doneFn != null ? doneFn : Nullable.NULL_FUNCTION);
      }
   }
}
