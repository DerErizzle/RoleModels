package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.gameplay.*;
   import jackboxgames.rolemodels.userinteraction.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.rolemodels.widgets.gameplay.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class InitialVote extends JBGActionPackage implements IResultVoteHandler
   {
      
      private static const LOW_FIDELITY_SOURCE:String = "lo/rm_round_lo.swf";
      
      private static const PICK_CATEGORY_IDLE_TIMEOUT:Number = 5;
      
      private static const CATEGORIZATION_IDLE_TIMEOUT:Number = 10;
       
      
      private var _possiblePrompts:Array;
      
      private var _currentPrompt:Object;
      
      private var _chosenCategoryIndex:int;
      
      private var _roles:Array;
      
      private var _roleSelectorInteraction:InteractionHandler;
      
      private var _categoryPickerInteraction:InteractionHandler;
      
      private var _categoryVotes:PerPlayerContainer;
      
      private var _roleVotes:PerPlayerContainer;
      
      private var _biscuit:BiscuitWidget;
      
      private var _categoriesWidget:CategoriesWidget;
      
      private var _categorizationScreenWidget:CategorizationScreenWidget;
      
      private var _handWidget:CategorizationHandWidget;
      
      private var _eyesWidget:CategorizationEyesWidget;
      
      private var _blinkTransitionWidget:BlinkTransitionWidget;
      
      private var _categorizationAvatarsWidget:SubmittedAvatarsWidget;
      
      private var _votingAudienceInputter:AudienceAwareInputter;
      
      private var _categoryPickerEndTimerCanceler:Function;
      
      private var _categorizationEndTimerCanceler:Function;
      
      public function InitialVote(sourceURL:String)
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
         _ts.g.initialVote = this;
         this._categoryVotes = new PerPlayerContainer();
         this._categoryPickerInteraction = new InteractionHandler(new MakeSingleChoiceWithSubmit(function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn():Object
         {
            return {"html":LocalizationUtil.getPrintfText("INITIAL_VOTE_CATEGORY_SELECTION_PROMPT")};
         },function getChoicesFn(p:Player):Array
         {
            return _possiblePrompts.map(function(prompt:Object, ... args):Object
            {
               return {
                  "html":prompt.category.toUpperCase(),
                  "selected":false
               };
            });
         },function getChoiceTypeFn(p:Player):String
         {
            return "Prompt";
         },function getChoiceIdFn(p:Player):String
         {
            return undefined;
         },function getClassesFn(p:Player):Array
         {
            return [];
         },function finalizeBlob(p:Player, blob:Object):void
         {
         },function playerMadeChoiceFn(p:Player, choice:int, allPlayersHaveMadeAChoice:Boolean):void
         {
            if(choice < _possiblePrompts.length)
            {
               _categoryPickerEndTimerCanceler();
               _categoriesWidget.setVoteForCategoryShown(true,p,choice,Nullable.NULL_FUNCTION);
               GameState.instance.audioRegistrationStack.play("VoteIn",Nullable.NULL_FUNCTION);
            }
            if(allPlayersHaveMadeAChoice)
            {
               _categoryPickerEndTimerCanceler = JBGUtil.runFunctionAfter(_endPickCategoryTimer,Duration.fromSec(PICK_CATEGORY_IDLE_TIMEOUT));
            }
         },function doneFn(finishedOnUserInput:Boolean, chosenChoices:PerPlayerContainer):void
         {
            _categoryPickerEndTimerCanceler();
            if(finishedOnUserInput)
            {
               TSInputHandler.instance.input("Done");
            }
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            });
            _categoryVotes = chosenChoices;
         }),GameState.instance,true,true);
         this._roleVotes = new PerPlayerContainer();
         this._roleSelectorInteraction = new InteractionHandler(new SortableBehavior(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":_currentPrompt.category.toUpperCase()};
         },function getRolesFn(p:Player):Array
         {
            return _roles.map(function(r:RoleData, i:int, ... args):Object
            {
               return {
                  "index":i,
                  "choice":r.shortName.toUpperCase()
               };
            });
         },function getPlayersFn():Array
         {
            return GameState.instance.players.map(function(player:Player, i:int, ... args):Object
            {
               return {
                  "index":player.index.val,
                  "name":player.name.val,
                  "color":GameConstants.PLAYER_COLORS[player.index.val]
               };
            });
         },function finalizeBlob(p:Player, blob:Object):void
         {
         },function userUpdatedSlotsFn(p:Player, choices:Array, submitted:Boolean):Boolean
         {
            _roleVotes.setDataForPlayer(p,choices);
            if(submitted)
            {
               _categorizationAvatarsWidget.setAvatarShown(true,p.index.val,Nullable.NULL_FUNCTION);
            }
            else
            {
               _categorizationAvatarsWidget.setAvatarShown(false,p.index.val,Nullable.NULL_FUNCTION);
               _categorizationEndTimerCanceler();
               _categorizationEndTimerCanceler = JBGUtil.runFunctionAfter(_endCategorizationTimer,Duration.fromSec(CATEGORIZATION_IDLE_TIMEOUT));
            }
            return true;
         },function doneFn(finishedOnUserInput:Boolean, choices:PerPlayerContainer):void
         {
            _roleVotes = choices;
            _categorizationEndTimerCanceler();
            if(finishedOnUserInput)
            {
               TSInputHandler.instance.input("Done");
            }
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               _categorizationAvatarsWidget.setAvatarShown(false,p.index.val,Nullable.NULL_FUNCTION);
               GameState.instance.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            });
         }),GameState.instance,true,true);
         this._biscuit = new BiscuitWidget(_mc.biscuit);
         this._biscuit.setup();
         this._categoriesWidget = new CategoriesWidget(_mc.categorySelection);
         this._categorizationScreenWidget = new CategorizationScreenWidget(_mc.categorization);
         this._handWidget = new CategorizationHandWidget(_mc.categorySelection.hand);
         this._eyesWidget = new CategorizationEyesWidget(_mc.categorySelection.microscope.eyes);
         this._blinkTransitionWidget = new BlinkTransitionWidget(_mc.transition);
         this._categorizationAvatarsWidget = new SubmittedAvatarsWidget(_mc.categorization.avatars);
         this._votingAudienceInputter = new AudienceAwareInputter(GameState.instance.gameAudience.audienceModule,GameState.instance.gameAudience.votingModule,"Done",Duration.fromSec(3));
         GameState.instance.gameAudience.setResultVoteHandler("InitialVote",this);
         this._categoryPickerEndTimerCanceler = Nullable.NULL_FUNCTION;
         this._categorizationEndTimerCanceler = Nullable.NULL_FUNCTION;
      }
      
      private function _endPickCategoryTimer() : void
      {
         TSInputHandler.instance.input("Done");
      }
      
      private function _hasAllPlayersSlotted(p:Player) : Boolean
      {
         if(!this._roleVotes.hasDataForPlayer(p))
         {
            return false;
         }
         return this._roleVotes.getDataForPlayer(p).length == GameState.instance.players.length;
      }
      
      private function _allPlayersHaveAllPlayersSlotted() : Boolean
      {
         var p:Player = null;
         for each(p in GameState.instance.players)
         {
            if(!this._hasAllPlayersSlotted(p))
            {
               return false;
            }
         }
         return true;
      }
      
      private function _endCategorizationTimer() : void
      {
         if(this._allPlayersHaveAllPlayersSlotted())
         {
            TSInputHandler.instance.input("Done");
         }
         else
         {
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               if(_hasAllPlayersSlotted(p))
               {
                  _categorizationAvatarsWidget.setAvatarShown(true,p.index.val,Nullable.NULL_FUNCTION);
               }
            });
         }
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         resetDelegates();
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         DebugTextWidget.sharedInstance.reset();
         this._currentPrompt = null;
         this._roles = [];
         this._categoryPickerEndTimerCanceler = Nullable.NULL_FUNCTION;
         this._categorizationEndTimerCanceler = Nullable.NULL_FUNCTION;
         JBGUtil.reset([this._roleSelectorInteraction,this._categoryPickerInteraction,this._categoryVotes,this._roleVotes,this._biscuit,this._categoriesWidget,this._categorizationScreenWidget,this._handWidget,this._eyesWidget,this._blinkTransitionWidget,this._categorizationAvatarsWidget,this._votingAudienceInputter]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         this._possiblePrompts = CategoryManager.instance.getCategories();
         this._categoriesWidget.setup(this._possiblePrompts);
         this._categorizationAvatarsWidget.setup(GameState.instance.players);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         resetDelegates();
         this._categorizationScreenWidget.reset();
         ref.end();
      }
      
      public function handleActionSetupCategory(ref:IActionRef, params:Object) : void
      {
         var voteCounts:Array = null;
         var prompt:Object = null;
         var maxVotes:int = 0;
         var indexesAtMax:Array = null;
         var i:int = 0;
         voteCounts = [];
         for each(prompt in this._possiblePrompts)
         {
            voteCounts.push(0);
         }
         this._categoryVotes.forEach(function(choice:int, ... args):void
         {
            ++voteCounts[choice];
         });
         maxVotes = 0;
         indexesAtMax = [];
         for(i = 0; i < voteCounts.length; i++)
         {
            if(voteCounts[i] > maxVotes)
            {
               indexesAtMax = [i];
               maxVotes = int(voteCounts[i]);
            }
            else if(voteCounts[i] == maxVotes)
            {
               indexesAtMax.push(i);
            }
         }
         this._currentPrompt = this._possiblePrompts[ArrayUtil.getRandomElement(indexesAtMax)];
         this._chosenCategoryIndex = this._possiblePrompts.indexOf(this._currentPrompt);
         GameState.instance.currentRound.setContent(this._currentPrompt);
         _ts.g.templateRootPath = JBGLoader.instance.getUrl(this._currentPrompt.path);
         DebugTextWidget.sharedInstance.text = this._currentPrompt.contentType + " " + this._currentPrompt.id;
         this._roles = GameState.instance.currentRound.getRolesOfSource(RoleData.ROLE_SOURCE.INITIAL);
         ref.end();
      }
      
      public function handleActionSetupCategorizationVotes(ref:IActionRef, params:Object) : void
      {
         GameState.instance.currentRound.setRoundVotes(GameState.instance.isAutoVoteOn ? AutoVoter.formatAutoVotes(GameState.instance.players,this._roles) : RMUtil.formatVotes(GameState.instance.players,this._roleVotes,this._roles));
         GameState.instance.currentRound.setDoubleDownVotes(RMUtil.extractDoubleDownFromVotes(this._roleVotes,this._roles));
         ref.end();
      }
      
      public function handleActionSetSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._roleSelectorInteraction.setIsActive(GameState.instance.players,params.isActive);
         ref.end();
      }
      
      public function handleActionSetPickerSubmissionActive(ref:IActionRef, params:Object) : void
      {
         this._categoryPickerInteraction.setIsActive(GameState.instance.players,params.isActive);
         ref.end();
      }
      
      public function handleActionSetupCategorizationScreen(ref:IActionRef, params:Object) : void
      {
         this._categorizationScreenWidget.setup(this._currentPrompt.category.toUpperCase(),this._chosenCategoryIndex);
         ref.end();
      }
      
      public function handleActionMoveToMicroscope(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.shower.doAnimation("Move",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowCategories(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.showBubbles();
         this._categoriesWidget.shower.setShown(true,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoHandAnimation(ref:IActionRef, params:Object) : void
      {
         this._handWidget.doAnimation(params.animation,this._chosenCategoryIndex,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoEyesAnimation(ref:IActionRef, params:Object) : void
      {
         this._eyesWidget.doAnimation(params.animation,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoInitialVoteBlinkTransition(ref:IActionRef, params:Object) : void
      {
         this._blinkTransitionWidget.doTransition(function():void
         {
            _categoriesWidget.shower.reset();
         },TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDrawCategoryLiquid(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.drawLiquid(this._chosenCategoryIndex,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHideNonChosenBubbles(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.disappearNonChosenBubbles(this._chosenCategoryIndex);
         ref.end();
      }
      
      public function handleActionHighlightChosenBubble(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.highlightChosenBubble(this._chosenCategoryIndex);
         ref.end();
      }
      
      public function handleActionHideChosenBubble(ref:IActionRef, params:Object) : void
      {
         this._categoriesWidget.disappearChosen(this._chosenCategoryIndex);
         ref.end();
      }
      
      public function handleActionSetBiscuitShown(ref:IActionRef, params:Object) : void
      {
         this._biscuit.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowInstructions(ref:IActionRef, params:Object) : void
      {
         this._categorizationScreenWidget.showInstructions(TSUtil.createRefEndFn(ref));
      }
      
      public function get resultVoteText() : String
      {
         return LocalizationUtil.getPrintfText("INITIAL_VOTE_AUDIENCE_PROMPT");
      }
      
      public function get resultVoteKeys() : Array
      {
         return this._roles.map(function(r:RoleData, i:int, ... args):Object
         {
            return String(i);
         });
      }
      
      public function get resultVoteChoices() : Array
      {
         return this._roles.map(function(r:RoleData, i:int, ... args):Object
         {
            return {"html":r.name.toUpperCase()};
         });
      }
      
      public function applyResultVote(results:Object) : void
      {
         var totalNumberOfVotes:Number = NaN;
         var audienceVotesForBonusRole:Object = null;
         totalNumberOfVotes = ObjectUtil.getTotal(results);
         audienceVotesForBonusRole = {};
         this._roles.forEach(function(r:RoleData, i:int, ... args):void
         {
            audienceVotesForBonusRole[r.name] = totalNumberOfVotes > 0 ? Number(results[String(i)] / totalNumberOfVotes) : 0;
         });
         GameState.instance.currentRound.generateAudienceBonusRoleFromVoteData(this._roles,audienceVotesForBonusRole);
      }
   }
}
