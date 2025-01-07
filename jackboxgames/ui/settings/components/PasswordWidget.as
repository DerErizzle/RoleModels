package jackboxgames.ui.settings.components
{
   import flash.display.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class PasswordWidget
   {
      private var _shower:MovieClipShower;
      
      private var _labelTf:ExtendableTextField;
      
      private var _passwordTf:ExtendableTextField;
      
      public function PasswordWidget(mc:MovieClip, label:String)
      {
         super();
         this._shower = new MovieClipShower(mc);
         this._passwordTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.code);
         this._labelTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.label);
         this._labelTf.text = label;
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get label() : ExtendableTextField
      {
         return this._labelTf;
      }
      
      public function get password() : ExtendableTextField
      {
         return this._passwordTf;
      }
      
      public function dispose() : void
      {
         if(this._shower == null)
         {
            return;
         }
         this._shower.dispose();
         this._shower = null;
         this._passwordTf = null;
         this._labelTf = null;
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
   }
}

