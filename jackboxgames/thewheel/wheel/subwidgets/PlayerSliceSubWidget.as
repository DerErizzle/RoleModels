package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class PlayerSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _params:SliceParameters;
      
      private var _data:PlayerSliceData;
      
      private var _stakeMcs:Array;
      
      private var _multiplierTf:ExtendableTextField;
      
      private var _lastStakeFrame:Array;
      
      public function PlayerSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._params = params;
         this._data = PlayerSliceData(params.data);
         this._stakeMcs = JBGUtil.getPropertiesOfNameInOrder(this._mc.owners,"p",1);
         this._multiplierTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.multiplier.amount);
         this._lastStakeFrame = ArrayUtil.makeArray(this._stakeMcs.length,"Park");
         this.updateVisuals();
      }
      
      public function dispose() : void
      {
      }
      
      private function _getStakeMcForPlayer(p:Player) : MovieClip
      {
         return this._stakeMcs[p.avatar.index];
      }
      
      private function _getPlayerForStakeMc(stakeMc:MovieClip) : Player
      {
         var index:int = 0;
         index = int(this._stakeMcs.indexOf(stakeMc));
         return ArrayUtil.find(GameState.instance.players,function(p:Player, ... args):Boolean
         {
            return p.avatar.index == index;
         });
      }
      
      private function _tryToChangeStakeToFrame(stakeMc:MovieClip, frame:String) : void
      {
         var index:int = int(this._stakeMcs.indexOf(stakeMc));
         if(this._lastStakeFrame[index] != frame)
         {
            JBGUtil.gotoFrame(stakeMc,frame);
            this._lastStakeFrame[index] = frame;
         }
      }
      
      private function _getBaseFrameForPlayer(p:Player) : String
      {
         if(this._data.getMultiplierForPlayer(p) > 0)
         {
            return p.isInWinnerMode ? "AppearWinState" : "Appear";
         }
         return "Park";
      }
      
      public function updateVisuals() : void
      {
         this._stakeMcs.forEach(function(stakeMc:MovieClip, ... args):void
         {
            var player:Player = _getPlayerForStakeMc(stakeMc);
            if(Boolean(player))
            {
               _tryToChangeStakeToFrame(stakeMc,_getBaseFrameForPlayer(player));
            }
            else
            {
               _tryToChangeStakeToFrame(stakeMc,"Park");
            }
         });
         if(this._data.multiplier > 1)
         {
            this._multiplierTf.text = this._data.multiplier + "x";
            JBGUtil.gotoFrame(this._mc.multiplier,"Appear");
         }
         else
         {
            JBGUtil.gotoFrame(this._mc.multiplier,"Park");
         }
      }
      
      public function setPlayerStakeHighlighted(p:Player, isHighlighted:Boolean) : void
      {
         Assert.assert(this._data.getNumStakesForPlayer(p) > 0);
         this._tryToChangeStakeToFrame(this._getStakeMcForPlayer(p),isHighlighted ? "Highlight" : this._getBaseFrameForPlayer(p));
      }
      
      public function doRandomizationAnimation(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.owners.randomize,"Randomize",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}

