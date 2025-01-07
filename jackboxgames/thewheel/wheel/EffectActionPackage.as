package jackboxgames.thewheel.wheel
{
   import jackboxgames.talkshow.actions.JBGActionPackage;
   import jackboxgames.talkshow.api.IActionPackageRef;
   
   public class EffectActionPackage extends JBGActionPackage
   {
      protected var _param:DoSpinResultParam;
      
      protected var _spinResult:SpinResult;
      
      public function EffectActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      protected function get _linkage() : String
      {
         return null;
      }
      
      protected function get _propertyName() : String
      {
         return null;
      }
      
      override protected function get _sourceURL() : String
      {
         return null;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
         this._spinResult = spinResult;
         this._doSetup();
      }
      
      public function reset() : void
      {
         this._doReset();
         this._param = null;
         this._spinResult = null;
      }
      
      protected function _doSetup() : void
      {
      }
      
      protected function _doReset() : void
      {
      }
   }
}

