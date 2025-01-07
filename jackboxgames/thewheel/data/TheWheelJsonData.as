package jackboxgames.thewheel.data
{
   import flash.utils.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.loader.*;
   import jackboxgames.utils.*;
   
   public class TheWheelJsonData
   {
      public static const DATA_TO_LOAD:Array = [new JsonDataDef("avatars.json",Avatar,"_avatars"),new JsonDataDef("gameconfig.json",GameConfig,"_gameConfig"),new JsonDataDef("spintypes.json",SpinType,"_spinTypes"),new JsonDataDef("roundsetups.json",RoundSetup,"_roundSetups"),new JsonDataDef("timerconfigs.json",TimerConfig,"_timerConfigs"),new JsonDataDef("startingsliceconfigs.json",StartingSliceConfig,"_startingSliceConfigs"),new JsonDataDef("answerbuckets.json",AnswerBucket,"_answerBuckets")];
      
      private var _gameConfig:GameConfig;
      
      private var _avatars:Array;
      
      private var _spinTypes:Array;
      
      private var _roundSetups:Array;
      
      private var _startingSliceConfigs:Array;
      
      private var _timerConfigs:Array;
      
      private var _answerBuckets:Array;
      
      public function TheWheelJsonData()
      {
         super();
      }
      
      public function get gameConfig() : GameConfig
      {
         return this._gameConfig;
      }
      
      public function get avatars() : Array
      {
         return this._avatars;
      }
      
      public function get roundSetups() : Array
      {
         return this._roundSetups;
      }
      
      public function get startingSliceConfigs() : Array
      {
         return this._startingSliceConfigs;
      }
      
      public function get answerBuckets() : Array
      {
         return this._answerBuckets;
      }
      
      public function reset() : void
      {
         var d:JsonDataDef = null;
         for each(d in DATA_TO_LOAD)
         {
            this[d.property] = null;
         }
      }
      
      public function load() : Promise
      {
         var dataPromises:Array = null;
         var basePath:String = null;
         var _this:TheWheelJsonData = null;
         dataPromises = [];
         basePath = BuildConfig.instance.configVal("jsonDataRoot");
         _this = this;
         DATA_TO_LOAD.forEach(function(d:JsonDataDef, ... args):void
         {
            var dataPromise:Promise = null;
            dataPromise = new Promise();
            dataPromises.push(dataPromise);
            JBGLoader.instance.loadFile(basePath + "/" + d.file,function(result:Object):void
            {
               var json:Object = null;
               var array:Array = null;
               var arrayPromises:Array = null;
               if(!result || !result.success)
               {
                  dataPromise.reject(null);
                  return;
               }
               json = result.loader.contentAsJSON;
               if(!json || !json.payload)
               {
                  dataPromise.reject(null);
                  return;
               }
               if(getQualifiedClassName(json.payload) == "Object")
               {
                  _this[d.property] = new d.type();
                  IJsonData(_this[d.property]).load(json.payload).then(function(value:*):void
                  {
                     dataPromise.resolve(value);
                  },function(value:*):void
                  {
                     dataPromise.reject(value);
                  });
               }
               else if(getQualifiedClassName(json.payload) == "Array")
               {
                  array = json.payload.map(function(... args):IJsonData
                  {
                     return new d.type();
                  });
                  arrayPromises = array.map(function(data:IJsonData, i:int, a:Array):Promise
                  {
                     return data.load(json.payload[i]);
                  });
                  _this[d.property] = array;
                  PromiseUtil.ALL(arrayPromises).then(function(value:*):void
                  {
                     dataPromise.resolve(value);
                  },function(value:*):void
                  {
                     dataPromise.reject(value);
                  });
               }
               else
               {
                  dataPromise.reject(null);
               }
            });
         });
         return PromiseUtil.ALL(dataPromises);
      }
      
      public function getSpinType(category:String, power:Number) : SpinType
      {
         power = Math.max(0,Math.min(power,1));
         var type:SpinType = ArrayUtil.find(this._spinTypes,function(s:SpinType, ... args):Boolean
         {
            if(s.category != category)
            {
               return false;
            }
            if(power == 1 && s.maxPower == 1)
            {
               return true;
            }
            return power >= s.minPower && power < s.maxPower;
         });
         Assert.assert(type != null);
         return type;
      }
      
      public function getTimerConfig(id:String) : TimerConfig
      {
         var cfg:TimerConfig = ArrayUtil.find(this._timerConfigs,function(tc:TimerConfig, ... args):Boolean
         {
            return tc.id == id;
         });
         if(!cfg)
         {
            cfg = new TimerConfig();
            cfg.load({
               "totalDurationInSec":5,
               "extendedDurationInSec":10
            });
         }
         return cfg;
      }
   }
}

