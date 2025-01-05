package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.utils.*;
   
   public class VoteResultPlayerLineUpWidget
   {
      
      private static var TIME_MS_BETWEEN_VOTE_APPEAR:Number = 50;
       
      
      private var _mc:MovieClip;
      
      private var _voteResultsPlayerWidgets:Array;
      
      private var _activeVoteResultPlayerWidgets:Array;
      
      public function VoteResultPlayerLineUpWidget(mc:MovieClip, namePosition:String)
      {
         super();
         this._mc = mc;
         JBGUtil.gotoFrame(this._mc,"Park");
         this._voteResultsPlayerWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatar").map(function(playerMC:MovieClip, ... args):VoteResultPlayerWidget
         {
            return new VoteResultPlayerWidget(playerMC,namePosition);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc],"Park");
         JBGUtil.reset(this._activeVoteResultPlayerWidgets);
      }
      
      public function setup(role:RoleData = null) : void
      {
         if(Boolean(role))
         {
            this._setupWithRole(role);
         }
         else
         {
            this._setupNoRole();
         }
      }
      
      private function _setupWithRole(role:RoleData) : void
      {
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + GameState.instance.players.length);
         this._activeVoteResultPlayerWidgets = this._voteResultsPlayerWidgets.slice(0,GameState.instance.players.length);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, index:int, ... args):void
         {
            var playerVotedFor:Player = GameState.instance.currentRound.getPlayerVotedForRole(GameState.instance.players[index],role);
            widget.setup(GameState.instance.players[index],playerVotedFor);
            widget.setupPlayerListener();
         });
      }
      
      private function _setupNoRole() : void
      {
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + GameState.instance.players.length);
         this._activeVoteResultPlayerWidgets = this._voteResultsPlayerWidgets.slice(0,GameState.instance.players.length);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, index:int, ... args):void
         {
            widget.setup(GameState.instance.players[index],null);
            widget.setupPlayerListener();
         });
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._activeVoteResultPlayerWidgets.length,doneFn);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            widget.setShown(isShown,c.generateDoneFn());
         });
      }
      
      public function setVotesShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._activeVoteResultPlayerWidgets.length,doneFn);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, index:int, ... args):void
         {
            JBGUtil.runFunctionAfter(function():void
            {
               widget.setVoteShown(isShown,c.generateDoneFn());
            },Duration.fromMs(TIME_MS_BETWEEN_VOTE_APPEAR * index));
         });
      }
      
      private function _setPlayerPercentShown(isShown:Boolean, doneFn:Function, playerWidgets:Array) : void
      {
         var c:Counter = null;
         if(playerWidgets.length == 0)
         {
            doneFn();
            return;
         }
         c = new Counter(playerWidgets.length,doneFn);
         playerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            widget.setPercentShown(isShown,c.generateDoneFn());
         });
      }
      
      public function setAllDoubleDownPercentShown(isShown:Boolean, doneFn:Function) : void
      {
         var playerWidgets:Array = null;
         playerWidgets = [];
         GameState.instance.currentReveal.rolesInvolved.forEach(function(role:RoleData, ... args):void
         {
            _activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
            {
               if(GameState.instance.currentRound.playerDoubledDownOnRole(widget.player,role))
               {
                  playerWidgets.push(widget);
               }
            });
         });
         if(playerWidgets.length > 0 && isShown)
         {
            GameState.instance.audioRegistrationStack.play("Review99Percent",Nullable.NULL_FUNCTION);
         }
         this._setPlayerPercentShown(isShown,doneFn,playerWidgets);
      }
      
      public function setWinningDoubleDownPercentShown(isShown:Boolean, doneFn:Function) : void
      {
         var playerWidgets:Array = null;
         playerWidgets = [];
         GameState.instance.currentReveal.rolesInvolved.forEach(function(role:RoleData, ... args):void
         {
            _activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
            {
               if(GameState.instance.currentRound.playerWonDoubleDown(widget.player,role))
               {
                  playerWidgets.push(widget);
               }
            });
         });
         if(playerWidgets.length > 0 && isShown)
         {
            GameState.instance.audioRegistrationStack.play("Review99Percent",Nullable.NULL_FUNCTION);
         }
         this._setPlayerPercentShown(isShown,doneFn,playerWidgets);
      }
      
      public function hideLosingDoubleDownPercents(doneFn:Function) : void
      {
         var playerWidgets:Array = null;
         playerWidgets = [];
         GameState.instance.currentReveal.rolesInvolved.forEach(function(role:RoleData, ... args):void
         {
            _activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
            {
               if(!GameState.instance.currentRound.playerWonDoubleDown(widget.player,role))
               {
                  playerWidgets.push(widget);
               }
            });
         });
         this._setPlayerPercentShown(false,doneFn,playerWidgets);
      }
      
      public function hideBiscuits(doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._activeVoteResultPlayerWidgets.length,doneFn);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            widget.setBiscuitShown(false,c.generateDoneFn());
         });
      }
      
      public function highlightVoters(votersToHighlight:Array, highlight:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(votersToHighlight.length,doneFn);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            if(ArrayUtil.arrayContainsElement(votersToHighlight,widget.player))
            {
               widget.setHighlight(highlight,c.generateDoneFn());
            }
         });
      }
      
      public function giveBonus(playersGettingBonus:Array, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(playersGettingBonus.length,doneFn);
         this._activeVoteResultPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            if(ArrayUtil.arrayContainsElement(playersGettingBonus,widget.player))
            {
               widget.shower.doAnimation("GiveBonus",c.generateDoneFn());
            }
         });
      }
      
      public function hideLosingPlayerVotes(doneFn:Function) : void
      {
         var losingPlayerWidgets:Array;
         var role:RoleData = null;
         var c:Counter = null;
         if(!GameState.instance.currentReveal.roleData)
         {
            return;
         }
         role = GameState.instance.currentReveal.roleData;
         losingPlayerWidgets = this._activeVoteResultPlayerWidgets.filter(function(widget:VoteResultPlayerWidget, ... args):Boolean
         {
            return !ArrayUtil.arrayContainsElement(GameState.instance.currentReveal.primaryPlayers,GameState.instance.currentRound.getPlayerVotedForRole(widget.player,role)) && widget.isVoteShown;
         });
         if(losingPlayerWidgets.length == 0)
         {
            doneFn();
            return;
         }
         c = new Counter(losingPlayerWidgets.length,doneFn);
         GameState.instance.audioRegistrationStack.play("HideOutlierVotes",Nullable.NULL_FUNCTION);
         losingPlayerWidgets.forEach(function(widget:VoteResultPlayerWidget, ... args):void
         {
            widget.setVoteShown(false,c.generateDoneFn());
         });
      }
      
      public function hidePlayerVotesForAssignedPlayers(doneFn:Function) : void
      {
         var c:Counter = null;
         var assignedPlayerWidgets:Array = this._activeVoteResultPlayerWidgets.filter(function(widget:VoteResultPlayerWidget, ... args):Boolean
         {
            return ArrayUtil.arrayContainsElement(GameState.instance.playersWhoVotedForAssignedPlayers,widget.player);
         });
         if(assignedPlayerWidgets.length == 0)
         {
            doneFn();
            return;
         }
         c = new Counter(assignedPlayerWidgets.length,doneFn);
         GameState.instance.audioRegistrationStack.play("HideOutlierVotes",Nullable.NULL_FUNCTION);
         assignedPlayerWidgets.forEach(function(aw:VoteResultPlayerWidget, ... args):void
         {
            aw.setPercentShown(false,Nullable.NULL_FUNCTION);
            aw.setVoteShown(false,c.generateDoneFn());
         });
      }
      
      public function showAudienceBonus(player:Player, doneFn:Function) : void
      {
         var audienceWinnerWidget:VoteResultPlayerWidget = ArrayUtil.find(this._activeVoteResultPlayerWidgets,function(widget:VoteResultPlayerWidget, ... args):Boolean
         {
            return player == widget.player;
         });
         if(Boolean(audienceWinnerWidget))
         {
            audienceWinnerWidget.showAudienceBonus(doneFn);
         }
         else
         {
            doneFn();
         }
      }
   }
}
