package jackboxgames.talkshow.cells
{
   import jackboxgames.talkshow.api.Constants;
   
   public class InputBranch extends AbstractBranch
   {
      private var _input:String;
      
      private var _choiceNum:int;
      
      public function InputBranch(cell:InputCell, branchId:uint, targetId:int, type:uint, input:String, choiceNum:int = -1)
      {
         super(cell,branchId,targetId,type);
         this._input = input;
         this._choiceNum = choiceNum;
      }
      
      override public function toString() : String
      {
         return "[InputBranch target=" + _targetId + " input=" + this._input + " type=" + _type + "]";
      }
      
      override public function evaluate(x:*) : Boolean
      {
         if(_type == Constants.BR_NOMATCH)
         {
            return true;
         }
         if(_type == Constants.BR_MC || _type == Constants.BR_FIB)
         {
            return this.cleanInput(x) == this.cleanInput(this._input);
         }
         return false;
      }
      
      public function get input() : String
      {
         return this._input;
      }
      
      private function cleanInput(s:String) : String
      {
         return s.replace("[^\\w\\.@-_ ]","~");
      }
      
      public function get choiceNum() : int
      {
         return this._choiceNum;
      }
   }
}

