package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class BiscuitPileWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _biscuitWidgets:Array;
      
      private var _activeBiscuitWidgets:Array;
      
      private var _scoreTF:ExtendableTextField;
      
      public function BiscuitPileWidget(mc:MovieClip)
      {
         var biscuitMCs:Array;
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         biscuitMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc.biscuits,"biscuit");
         this._biscuitWidgets = biscuitMCs.map(function(biscuitMC:MovieClip, ... args):BiscuitWidget
         {
            return new BiscuitWidget(biscuitMC);
         });
         this._scoreTF = new ExtendableTextField(this._mc.tf,[],[PostEffectFactory.createDynamicResizerEffect(),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         JBGUtil.reset(this._biscuitWidgets);
         this._activeBiscuitWidgets = [];
      }
      
      public function setup(score:int) : void
      {
         var numBiscuitWidgets:int = 0;
         this._scoreTF.text = String(score);
         if(score > 14)
         {
            numBiscuitWidgets = 15;
            JBGUtil.gotoFrame(this._mc.biscuits,"Biscuits15OrMore");
         }
         else
         {
            numBiscuitWidgets = score;
            JBGUtil.gotoFrame(this._mc.biscuits,"Biscuits" + String(numBiscuitWidgets));
         }
         for(var i:int = 0; i < numBiscuitWidgets; i++)
         {
            this._biscuitWidgets[i].setup();
            this._activeBiscuitWidgets.push(this._biscuitWidgets[i]);
         }
      }
      
      public function showPile(doneFn:Function) : void
      {
         var biscuitShowers:Array = this._activeBiscuitWidgets.map(function(bw:BiscuitWidget, ... args):MovieClipShower
         {
            return bw.shower;
         });
         MovieClipShower.setMultiple(biscuitShowers,true,Duration.fromMs(30),doneFn);
      }
   }
}
