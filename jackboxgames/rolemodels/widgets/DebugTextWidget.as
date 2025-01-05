package jackboxgames.rolemodels.widgets
{
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class DebugTextWidget
   {
      
      private static var _instance:DebugTextWidget;
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      private var _text:String;
      
      private var _isActive:Boolean;
      
      public function DebugTextWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._tf = new ExtendableTextField(this._mc.content,[],[PostEffectFactory.createDynamicResizerEffect(2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         if(EnvUtil.isDebug())
         {
            StageRef.addEventListener(KeyboardEvent.KEY_DOWN,this._onKeyboard);
         }
         this._text = "";
         this._isActive = false;
         if(!_instance)
         {
            _instance = this;
         }
      }
      
      public static function get sharedInstance() : DebugTextWidget
      {
         return _instance;
      }
      
      public function reset() : void
      {
         this.text = null;
      }
      
      public function set text(val:String) : void
      {
         if(!val)
         {
            val = "";
         }
         this._text = val;
         this._tf.text = this._text;
         this._updateShown();
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      private function _updateShown() : void
      {
         this._shower.setShown(this._text != "" && this._isActive,Nullable.NULL_FUNCTION);
      }
      
      private function _onKeyboard(evt:KeyboardEvent) : void
      {
         if(evt.keyCode == Keyboard.P)
         {
            this._isActive = !this._isActive;
            this._updateShown();
         }
      }
   }
}
