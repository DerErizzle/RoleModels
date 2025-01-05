package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.rolemodels.widgets.gameplay.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   
   public class Reveal extends JBGActionPackage
   {
      
      private static const LOW_FIDELITY_SOURCE:String = "lo/rm_reveal_lo.swf";
       
      
      private var _promptWidget:RevealPromptWidget;
      
      private var _instructionWidget:RevealInstructionWidget;
      
      private var _playersAndAnswers:RevealLineUpWidget;
      
      private var _voteResultsWidget:VoteResultWidget;
      
      private var _backgroundWidget:BackgroundWidget;
      
      private var _lineupWidget:LineUpWidget;
      
      private var _minigameTitleWidget:MinigameTextWidget;
      
      private var _categoryAndRoleWidget:MinigameRoleAndCategoryWidget;
      
      private var _roleBubblesWidget:RoleBubblesWidget;
      
      private var _minigameVoteLineupWidget:MinigamePlayerVoteLineupWidget;
      
      private var _wipeTransitionWidget:WipeTransitionWidget;
      
      private var _minigameDecorationWidget:MinigameDecorationWidget;
      
      private var _lineupCategoryAndRole:LineupCategoryAndRoleWidget;
      
      private var _preloader:PreloaderDelegate;
      
      public function Reveal(sourceURL:String)
      {
         if(Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW)
         {
            sourceURL = LOW_FIDELITY_SOURCE;
         }
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         GameState.instance.screenOrganizer.addChild(_mc,0);
         _ts.g.reveal = this;
         this._playersAndAnswers = new RevealLineUpWidget(_mc.minigames.players);
         this._promptWidget = new RevealPromptWidget(_mc.minigames.prompt);
         this._instructionWidget = new RevealInstructionWidget(_mc.minigames.instructions);
         this._voteResultsWidget = new VoteResultWidget(_mc.reveal);
         this._backgroundWidget = new BackgroundWidget(_mc.bg);
         this._lineupWidget = new LineUpWidget(_mc.lineup);
         this._minigameTitleWidget = new MinigameTextWidget(_mc.minigames.minigameTitleTF);
         this._categoryAndRoleWidget = new MinigameRoleAndCategoryWidget(_mc.minigames.categoryAndRoleTF);
         this._minigameVoteLineupWidget = new MinigamePlayerVoteLineupWidget(_mc.minigames.votes);
         this._wipeTransitionWidget = new WipeTransitionWidget(_mc.transition);
         this._lineupCategoryAndRole = new LineupCategoryAndRoleWidget(_mc.categoryTF);
         this._roleBubblesWidget = new RoleBubblesWidget(_mc.minigames.roleBubbles);
         this._minigameDecorationWidget = new MinigameDecorationWidget(_mc.minigames.decoration);
         this._preloader = new PreloaderDelegate(_mc.preloader);
         addDelegate(this._preloader);
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         JBGUtil.reset([this._promptWidget,this._instructionWidget,this._voteResultsWidget,this._backgroundWidget,this._lineupWidget,this._minigameTitleWidget,this._categoryAndRoleWidget,this._minigameVoteLineupWidget,this._wipeTransitionWidget,this._lineupCategoryAndRole,this._minigameDecorationWidget,this._roleBubblesWidget].concat(this._playersAndAnswers));
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         this._backgroundWidget.appear();
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         this._backgroundWidget.reset();
         ref.end();
      }
      
      public function handleActionTransitionBackground(ref:IActionRef, params:Object) : void
      {
         this._backgroundWidget.transitionBackground(params.backgroundState,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupPlayerAvatars(ref:IActionRef, params:Object) : void
      {
         this._playersAndAnswers.setup(GameState.instance.getPlayerListFromString(params.players));
         ref.end();
      }
      
      public function handleActionWipeTransition(ref:IActionRef, params:Object) : void
      {
         this._wipeTransitionWidget.doTransition(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayersShown(ref:IActionRef, params:Object) : void
      {
         GameState.instance.audioRegistrationStack.play(Boolean(params.isShown) ? "TiebreakerAvatarsAppear" : "TiebreakerAvatarsDisappear",Nullable.NULL_FUNCTION);
         this._playersAndAnswers.setPlayersShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetAnswersShown(ref:IActionRef, params:Object) : void
      {
         GameState.instance.audioRegistrationStack.play(Boolean(params.isShown) ? "WordBalloonsOn" : "WordBalloonsOff",Nullable.NULL_FUNCTION);
         this._playersAndAnswers.setAnswersShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetVotesShown(ref:IActionRef, params:Object) : void
      {
         this._playersAndAnswers.setVotesShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         this._promptWidget.setShown(params.isShown,params.text,params.small,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetInstructionsShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._instructionWidget.setup(params.text);
            if(!this._instructionWidget.shower.isShown)
            {
               GameState.instance.audioRegistrationStack.play("TiebreakerPromptAppear",Nullable.NULL_FUNCTION);
            }
         }
         this._instructionWidget.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShrinkPrompt(ref:IActionRef, params:Object) : void
      {
         this._promptWidget.shrink(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionEnsureAllPlayersHaveRoles(ref:IActionRef, params:Object) : void
      {
         var unassignedPlayer:Player = null;
         var role:RoleData = null;
         for each(unassignedPlayer in GameState.instance.currentRound.unassignedPlayers)
         {
            role = ArrayUtil.getRandomElement(GameState.instance.currentRound.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL));
            role.playerAssignedRole = unassignedPlayer;
            unassignedPlayer.score.val += GameConstants.REVEAL_CONSTANTS.freebie.getProperty("points");
         }
         ref.end();
      }
      
      public function handleActionSetMinigameTitleTextShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._minigameTitleWidget.setup(params.text,this._backgroundWidget.backgroundState);
         }
         this._minigameTitleWidget.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionFadeMinigameTitleText(ref:IActionRef, params:Object) : void
      {
         this._minigameTitleWidget.shower.doAnimation("Grow",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDisappearMinigameTextVertically(ref:IActionRef, params:Object) : void
      {
         this._minigameTitleWidget.disappearVertical(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetMinigameCategoryAndRoleShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._categoryAndRoleWidget.setup();
         }
         this._categoryAndRoleWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
         ref.end();
      }
      
      public function handleActionSetupRoleAward(ref:IActionRef, params:Object) : void
      {
         var player:Player = GameState.instance.getPlayerListFromString(params.player)[0];
         var role:RoleData = VariableUtil.getVariableValue(params.role);
         this._voteResultsWidget.setupAward(player,role,GameState.instance.currentRound.category);
         ref.end();
      }
      
      public function handleActionSetupRoleNoAward(ref:IActionRef, params:Object) : void
      {
         var role:RoleData = VariableUtil.getVariableValue(params.role);
         this._voteResultsWidget.setup(GameState.instance.currentRound.category,role);
         ref.end();
      }
      
      public function handleActionSetupNoRole(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setupNoRole(GameState.instance.currentReveal.primaryPlayers,LocalizationUtil.getPrintfText("VOTE_RESULT_NO_ROLE"));
         ref.end();
      }
      
      public function handleActionSetCategoryAndRoleShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setCategoryAndRoleShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShrinkCategoryAndRole(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.shrinkCategoryAndRole(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayerVoteLineUpShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setPlayerVoteLineUpShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayerVotesShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setPlayerVotesShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHidePlayerBiscuits(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.hidePlayerBiscuits(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetVoteResultsShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowBucket(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.showBucket(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowHand(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.showHand(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowHandAndBucket(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.showHandAndBucket(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealHand(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.revealPlayerInHand(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionBucketPlayer(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.bucketPlayer(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHighlightPlayers(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.highlightVoters(GameState.instance.getPlayerListFromString(params.players),params.highlight,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionGivePlayersBonus(ref:IActionRef, params:Object) : void
      {
         var players:Array = GameState.instance.getPlayerListFromString(params.players);
         players.forEach(function(p:Player, ... args):void
         {
            p.score.val += params.amount;
         });
         this._voteResultsWidget.giveBonus(players,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupLineup(ref:IActionRef, params:Object) : void
      {
         this._lineupCategoryAndRole.setup(GameState.instance.currentRound.category);
         this._lineupWidget.setup();
         ref.end();
      }
      
      public function handleActionSetLineupShown(ref:IActionRef, params:Object) : void
      {
         this._lineupWidget.setLineUpShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowLineupBiscuitPiles(ref:IActionRef, params:Object) : void
      {
         this._lineupWidget.showLineupBiscuits(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetLineupCategoryAndRoleShown(ref:IActionRef, params:Object) : void
      {
         this._lineupCategoryAndRole.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupRoleBubbles(ref:IActionRef, params:Object) : void
      {
         var primaryStrings:Array = [];
         if(params.firstPrimaryString != "")
         {
            primaryStrings.push(params.firstPrimaryString);
         }
         if(params.secondPrimaryString != "")
         {
            primaryStrings.push(params.secondPrimaryString);
         }
         var transformedStrings:Array = [];
         if(params.firstTransformedString != "")
         {
            transformedStrings.push(params.firstTransformedString);
         }
         if(params.secondTransformedString != "")
         {
            transformedStrings.push(params.secondTransformedString);
         }
         this._roleBubblesWidget.setup(primaryStrings,transformedStrings,this._backgroundWidget.backgroundState,params.promptOnScreenDuringAppear);
         ref.end();
      }
      
      public function handleActionSetRoleBubblesShown(ref:IActionRef, params:Object) : void
      {
         this._roleBubblesWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionTransformRoleBubblesToTags(ref:IActionRef, params:Object) : void
      {
         this._roleBubblesWidget.transformToTag(params.forBubbles,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShiftRoleBubblesForPrompt(ref:IActionRef, params:Object) : void
      {
         this._roleBubblesWidget.shiftForPrompt(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionAwardRoleBubbles(ref:IActionRef, params:Object) : void
      {
         this._roleBubblesWidget.awardBubbles(GameState.instance.currentReveal.primaryPlayers.length,params.winningIndex,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHighlightWinningPlayer(ref:IActionRef, params:Object) : void
      {
         this._lineupWidget.highlightWinningPlayer(params.isHighlighted,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionResetVoteResultsWidget(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.reset();
         ref.end();
      }
      
      public function handleActionDoAvatarAnimations(ref:IActionRef, params:Object) : void
      {
         var losingPlayers:Array;
         GameState.instance.playersWithPendingPoints.forEach(function(p:Player, ... args):void
         {
            var frameLabel:String = String(PlayerWidget.AVATAR_ANIMATION_LABELS.WIN);
            if(GameState.instance.currentReveal.roleData != null && GameState.instance.currentRound.playerVotedForSelf(p,GameState.instance.currentReveal.roleData) && GameState.instance.currentReveal.roleData.playerAssignedRole == p)
            {
               frameLabel = String(PlayerWidget.AVATAR_ANIMATION_LABELS.SUPER_WIN);
            }
            p.broadcast("AvatarAnimation",{"frameLabel":frameLabel});
         });
         losingPlayers = ArrayUtil.difference(GameState.instance.currentReveal.primaryPlayers,GameState.instance.playersWithPendingPoints);
         losingPlayers.forEach(function(p:Player, ... args):void
         {
            p.broadcast("AvatarAnimation",{"frameLabel":PlayerWidget.AVATAR_ANIMATION_LABELS.LOSE});
         });
         ref.end();
      }
      
      public function handleActionPlayAvatarAnimationOnPlayers(ref:IActionRef, params:Object) : void
      {
         var players:Array = GameState.instance.getPlayerListFromString(params.players);
         players.forEach(function(p:Player, ... args):void
         {
            p.broadcast("AvatarAnimation",{"frameLabel":params.frameLabel});
         });
         ref.end();
      }
      
      public function handleActionDistributePoints(ref:IActionRef, params:Object) : void
      {
         GameState.instance.playersWithPendingPoints.forEach(function(p:Player, ... args):void
         {
            var pendingPoints:int = p.pendingPoints.val;
            var scoreBefore:int = p.score.val;
            p.pendingPoints.val = 0;
            p.score.val += pendingPoints;
            p.broadcast("PointsDistributed",{
               "from":scoreBefore,
               "to":p.score.val,
               "diff":p.score.val - scoreBefore,
               "numberOverride":params.numberOverride
            });
         });
         ref.end();
      }
      
      public function handleActionAwardDoubleDownPointsForCurrentReveal(ref:IActionRef, params:Object) : void
      {
         GameState.instance.awardDoubleDownPointsForCurrentReveal();
         ref.end();
      }
      
      public function handleActionSetWinningDoubleDownPercentShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setWinningPlayersPercentShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetAllPlayersWhoDoubledDownForRolePercentShown(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.setAllPlayersPercentShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHideLosingPlayersPercent(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.hideLosingPlayersPercent(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupPlayerVoteLineup(ref:IActionRef, params:Object) : void
      {
         var role:RoleData = VariableUtil.getVariableValue(params.role);
         this._voteResultsWidget.setupPlayerLineup(role);
         ref.end();
      }
      
      public function handleActionHideLosingPlayerVotes(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.hideLosingPlayerVotes(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHideAssignedPlayerVotesAndPercentages(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.hidePlayerVotesForAssignedPlayers(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoHandAvatarAnimation(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.doHandAvatarAnimation(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupMinigamePlayerVoteLineup(ref:IActionRef, params:Object) : void
      {
         var players:Array = GameState.instance.getPlayerListFromString(params.players);
         this._minigameVoteLineupWidget.setup(players,params.playerAnswersWillBeOnscreen);
         ref.end();
      }
      
      public function handleActionSetMinigamePlayerVoteLineupShown(ref:IActionRef, params:Object) : void
      {
         this._minigameVoteLineupWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionAwardAudienceBonus(ref:IActionRef, params:Object) : void
      {
         var player:Player = GameState.instance.playerToAwardAudienceBonus;
         if(Boolean(player))
         {
            player.pendingPoints.val += GameConstants.AUDIENCE_VOTE_EXTRA_PELLET;
         }
         ref.end();
      }
      
      public function handleActionShowAudienceBonus(ref:IActionRef, params:Object) : void
      {
         this._voteResultsWidget.showAudienceBonus(GameState.instance.playerToAwardAudienceBonus,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionBucketMinigameWinners(ref:IActionRef, params:Object) : void
      {
         var winningPlayers:Array = GameState.instance.currentReveal.primaryPlayers.filter(function(player:Player, ... args):Boolean
         {
            var role:* = undefined;
            var playerGotRole:* = false;
            for each(role in GameState.instance.currentReveal.rolesInvolved)
            {
               if(role.playerAssignedRole == player)
               {
                  playerGotRole = true;
               }
            }
            return playerGotRole;
         });
         this._playersAndAnswers.bucketPlayers(winningPlayers,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowBucketedPlayersRoles(ref:IActionRef, params:Object) : void
      {
         this._playersAndAnswers.showBucketedPlayersRoles(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetMinigameDecorationsShown(ref:IActionRef, params:Object) : void
      {
         this._minigameDecorationWidget.setShown(params.isShown,Duration.fromSec(params.delayBetweenAppears),this._backgroundWidget.backgroundState,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetIsOnScreen(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,Boolean(params.isOn) ? DisplayObjectOrganizer.STATE_ON : DisplayObjectOrganizer.STATE_OFF);
         ref.end();
      }
   }
}
