package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionPackageRef;
   import jackboxgames.talkshow.api.IParameter;
   
   public class Action implements IAction
   {
       
      
      private var _id:int;
      
      private var _name:String;
      
      private var _pkg:ActionPackageRef;
      
      private var _params:Array;
      
      private var _primaryMediaParamIdx:int;
      
      private var _indices:Object;
      
      public function Action(id:int, name:String, pkg:ActionPackageRef)
      {
         super();
         this._id = id;
         this._name = name;
         this._pkg = pkg;
         this._params = new Array();
         this._primaryMediaParamIdx = -1;
         this._indices = {};
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get actionPackage() : IActionPackageRef
      {
         return this._pkg;
      }
      
      public function addParameter(p:Parameter) : void
      {
         this._indices[p.name] = this._params.length;
         this._params.push(p);
      }
      
      public function getParameter(index:uint) : IParameter
      {
         return this._params[index];
      }
      
      public function getParameterIdxByName(paramName:String) : int
      {
         return this._indices[paramName];
      }
      
      public function getParameterIdx(p:IParameter) : int
      {
         for(var i:int = 0; i < this._params.length; i++)
         {
            if(this._params[i] == p)
            {
               return i;
            }
         }
         return -1;
      }
      
      public function getPrimaryMediaParameterIdx() : int
      {
         var p:int = 0;
         if(this._primaryMediaParamIdx == -2)
         {
            return -1;
         }
         if(this._primaryMediaParamIdx == -1)
         {
            for(p = 0; p < this._params.length; p++)
            {
               if(Boolean(this._params[p].isMedia()))
               {
                  this._primaryMediaParamIdx = p;
                  return p;
               }
            }
            this._primaryMediaParamIdx = -2;
            return -1;
         }
         return this._primaryMediaParamIdx;
      }
   }
}
