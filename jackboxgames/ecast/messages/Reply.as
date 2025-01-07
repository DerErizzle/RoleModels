package jackboxgames.ecast.messages
{
   public class Reply
   {
      private var _pc:int;
      
      private var _re:int;
      
      private var _opcode:String;
      
      private var _result:Object;
      
      public function Reply(pc:int, re:int, opcode:String, result:Object)
      {
         super();
         this._pc = pc;
         this._re = re;
         this._opcode = opcode;
         this._result = result;
      }
      
      public function get pc() : int
      {
         return this._pc;
      }
      
      public function get re() : int
      {
         return this._re;
      }
      
      public function get opcode() : String
      {
         return this._opcode;
      }
      
      public function get result() : Object
      {
         return this._result;
      }
   }
}

