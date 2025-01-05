package jackboxgames.userinteraction.commonbehaviors
{
   import jackboxgames.blobcast.model.BlobCastPlayer;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class MakeSingleChoice implements IInteractionBehavior
   {
       
      
      private var _allowDuplicates:Boolean;
      
      private var _setupFn:Function;
      
      private var _getPromptFn:Function;
      
      private var _getChoicesFn:Function;
      
      private var _getChoiceTypeFn:Function;
      
      private var _getDoneTextFn:Function;
      
      private var _getChoiceIdFn:Function;
      
      private var _getClassesFn:Function;
      
      private var _finalizeBlobFn:Function;
      
      private var _playerMadeChoiceFn:Function;
      
      private var _doneFn:Function;
      
      private var _players:Array;
      
      private var _chosenChoices:PerPlayerContainer;
      
      public function MakeSingleChoice(allowDuplicates:Boolean, setupFn:Function, getPromptFn:Function, getChoicesFn:Function, getChoiceTypeFn:Function, getDoneTextFn:Function, getChoiceIdFn:Function, getClassesFn:Function, finalizeBlobFn:Function, playerMadeChoiceFn:Function, doneFn:Function)
      {
         super();
         this._allowDuplicates = allowDuplicates;
         this._setupFn = setupFn;
         this._getPromptFn = getPromptFn;
         this._getChoicesFn = getChoicesFn;
         this._getChoiceTypeFn = getChoiceTypeFn;
         this._getDoneTextFn = getDoneTextFn;
         this._getChoiceIdFn = getChoiceIdFn;
         this._getClassesFn = getClassesFn;
         this._finalizeBlobFn = finalizeBlobFn;
         this._playerMadeChoiceFn = playerMadeChoiceFn;
         this._doneFn = doneFn;
      }
      
      public function setup(players:Array) : void
      {
         this._players = players;
         this._chosenChoices = new PerPlayerContainer();
         this._setupFn(this._players);
      }
      
      private function _anyPlayerHasChosenChoiceIndex(i:int) : Boolean
      {
         var p:BlobCastPlayer = null;
         for each(p in this._players)
         {
            if(this._chosenChoices.hasDataForPlayer(p) && this._chosenChoices.getDataForPlayer(p) == i)
            {
               return true;
            }
         }
         return false;
      }
      
      public function generateBlob(forPlayer:BlobCastPlayer) : Object
      {
         var blob:Object;
         var chosen:int = this._chosenChoices.hasDataForPlayer(forPlayer) ? this._chosenChoices.getDataForPlayer(forPlayer) : -1;
         var choices:Array = this._getChoicesFn(forPlayer);
         if(!this._allowDuplicates)
         {
            choices.forEach(function(c:Object, i:int, a:Array):void
            {
               c.disabled = c.disabled || _anyPlayerHasChosenChoiceIndex(i);
            });
         }
         blob = {
            "state":"MakeSingleChoice",
            "prompt":this._getPromptFn(forPlayer),
            "choices":choices,
            "choiceId":this._getChoiceIdFn(forPlayer),
            "classes":this._getClassesFn(forPlayer)
         };
         if(this._getChoiceTypeFn != null && this._getChoiceTypeFn != Nullable.NULL_FUNCTION)
         {
            blob.choiceType = this._getChoiceTypeFn(forPlayer);
         }
         if(chosen >= 0)
         {
            blob.chosen = chosen;
            blob.doneText = this._getDoneTextFn(forPlayer,chosen);
         }
         this._finalizeBlobFn(forPlayer,blob);
         return blob;
      }
      
      public function handleMessage(fromPlayer:BlobCastPlayer, message:Object) : String
      {
         if(this._chosenChoices.hasDataForPlayer(fromPlayer))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(!message.hasOwnProperty("action"))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         var action:String = String(message.action);
         if(action != "choose")
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         var choice:int = int(message.choice);
         if(!NumberUtil.isValidIndexForArray(choice,this._getChoicesFn(fromPlayer)))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(!this._allowDuplicates && this._anyPlayerHasChosenChoiceIndex(choice))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(!this._playerMadeChoiceFn(fromPlayer,choice))
         {
            return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
         }
         this._chosenChoices.setDataForPlayer(fromPlayer,choice);
         return this._allowDuplicates ? InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB : InteractionHandler.MESSAGE_RESULT_UPDATE_ALL_BLOBS;
      }
      
      public function playerIsDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return this._chosenChoices.hasDataForPlayer(p);
      }
      
      public function cleanUp(finishedOnPlayerInput:Boolean) : void
      {
         this._doneFn(finishedOnPlayerInput,this._chosenChoices);
      }
   }
}
