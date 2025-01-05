package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class MinigameDecorationWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _blueDecorations:Array;
      
      private var _pinkDecorations:Array;
      
      private var _redDecorations:Array;
      
      public function MinigameDecorationWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._blueDecorations = JBGUtil.getPropertiesOfNameInOrder(this._mc.decoBlue,"dna").map(function(helixMC:MovieClip, ... args):MovieClipShower
         {
            return new MovieClipShower(helixMC);
         });
         this._pinkDecorations = JBGUtil.getPropertiesOfNameInOrder(this._mc.decoPink,"atom").map(function(atomMC:MovieClip, ... args):MovieClipShower
         {
            return new MovieClipShower(atomMC);
         });
         this._redDecorations = JBGUtil.getPropertiesOfNameInOrder(this._mc.decoRed,"molecule").map(function(moleculeMC:MovieClip, ... args):MovieClipShower
         {
            return new MovieClipShower(moleculeMC);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._redDecorations);
         JBGUtil.reset(this._blueDecorations);
         JBGUtil.reset(this._pinkDecorations);
      }
      
      public function setShown(isShown:Boolean, delay:Duration, backgroundState:String, doneFn:Function) : void
      {
         var showers:Array = null;
         var c:Counter = null;
         switch(backgroundState)
         {
            case BackgroundWidget.BACKGROUND_STATES.blue:
               showers = this._blueDecorations;
               break;
            case BackgroundWidget.BACKGROUND_STATES.pink:
               showers = this._pinkDecorations;
               break;
            case BackgroundWidget.BACKGROUND_STATES.red:
               showers = this._redDecorations;
               break;
            default:
               return;
         }
         JBGUtil.gotoFrame(this._mc,backgroundState);
         c = new Counter(showers.length,doneFn);
         showers.forEach(function(decorationShower:MovieClipShower, index:int, ... args):void
         {
            JBGUtil.runFunctionAfter(function():void
            {
               decorationShower.setShown(isShown,function():void
               {
                  if(isShown)
                  {
                     decorationShower.doAnimation("Loop",Nullable.NULL_FUNCTION);
                  }
                  c.tick();
               });
            },Duration.scale(delay,index));
         });
      }
   }
}
