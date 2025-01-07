package jackboxgames.utils
{
   import jackboxgames.events.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   
   public class ContentManager extends PausableEventDispatcher
   {
      private static var _instance:ContentManager;
      
      public static const EVENT_LOAD_RESULT:String = "ContentManager.LoadComplete";
      
      public static const EVENT_CONTENT_METADATA_CHANGED:String = "ContentManager.ContentMetadata";
      
      public static const DEFAULT_CONTENT_SOURCE:String = "content";
      
      private static const TIME_LAST_SEEN_ID_KEY:String = "TIME_LAST_SEEN_ID";
      
      private static const DISABLED_SOURCES_KEY:String = "DISABLED_SOURCES";
      
      private static const CONTENT_METADATA_KEY:String = "CONTENT_METADATA";
      
      private static const CONTENT_MULTIPLE_TO_LOOK_FORWARD_WHEN_RANDOMIZING:int = 4;
      
      private var _expressionParser:ExpressionParser;
      
      private var _expressionDataDelegate:IExpressionDataDelegate;
      
      private var _contentPerSource:Object;
      
      private var _manifestPerSource:Object;
      
      private var _timeLastSeenIdPerType:Object;
      
      private var _contentMetadataPerSourcePerType:Object;
      
      private var _disabledSources:Array;
      
      private var _isLoading:Boolean;
      
      private var _shortCircuits:Array;
      
      private var _sortByLastSeen:Boolean = true;
      
      private var _randomize:Boolean = true;
      
      public function ContentManager(expressionDataDelegate:IExpressionDataDelegate)
      {
         super();
         this._expressionParser = new ExpressionParser();
         this._expressionDataDelegate = expressionDataDelegate;
         this._contentPerSource = null;
         this._manifestPerSource = null;
         this._loadSaveData();
         this._isLoading = false;
         this._shortCircuits = [];
      }
      
      public static function initialize(expressionDataDelegate:IExpressionDataDelegate) : void
      {
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new ContentManager(expressionDataDelegate);
      }
      
      public static function get instance() : ContentManager
      {
         return _instance;
      }
      
      public function get sortByLastSeen() : Boolean
      {
         return this._sortByLastSeen;
      }
      
      public function set sortByLastSeen(value:Boolean) : void
      {
         this._sortByLastSeen = value;
      }
      
      public function get randomize() : Boolean
      {
         return this._randomize;
      }
      
      public function set randomize(value:Boolean) : void
      {
         this._randomize = value;
      }
      
      private function _loadSaveData() : void
      {
         this._timeLastSeenIdPerType = Save.instance.loadObject(TIME_LAST_SEEN_ID_KEY);
         if(!this._timeLastSeenIdPerType)
         {
            this._timeLastSeenIdPerType = {};
            Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,this._timeLastSeenIdPerType);
         }
         this._contentMetadataPerSourcePerType = Save.instance.loadObject(CONTENT_METADATA_KEY);
         if(!this._contentMetadataPerSourcePerType)
         {
            this._contentMetadataPerSourcePerType = {};
            Save.instance.saveObject(CONTENT_METADATA_KEY,this._contentMetadataPerSourcePerType);
         }
         this._disabledSources = Save.instance.loadObject(DISABLED_SOURCES_KEY);
         if(!this._disabledSources)
         {
            this._disabledSources = [];
            Save.instance.saveObject(DISABLED_SOURCES_KEY,this._disabledSources);
         }
      }
      
      public function deleteRecords() : void
      {
         var source:String = null;
         var type:String = null;
         for(source in this._contentPerSource)
         {
            for(type in this._contentPerSource[source])
            {
               this._timeLastSeenIdPerType[type] = {};
               this._contentMetadataPerSourcePerType[source][type] = {"percentCompleted":0};
            }
         }
         Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,this._timeLastSeenIdPerType);
         Save.instance.saveObject(CONTENT_METADATA_KEY,this._contentMetadataPerSourcePerType);
         dispatchEvent(new EventWithData(EVENT_CONTENT_METADATA_CHANGED,null));
      }
      
      public function load() : void
      {
         var contentRoot:String;
         var _this:ContentManager = null;
         if(this._isLoading)
         {
            Logger.error("ContentManager:load () already running.");
            return;
         }
         this._isLoading = true;
         this._contentPerSource = {};
         this._manifestPerSource = {};
         this._loadSaveData();
         _this = this;
         contentRoot = BuildConfig.instance.hasConfigVal("contentRoot") ? BuildConfig.instance.configVal("contentRoot") : DEFAULT_CONTENT_SOURCE;
         this._loadContent(contentRoot,function(success:Boolean):void
         {
            _isLoading = false;
            _this.dispatchEvent(new EventWithData(EVENT_LOAD_RESULT,{"success":success}));
         });
      }
      
      private function _loadJson(path:String, filename:String, callback:Function) : void
      {
         var g:JBGLoader = null;
         JBGLoader.instance.loadFile(path + "/" + filename,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               callback(result.loader.contentAsJSON,path);
            }
            else
            {
               callback(null,null);
            }
         });
      }
      
      private function _loadLocalizedJson(path:String, contentType:String, onLoadedFn:Function) : void
      {
         Logger.debug("ContentManager: Looking for \"" + path + "/" + LocalizationManager.instance.currentLocale + "/" + contentType + ".jet\"");
         this._loadJson(path + "/" + LocalizationManager.instance.currentLocale,contentType + ".jet",function(contentData:*, dataPath:String):void
         {
            if(!contentData)
            {
               Logger.debug("ContentManager: No localized content for type \"" + contentType + "\" loading default instead.");
               _loadJson(path,contentType + ".jet",onLoadedFn);
            }
            else
            {
               Logger.debug("ContentManager: Loaded localized content for type \"" + contentType + "\"");
               onLoadedFn(contentData,dataPath);
            }
         });
      }
      
      private function _loadContent(path:String, callback:Function) : void
      {
         var _this:ContentManager = this;
         this._loadJson(path,"manifest.jet",function(manifestData:*, dataPath:String):void
         {
            var createContentFn:Function;
            var numCompletedLoads:int = 0;
            var contentType:String = null;
            if(!manifestData)
            {
               callback(false);
               return;
            }
            _manifestPerSource[manifestData.id] = manifestData;
            _contentPerSource[manifestData.id] = {};
            if(!_contentMetadataPerSourcePerType.hasOwnProperty(manifestData.id))
            {
               _contentMetadataPerSourcePerType[manifestData.id] = {};
            }
            numCompletedLoads = 0;
            createContentFn = function(t:String):Function
            {
               return function(contentData:*, dataPath:String):void
               {
                  var isValidResult:* = undefined;
                  if(!contentData)
                  {
                     callback(false);
                     return;
                  }
                  if(!_timeLastSeenIdPerType[t])
                  {
                     _timeLastSeenIdPerType[t] = {};
                     Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,_timeLastSeenIdPerType);
                  }
                  _contentPerSource[manifestData.id][t] = [];
                  var content:* = contentData.content;
                  for(var i:* = 0; i < content.length; i++)
                  {
                     if(!content[i].hasOwnProperty("id"))
                     {
                        content[i].id = String(i);
                     }
                     content[i].contentType = t;
                     content[i].path = dataPath;
                     content[i].random_for_content_manager = Math.random();
                     if(Boolean(content[i].hasOwnProperty("isValid")))
                     {
                        if(content[i].isValid is String && content[i].isValid.length > 0)
                        {
                           isValidResult = _expressionParser.parse(content[i].isValid);
                           if(Boolean(isValidResult.succeeded))
                           {
                              content[i].isValid = isValidResult.payload;
                           }
                           else
                           {
                              Logger.error("ContentManager isValid error(" + content[i].id + "): " + isValidResult.payload);
                              delete content[i]["isValid"];
                           }
                        }
                        else
                        {
                           delete content[i]["isValid"];
                        }
                     }
                     _contentPerSource[manifestData.id][t].push(content[i]);
                  }
                  ++numCompletedLoads;
                  if(numCompletedLoads == manifestData.types.length)
                  {
                     _updateContentMetadataIfNecessary();
                     callback(true);
                  }
               };
            };
            if(manifestData.types.length == 0)
            {
               _updateContentMetadataIfNecessary();
               callback(true);
            }
            else
            {
               for each(contentType in manifestData.types)
               {
                  _loadLocalizedJson(path,contentType,createContentFn(contentType));
               }
            }
         });
      }
      
      public function get sources() : Array
      {
         return ObjectUtil.getProperties(this._contentPerSource);
      }
      
      public function getNameOfSource(source:String) : String
      {
         if(!this._manifestPerSource.hasOwnProperty(source))
         {
            return null;
         }
         return this._manifestPerSource[source].name;
      }
      
      public function getContentTypesInSource(source:String) : Array
      {
         var type:String = null;
         if(!this._contentPerSource || !this._contentPerSource.hasOwnProperty(source))
         {
            return [];
         }
         var types:Array = [];
         for(type in this._contentPerSource[source])
         {
            types.push(type);
         }
         return types;
      }
      
      public function getNumContentOfTypeInSource(source:String, type:String) : int
      {
         if(!this._contentPerSource || !this._contentPerSource.hasOwnProperty(source) || !this._contentPerSource[source].hasOwnProperty(type))
         {
            return 0;
         }
         return this._contentPerSource[source][type].length;
      }
      
      public function sourceIsEnabled(source:String) : Boolean
      {
         return !ArrayUtil.arrayContainsElement(this._disabledSources,source);
      }
      
      public function setSourceEnabled(type:String, source:String, enabled:Boolean) : void
      {
         if(enabled)
         {
            ArrayUtil.removeElementFromArray(this._disabledSources,source);
         }
         else if(!ArrayUtil.arrayContainsElement(this._disabledSources,source))
         {
            this._disabledSources.push(source);
         }
      }
      
      public function getAllContent(type:String, filters:Array = null) : Array
      {
         var source:String = null;
         var f:Function = null;
         var contentLeft:Array = [];
         for(source in this._contentPerSource)
         {
            if(this.sourceIsEnabled(source))
            {
               if(this._contentPerSource[source].hasOwnProperty(type))
               {
                  contentLeft = contentLeft.concat(this._contentPerSource[source][type]);
               }
            }
         }
         if(Boolean(filters))
         {
            for each(f in filters)
            {
               contentLeft = contentLeft.filter(f);
            }
         }
         return contentLeft;
      }
      
      public function getContentByProperty(questionType:*, property:String, value:*) : Array
      {
         var source:String = null;
         var type:String = null;
         var types:Array = ArrayUtil.makeArrayIfNecessary(questionType);
         var contentLeft:Array = [];
         for(source in this._contentPerSource)
         {
            if(this.sourceIsEnabled(source))
            {
               for each(type in types)
               {
                  if(Boolean(this._contentPerSource[source].hasOwnProperty(type)))
                  {
                     contentLeft = contentLeft.concat(this._contentPerSource[source][type]);
                  }
               }
            }
         }
         return contentLeft.filter(function(element:Object, index:int, arr:Array):Boolean
         {
            return element[property] == value;
         });
      }
      
      public function addShortCircuit(fn:Function) : Function
      {
         this._shortCircuits.push(fn);
         return function():void
         {
            ArrayUtil.removeElementFromArray(_shortCircuits,fn);
         };
      }
      
      public function getRandomUnusedContent(questionType:*, num:int, filters:Array = null, record:Boolean = true, lookBack:Boolean = true) : Array
      {
         var source:String = null;
         var sc:Function = null;
         var chosen:Array = null;
         var type:String = null;
         var scContent:Array = null;
         var f:Function = null;
         var choices:Array = null;
         var types:Array = ArrayUtil.makeArrayIfNecessary(questionType);
         var contentLeft:Array = [];
         for(source in this._contentPerSource)
         {
            if(this.sourceIsEnabled(source))
            {
               for each(type in types)
               {
                  if(Boolean(this._contentPerSource[source].hasOwnProperty(type)))
                  {
                     contentLeft = contentLeft.concat(this._contentPerSource[source][type]);
                  }
               }
            }
         }
         for each(sc in this._shortCircuits)
         {
            scContent = sc(types,num,contentLeft);
            if(Boolean(scContent))
            {
               return scContent;
            }
         }
         if(Boolean(filters))
         {
            for each(f in filters)
            {
               contentLeft = contentLeft.filter(f);
            }
         }
         contentLeft = contentLeft.filter(function(content:Object, ... args):Boolean
         {
            return !!content.hasOwnProperty("isValid") ? Boolean(IExpression(content.isValid).evaluate(_expressionDataDelegate)) : true;
         });
         if(contentLeft.length == 0)
         {
            return [];
         }
         if(this._sortByLastSeen)
         {
            contentLeft.sort(function(a:Object, b:Object):int
            {
               var timeLastSeenA:Number = _getTimeLastSeen(a.contentType,a.id);
               var timeLastSeenB:Number = _getTimeLastSeen(b.contentType,b.id);
               if(timeLastSeenA == timeLastSeenB)
               {
                  return NumberUtil.compareNumbers(a.random_for_content_manager,b.random_for_content_manager);
               }
               if(timeLastSeenA < timeLastSeenB)
               {
                  return -1;
               }
               return 1;
            });
         }
         if(this._randomize)
         {
            choices = lookBack ? ArrayUtil.shuffled(contentLeft.splice(0,num * CONTENT_MULTIPLE_TO_LOOK_FORWARD_WHEN_RANDOMIZING)) : contentLeft;
            chosen = choices.splice(0,num);
         }
         else
         {
            chosen = contentLeft.splice(0,num);
         }
         if(record)
         {
            this._recordHavingSeenId(chosen);
         }
         return chosen;
      }
      
      private function _recordHavingSeenId(chosen:Array) : void
      {
         var currentDate:Date = null;
         currentDate = new Date();
         chosen.forEach(function(o:Object, ... args):void
         {
            _timeLastSeenIdPerType[o.contentType][o.id] = currentDate.time;
         });
         Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,this._timeLastSeenIdPerType);
         this._updateContentMetadataIfNecessary();
      }
      
      public function recordHavingSeenId(type:String, ids:Array) : void
      {
         var id:String = null;
         var currentDate:Date = new Date();
         for each(id in ids)
         {
            this._timeLastSeenIdPerType[type][id] = currentDate.time;
         }
         Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,this._timeLastSeenIdPerType);
         this._updateContentMetadataIfNecessary();
      }
      
      private function _getTimeLastSeen(type:String, id:String) : Number
      {
         return Boolean(this._timeLastSeenIdPerType[type].hasOwnProperty(id)) ? Number(this._timeLastSeenIdPerType[type][id]) : 0;
      }
      
      private function _updateContentMetadataIfNecessary() : void
      {
         var source:String = null;
         var type:String = null;
         var contentPlayed:Array = null;
         var percent:Number = NaN;
         var changed:Boolean = false;
         for(source in this._contentPerSource)
         {
            for(type in this._contentPerSource[source])
            {
               if(!this._contentMetadataPerSourcePerType[source].hasOwnProperty(type))
               {
                  this._contentMetadataPerSourcePerType[source][type] = {"percentCompleted":0};
                  changed = true;
               }
               contentPlayed = this._contentPerSource[source][type].filter(function(element:Object, index:int, a:Array):Boolean
               {
                  return _getTimeLastSeen(type,element.id) > 0;
               });
               percent = Number(contentPlayed.length) / Number(this._contentPerSource[source][type].length);
               if(percent > this._contentMetadataPerSourcePerType[source][type].percentCompleted)
               {
                  this._contentMetadataPerSourcePerType[source][type].percentCompleted = percent;
                  changed = true;
               }
            }
         }
         if(changed)
         {
            Save.instance.saveObject(CONTENT_METADATA_KEY,this._contentMetadataPerSourcePerType);
            dispatchEvent(new EventWithData(EVENT_CONTENT_METADATA_CHANGED,null));
         }
      }
      
      public function getContentMetadata(source:String, type:String) : Object
      {
         if(!this._contentMetadataPerSourcePerType || !this._contentMetadataPerSourcePerType.hasOwnProperty(source) || !this._contentMetadataPerSourcePerType[source].hasOwnProperty(type))
         {
            return null;
         }
         return this._contentMetadataPerSourcePerType[source][type];
      }
      
      public function contentUsed() : Array
      {
         var source:String = null;
         var type:String = null;
         var contentPlayed:Array = null;
         var percent:Number = NaN;
         var result:Array = [];
         for(source in this._contentPerSource)
         {
            for(type in this._contentPerSource[source])
            {
               contentPlayed = this._contentPerSource[source][type].filter(function(element:Object, index:int, a:Array):Boolean
               {
                  return _getTimeLastSeen(type,element.id) > 0;
               });
               percent = Number(contentPlayed.length) / Number(this._contentPerSource[source][type].length);
               result.push(source + " - " + type + ": " + contentPlayed.length + " / " + this._contentPerSource[source][type].length + " (" + percent * 100 + "%)");
            }
         }
         return result;
      }
      
      public function printContent(typefilter:String = null) : void
      {
         var counter:int = 0;
         var source:String = null;
         var type:String = null;
         var o:Object = null;
         if(EnvUtil.isDebug())
         {
            Logger.info("ContentManager::printContent() starts");
            counter = 0;
            for(source in this._contentPerSource)
            {
               Logger.info("From source : " + source);
               for(type in this._contentPerSource[source])
               {
                  if(!(typefilter != null && typefilter != type))
                  {
                     Logger.info("    Type : " + type);
                     for each(o in this._contentPerSource[source][type])
                     {
                        counter++;
                        Logger.info(counter + "  id: " + o.id + " Last Seeen: " + this._getTimeLastSeen(type,o.id) + " \"" + o.prompt + "\"");
                     }
                  }
               }
            }
            Logger.info("ContentManager::printContent() ends");
         }
      }
      
      public function setContent(source:String, contentToSet:*) : void
      {
         var t:String = null;
         var contentData:* = undefined;
         var content:Array = null;
         var i:int = 0;
         if(!this._contentPerSource[source])
         {
            this._contentPerSource[source] = {};
         }
         for(t in contentToSet)
         {
            if(!this._contentPerSource[source][t])
            {
               this._contentPerSource[source][t] = [];
            }
            contentData = contentToSet[t];
            if(contentData)
            {
               if(!this._timeLastSeenIdPerType[t])
               {
                  this._timeLastSeenIdPerType[t] = {};
                  Save.instance.saveObject(TIME_LAST_SEEN_ID_KEY,this._timeLastSeenIdPerType);
               }
               this._contentPerSource[source][t] = [];
               content = contentData.content;
               for(i = 0; i < content.length; i++)
               {
                  content[i].contentType = t;
                  content[i].path = t;
                  content[i].random_for_content_manager = Math.random();
                  this._contentPerSource[source][t].push(content[i]);
               }
            }
         }
         this._updateContentMetadataIfNecessary();
      }
   }
}

