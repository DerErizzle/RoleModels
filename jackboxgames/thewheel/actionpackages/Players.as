package jackboxgames.thewheel.actionpackages
{
   import jackboxgames.model.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public dynamic class Players extends JBGActionPackage
   {
      public function Players(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return null;
      }
      
      private function _generateAction(name:String, arrayFn:Function, perPlayerFn:Function, argList:Array) : void
      {
         var _this:Players = null;
         _this = this;
         _this["handleAction" + name] = function(ref:IActionRef, params:Object):void
         {
            var p:IHasPlayerWidget = null;
            var players:Array = TSUtil.resolveArrayFromVariablePath(params.players,IHasPlayerWidget);
            var args:Array = argList.map(function(p:String, ... args):*
            {
               return params[p];
            });
            arrayFn.apply(_this,[players].concat(args));
            for each(p in players)
            {
               perPlayerFn.apply(_this,[p].concat(args));
            }
            ref.end();
         };
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         this._generateAction("UpdatePlayersControllerState",Nullable.NULL_FUNCTION,this._updatePlayersControllerState,[]);
         this._generateAction("SetPlayersScoreShown",Nullable.NULL_FUNCTION,this._setPlayerScoreShown,["isShown"]);
         this._generateAction("UpdatePlayersScore",Nullable.NULL_FUNCTION,this._updatePlayerScore,["rackUpTimeMs"]);
         this._generateAction("UpdatePlayersWinnerMode",Nullable.NULL_FUNCTION,this._updateWinnerMode,[]);
         this._generateAction("SetPlayersResultsShown",Nullable.NULL_FUNCTION,this._setPlayerResultsShown,["isShown"]);
         this._generateAction("SetPlayersResultsHighlighted",Nullable.NULL_FUNCTION,this._setPlayerResultsHighlighted,["isHighlighted"]);
         this._generateAction("SetBestPerformanceShown",Nullable.NULL_FUNCTION,this._setBestPerformanceShown,["isShown"]);
         this._generateAction("SetPlayersUniqueResultsShown",Nullable.NULL_FUNCTION,this._setUniqueResultsShown,["isShown"]);
         this._generateAction("SetPlayersAnswering",Nullable.NULL_FUNCTION,this._setPlayerAnswering,["isAnswering"]);
         this._generateAction("SetPlayersHighlighted",this._onPlayersHighlighted,this._setPlayerHighlighted,["isHighlighted"]);
         this._generateAction("SetPlayersDimmed",Nullable.NULL_FUNCTION,this._setPlayerDimmed,["isDimmed"]);
         this._generateAction("SetPlayersSlicesShown",Nullable.NULL_FUNCTION,this._setSlicesShown,["isShown"]);
         this._generateAction("AddSlicesToPlayers",Nullable.NULL_FUNCTION,this._addSlices,["numSlices"]);
         this._generateAction("SetPlayersBonusSliceShown",Nullable.NULL_FUNCTION,this._setBonusSliceShown,["isShown"]);
         this._generateAction("SetupScoreReveal",Nullable.NULL_FUNCTION,this._setupScoreReveal,[]);
         this._generateAction("SetMultipliersShown",Nullable.NULL_FUNCTION,this._setMultipliersShown,["isShown"]);
         this._generateAction("ShowPendingPoints",Nullable.NULL_FUNCTION,this._setPendingPointsShown,["includeMultipliers","skipIfNoMultipliers"]);
         this._generateAction("ShowCurrentScore",Nullable.NULL_FUNCTION,this._showCurrentScore,[]);
         ref.end();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      private function _updatePlayersControllerState(p:Player) : void
      {
         p.requestToUpdateControllerState();
      }
      
      private function _setPlayerScoreShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setScoreShown(isShown);
      }
      
      private function _updatePlayerScore(p:Player, rackUpTimeMs:Number) : void
      {
         p.widget.updateScore(Duration.fromMs(rackUpTimeMs));
      }
      
      private function _updateWinnerMode(p:Player) : void
      {
         p.widget.updateWinnerMode();
      }
      
      private function _setPlayerResultsShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setResultsShown(isShown);
      }
      
      private function _setPlayerResultsHighlighted(p:Player, isHighlighted:Boolean) : void
      {
         p.widget.setResultsHighlighted(isHighlighted);
      }
      
      private function _setBestPerformanceShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setBestPerformanceShown(isShown);
      }
      
      private function _setUniqueResultsShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setUniqueResultsShown(isShown);
      }
      
      private function _onPlayersHighlighted(players:Array, isHighlighted:Boolean) : void
      {
         var event:String = null;
         if(players.length == 1)
         {
            event = (isHighlighted ? "highlight" : "unhighlight") + Player(ArrayUtil.first(players)).avatar.id;
         }
         else
         {
            event = isHighlighted ? "highlightManyPlayers" : "unhighlightManyPlayers";
         }
         GameState.instance.audioRegistrationStack.play(event);
      }
      
      private function _setPlayerAnswering(p:Player, isAnswering:Boolean) : void
      {
         p.widget.setAnswering(isAnswering);
      }
      
      private function _setPlayerHighlighted(p:Player, isHighlighted:Boolean) : void
      {
         p.widget.setHighlighted(isHighlighted);
      }
      
      private function _setPlayerDimmed(p:Player, isDimmed:Boolean) : void
      {
         p.widget.setDimmed(isDimmed);
      }
      
      private function _setSlicesShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setSlicesShown(isShown);
      }
      
      private function _addSlices(p:Player, numSlices:int) : void
      {
         p.widget.addSlices(numSlices);
      }
      
      private function _setBonusSliceShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setBonusSliceShown(isShown);
      }
      
      private function _setupScoreReveal(p:Player) : void
      {
         p.widget.setupScoreReveal();
      }
      
      private function _setMultipliersShown(p:Player, isShown:Boolean) : void
      {
         p.widget.setMultipliersShown(isShown);
      }
      
      private function _setPendingPointsShown(p:Player, includeMultipliers:Boolean, skipIfNoMultipliers:Boolean) : void
      {
         p.widget.showPendingPoints(includeMultipliers,skipIfNoMultipliers);
      }
      
      private function _showCurrentScore(p:Player) : void
      {
         p.widget.showCurrentScore();
      }
   }
}

