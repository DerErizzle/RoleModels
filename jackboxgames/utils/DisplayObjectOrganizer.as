package jackboxgames.utils
{
   import flash.display.*;
   
   public class DisplayObjectOrganizer
   {
      public static const STATE_ON:String = "on";
      
      public static const STATE_OFF:String = "off";
      
      public static const STATE_PERMANENTLY_ON:String = "permanently_on";
      
      private var _parent:DisplayObjectContainer;
      
      private var _childData:Array;
      
      public function DisplayObjectOrganizer(parent:DisplayObjectContainer)
      {
         super();
         this._parent = parent;
         this._childData = [];
      }
      
      public function reset() : void
      {
         var cd:Object = null;
         for each(cd in this._childData)
         {
            if(cd.state == STATE_ON)
            {
               cd.state = STATE_OFF;
            }
         }
         this._reorganize();
      }
      
      private function _getChildDataFromChild(child:DisplayObject) : Object
      {
         var cd:Object = null;
         for each(cd in this._childData)
         {
            if(cd.displayObject == child)
            {
               return cd;
            }
         }
         return null;
      }
      
      public function addChild(displayObject:DisplayObject, i:int) : void
      {
         var newData:Object = {
            "displayObject":displayObject,
            "index":i,
            "state":STATE_OFF
         };
         var indexToInsert:int = 0;
         while(indexToInsert < this._childData.length && this._childData[indexToInsert].index < i)
         {
            indexToInsert++;
         }
         this._childData.splice(indexToInsert,0,newData);
      }
      
      public function removeChild(displayObject:DisplayObject) : void
      {
         this._childData = this._childData.filter(function(cd:Object, ... args):Boolean
         {
            return cd.displayObject != displayObject;
         });
         this._reorganize();
      }
      
      public function setChildState(displayObject:DisplayObject, state:String) : void
      {
         var cd:Object = this._getChildDataFromChild(displayObject);
         if(!cd)
         {
            return;
         }
         if(cd.state == state)
         {
            return;
         }
         cd.state = state;
         this._reorganize();
      }
      
      private function _shouldChildDataBeOnScreen(cd:Object) : Boolean
      {
         return cd.state == STATE_ON || cd.state == STATE_PERMANENTLY_ON;
      }
      
      public function _reorganize() : void
      {
         var cd:Object = null;
         var currentIndex:int = 0;
         for each(cd in this._childData)
         {
            if(this._shouldChildDataBeOnScreen(cd))
            {
               if(!this._parent.contains(cd.displayObject))
               {
                  this._parent.addChildAt(cd.displayObject,currentIndex);
               }
               currentIndex++;
            }
            else if(!this._shouldChildDataBeOnScreen(cd))
            {
               if(this._parent.contains(cd.displayObject))
               {
                  JBGUtil.safeRemoveChild(this._parent,cd.displayObject);
               }
            }
         }
      }
   }
}

