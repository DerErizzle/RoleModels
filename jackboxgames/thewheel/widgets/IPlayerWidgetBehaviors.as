package jackboxgames.thewheel.widgets
{
   import jackboxgames.utils.Duration;
   
   public interface IPlayerWidgetBehaviors
   {
      function setScoreShown(param1:Boolean) : void;
      
      function updateScore(param1:Duration) : void;
      
      function setResultViewMode(param1:String) : void;
      
      function setResultsShown(param1:Boolean) : void;
      
      function setResultsHighlighted(param1:Boolean) : void;
      
      function setBestPerformanceLabel(param1:String) : void;
      
      function setBestPerformanceShown(param1:Boolean) : void;
      
      function setUniqueResultsShown(param1:Boolean) : void;
      
      function updateResult(param1:int) : void;
      
      function updateResultWithDuration(param1:Duration) : void;
      
      function updateUniqueResult(param1:int) : void;
      
      function setAnswering(param1:Boolean) : void;
      
      function setHighlighted(param1:Boolean) : void;
      
      function setDimmed(param1:Boolean) : void;
      
      function setSelectable(param1:Boolean) : void;
      
      function setSelected(param1:Boolean) : void;
      
      function setFrozen(param1:Boolean) : void;
      
      function setSlicesShown(param1:Boolean) : void;
      
      function addSlices(param1:int) : void;
      
      function setBonusSliceShown(param1:Boolean) : void;
      
      function setupScoreReveal() : void;
      
      function setMultipliersShown(param1:Boolean) : void;
      
      function showPendingPoints(param1:Boolean, param2:Boolean) : void;
      
      function showCurrentScore() : void;
      
      function get hasMultiplier() : Boolean;
      
      function updateWinnerMode() : void;
      
      function showTemporaryAnswer(param1:String) : void;
   }
}

