package jackboxgames.talkshow.api.events
{
   import flash.events.Event;
   import jackboxgames.talkshow.api.IBranch;
   
   public class BranchEvent extends Event
   {
      public static const BRANCH_STARTED:String = "branchStarted";
      
      private var _branch:IBranch;
      
      private var _input:String;
      
      private var _raw:String;
      
      public function BranchEvent(type:String, b:IBranch = null, i:String = null, r:String = null)
      {
         super(type,false,false);
         this._branch = b;
         this._input = i;
         this._raw = r;
      }
      
      public function get branch() : IBranch
      {
         return this._branch;
      }
      
      public function get input() : String
      {
         return this._input;
      }
      
      public function get raw() : String
      {
         return this._raw;
      }
   }
}

