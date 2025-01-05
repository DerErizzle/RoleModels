package jackboxgames.text
{
   import jackboxgames.utils.IToSimpleObject;
   import jackboxgames.utils.WatchableValue;
   
   public class UserString implements IToSimpleObject
   {
       
      
      private var _id:int;
      
      private var _unfiltered:String;
      
      private var _author:*;
      
      private var _metadata:*;
      
      private var _filterFn:Function;
      
      private var _isCensored:WatchableValue;
      
      public function UserString(id:int, unfiltered:String, author:*, metadata:*, filterFn:Function)
      {
         super();
         this._id = id;
         this._unfiltered = unfiltered;
         this._author = author;
         this._metadata = metadata;
         this._filterFn = filterFn;
         this._isCensored = new WatchableValue(false,this);
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get unfiltered() : String
      {
         return this._unfiltered;
      }
      
      public function get filtered() : String
      {
         return this._filterFn(this._unfiltered);
      }
      
      public function get author() : *
      {
         return this._author;
      }
      
      public function get metadata() : *
      {
         return this._metadata;
      }
      
      public function get isCensored() : WatchableValue
      {
         return this._isCensored;
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "text":this.filtered,
            "isCensored":this.isCensored.val
         };
      }
   }
}
