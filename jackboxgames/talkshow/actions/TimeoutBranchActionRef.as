package jackboxgames.talkshow.actions
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.timing.Timing;
   
   public class TimeoutBranchActionRef extends ActionRef
   {
       
      
      private var TIMING_BRANCH_ID:int = -99998;
      
      protected var _tCell:ICell;
      
      public function TimeoutBranchActionRef(targetCell:ICell, timing:Timing)
      {
         super(new Action(this.TIMING_BRANCH_ID,"TimingBranch",null),timing);
         this._tCell = targetCell;
      }
      
      override public function toString() : String
      {
         return "[TimeoutBranchActionRef nextCell=" + this._tCell + " timing=" + _timing + "]";
      }
      
      override public function start(isPrimary:Boolean = false) : void
      {
         if(this._tCell != null)
         {
            PlaybackEngine.getInstance().startNextManager.reset();
            PlaybackEngine.getInstance().inputManager.enterTimeoutMode();
            Logger.info("Timeout: " + this,"Cell");
            this._tCell.start();
         }
      }
      
      override public function load(data:ILoadData = null) : void
      {
      }
      
      override public function isLoaded() : Boolean
      {
         return true;
      }
   }
}
