package jackboxgames.ecast.messages
{
   public class Request
   {
      private var _seq:int;
      
      private var _opcode:String;
      
      private var _params:Object;
      
      public function Request(seq:int, opcode:String, params:Object)
      {
         super();
         this._seq = seq;
         this._opcode = opcode;
         this._params = params;
      }
      
      public function get seq() : int
      {
         return this._seq;
      }
      
      public function get opcode() : String
      {
         return this._opcode;
      }
      
      public function get params() : Object
      {
         return this._params;
      }
   }
}

