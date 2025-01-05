package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class BiscuitLineupWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _biscuitWidgets:Array;
      
      private var _activeBiscuitWidgets:Array;
      
      public function BiscuitLineupWidget(mc:MovieClip)
      {
         var biscuitMCs:Array;
         super();
         this._mc = mc;
         biscuitMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"biscuit");
         this._biscuitWidgets = biscuitMCs.map(function(biscuitMC:MovieClip, ... args):BiscuitWidget
         {
            return new BiscuitWidget(biscuitMC);
         });
         this._activeBiscuitWidgets = [];
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._biscuitWidgets);
         this._activeBiscuitWidgets = [];
      }
      
      public function doScoreChange(diff:int, doneFn:Function) : void
      {
         var numActiveBiscuits:int;
         var i:int;
         var showers:Array = null;
         this.reset();
         numActiveBiscuits = NumberUtil.clamp(Number(diff),0,6);
         JBGUtil.gotoFrame(this._mc,"BiscuitsAre" + numActiveBiscuits);
         for(i = 0; i < numActiveBiscuits; i++)
         {
            this._biscuitWidgets[i].setup();
            this._activeBiscuitWidgets.push(this._biscuitWidgets[i]);
         }
         showers = this._activeBiscuitWidgets.map(function(widget:BiscuitWidget, ... args):MovieClipShower
         {
            return widget.shower;
         });
         MovieClipShower.setMultiple(showers,true,Duration.fromMs(30),function():void
         {
            MovieClipShower.setMultiple(showers,false,Duration.fromMs(30),doneFn);
         });
      }
   }
}
