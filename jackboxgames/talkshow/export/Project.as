package jackboxgames.talkshow.export
{
   import jackboxgames.talkshow.api.IActionPackageRef;
   import jackboxgames.talkshow.api.IFlowchart;
   
   public class Project
   {
       
      
      private var _id:int;
      
      private var _name:String;
      
      private var _f:Array;
      
      private var _a:Array;
      
      public function Project(exp:Export, id:uint, name:String)
      {
         super();
         this._id = id;
         this._name = name;
         this._f = new Array();
         this._a = new Array();
      }
      
      public static function createID(internalID:uint) : String
      {
         return "P_" + internalID;
      }
      
      public function toString() : String
      {
         return "[Project " + this._name + "]";
      }
      
      internal function addFlowchart(f:IFlowchart) : void
      {
         this._f.push(f);
      }
      
      internal function addActionPackage(a:IActionPackageRef) : void
      {
         this._a.push(a);
      }
      
      internal function getFlowchart(name:String) : IFlowchart
      {
         var f:Object = null;
         for each(f in this._f)
         {
            if((f as IFlowchart).flowchartName == name)
            {
               return f as IFlowchart;
            }
         }
         return null;
      }
      
      internal function getActionPackage(name:String) : IActionPackageRef
      {
         var a:Object = null;
         for each(a in this._a)
         {
            if((a as IActionPackageRef).name == name)
            {
               return a as IActionPackageRef;
            }
         }
         return null;
      }
      
      public function getName() : String
      {
         return this._name;
      }
      
      public function getId() : int
      {
         return this._id;
      }
   }
}
