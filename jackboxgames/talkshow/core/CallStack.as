package jackboxgames.talkshow.core
{
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.ISubroutine;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.cells.CallCell;
   
   public class CallStack
   {
      private var _list:Array;
      
      public function CallStack(engine:PlaybackEngine)
      {
         super();
         this._list = new Array();
         engine.addEventListener(CellEvent.CELL_JUMPED,this.handleCellJump);
      }
      
      public function push(callCell:CallCell, commit:Boolean = false, l:Object = null) : void
      {
         var call:SubroutineCall = new SubroutineCall(callCell,l);
         this._list.push(call);
         if(commit)
         {
            PlaybackEngine.getInstance().setLocalVariableObject(call.l);
            callCell.subroutine.setLocalVariableObject(PlaybackEngine.getInstance().l);
         }
      }
      
      public function pop(commit:Boolean = false) : CallCell
      {
         if(this._list == null || this._list.length == 0)
         {
            return null;
         }
         var call:SubroutineCall = this._list.pop() as SubroutineCall;
         if(commit)
         {
            PlaybackEngine.getInstance().setLocalVariableObject(this.l);
            if(this._list.length > 0)
            {
               if(Boolean(this.currentCallCell.subroutine))
               {
                  this.currentCallCell.subroutine.setLocalVariableObject(PlaybackEngine.getInstance().l);
               }
            }
         }
         return call.callCell;
      }
      
      public function get bottomCell() : CallCell
      {
         if(this._list == null || this._list.length == 0)
         {
            return null;
         }
         return (this._list[0] as SubroutineCall).callCell;
      }
      
      public function get currentCallCell() : CallCell
      {
         if(this._list == null || this._list.length == 0)
         {
            return null;
         }
         return (this._list[this._list.length - 1] as SubroutineCall).callCell;
      }
      
      public function get cellAfterReturn() : ICell
      {
         if(this.currentCallCell == null)
         {
            return null;
         }
         return this.currentCallCell.child;
      }
      
      public function get l() : Object
      {
         if(this._list.length == 0)
         {
            return null;
         }
         return this._list[this._list.length - 1].l;
      }
      
      private function handleCellJump(evt:CellEvent) : void
      {
         var current:CallCell = this.currentCallCell;
         if(current != null && evt.cell.flowchart is ISubroutine && evt.cell.flowchart.id == current.subroutine.id)
         {
            return;
         }
         while(this._list.length > 0)
         {
            this.pop(true);
         }
      }
   }
}

