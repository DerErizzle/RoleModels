package jackboxgames.talkshow.cells
{
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.utils.TSUtil;
   
   public class StopListeningCell extends AbstractCell
   {
       
      
      private var _childId:uint;
      
      public function StopListeningCell(f:IFlowchart, id:uint, target:String, childId:uint)
      {
         super(f,id,target,Constants.CELL_STOP_LISTENING);
         this._childId = childId;
      }
      
      override public function toString() : String
      {
         return "[StopListeningCell id=" + _id + "]";
      }
      
      override public function start() : void
      {
         super.start();
         TSUtil.cancelSafeInputs();
         PlaybackEngine.getInstance().inputManager.stopListening();
         if(this._childId == 0)
         {
            return;
         }
         _f.getCellByID(this._childId).start();
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(data == null || data.level == 0 || !data.add(this) || this._childId == 0)
         {
            return;
         }
         _f.getCellByID(this._childId).load(data);
      }
   }
}
