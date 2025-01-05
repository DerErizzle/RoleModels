package jackboxgames.ugc
{
   import jackboxgames.blobcast.services.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class UGCContentManager extends PausableEventDispatcher
   {
      
      private static var _instance:UGCContentManager;
       
      
      private var _activeContent:WatchableValue;
      
      private var _timeLastSeenId:Object;
      
      public function UGCContentManager()
      {
         super();
         this._activeContent = new WatchableValue(null,null,null,null);
      }
      
      public static function get instance() : UGCContentManager
      {
         if(!_instance)
         {
            _instance = new UGCContentManager();
         }
         return _instance;
      }
      
      public function get activeContent() : WatchableValue
      {
         return this._activeContent;
      }
      
      public function reset() : void
      {
         this._activeContent.val = null;
         this._timeLastSeenId = {};
      }
      
      public function activateContentData(data:Object, resultFn:Function) : void
      {
         this._activeContent.val = data;
         this._prepareContent();
         resultFn({"success":true});
      }
      
      private function _prepareContent() : void
      {
         var c:Object = null;
         var currentIndex:int = 0;
         for each(c in this._activeContent.val.blob.content)
         {
            c.id = "UGC_" + currentIndex;
            c.isUGC = true;
            c.path = ContentManager.MAIN_CONTENT_SOURCE;
            c.random_for_content_manager = Math.random();
            currentIndex++;
         }
      }
      
      public function clearContent() : void
      {
         this.reset();
      }
      
      public function getRandomContent(num:int) : Array
      {
         var contentLeft:Array;
         var randomize:Array;
         var contentChosen:Array;
         var currentDate:Date;
         var o:Object = null;
         if(!this._activeContent.val)
         {
            return [];
         }
         contentLeft = this._activeContent.val.blob.content.filter(function(o:Object, i:int, a:Array):Boolean
         {
            return !ObjectUtil.hasProperties(_timeLastSeenId,[o.id]);
         });
         randomize = ArrayUtil.shuffled(contentLeft);
         contentChosen = randomize.splice(0,num);
         currentDate = new Date();
         for each(o in contentChosen)
         {
            this._timeLastSeenId[o.id] = currentDate.time;
         }
         return contentChosen;
      }
   }
}
