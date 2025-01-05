package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class LineUpWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _bucketWidgets:Array;
      
      private var _activeBucketWidgets:Array;
      
      public function LineUpWidget(mc:MovieClip)
      {
         var bucketMCs:Array;
         super();
         this._mc = mc;
         bucketMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"bucket");
         this._bucketWidgets = bucketMCs.map(function(bucketMC:MovieClip, ... args):BucketWidget
         {
            return new BucketWidget(bucketMC);
         });
         this._activeBucketWidgets = [];
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         JBGUtil.reset(this._bucketWidgets);
         this._activeBucketWidgets = [];
      }
      
      public function setLineUpShown(isShown:Boolean, doneFn:Function) : void
      {
         if(isShown)
         {
            this._showLineup(doneFn);
         }
         else
         {
            this._hideLineup(doneFn);
         }
      }
      
      private function _showLineup(doneFn:Function) : void
      {
         var roleShowers:Array = null;
         var bucketShowers:Array = this._activeBucketWidgets.map(function(bw:BucketWidget, ... args):MovieClipShower
         {
            return bw.shower;
         });
         roleShowers = this._activeBucketWidgets.map(function(bw:BucketWidget, ... args):MovieClipShower
         {
            return bw.roleShower;
         });
         var biscuitShowers:Array = this._activeBucketWidgets.map(function(bw:BucketWidget, ... args):MovieClipShower
         {
            return bw.biscuitShower;
         });
         GameState.instance.audioRegistrationStack.play("LineupHolesOpen",Nullable.NULL_FUNCTION);
         JBGUtil.runFunctionAfterFrames(function():void
         {
            GameState.instance.audioRegistrationStack.play("LineupBucketsAppear",Nullable.NULL_FUNCTION);
         },13);
         JBGUtil.runFunctionAfterFrames(function():void
         {
            GameState.instance.audioRegistrationStack.play("LineupBucketsBounce",Nullable.NULL_FUNCTION);
         },34);
         MovieClipShower.setMultiple(bucketShowers,true,Duration.fromMs(50),function():void
         {
            GameState.instance.audioRegistrationStack.play("LineupRolesAppear",Nullable.NULL_FUNCTION);
            MovieClipShower.setMultiple(roleShowers.reverse(),true,Duration.fromMs(50),doneFn);
         });
      }
      
      public function showLineupBiscuits(doneFn:Function) : void
      {
         var c:Counter = null;
         if(this._activeBucketWidgets.length == 0)
         {
            doneFn();
            return;
         }
         c = new Counter(this._activeBucketWidgets.length,doneFn);
         GameState.instance.audioRegistrationStack.play("LineupPelletsAppear",Nullable.NULL_FUNCTION);
         this._activeBucketWidgets.forEach(function(bw:BucketWidget, index:int, ... args):void
         {
            JBGUtil.runFunctionAfter(function():void
            {
               bw.biscuitShower.setShown(true,Nullable.NULL_FUNCTION);
               bw.showBiscuitPile(c.generateDoneFn());
            },Duration.scale(Duration.fromMs(50),index));
         });
      }
      
      private function _hideLineup(doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._activeBucketWidgets.length,doneFn);
         GameState.instance.audioRegistrationStack.play("LineupBucketsDisappear",Nullable.NULL_FUNCTION);
         this._activeBucketWidgets.forEach(function(bw:BucketWidget, ... args):void
         {
            bw.shower.setShown(false,c.generateDoneFn());
         });
      }
      
      public function setup() : void
      {
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + GameState.instance.players.length);
         GameState.instance.getPlayersSorted(Player.PROPERTY_FUNCTION_SCORE,GameState.SORT_TYPE_DESCENDING).forEach(function(p:Player, i:int, ... args):void
         {
            _bucketWidgets[i].setup(p,GameState.instance.currentRound.getRoleAssignedToPlayer(p));
            _activeBucketWidgets.push(_bucketWidgets[i]);
         });
      }
      
      public function highlightWinningPlayer(isHighlighted:Boolean, doneFn:Function) : void
      {
         this._activeBucketWidgets[0].highlight(isHighlighted,doneFn);
      }
   }
}
