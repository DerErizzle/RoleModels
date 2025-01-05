package jackboxgames.rolemodels.widgets.postgame
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.widgets.BiscuitWidget;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.MovieClipShower;
   import jackboxgames.utils.Nullable;
   
   public class EatingMouthWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _isAnimating:Boolean;
      
      private var _allBiscuitsFed:Boolean;
      
      private var _biscuits:Array;
      
      private var _lastBiscuitCount:int;
      
      public function EatingMouthWidget(mc:MovieClip)
      {
         var biscuitMCs:Array;
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._isAnimating = false;
         biscuitMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"biscuit");
         this._biscuits = biscuitMCs.map(function(biscuitMC:MovieClip, ... args):BiscuitWidget
         {
            return new BiscuitWidget(biscuitMC);
         });
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.reset(this._biscuits);
         this._isAnimating = false;
      }
      
      public function setup() : void
      {
         this._biscuits.forEach(function(bw:BiscuitWidget, ... args):void
         {
            bw.setup();
         });
         this._lastBiscuitCount = 0;
      }
      
      private function _getAvailableBiscuits() : Array
      {
         return this._biscuits.filter(function(bw:BiscuitWidget, ... args):Boolean
         {
            return !bw.shower.isShown;
         });
      }
      
      public function chew(currentBiscuitCount:int, allBiscutsFed:Boolean, doneFn:Function) : void
      {
         var biscuitsToAnimate:Array;
         var biscuitDelta:int = currentBiscuitCount - this._lastBiscuitCount;
         this._lastBiscuitCount = currentBiscuitCount;
         biscuitsToAnimate = [];
         if(biscuitDelta > 0)
         {
            biscuitsToAnimate = biscuitsToAnimate.concat(this._getAvailableBiscuits().slice(0,biscuitDelta));
         }
         biscuitsToAnimate.forEach(function(bw:BiscuitWidget, ... args):void
         {
            bw.shower.setShown(true,Nullable.NULL_FUNCTION);
         });
         this._allBiscuitsFed = allBiscutsFed;
         if(this._isAnimating)
         {
            doneFn();
            return;
         }
         this._isAnimating = true;
         this._shower.doAnimation("Eat",function():void
         {
            JBGUtil.reset(_biscuits);
            if(_allBiscuitsFed)
            {
               _shower.doAnimation("Barf",function():void
               {
                  _isAnimating = false;
                  doneFn();
               });
            }
            else
            {
               _isAnimating = false;
               doneFn();
            }
         });
      }
      
      public function countdown(doneFn:Function) : void
      {
         if(this._mc.currentLabel == "Barf")
         {
            doneFn();
            return;
         }
         this._isAnimating = true;
         this._shower.doAnimation("Countdown",function():void
         {
            _isAnimating = false;
            doneFn();
         });
      }
      
      public function stopCountdown(doneFn:Function) : void
      {
         if(this._mc.currentLabel == "Barf")
         {
            doneFn();
            return;
         }
         this._isAnimating = false;
         this._shower.doAnimation("Idle",function():void
         {
            if(_allBiscuitsFed)
            {
               _shower.doAnimation("Barf",doneFn);
            }
            else
            {
               doneFn();
            }
         });
      }
   }
}
