package jackboxgames.talkshow.input
{
   import jackboxgames.talkshow.api.IEngineAPI;
   
   public class TSInputHandler
   {
      private static var _instance:TSInputHandler;
      
      private var _ts:IEngineAPI;
      
      private var _currentModule:ITSInputModule;
      
      public function TSInputHandler(ts:IEngineAPI)
      {
         super();
         this._ts = ts;
         this.reset();
      }
      
      public static function initialize(ts:IEngineAPI) : void
      {
         _instance = new TSInputHandler(ts);
      }
      
      public static function get instance() : TSInputHandler
      {
         return _instance;
      }
      
      public function reset() : void
      {
         this._currentModule = new TSNoInput();
      }
      
      public function setupForAnyInput() : void
      {
         this._currentModule = new TSAnyInput();
      }
      
      public function setupForSingleInput() : void
      {
         this._currentModule = new TSSingleInput();
      }
      
      public function setupForMultiInput(requiredInput:Array, inputToSend:String) : void
      {
         this._currentModule = new TSMultiInput(requiredInput,inputToSend);
      }
      
      public function setupForNoInput() : void
      {
         this._currentModule = new TSNoInput();
      }
      
      public function setupForCustomInput(module:ITSInputModule) : void
      {
         this._currentModule = module;
      }
      
      public function input(input:String) : void
      {
         this._currentModule.input(input);
      }
   }
}

