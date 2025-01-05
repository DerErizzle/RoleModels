package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.data.RoleData;
   import jackboxgames.rolemodels.data.TagData;
   
   public class RoleWithPower
   {
       
      
      private var _role:RoleData;
      
      private var _tag:TagData;
      
      private var _power:String;
      
      public function RoleWithPower(role:RoleData, tag:TagData, power:String)
      {
         super();
         this._role = role;
         this._tag = tag;
         this._power = power;
      }
      
      public function get role() : RoleData
      {
         return this._role;
      }
      
      public function get tag() : TagData
      {
         return this._tag;
      }
      
      public function get power() : String
      {
         return this._power;
      }
   }
}
