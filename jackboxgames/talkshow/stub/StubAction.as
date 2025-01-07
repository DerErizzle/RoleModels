package jackboxgames.talkshow.stub
{
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionPackageRef;
   import jackboxgames.talkshow.api.IParameter;
   
   public class StubAction implements IAction
   {
      private var _actionName:String;
      
      public function StubAction(actionName:String)
      {
         super();
         this._actionName = actionName;
      }
      
      public function get id() : int
      {
         return 0;
      }
      
      public function get name() : String
      {
         return this._actionName;
      }
      
      public function get actionPackage() : IActionPackageRef
      {
         return null;
      }
      
      public function getParameter(index:uint) : IParameter
      {
         return null;
      }
      
      public function getPrimaryMediaParameterIdx() : int
      {
         return 0;
      }
      
      public function getParameterIdx(p:IParameter) : int
      {
         return 0;
      }
      
      public function getParameterIdxByName(paramName:String) : int
      {
         return 0;
      }
      
      public function get numParameters() : int
      {
         return 0;
      }
   }
}

