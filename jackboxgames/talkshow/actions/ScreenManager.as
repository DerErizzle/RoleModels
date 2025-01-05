package jackboxgames.talkshow.actions
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import jackboxgames.talkshow.api.IScreenManager;
   
   public dynamic class ScreenManager extends MovieClip implements IScreenManager
   {
       
      
      private var _fore:uint = 0;
      
      private var _back:uint = 0;
      
      private var _tags:Dictionary;
      
      private var _objTags:Dictionary;
      
      public function ScreenManager()
      {
         super();
         this._tags = new Dictionary();
         this._objTags = new Dictionary();
      }
      
      public function addToScreen(obj:DisplayObject, layer:String = null, pos:String = "front", tags:String = "") : DisplayObject
      {
         var currentInd:int = -1;
         if(contains(obj))
         {
            currentInd = getChildIndex(obj);
         }
         var newIndex:uint = uint(this.determineIndex(layer,pos,currentInd));
         if(contains(obj))
         {
            setChildIndex(obj,newIndex);
         }
         else
         {
            addChildAt(obj,newIndex);
         }
         switch(layer)
         {
            case "foreground":
               obj.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromForeground,false,0,true);
               this._fore += 1;
               break;
            case "background":
               obj.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromBackground,false,0,true);
               this._back += 1;
               break;
            default:
               obj.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromMiddle,false,0,true);
         }
         this.addTags(obj,tags);
         return obj;
      }
      
      public function addTags(obj:DisplayObject, taglist:String) : void
      {
         var tag:String = null;
         var d:Array = null;
         if(taglist == null || taglist.length == 0)
         {
            return;
         }
         var tags:Array = taglist.split(",");
         var oTags:Array = this._objTags[obj];
         if(oTags == null)
         {
            oTags = [];
            this._objTags[obj] = oTags;
         }
         for each(tag in tags)
         {
            if(tag.length != 0)
            {
               d = this._tags[tag];
               if(d == null)
               {
                  d = [];
                  this._tags[tag] = d;
               }
               this.addToArray(d,obj);
               this.addToArray(oTags,tag);
            }
         }
      }
      
      public function removeTags(obj:DisplayObject, taglist:String) : void
      {
         var tag:String = null;
         var d:Array = null;
         if(taglist == null || taglist.length == 0)
         {
            return;
         }
         var tags:Array = taglist.split(",");
         for each(tag in tags)
         {
            d = this._tags[tag];
            if(d != null)
            {
               this.removeFromArray(d,obj);
            }
            this.removeFromArray(this._objTags[obj],tag);
         }
      }
      
      public function getTagged(tag:String) : Array
      {
         var list:Array = this._tags[tag];
         if(list == null)
         {
            return [];
         }
         return list;
      }
      
      public function get screen() : MovieClip
      {
         return this;
      }
      
      protected function determineIndex(layer:String, pos:String, currentInd:int) : int
      {
         var nc:int = 0;
         if(currentInd != -1)
         {
            if(currentInd >= numChildren - this._fore)
            {
               this.removeFromLayer(getChildAt(currentInd),1);
            }
            if(currentInd < this._back)
            {
               this.removeFromLayer(getChildAt(currentInd),-1);
            }
            nc = numChildren - 1;
         }
         else
         {
            nc = numChildren;
         }
         var frontOfFront:int = nc;
         var backOfFront:int = nc - this._fore;
         var frontOfBack:int = int(this._back);
         var backOfBack:int = 0;
         if(pos != "front" && pos != "back")
         {
            pos = "front";
         }
         switch(layer)
         {
            case "foreground":
               if(pos == "front")
               {
                  return frontOfFront;
               }
               if(pos == "back")
               {
                  return backOfFront;
               }
               break;
            case "background":
               if(pos == "back")
               {
                  return backOfBack;
               }
               if(pos == "front")
               {
                  return frontOfBack;
               }
               break;
            default:
               if(pos == "back")
               {
                  return frontOfBack;
               }
               if(pos == "front")
               {
                  return backOfFront;
               }
               break;
         }
         return backOfFront;
      }
      
      private function removeFromArray(array:Array, item:Object) : Boolean
      {
         if(array == null)
         {
            return false;
         }
         for(var i:int = 0; i < array.length; i++)
         {
            if(item == array[i])
            {
               array.splice(i,1);
               return true;
            }
         }
         return false;
      }
      
      private function addToArray(array:Array, item:Object) : Boolean
      {
         if(array == null)
         {
            return false;
         }
         for(var i:int = 0; i < array.length; i++)
         {
            if(item == array[i])
            {
               return false;
            }
         }
         array.push(item);
         return true;
      }
      
      protected function removedFromForeground(e:Event) : void
      {
         this.removeFromLayer(e.target as DisplayObject,1);
      }
      
      protected function removedFromBackground(e:Event) : void
      {
         this.removeFromLayer(e.target as DisplayObject,-1);
      }
      
      protected function removedFromMiddle(e:Event) : void
      {
         this.removeFromLayer(e.target as DisplayObject,0);
      }
      
      protected function removeFromLayer(obj:DisplayObject, layer:int) : void
      {
         var f:Function = null;
         switch(layer)
         {
            case 1:
               f = this.removedFromForeground;
               this._fore -= 1;
               break;
            case -1:
               f = this.removedFromBackground;
               this._back -= 1;
               break;
            default:
               f = this.removedFromMiddle;
         }
         obj.removeEventListener(Event.REMOVED_FROM_STAGE,f);
         this.clearTags(obj);
      }
      
      private function clearTags(obj:Object) : void
      {
         var s:String = null;
         if(this._objTags[obj] == null)
         {
            return;
         }
         for each(s in this._objTags[obj])
         {
            this.removeFromArray(this._tags[s],obj);
         }
         delete this._objTags[obj];
      }
   }
}
