package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class ReturnCell extends AbstractCell
   {
       
      
      private var _returnValue:String;
      
      public function ReturnCell(f:IFlowchart, id:uint, target:String, returnValue:String)
      {
         super(f,id,target,Constants.CELL_RETURN);
         this._returnValue = returnValue;
      }
      
      override public function toString() : String
      {
         return "[ReturnCell id=" + flowchart.flowchartName + ":" + _id + "(" + flowchart.id + ":" + _id + ")]";
      }
      
      override public function start() : void
      {
         super.start();
         flowchart.getParentExport().onReturnFromFlowchart(flowchart);
         var cell:CallCell = PlaybackEngine.getInstance().callStack.currentCallCell;
         if(cell == null)
         {
            Logger.error("ReturnCell: Call stack is empty.  I\'ve got nowhere else to go!");
            return;
         }
         var returnValue:* = VariableUtil.replaceVariables(this._returnValue);
         PlaybackEngine.getInstance().callStack.pop(true);
         VariableUtil.setVariableValue(cell.returnVariable,returnValue);
         if(cell.child != null)
         {
            cell.child.start();
         }
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(data == null || !data.add(this) || data.level == 0)
         {
            return;
         }
         var l:Object = PlaybackEngine.getInstance().callStack.l;
         var callCell:CallCell = PlaybackEngine.getInstance().callStack.pop();
         if(callCell != null && callCell.child != null)
         {
            callCell.child.load(data);
         }
         if(callCell != null)
         {
            PlaybackEngine.getInstance().callStack.push(callCell,false,l);
         }
      }
   }
}
