package jackboxgames.utils
{
   import flash.events.Event;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.api.events.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.talkshow.utils.*;
   
   public final class TSUtil
   {
      private static var _ts:IEngineAPI;
      
      private static var _cancelInputListeners:Array = [];
      
      private static var _safeInputCancelers:Array = [];
      
      public function TSUtil()
      {
         super();
      }
      
      public static function setup(ts:IEngineAPI) : void
      {
         _ts = ts;
      }
      
      public static function cancelInputListeners() : void
      {
         var f:Function = null;
         for each(f in _cancelInputListeners)
         {
            f();
         }
         _cancelInputListeners = [];
      }
      
      public static function createRefEndFn(ref:IActionRef) : Function
      {
         var okayToEndRef:Boolean = false;
         var inputCanceller:Function = null;
         var jumpCanceller:Function = null;
         okayToEndRef = true;
         inputCanceller = JBGUtil.eventOnce(PlaybackEngine.getInstance(),InputEvent.INPUT,function(evt:Event):void
         {
            okayToEndRef = false;
         });
         jumpCanceller = JBGUtil.eventOnce(PlaybackEngine.getInstance(),CellEvent.CELL_JUMP,function(evt:Event):void
         {
            okayToEndRef = false;
         });
         _cancelInputListeners.push(inputCanceller);
         _cancelInputListeners.push(jumpCanceller);
         return function(... args):*
         {
            ArrayUtil.removeElementFromArray(_cancelInputListeners,inputCanceller);
            ArrayUtil.removeElementFromArray(_cancelInputListeners,jumpCanceller);
            if(okayToEndRef)
            {
               ref.end();
            }
            return null;
         };
      }
      
      public static function setTemplateRootPath(path:String) : void
      {
         _ts.g.templateRootPath = path;
      }
      
      public static function createCellPath(fc:String, cell:String) : String
      {
         return PlaybackEngine.getInstance().activeExport.projectName + ":" + fc + ":" + cell;
      }
      
      public static function safeInput(input:String) : void
      {
         var canceler:Function = null;
         canceler = JBGUtil.runFunctionAfter(function():void
         {
            ArrayUtil.removeElementFromArray(_safeInputCancelers,canceler);
            _ts.input(input);
         },Duration.fromMs(100));
         _safeInputCancelers.push(canceler);
      }
      
      public static function cancelSafeInputs() : void
      {
         var canceler:Function = null;
         for each(canceler in _safeInputCancelers)
         {
            canceler();
         }
         _safeInputCancelers = [];
      }
      
      public static function parseTimingString(s:String) : Object
      {
         var r:RegExp = /([SE])\s*\+\s*([0-9]*[.]?[0-9]+)/i;
         var captures:Array = r.exec(s);
         if(!captures)
         {
            return null;
         }
         var start:Boolean = captures[1].toUpperCase() == "S";
         var seconds:Number = Number(captures[2]);
         if(isNaN(seconds))
         {
            return null;
         }
         return {
            "start":start,
            "duration":Duration.fromSec(seconds)
         };
      }
      
      public static function resolveArrayFromVariablePath(path:String, type:Class) : Array
      {
         var lookup:* = VariableUtil.getVariableValue(path);
         if(lookup && lookup is Array)
         {
            return lookup;
         }
         if(lookup && lookup is type)
         {
            return [lookup];
         }
         return [];
      }
      
      public static function resolveFromVariablePath(path:String, type:Class) : *
      {
         var lookup:* = VariableUtil.getVariableValue(path);
         if(lookup is type)
         {
            return lookup;
         }
         return null;
      }
   }
}

