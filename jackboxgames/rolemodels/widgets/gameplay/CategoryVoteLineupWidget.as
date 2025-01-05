package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.Player;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Counter;
   import jackboxgames.utils.JBGUtil;
   
   public class CategoryVoteLineupWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _categoryVoteWidgets:Array;
      
      public function CategoryVoteLineupWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._categoryVoteWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatar").map(function(voteHeadMC:MovieClip, ... args):CategoryVoteWidget
         {
            return new CategoryVoteWidget(voteHeadMC);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._categoryVoteWidgets);
      }
      
      public function hideAllVotesForCategory(doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._categoryVoteWidgets.length,doneFn);
         this._categoryVoteWidgets.forEach(function(widget:CategoryVoteWidget, ... args):void
         {
            widget.setShown(false,c.generateDoneFn());
         });
      }
      
      public function setVoteForCategoryShown(isShown:Boolean, player:Player, doneFn:Function) : void
      {
         var unusedWidget:CategoryVoteWidget = null;
         var voteWidget:CategoryVoteWidget = null;
         if(isShown)
         {
            unusedWidget = ArrayUtil.find(this._categoryVoteWidgets,function(widget:CategoryVoteWidget, ... args):Boolean
            {
               return !widget.isShown;
            });
            unusedWidget.setPlayer(player);
            unusedWidget.setShown(true,doneFn);
         }
         else
         {
            voteWidget = ArrayUtil.find(this._categoryVoteWidgets,function(widget:CategoryVoteWidget, ... args):Boolean
            {
               return widget.player == player;
            });
            if(Boolean(voteWidget))
            {
               voteWidget.setShown(false,doneFn);
            }
         }
      }
   }
}
