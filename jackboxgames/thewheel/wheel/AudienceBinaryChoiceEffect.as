package jackboxgames.thewheel.wheel
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.localizy.LocalizationManager;
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.utils.LocalizationUtil;
   import jackboxgames.utils.PromiseUtil;
   
   public class AudienceBinaryChoiceEffect implements ISliceEffect
   {
      protected var _param:DoSpinResultParam;
      
      protected var _spinResult:SpinResult;
      
      private var _chosenOption:String;
      
      private var _ratioForA:Number;
      
      private var _ratioForB:Number;
      
      public function AudienceBinaryChoiceEffect()
      {
         super();
         GameState.instance.audioRegistrationStack.play("wheelSliceFlip");
      }
      
      public function get prompt() : String
      {
         return LocalizationManager.instance.getText(this._promptKey);
      }
      
      public function get controllerPrompt() : String
      {
         return "[name]" + LocalizationManager.instance.getText(this._nameKey) + "[/name]" + LocalizationManager.instance.getText(this._promptKey);
      }
      
      public function get optionA() : String
      {
         return LocalizationUtil.getPrintfText(this._optionAKey);
      }
      
      public function get optionB() : String
      {
         return LocalizationUtil.getPrintfText(this._optionBKey);
      }
      
      public function get chosenOption() : String
      {
         return this._chosenOption;
      }
      
      public function get ratioForA() : Number
      {
         return this._ratioForA;
      }
      
      public function get ratioForB() : Number
      {
         return this._ratioForB;
      }
      
      public function get description() : String
      {
         return "";
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
         this._spinResult = spinResult;
         this._doSetup();
      }
      
      public function prepareForEvaluation(votesForA:int, votesForB:int) : void
      {
         var total:int = votesForA + votesForB;
         if(total > 0)
         {
            this._chosenOption = votesForA >= votesForB ? GameConstants.OPTION_A : GameConstants.OPTION_B;
            this._ratioForA = Number(votesForA) / total;
            this._ratioForB = Number(votesForB) / total;
         }
         else
         {
            this._chosenOption = GameConstants.OPTION_NONE;
            this._ratioForA = 0;
            this._ratioForB = 0;
         }
      }
      
      public function evaluate() : Promise
      {
         if(this._chosenOption == GameConstants.OPTION_A)
         {
            return this._evaluateOptionA();
         }
         return this._evaluateOptionB();
      }
      
      protected function get _nameKey() : String
      {
         return null;
      }
      
      protected function get _promptKey() : String
      {
         return null;
      }
      
      protected function get _optionAKey() : String
      {
         return null;
      }
      
      protected function get _optionBKey() : String
      {
         return null;
      }
      
      protected function _doSetup() : void
      {
      }
      
      protected function _evaluateOptionA() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
      
      protected function _evaluateOptionB() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

