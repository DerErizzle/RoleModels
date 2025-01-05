package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.data.RoleData;
   
   public class RolePairAndTags
   {
       
      
      private var _role1:RoleData;
      
      private var _role2:RoleData;
      
      private var _tags:Array;
      
      public function RolePairAndTags(role1:RoleData, role2:RoleData, tags:Array)
      {
         super();
         this._role1 = role1;
         this._role2 = role2;
         this._tags = tags;
      }
      
      public function get role1() : RoleData
      {
         return this._role1;
      }
      
      public function get role2() : RoleData
      {
         return this._role2;
      }
      
      public function get tags() : Array
      {
         return this._tags;
      }
      
      public function set tags(val:Array) : void
      {
         this._tags = val;
      }
   }
}
