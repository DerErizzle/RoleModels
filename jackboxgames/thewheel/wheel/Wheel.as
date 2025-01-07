package jackboxgames.thewheel.wheel
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.getDefinitionByName;
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.utils.*;
   
   public class Wheel extends Sprite
   {
      public static const REPLACE_TYPE_OVERWRITE:String = "overwrite";
      
      public static const REPLACE_TYPE_FLIP:String = "flip";
      
      private var _id:String;
      
      private var _bcMc:MovieClip;
      
      private var _sliceContainer:Sprite;
      
      private var _iconRingMc:MovieClip;
      
      private var _flapperMc:MovieClip;
      
      private var _iconRingShower:MovieClipShower;
      
      private var _slices:Array;
      
      private var _flapperPosition:int;
      
      private var _flapEveryDegrees:int;
      
      private var _sliceSize:int;
      
      private var _slicePositions:Array;
      
      private var _spin:Number;
      
      public function Wheel(id:String, flapperPosition:int, flapEveryDegrees:int, sliceSize:int, bgClassName:String, flapperClassNameOrMc:*)
      {
         var flapperClass:Class = null;
         super();
         this._id = id;
         this._slices = [];
         this._spin = 0;
         var bgClass:Class = Class(getDefinitionByName(bgClassName));
         this._bcMc = new bgClass();
         addChild(this._bcMc);
         this._sliceContainer = new Sprite();
         addChild(this._sliceContainer);
         var iconRingClass:Class = Class(getDefinitionByName("IconRing"));
         this._iconRingMc = new iconRingClass();
         addChild(this._iconRingMc);
         this._flapperPosition = flapperPosition;
         this._flapEveryDegrees = flapEveryDegrees;
         if(flapperClassNameOrMc is MovieClip)
         {
            this._flapperMc = flapperClassNameOrMc;
         }
         else if(flapperClassNameOrMc is String)
         {
            flapperClass = Class(getDefinitionByName(flapperClassNameOrMc));
            this._flapperMc = new flapperClass();
            this._flapperMc.rotation = this._flapperPosition;
            addChild(this._flapperMc);
         }
         Assert.assert(this._flapperMc != null);
         this._iconRingShower = new MovieClipShower(this._iconRingMc);
         this._sliceSize = sliceSize;
         this._slicePositions = [];
         for(var position:int = 0; position < 360; position += this._sliceSize)
         {
            this._slicePositions.push(position);
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get iconRingShower() : MovieClipShower
      {
         return this._iconRingShower;
      }
      
      public function get flapperPosition() : int
      {
         return this._flapperPosition;
      }
      
      public function get sliceSize() : int
      {
         return this._sliceSize;
      }
      
      public function get slicePositions() : Array
      {
         return this._slicePositions;
      }
      
      public function dispose() : void
      {
         var s:Slice = null;
         this._iconRingShower.dispose();
         for each(s in this._slices)
         {
            s.dispose();
         }
         this._slices = [];
         removeChildren();
      }
      
      private function _setSpin(val:Number) : void
      {
         this._spin = val;
         this._bcMc.rotation = this._spin;
         this._sliceContainer.rotation = this._spin;
         this._iconRingMc.rotation = this._spin;
      }
      
      public function get spin() : Number
      {
         return this._spin;
      }
      
      public function set spin(val:Number) : void
      {
         var flapperBefore:int = this._spin + this._flapperPosition;
         this._setSpin(val);
         var flapperAfter:int = this._spin + this._flapperPosition;
         if(!this._flapperMc.isPlaying && Math.floor(flapperBefore / this._flapEveryDegrees) != Math.floor(flapperAfter / this._flapEveryDegrees))
         {
            JBGUtil.gotoFrame(this._flapperMc,"Tick");
         }
      }
      
      public function setSpinInstant(val:Number) : void
      {
         this._setSpin(val);
      }
      
      public function addSlice(params:SliceParameters, position:int) : Slice
      {
         var s:Slice = new Slice(params,position,this._sliceSize);
         s.mc.rotation = position;
         this._sliceContainer.addChild(s.mc);
         this._slices.push(s);
         return s;
      }
      
      public function removeSlice(existingSlice:Slice) : void
      {
         ArrayUtil.removeElementFromArray(this._slices,existingSlice);
         this._sliceContainer.removeChild(existingSlice.mc);
         existingSlice.dispose();
      }
      
      private function _replaceOverwrite(replaceMe:Slice, withThisSlice:Slice, doneFn:Function) : void
      {
         ArrayUtil.removeElementFromArray(this._slices,replaceMe);
         withThisSlice.slideIn(function():void
         {
            _sliceContainer.removeChild(replaceMe.mc);
            replaceMe.dispose();
            doneFn();
         });
      }
      
      private function _replaceFlip(replaceMe:Slice, withThisSlice:Slice, doneFn:Function) : void
      {
         var c:Counter;
         ArrayUtil.removeElementFromArray(this._slices,replaceMe);
         c = new Counter(2,function():void
         {
            _sliceContainer.removeChild(replaceMe.mc);
            replaceMe.dispose();
            doneFn();
         });
         replaceMe.flipOff(c.generateDoneFn());
         withThisSlice.flipOn(c.generateDoneFn());
      }
      
      private function _replaceSlice(replaceMe:Slice, withThisSlice:Slice, type:String, doneFn:Function) : void
      {
         if(type == REPLACE_TYPE_OVERWRITE)
         {
            this._replaceOverwrite(replaceMe,withThisSlice,doneFn);
         }
         else if(type == REPLACE_TYPE_FLIP)
         {
            this._replaceFlip(replaceMe,withThisSlice,doneFn);
         }
      }
      
      public function replaceSliceWithNewSlice(replaceMe:Slice, withThisParams:SliceParameters, type:String, doneFn:Function) : Slice
      {
         var newSlice:Slice = this.addSlice(withThisParams,replaceMe.position);
         this._replaceSlice(replaceMe,newSlice,type,doneFn);
         return newSlice;
      }
      
      public function replaceSliceWithExistingSlice(replaceMe:Slice, withThisSlice:Slice, type:String, doneFn:Function) : void
      {
         this._replaceSlice(replaceMe,withThisSlice,type,doneFn);
      }
      
      public function getAllSlices() : Array
      {
         return this._slices;
      }
      
      public function getSliceAtFlapper() : Slice
      {
         return this.getSliceAt(this._flapperPosition,true);
      }
      
      public function getSlicesAt(position:int, withSpin:Boolean) : Array
      {
         position %= 360;
         var sliceToReturn:Slice = null;
         return this._slices.filter(function(s:Slice, ... args):Boolean
         {
            var start:* = (withSpin ? s.position + _spin : s.position) % 360;
            var end:* = (start + s.size) % 360;
            if(end >= start)
            {
               if(position >= start && position < end)
               {
                  return true;
               }
            }
            else if(position >= start || position < end)
            {
               return true;
            }
            return false;
         });
      }
      
      public function getSliceAt(position:int, withSpin:Boolean) : Slice
      {
         var s:Slice = null;
         var start:Number = NaN;
         var end:Number = NaN;
         position %= 360;
         var sliceToReturn:Slice = null;
         for each(s in this._slices)
         {
            start = (withSpin ? s.position + this._spin : s.position) % 360;
            end = (start + s.size) % 360;
            if(end >= start)
            {
               if(position >= start && position < end)
               {
                  sliceToReturn = s;
               }
            }
            else if(position >= start || position < end)
            {
               sliceToReturn = s;
            }
         }
         return sliceToReturn;
      }
      
      public function getSlicesAdjacentTo(s:Slice) : Array
      {
         var slices:Array = [];
         var reverse:Slice = this.getSliceAt(s.position - GameState.instance.jsonData.gameConfig.sliceSize,false);
         if(Boolean(reverse))
         {
            slices.push(reverse);
         }
         var forward:Slice = this.getSliceAt(s.position + GameState.instance.jsonData.gameConfig.sliceSize,false);
         if(Boolean(forward))
         {
            slices.push(forward);
         }
         return slices;
      }
      
      public function getSlicesWithParams(params:SliceParameters) : Array
      {
         return this._slices.filter(function(s:Slice, ... args):Boolean
         {
            return s.params == params;
         });
      }
      
      public function getSlicesWithType(type:SliceType) : Array
      {
         return this._slices.filter(function(s:Slice, ... args):Boolean
         {
            return s.params.type == type;
         });
      }
      
      public function getSlicesAdjacentToSlicesWithType(type:SliceType) : Array
      {
         var neighboring:Array = MapFold.process(this.getSlicesWithType(type),function(s:Slice, ... args):Array
         {
            return getSlicesAdjacentTo(s);
         },ArrayUtil.FOLD_CONCAT);
         return ArrayUtil.deduplicated(neighboring);
      }
      
      public function distanceToSlice(slice:Slice) : Object
      {
         var adjustToWheel:Function = function(d:int):int
         {
            return d < 90 ? 90 - d : 90 + (360 - d);
         };
         var start:int = (slice.position + this._spin) % 360;
         var minDist:int = adjustToWheel(start + slice.size);
         var maxDist:int = adjustToWheel(start);
         if(maxDist < minDist)
         {
            maxDist += 360;
         }
         return {
            "min":minDist,
            "max":maxDist
         };
      }
   }
}

