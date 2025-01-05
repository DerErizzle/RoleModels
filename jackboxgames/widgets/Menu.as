package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import jackboxgames.events.*;
   import jackboxgames.flash.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class Menu extends PausableEventDispatcher
   {
      
      private static const MENU_CONFIG_FILE:String = "menu.jet";
      
      public static const EVENT_ITEM_SELECTED:String = "Menu.ItemSelected";
      
      public static const EVENT_HIGHLIGHTED_ITEM_CHANGED:String = "Menu.HighlightedItemChanged";
       
      
      private var _mc:MovieClip;
      
      private var _itemMcs:Array;
      
      private var _itemTitleTfs:Array;
      
      private var _itemDescriptionTfs:Array;
      
      private var _itemTouchables:Array;
      
      private var _itemMcsInUse:Array;
      
      private var _itemActions:Array;
      
      private var _currentlySelected:int = 0;
      
      private var _listeningForInput:Boolean = false;
      
      private var _configFile:String;
      
      private var _config:Object;
      
      private var _showFn:Function;
      
      private var _dismissFn:Function;
      
      private var _postSetupFn:Function;
      
      public function Menu(mc:MovieClip, configFile:String = "menu.jet")
      {
         var makeMouseOverFn:Function;
         var makeClickFn:Function;
         var itemMc:MovieClip = null;
         super();
         this._configFile = configFile;
         this._mc = mc;
         this._itemMcs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"item");
         this._itemActions = [];
         this._itemTitleTfs = this._itemMcs.map(function(element:MovieClip, i:int, a:Array):ExtendableTextField
         {
            return new ExtendableTextField(element.txt,[],[]);
         });
         this._itemDescriptionTfs = this._itemMcs.map(function(element:MovieClip, i:int, a:Array):ExtendableTextField
         {
            return new ExtendableTextField(element.descTxt,[],[]);
         });
         makeMouseOverFn = function(mc:MovieClip):Function
         {
            return function(evt:Event):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               _changeSelection(_itemMcs.indexOf(mc));
            };
         };
         makeClickFn = function(mc:MovieClip):Function
         {
            return function(evt:Event):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               _changeSelection(_itemMcs.indexOf(mc));
               dispatchEvent(new EventWithData(EVENT_ITEM_SELECTED,{
                  "choice":_currentlySelected,
                  "action":_itemActions[_currentlySelected]
               }));
            };
         };
         for each(itemMc in this._itemMcs)
         {
            itemMc.useHandCursor = true;
            itemMc.buttonMode = true;
            itemMc.mouseChildren = false;
            itemMc.addEventListener(MouseEvent.MOUSE_OVER,makeMouseOverFn(itemMc));
            itemMc.addEventListener(MouseEvent.MOUSE_DOWN,makeClickFn(itemMc));
         }
         this._showFn = this._defaultShow;
         this._dismissFn = this._defaultDismiss;
         this._postSetupFn = Nullable.NULL_FUNCTION;
      }
      
      public function set showFn(val:Function) : void
      {
         this._showFn = val;
      }
      
      public function set dismissFn(val:Function) : void
      {
         this._dismissFn = val;
      }
      
      public function set postSetupFn(val:Function) : void
      {
         this._postSetupFn = val;
      }
      
      public function setup(callback:Function = null) : void
      {
         this._itemMcsInUse = [];
         this._currentlySelected = 0;
         this.listenForInput = false;
         JBGLoader.instance.loadFile(this._configFile,function(result:Object):void
         {
            var items:Array = null;
            var i:int = 0;
            if(Boolean(result.success))
            {
               _config = result.contentAsJSON;
               items = _config.items;
               for(i = 0; i < items.length; i++)
               {
                  _itemMcsInUse.push(_itemMcs[i]);
                  _itemTitleTfs[i].text = LocalizationManager.instance.getText(items[i].title);
                  _itemDescriptionTfs[i].text = LocalizationManager.instance.getText(items[i].description);
                  _itemActions.push(Boolean(items[i].action) ? items[i].action : "doNothing");
               }
               _postSetupFn(items,_itemMcsInUse);
            }
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      public function reset() : void
      {
         for(var i:int = 0; i < this._itemMcs.length; i++)
         {
            JBGUtil.gotoFrame(this._itemMcs[i],"Park");
         }
         this.listenForInput = false;
      }
      
      private function _defaultShow(mc:MovieClip, itemMcs:Array, doneFn:Function) : void
      {
         JBGUtil.arrayGotoFrameWithFnAndDuration(itemMcs,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            doneFn();
         },Duration.fromMs(200));
      }
      
      public function show(doneFn:Function) : void
      {
         this._showFn(this._mc,this._itemMcsInUse,function():void
         {
            _changeSelection(_currentlySelected);
            listenForInput = true;
            doneFn();
         });
      }
      
      private function _defaultDismiss(mc:MovieClip, itemMcs:Array, currentlySelected:int, doneFn:Function) : void
      {
         for(var i:int = 0; i < itemMcs.length; i++)
         {
            if(i == currentlySelected)
            {
               JBGUtil.gotoFrameWithFn(itemMcs[i],"DisappearHigh",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
            }
            else
            {
               JBGUtil.gotoFrame(itemMcs[i],"Disappear");
            }
         }
      }
      
      public function dismiss(doneFn:Function) : void
      {
         this.listenForInput = false;
         this._dismissFn(this._mc,this._itemMcsInUse,this._currentlySelected,doneFn);
      }
      
      private function _changeSelection(newSelected:int) : void
      {
         if(newSelected != this._currentlySelected)
         {
            JBGUtil.gotoFrame(this._itemMcs[this._currentlySelected],"Unhighlight");
            dispatchEvent(new EventWithData(EVENT_HIGHLIGHTED_ITEM_CHANGED,{
               "newSelected":newSelected,
               "oldSelected":this._currentlySelected
            }));
         }
         this._currentlySelected = newSelected;
         JBGUtil.gotoFrame(this._itemMcs[this._currentlySelected],"Highlight");
      }
      
      public function set listenForInput(val:Boolean) : void
      {
         if(val == this._listeningForInput)
         {
            return;
         }
         this._listeningForInput = val;
         if(this._listeningForInput)
         {
            Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepad);
            MouseManager.instance.addEventListener(MouseManager.EVENT_MOUSE_WHEEL,this._onMouseWheel);
         }
         else
         {
            Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepad);
            MouseManager.instance.removeEventListener(MouseManager.EVENT_MOUSE_WHEEL,this._onMouseWheel);
         }
      }
      
      private function _onGamepad(evt:EventWithData) : void
      {
         var newSelected:int = 0;
         if(ArrayUtil.arrayContainsElement(evt.data.inputs,"A") || ArrayUtil.arrayContainsElement(evt.data.inputs,"SELECT"))
         {
            dispatchEvent(new EventWithData(EVENT_ITEM_SELECTED,{
               "choice":this._currentlySelected,
               "action":this._itemActions[this._currentlySelected]
            }));
         }
         else if(ArrayUtil.arrayContainsElement(evt.data.inputs,"B") || ArrayUtil.arrayContainsElement(evt.data.inputs,"BACK"))
         {
            if(!EnvUtil.isMobile())
            {
               return;
            }
            dispatchEvent(new EventWithData(EVENT_ITEM_SELECTED,{
               "choice":-1,
               "action":"doBackToPack"
            }));
         }
         else if(ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_DOWN") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_DOWN"))
         {
            newSelected = this._currentlySelected + 1;
            this._changeSelection(newSelected >= this._itemMcsInUse.length ? 0 : newSelected);
         }
         else if(ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_UP") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_UP"))
         {
            newSelected = this._currentlySelected - 1;
            this._changeSelection(newSelected < 0 ? this._itemMcsInUse.length - 1 : newSelected);
         }
      }
      
      private function _onMouseWheel(evt:EventWithData) : void
      {
         if(Boolean(evt.data.wheelUp))
         {
            if(this._currentlySelected > 0)
            {
               this._changeSelection(this._currentlySelected - 1);
            }
         }
         else if(this._currentlySelected < this._itemMcsInUse.length - 1)
         {
            this._changeSelection(this._currentlySelected + 1);
         }
      }
   }
}
