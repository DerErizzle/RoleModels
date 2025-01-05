package jackboxgames.userinteraction.commonbehaviors
{
   import jackboxgames.blobcast.model.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class EnterSingleText implements IInteractionBehavior
   {
       
      
      private var _maxLength:int;
      
      private var _allowDuplicates:Boolean;
      
      private var _setupFn:Function;
      
      private var _getPromptFn:Function;
      
      private var _getPlaceholderFn:Function;
      
      private var _getDoneTextFn:Function;
      
      private var _getErrorTextFn:Function;
      
      private var _getInputTypeFn:Function;
      
      private var _getEntryIdFn:Function;
      
      private var _finalizeBlobFn:Function;
      
      private var _onPlayerEntered:Function;
      
      protected var _doneFn:Function;
      
      protected var _players:Array;
      
      protected var _entries:PerPlayerContainer;
      
      private var _playersThatHaveErrored:Array;
      
      public function EnterSingleText(maxLength:int, allowDuplicates:Boolean, setupFn:Function, getPromptFn:Function, getPlaceholderFn:Function, getDoneTextFn:Function, getErrorTextFn:Function, getInputTypeFn:Function, getEntryIdFn:Function, finalizeBlobFn:Function, onPlayerEntered:Function, doneFn:Function)
      {
         super();
         this._maxLength = maxLength;
         this._allowDuplicates = allowDuplicates;
         this._setupFn = setupFn;
         this._getPromptFn = getPromptFn;
         this._getPlaceholderFn = getPlaceholderFn;
         this._getDoneTextFn = getDoneTextFn;
         this._getErrorTextFn = getErrorTextFn;
         this._getInputTypeFn = getInputTypeFn;
         this._getEntryIdFn = getEntryIdFn;
         this._finalizeBlobFn = finalizeBlobFn;
         this._onPlayerEntered = onPlayerEntered;
         this._doneFn = doneFn;
      }
      
      public function setup(players:Array) : void
      {
         this._players = players;
         this._entries = new PerPlayerContainer();
         this._playersThatHaveErrored = [];
         this._setupFn(players);
      }
      
      public function generateBlob(forPlayer:BlobCastPlayer) : Object
      {
         var entry:String = this._entries.getDataForPlayer(forPlayer);
         var blob:Object = {
            "state":"EnterSingleText",
            "entryId":this._getEntryIdFn(forPlayer),
            "prompt":this._getPromptFn(forPlayer),
            "placeholder":this._getPlaceholderFn(forPlayer),
            "inputType":this._getInputTypeFn(),
            "maxLength":this._maxLength,
            "entry":(Boolean(entry) ? true : false),
            "error":(ArrayUtil.arrayContainsElement(this._playersThatHaveErrored,forPlayer) ? this._getErrorTextFn(forPlayer) : null)
         };
         if(Boolean(entry))
         {
            blob.doneText = this._getDoneTextFn(forPlayer,entry);
         }
         this._finalizeBlobFn(forPlayer,blob);
         return blob;
      }
      
      public function handleMessage(fromPlayer:BlobCastPlayer, message:Object) : String
      {
         var otherPlayer:BlobCastPlayer = null;
         var otherEntry:String = null;
         if(this._entries.hasDataForPlayer(fromPlayer))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(!message.hasOwnProperty("entry"))
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         var entry:String = String(message.entry);
         if(!entry)
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         if(entry.length <= 0)
         {
            return InteractionHandler.MESSAGE_RESULT_ERROR;
         }
         entry = TextUtils.htmlEscapedTruncate(entry,this._maxLength);
         if(!this._allowDuplicates)
         {
            for each(otherPlayer in this._players)
            {
               if(otherPlayer != fromPlayer)
               {
                  if(this._entries.hasDataForPlayer(otherPlayer))
                  {
                     otherEntry = this._entries.getDataForPlayer(otherPlayer);
                     if(TextUtils.caseInsensitiveCompare(entry,otherEntry))
                     {
                        ArrayUtil.deduplicatedPush(this._playersThatHaveErrored,fromPlayer);
                        return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
                     }
                  }
               }
            }
         }
         if(!this._onPlayerEntered(fromPlayer,entry))
         {
            ArrayUtil.deduplicatedPush(this._playersThatHaveErrored,fromPlayer);
            return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
         }
         this._entries.setDataForPlayer(fromPlayer,entry);
         return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
      }
      
      public function playerIsDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return this._entries.hasDataForPlayer(p);
      }
      
      public function cleanUp(finishedOnPlayerInput:Boolean) : void
      {
         this._doneFn(finishedOnPlayerInput,this._entries);
      }
   }
}
