package jackboxgames.talkshow.cells
{
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   
   public class CodeCell extends AbstractCell
   {
       
      
      private var _childId:uint;
      
      public function CodeCell(f:IFlowchart, id:uint, target:String, childId:uint)
      {
         super(f,id,target,Constants.CELL_CODE);
         this._childId = childId;
      }
      
      override public function toString() : String
      {
         return "[CodeCell id=" + _id + "]";
      }
      
      override public function start() : void
      {
         super.start();
         _f.evalCell(_id);
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
         data.volatile = true;
         _f.getCellByID(this._childId).load(data);
      }
   }
}
