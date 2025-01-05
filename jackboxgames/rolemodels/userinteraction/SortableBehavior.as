package jackboxgames.rolemodels.userinteraction
{
   import jackboxgames.blobcast.model.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class SortableBehavior implements IInteractionBehavior
   {
       
      
      private var _showDoubleDown:Boolean;
      
      private var _setupFn:Function;
      
      private var _getPromptFn:Function;
      
      private var _getChoicesFn:Function;
      
      private var _getPlayersFn:Function;
      
      private var _finalizeBlobFn:Function;
      
      private var _userUpdatedSlotsFn:Function;
      
      private var _doneFn:Function;
      
      private var _choices:PerPlayerContainer;
      
      private var _playersWhoHaveSubmitted:Array;
      
      public function SortableBehavior(showDoubleDown:Boolean, setupFn:Function, getPromptFn:Function, getChoicesFn:Function, getPlayersFn:Function, finalizeBlobFn:Function, userUpdatedSlotsFn:Function, doneFn:Function)
      {
         super();
         this._showDoubleDown = showDoubleDown;
         this._setupFn = setupFn;
         this._getPromptFn = getPromptFn;
         this._getChoicesFn = getChoicesFn;
         this._getPlayersFn = getPlayersFn;
         this._finalizeBlobFn = finalizeBlobFn;
         this._userUpdatedSlotsFn = userUpdatedSlotsFn;
         this._doneFn = doneFn;
      }
      
      public function setup(players:Array) : void
      {
         this._choices = new PerPlayerContainer();
         this._setupFn(players);
         this._playersWhoHaveSubmitted = [];
      }
      
      public function generateBlob(forPlayer:BlobCastPlayer) : Object
      {
         var isConfirmed:Boolean = ArrayUtil.arrayContainsElement(this._playersWhoHaveSubmitted,forPlayer);
         var blob:Object = {
            "state":"Sortable",
            "showDoubleDown":this._showDoubleDown,
            "prompt":this._getPromptFn(forPlayer),
            "roles":this._getChoicesFn(forPlayer),
            "players":this._getPlayersFn(),
            "canConfirm":true
         };
         this._finalizeBlobFn(forPlayer,blob);
         return isConfirmed ? {"state":"Logo"} : blob;
      }
      
      public function handleMessage(fromPlayer:BlobCastPlayer, message:Object) : String
      {
         if(!ObjectUtil.hasProperties(message,["action","layout","confirm"]))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         var action:String = String(message.action);
         if(action != "sort")
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         var results:Array = message.layout;
         var submitted:Boolean = Boolean(message.confirm) && results.length == this._getPlayersFn().length;
         if(results.length > 0)
         {
            if(!this._userUpdatedSlotsFn(fromPlayer,results,submitted))
            {
               return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
            }
         }
         this._choices.setDataForPlayer(fromPlayer,message.layout);
         if(submitted)
         {
            this._playersWhoHaveSubmitted.push(fromPlayer);
            return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
         }
         return InteractionHandler.MESSAGE_RESULT_NOTHING;
      }
      
      public function playerIsDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._playersWhoHaveSubmitted,p);
      }
      
      public function cleanUp(finishedOnPlayerInput:Boolean) : void
      {
         this._doneFn(finishedOnPlayerInput,this._choices);
      }
   }
}
