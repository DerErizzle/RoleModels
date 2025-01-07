package jackboxgames.moderation.model
{
   import jackboxgames.events.EventWithData;
   import jackboxgames.moderation.ModerationConstants;
   import jackboxgames.moderation.ModerationHandler;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Counter;
   
   public class ModerationWait
   {
      private var _handler:ModerationHandler;
      
      private var _dataToModerate:Array;
      
      private var _c:Counter;
      
      public function ModerationWait(handler:ModerationHandler, dataToModerate:Array, doneFn:Function)
      {
         super();
         this._dataToModerate = dataToModerate.filter(function(data:IUserData, ... args):Boolean
         {
            return data.moderationStatus == ModerationConstants.MODERATION_STATUS_PENDING;
         });
         if(this._dataToModerate.length == 0)
         {
            this._dataToModerate = null;
            doneFn();
         }
         this._handler = handler;
         this._c = new Counter(this._dataToModerate.length,function():void
         {
            doneFn();
            dispose();
         });
         this._handler.addEventListener(ModerationHandler.EVENT_MODERATION_RESULT,this._onModerationResult);
      }
      
      public function dispose() : void
      {
         if(this._dataToModerate == null)
         {
            return;
         }
         this.reset();
         this._c = null;
         this._dataToModerate = null;
         this._handler = null;
      }
      
      public function reset() : void
      {
         this._handler.removeEventListener(ModerationHandler.EVENT_MODERATION_RESULT,this._onModerationResult);
         this._c.reset();
      }
      
      public function get canceler() : Function
      {
         return function():void
         {
            dispose();
         };
      }
      
      private function _onModerationResult(event:EventWithData) : void
      {
         if(ArrayUtil.arrayContainsElement(this._dataToModerate,event.data))
         {
            this._c.tick();
         }
      }
   }
}

