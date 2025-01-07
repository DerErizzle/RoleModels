package jackboxgames.thewheel.widgets
{
   import jackboxgames.utils.Duration;
   
   public class NullPlayerWidget implements IPlayerWidgetBehaviors
   {
      public function NullPlayerWidget()
      {
         super();
      }
      
      public function setScoreShown(val:Boolean) : void
      {
      }
      
      public function updateScore(rackUpTime:Duration) : void
      {
      }
      
      public function setBestPerformanceLabel(key:String) : void
      {
      }
      
      public function setResultViewMode(mode:String) : void
      {
      }
      
      public function setResultsShown(val:Boolean) : void
      {
      }
      
      public function setResultsHighlighted(val:Boolean) : void
      {
      }
      
      public function setBestPerformanceShown(val:Boolean) : void
      {
      }
      
      public function setUniqueResultsShown(val:Boolean) : void
      {
      }
      
      public function updateResult(numCorrect:int) : void
      {
      }
      
      public function updateResultWithDuration(d:Duration) : void
      {
      }
      
      public function updateUniqueResult(numUnique:int) : void
      {
      }
      
      public function setAnswering(val:Boolean) : void
      {
      }
      
      public function setHighlighted(val:Boolean) : void
      {
      }
      
      public function setDimmed(val:Boolean) : void
      {
      }
      
      public function setSelectable(val:Boolean) : void
      {
      }
      
      public function setSelected(val:Boolean) : void
      {
      }
      
      public function setFrozen(val:Boolean) : void
      {
      }
      
      public function setSlicesShown(val:Boolean) : void
      {
      }
      
      public function addSlices(numSlices:int) : void
      {
      }
      
      public function setBonusSliceShown(val:Boolean) : void
      {
      }
      
      public function setupScoreReveal() : void
      {
      }
      
      public function setMultipliersShown(val:Boolean) : void
      {
      }
      
      public function showPendingPoints(includeMultipliers:Boolean, skipIfNoMultipliers:Boolean) : void
      {
      }
      
      public function showCurrentScore() : void
      {
      }
      
      public function get hasMultiplier() : Boolean
      {
         return false;
      }
      
      public function updateWinnerMode() : void
      {
      }
      
      public function showTemporaryAnswer(answer:String) : void
      {
      }
   }
}

