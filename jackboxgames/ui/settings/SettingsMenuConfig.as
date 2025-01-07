package jackboxgames.ui.settings
{
   import jackboxgames.algorithm.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuConfig implements IToSimpleObject
   {
      private static const NUM_SETTINGS_PER_PROGRAMMATIC_PAGE:int = 8;
      
      private var _items:Array;
      
      private var _tabs:Array;
      
      public function SettingsMenuConfig()
      {
         super();
      }
      
      public static function fromSimpleObject(o:Object) : SettingsMenuConfig
      {
         var c:SettingsMenuConfig = new SettingsMenuConfig();
         if(Boolean(o))
         {
            c._items = o.items;
            c._tabs = o.tabs;
         }
         return c;
      }
      
      public function get items() : Array
      {
         return this._items;
      }
      
      public function get tabs() : Array
      {
         return this._tabs;
      }
      
      public function load(file:String) : Promise
      {
         var p:Promise = null;
         p = new Promise();
         JBGLoader.instance.loadFile(file,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               _finishLoad(result.loader.contentAsJSON);
               p.resolve(_items);
            }
            else
            {
               p.reject(undefined);
            }
         });
         return p;
      }
      
      private function _finishLoad(json:Object) : void
      {
         var itemsWithNoTab:Array;
         var programmaticTabNum:int;
         var parser:ExpressionParser = null;
         var dataDelegate:MultipleDataDelegate = null;
         var otherTabItems:Array = null;
         parser = new ExpressionParser();
         dataDelegate = new MultipleDataDelegate();
         dataDelegate.add(BuildConfig.instance);
         dataDelegate.add(new PropertyDataDelegate(Platform.instance));
         if(Boolean(json.items))
         {
            this._items = json.items.filter(function(itemData:Object, ... args):Boolean
            {
               var res:* = undefined;
               if(itemData.hasOwnProperty("isValid"))
               {
                  res = parser.parse(itemData.isValid);
                  if(Boolean(res.succeeded))
                  {
                     return IExpression(res.payload).evaluate(dataDelegate);
                  }
                  return false;
               }
               return true;
            }).map(function(itemData:Object, ... args):SettingsMenuConfigItem
            {
               return new SettingsMenuConfigItem(itemData);
            });
         }
         else
         {
            this._items = [];
         }
         if(Boolean(json.tabs))
         {
            this._tabs = json.tabs.filter(function(tabData:Object, ... args):Boolean
            {
               return true;
            }).map(function(tabData:Object, ... args):SettingsMenuConfigTab
            {
               return new SettingsMenuConfigTab(tabData);
            });
         }
         else
         {
            this._tabs = [];
         }
         itemsWithNoTab = this._items.filter(function(item:SettingsMenuConfigItem, ... args):Boolean
         {
            var tabWithItem:* = ArrayUtil.find(_tabs,function(t:SettingsMenuConfigTab, ... args):Boolean
            {
               return ArrayUtil.arrayContainsElement(t.sources,item.source);
            });
            return tabWithItem == null;
         });
         programmaticTabNum = 1;
         while(itemsWithNoTab.length > 0)
         {
            otherTabItems = itemsWithNoTab.splice(0,NUM_SETTINGS_PER_PROGRAMMATIC_PAGE);
            this._tabs.push(new SettingsMenuConfigTab({
               "title":"OTHER " + programmaticTabNum,
               "sources":otherTabItems.map(function(item:SettingsMenuConfigItem, ... args):String
               {
                  return item.source;
               })
            }));
            programmaticTabNum++;
         }
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "items":this._items,
            "tabs":this._tabs
         };
      }
   }
}

