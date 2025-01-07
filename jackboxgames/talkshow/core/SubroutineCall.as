package jackboxgames.talkshow.core
{
   internal class SubroutineCall
   {
      private var _callCell:CallCell;
      
      private var _l:Object;
      
      public function SubroutineCall(callCell:CallCell, l:Object = null)
      {
         super();
         this._l = l == null ? new Object() : l;
         this._callCell = callCell;
      }
      
      public function toString() : String
      {
         return "[SubroutineCall cell=" + this.callCell + "]";
      }
      
      internal function get cellAfterReturn() : ICell
      {
         return this._callCell.child;
      }
      
      internal function get l() : Object
      {
         return this._l;
      }
      
      internal function get callCell() : CallCell
      {
         return this._callCell;
      }
   }
}

