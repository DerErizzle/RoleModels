package jackboxgames.thewheel.gameplay
{
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.utils.*;
   
   public class TriviaTypeActionPackage extends JBGActionPackage
   {
      private static var ACTION_PACKAGES:Dictionary = new Dictionary();
      
      public function TriviaTypeActionPackage(apRef:IActionPackageRef)
      {
         ACTION_PACKAGES[this._triviaType.id] = this;
         super(apRef);
      }
      
      public static function GET_ACTION_PACKAGE(type:TriviaType) : TriviaTypeActionPackage
      {
         return ACTION_PACKAGES[type.id];
      }
      
      override protected function get _sourceURL() : String
      {
         return null;
      }
      
      public function load() : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
         });
      }
      
      override protected function _createReferences() : void
      {
         Assert.assert(this._linkage != null);
         var c:Class = Class(getDefinitionByName(this._linkage));
         _mc = new c();
      }
      
      override protected function _disposeOfReferences() : void
      {
         _mc = null;
      }
      
      protected function _onLoaded() : void
      {
         Assert.assert(this._triviaType != null);
         _ts.g[this._triviaType.id] = this;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(_mc,"Park");
         this._doReset();
      }
      
      protected function get _linkage() : String
      {
         return null;
      }
      
      protected function get _triviaType() : TriviaType
      {
         return null;
      }
      
      public function setup() : void
      {
      }
      
      protected function _doReset() : void
      {
      }
      
      public function getPerformanceForPlayer(p:Player) : int
      {
         return 0;
      }
      
      public function getPlayersEligibleForBonusSlice() : Array
      {
         return [];
      }
      
      public function doBehavior(behavior:String, doneFn:Function) : void
      {
         doneFn();
      }
   }
}

