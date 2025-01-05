package jackboxgames.rolemodels.userinteraction
{
   import jackboxgames.blobcast.model.BlobCastPlayer;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class MakeSingleChoiceWithSubmit implements IInteractionBehavior
   {
       
      
      private var _setupFn:Function;
      
      private var _getPromptFn:Function;
      
      private var _getChoicesFn:Function;
      
      private var _getChoiceTypeFn:Function;
      
      private var _getChoiceIdFn:Function;
      
      private var _getClassesFn:Function;
      
      private var _finalizeBlobFn:Function;
      
      private var _playerMadeChoiceFn:Function;
      
      private var _doneFn:Function;
      
      private var _players:Array;
      
      private var _chosenChoices:PerPlayerContainer;
      
      private var _playersWhoSubmitted:Array;
      
      private var _submitIndex:int;
      
      public function MakeSingleChoiceWithSubmit(setupFn:Function, getPromptFn:Function, getChoicesFn:Function, getChoiceTypeFn:Function, getChoiceIdFn:Function, getClassesFn:Function, finalizeBlobFn:Function, playerMadeChoiceFn:Function, doneFn:Function)
      {
         super();
         this._setupFn = setupFn;
         this._getPromptFn = getPromptFn;
         this._getChoicesFn = getChoicesFn;
         this._getChoiceTypeFn = getChoiceTypeFn;
         this._getChoiceIdFn = getChoiceIdFn;
         this._getClassesFn = getClassesFn;
         this._finalizeBlobFn = finalizeBlobFn;
         this._playerMadeChoiceFn = playerMadeChoiceFn;
         this._doneFn = doneFn;
      }
      
      private function _choicesWithSubmit(forPlayer:BlobCastPlayer) : Array
      {
         var choices:Array = this._getChoicesFn(forPlayer).concat({"html":"SUBMIT"});
         this._submitIndex = choices.length - 1;
         choices[this._submitIndex].disabled = !this._chosenChoices.hasDataForPlayer(forPlayer);
         if(this._chosenChoices.hasDataForPlayer(forPlayer))
         {
            choices[this._chosenChoices.getDataForPlayer(forPlayer)].selected = true;
         }
         return choices;
      }
      
      public function setup(players:Array) : void
      {
         this._players = players;
         this._playersWhoSubmitted = [];
         this._chosenChoices = new PerPlayerContainer();
         this._setupFn(this._players);
      }
      
      public function generateBlob(forPlayer:BlobCastPlayer) : Object
      {
         var blob:Object = {
            "state":"MakeSingleChoice",
            "prompt":this._getPromptFn(),
            "choices":this._choicesWithSubmit(forPlayer),
            "choiceId":this._getChoiceIdFn(forPlayer),
            "classes":this._getClassesFn(forPlayer)
         };
         if(this._getChoiceTypeFn != null && this._getChoiceTypeFn != Nullable.NULL_FUNCTION)
         {
            blob.choiceType = this._getChoiceTypeFn(forPlayer);
         }
         this._finalizeBlobFn(forPlayer,blob);
         return this.playerIsDoneInteracting(forPlayer) ? {"state":"Logo"} : blob;
      }
      
      public function handleMessage(fromPlayer:BlobCastPlayer, message:Object) : String
      {
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
         if(!NumberUtil.isValidIndexForArray(choice,this._choicesWithSubmit(fromPlayer)))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(choice == this._submitIndex)
         {
            if(!this._chosenChoices.hasDataForPlayer(fromPlayer))
            {
               return InteractionHandler.MESSAGE_RESULT_ERROR;
            }
            this._playersWhoSubmitted.push(fromPlayer);
         }
         else if(this._chosenChoices.hasDataForPlayer(fromPlayer))
         {
            if(this._chosenChoices.getDataForPlayer(fromPlayer) == choice)
            {
               return InteractionHandler.MESSAGE_RESULT_ERROR;
            }
            this._chosenChoices.setDataForPlayer(fromPlayer,choice);
         }
         else
         {
            this._chosenChoices.setDataForPlayer(fromPlayer,choice);
         }
         this._playerMadeChoiceFn(fromPlayer,choice,this._chosenChoices.hasDataForAllOfThesePlayers(this._players));
         return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
      }
      
      public function playerIsDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._playersWhoSubmitted,p);
      }
      
      public function cleanUp(finishedOnPlayerInput:Boolean) : void
      {
         this._doneFn(finishedOnPlayerInput,this._chosenChoices);
      }
   }
}
