package jackboxgames.talkshow.cells
{
   import flash.utils.Dictionary;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ILoadable;
   
   public class LoadData implements ILoadData
   {
      public static const MAX_VOLATILE:uint = 3;
      
      public static const DEFAULT_LOAD_DEPTH:uint = 1;
      
      private var _pathchecked:Dictionary;
      
      private var _checkshared:Object;
      
      private var _level:uint;
      
      private var _volatile:Boolean;
      
      public function LoadData(level:uint, volatile:Boolean = false, pcheckshared:Object = null, parentchecked:Dictionary = null)
      {
         var id:Object = null;
         super();
         this._level = level;
         if(pcheckshared != null)
         {
            this._checkshared = pcheckshared;
         }
         else
         {
            this._checkshared = new Object();
         }
         this._pathchecked = new Dictionary(true);
         if(parentchecked != null)
         {
            for(id in parentchecked)
            {
               this._pathchecked[id] = 1;
            }
         }
         this._volatile = volatile;
      }
      
      public function get level() : uint
      {
         return this._level;
      }
      
      public function decrement() : void
      {
         --this._level;
      }
      
      public function add(item:ILoadable) : Boolean
      {
         if(this._pathchecked[item] != undefined)
         {
            return false;
         }
         var set:Dictionary = Dictionary(this._checkshared[this._level]);
         if(set == null)
         {
            set = new Dictionary(true);
            this._checkshared[this._level] = set;
         }
         if(set[item] != undefined)
         {
            return false;
         }
         set[item] = 1;
         this._pathchecked[item] = 1;
         return true;
      }
      
      public function remove(item:ILoadable) : void
      {
         var idx:String = null;
         delete this._pathchecked[item];
         for(idx in this._checkshared)
         {
            delete Dictionary(this._checkshared[idx])[item];
         }
      }
      
      public function get volatile() : Boolean
      {
         return this._volatile;
      }
      
      public function set volatile(b:Boolean) : void
      {
         this._volatile = b;
      }
      
      public function clone() : ILoadData
      {
         return new LoadData(this._level,this._volatile,this._checkshared,this._pathchecked);
      }
   }
}

