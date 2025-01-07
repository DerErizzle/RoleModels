package jackboxgames.talkshow.stub
{
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.talkshow.api.IMediaParamValue;
   
   public class StubActionRef implements IActionRef
   {
      private var _actionName:String;
      
      public function StubActionRef(actionName:String)
      {
         super();
         this._actionName = actionName;
      }
      
      public function get action() : IAction
      {
         return new StubAction(this._actionName);
      }
      
      public function get isPrimary() : Boolean
      {
         return true;
      }
      
      public function getValueByIndex(paramIndex:int) : *
      {
         return 0;
      }
      
      public function getValueByName(paramName:String) : *
      {
         return 0;
      }
      
      public function getPrimaryMediaParamValue() : IMediaParamValue
      {
         return null;
      }
      
      public function start(isPrimary:Boolean = false) : void
      {
      }
      
      public function end() : void
      {
      }
   }
}

