package jackboxgames.rolemodels.userinteraction
{
   import jackboxgames.blobcast.model.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.settings.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class FeedInteraction implements IInteractionBehavior
   {
      
      private static const FEED_ACTION:String = "feed";
       
      
      private var _adapter:IFeedInteractionAdapter;
      
      private var _players:Array;
      
      private var _totalBiscuits:int;
      
      public function FeedInteraction(adapter:IFeedInteractionAdapter)
      {
         super();
         this._adapter = adapter;
      }
      
      public function get totalBiscuits() : int
      {
         return this._totalBiscuits;
      }
      
      public function get allBiscuitsFed() : Boolean
      {
         var p:Player = null;
         if(this._totalBiscuits == 0)
         {
            return false;
         }
         for each(p in this._players)
         {
            if(p.score.val > 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function setup(players:Array) : void
      {
         this._players = players;
         this._totalBiscuits = 0;
      }
      
      public function generateBlob(forPlayer:BlobCastPlayer) : Object
      {
         var p:Player = Player(forPlayer);
         var choices:Array = [{
            "action":FEED_ACTION,
            "text":(p.score.val > 0 ? LocalizationUtil.getPrintfText("FEED_MOUTH_BUTTON_TEXT",p.score.val) : LocalizationUtil.getPrintfText("FEED_MOUTH_DISABLED_BUTTON_TEXT")),
            "disabled":p.score.val <= 0
         }];
         return {
            "state":"Lobby",
            "playerCanStartGame":p.isVIP && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val,
            "playerIsVIP":p.isVIP,
            "canDoUGC":false,
            "playerCanCensor":false,
            "choices":choices
         };
      }
      
      public function handleMessage(fromPlayer:BlobCastPlayer, message:Object) : String
      {
         var p:Player = Player(fromPlayer);
         if(message.action == FEED_ACTION)
         {
            ++this._totalBiscuits;
            p.score.val -= 1;
            this._adapter.onFeed();
         }
         return InteractionHandler.MESSAGE_RESULT_UPDATE_BLOB;
      }
      
      public function playerIsDoneInteracting(p:BlobCastPlayer) : Boolean
      {
         return false;
      }
      
      public function cleanUp(finishedOnPlayerInput:Boolean) : void
      {
      }
   }
}
