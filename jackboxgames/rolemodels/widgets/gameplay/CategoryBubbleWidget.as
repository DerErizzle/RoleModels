package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class CategoryBubbleWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _bubbleAnimations:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _bubbleIndex:int;
      
      private var _categoryVoteLineup:CategoryVoteLineupWidget;
      
      public function CategoryBubbleWidget(mc:MovieClip, bubbleIndex:int)
      {
         super();
         this._mc = mc;
         this._bubbleAnimations = this._mc.bubble;
         this._categoryVoteLineup = new CategoryVoteLineupWidget(this._mc.bubble.avatars);
         this._bubbleIndex = bubbleIndex;
         this._tf = new ExtendableTextField(this._mc.bubble.tf,[],[PostEffectFactory.createDynamicResizerEffect(3,4,128,2,false),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function setup(categoryName:String) : void
      {
         this._tf.text = categoryName;
         JBGUtil.gotoFrame(this._mc,"Float");
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc,this._bubbleAnimations],"Park");
         this._categoryVoteLineup.reset();
      }
      
      public function setVoteForCategoryShown(isShown:Boolean, player:Player, doneFn:Function) : void
      {
         this._categoryVoteLineup.setVoteForCategoryShown(isShown,player,doneFn);
      }
      
      public function doAnimation(animation:String) : void
      {
         this._categoryVoteLineup.hideAllVotesForCategory(Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrame(this._bubbleAnimations,"Bubble" + String(this._bubbleIndex) + animation);
      }
      
      public function disappearChosen() : void
      {
         JBGUtil.gotoFrame(this._bubbleAnimations,"Bubble" + String(this._bubbleIndex) + "ChosenDisappear");
      }
   }
}
