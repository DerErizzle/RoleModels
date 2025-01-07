package jackboxgames.ecast.messages
{
   public class Notification
   {
      private var _pc:int;
      
      private var _opcode:String;
      
      private var _result:*;
      
      public function Notification(pc:int, opcode:String, result:*)
      {
         super();
         this._pc = pc;
         this._opcode = opcode;
         this._result = result;
      }
      
      public function get pc() : int
      {
         return this._pc;
      }
      
      public function get opcode() : String
      {
         return this._opcode;
      }
      
      public function get result() : *
      {
         return this._result;
      }
   }
}

