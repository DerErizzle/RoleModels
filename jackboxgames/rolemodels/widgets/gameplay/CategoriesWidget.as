package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class CategoriesWidget
   {
       
      
      private var _containerShower:MovieClipShower;
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _beakerWidgets:Array;
      
      private var _bubbleWidgets:Array;
      
      public function CategoriesWidget(mc:MovieClip)
      {
         var bubbleMCs:Array;
         var numBeakerTypes:int;
         var i:int;
         var beakerMCs:Array;
         var beakerTypeIndicies:Array = null;
         super();
         this._containerShower = new MovieClipShower(mc);
         this._mc = mc.categorySelection;
         bubbleMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc.categories,"bubble");
         this._bubbleWidgets = bubbleMCs.map(function(bubbleMC:MovieClip, i:int, ... args):CategoryBubbleWidget
         {
            return new CategoryBubbleWidget(bubbleMC,i);
         });
         numBeakerTypes = int(MovieClipUtil.getFramesThatStartWith(this._mc.beakers0,"Beaker").length);
         beakerTypeIndicies = [];
         for(i = 0; i < numBeakerTypes; i++)
         {
            beakerTypeIndicies.push(i);
         }
         beakerMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"beakers");
         this._beakerWidgets = beakerMCs.map(function(beakerMC:MovieClip, i:int, ... args):BeakerWidget
         {
            return new BeakerWidget(beakerMC,i,ArrayUtil.getRandomElement(beakerTypeIndicies,true));
         });
         this._tf = new ExtendableTextField(this._mc.voteTF,[],[PostEffectFactory.createDynamicResizerEffect(1,72),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._containerShower;
      }
      
      public function reset() : void
      {
         this._containerShower.reset();
         JBGUtil.reset(this._beakerWidgets);
         JBGUtil.reset(this._bubbleWidgets);
      }
      
      public function setup(categoryObjects:Array) : void
      {
         var bw:BeakerWidget = null;
         for(var i:int = 0; i < GameConstants.NUMBER_OF_CATEGORY_OPTIONS; i++)
         {
            this._bubbleWidgets[i].setup(categoryObjects[i].category.toUpperCase());
         }
         for each(bw in this._beakerWidgets)
         {
            bw.setup();
         }
         this._tf.text = LocalizationUtil.getPrintfText("INITIAL_VOTE_CATEGORY_MAIN_SCREEN_PROMPT");
      }
      
      public function setVoteForCategoryShown(isShown:Boolean, player:Player, chosenIndex:int, doneFn:Function) : void
      {
         var bubbleWidget:CategoryBubbleWidget = null;
         for each(bubbleWidget in this._bubbleWidgets)
         {
            bubbleWidget.setVoteForCategoryShown(false,player,Nullable.NULL_FUNCTION);
         }
         this._bubbleWidgets[chosenIndex].setVoteForCategoryShown(isShown,player,doneFn);
      }
      
      public function showBubbles() : void
      {
         var cw:CategoryBubbleWidget = null;
         for each(cw in this._bubbleWidgets)
         {
            cw.doAnimation("Idle");
         }
      }
      
      public function disappearNonChosenBubbles(chosenIndex:int) : void
      {
         for(var i:int = 0; i < this._bubbleWidgets.length; i++)
         {
            if(i != chosenIndex)
            {
               this._bubbleWidgets[i].doAnimation("Disappear");
            }
         }
      }
      
      public function highlightChosenBubble(chosenIndex:int) : void
      {
         this._bubbleWidgets[chosenIndex].doAnimation("Chosen");
      }
      
      public function disappearChosen(categoryIndex:int) : void
      {
         this._bubbleWidgets[categoryIndex].disappearChosen();
      }
      
      public function drawLiquid(categoryIndex:int, doneFn:Function) : void
      {
         this._beakerWidgets[categoryIndex].drawLiquid(doneFn);
      }
   }
}
