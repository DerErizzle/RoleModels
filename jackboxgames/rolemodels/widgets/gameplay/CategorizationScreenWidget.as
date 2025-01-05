package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class CategorizationScreenWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _grid:MovieClip;
      
      private var _amoebas:CategorizationAmoebasWidget;
      
      private var _instructions:MovieClip;
      
      public function CategorizationScreenWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._grid = this._mc.grid;
         this._instructions = this._mc.instructionsTF;
         this._amoebas = new CategorizationAmoebasWidget(this._mc.amoebas);
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._grid,"Park");
         JBGUtil.gotoFrame(this._instructions,"Park");
         this._amoebas.reset();
      }
      
      public function setup(categoryText:String, chosenCategoryIndex:int) : void
      {
         JBGUtil.gotoFrame(this._grid,"Loop");
         this._amoebas.setup(categoryText,chosenCategoryIndex);
      }
      
      public function showInstructions(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._instructions,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
   }
}
