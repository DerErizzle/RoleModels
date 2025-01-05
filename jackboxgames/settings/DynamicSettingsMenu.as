package jackboxgames.settings
{
   import com.greensock.easing.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import jackboxgames.animation.tween.*;
   import jackboxgames.events.*;
   import jackboxgames.flash.MouseManager;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.mobile.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class DynamicSettingsMenu extends PausableEventDispatcher
   {
      
      public static const SETTINGS_CONFIG_FILE:String = "settings.jet";
      
      public static const EVENT_CLOSING:String = "SettingsMenu.Closing";
      
      public static const EVENT_CLOSED:String = "SettingsMenu.Closed";
      
      public static const EVENT_HIGHLIGHTED_ITEM_CHANGED:String = "SettingsMenu.HighlightedItemChanged";
      
      public static const EVENT_ITEM_VALUE_CHANGED:String = "SettingsMenu.ItemValueChanged";
      
      public static const ITEM_TYPE_TOGGLE:String = "Toggle";
      
      public static const ITEM_TYPE_RANGE:String = "Range";
      
      public static const ITEM_TYPE_LIST:String = "List";
       
      
      private var _titleSelectColor:uint = 0;
      
      private var _titleDefaultColor:uint = 3355443;
      
      private var _mc:MovieClip;
      
      private var _description:ExtendableTextField;
      
      private var _scroller:MovieClip;
      
      private var _listPane:MovieClip;
      
      private var _paneTween:JBGTween;
      
      private var _scrollerTween:JBGTween;
      
      private var _mobileScroller:Scroller;
      
      private var _listPaneContainerBounds:Rectangle;
      
      private var _config:Object;
      
      private var _itemMcs:Array;
      
      private var _itemTitleTFs:Array;
      
      private var _rowOrigin:int = 0;
      
      private var _selectedRow:int = 0;
      
      private var _numRows:int = 0;
      
      private var _selectedItem:int = 0;
      
      private var _listeningForInput:Boolean = false;
      
      private var _isTweening:Boolean = false;
      
      private var _closeBehaviors:ButtonCallout;
      
      private var _configFile:String;
      
      private var _localized:Boolean;
      
      private var _callback:Function = null;
      
      private var _dragY:Number;
      
      public function DynamicSettingsMenu(mc:MovieClip, configFile:String = "settings.jet", localized:Boolean = false)
      {
         var loader:ILoader = null;
         super();
         this._configFile = configFile;
         this._config = null;
         loader = JBGLoader.instance.loadFile(this._configFile,function(result:Object):void
         {
            var maxDescriptionSize:* = undefined;
            var items:* = undefined;
            if(Boolean(result.success))
            {
               _config = result.contentAsJSON;
               maxDescriptionSize = _config.hasOwnProperty("maxDescriptionSize") ? _config.maxDescriptionSize : 128;
               _description = new ExtendableTextField(_mc.settings.description,[],[PostEffectFactory.createDynamicResizerEffect(2,4,maxDescriptionSize),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
               _localized = _config.hasOwnProperty("localized") ? Boolean(_config.localized) : _localized;
               if(_localized)
               {
                  LocalizedTextFieldManager.instance.add([_mc.title.tf,_mc.close.tf]);
               }
               if(!Platform.instance.supportsWindow || BuildConfig.instance.configVal("supportsFullScreen") != true)
               {
                  items = _config.items.filter(function(element:Object, index:int, a:Array):Object
                  {
                     return element.source != SettingsConstants.SETTING_FULL_SCREEN;
                  });
                  _config.items = items;
               }
               _config.items = _config.items.filter(function(element:Object, index:int, a:Array):Boolean
               {
                  if(element.hasOwnProperty("hideWhenBuildConfigIs"))
                  {
                     if(BuildConfig.instance.hasConfigVal(element.hideWhenBuildConfigIs.id))
                     {
                        return BuildConfig.instance.configVal(element.hideWhenBuildConfigIs.id) != element.hideWhenBuildConfigIs.value;
                     }
                  }
                  return true;
               });
               setup();
            }
            else
            {
               _config = null;
            }
            loader.dispose();
         });
         this._mc = mc;
         this._localized = localized;
         this._description = new ExtendableTextField(this._mc.settings.description,[],[PostEffectFactory.createDynamicResizerEffect(2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
         this._description.text = "";
         this._scroller = this._mc.settings.scroller;
         this._listPane = this._mc.settings.listPane.pane;
         this._listPaneContainerBounds = this._mc.settings.listPane.getBounds(this._mc.settings.listPane);
         this._mobileScroller = new Scroller(this._listPane,StageRef,this._listPaneContainerBounds,this._onMobileScrolled,function():Number
         {
            if(_config == null || _config.items.length - _config.rows <= 0)
            {
               return 0;
            }
            return -(_config.cellHeight * (_config.items.length - _config.rows));
         });
         (this._scroller.arrows.upArrow as MovieClip).useHandCursor = true;
         (this._scroller.arrows.upArrow as MovieClip).buttonMode = true;
         (this._scroller.arrows.downArrow as MovieClip).useHandCursor = true;
         (this._scroller.arrows.downArrow as MovieClip).buttonMode = true;
         (this._scroller.bar as MovieClip).useHandCursor = true;
         (this._scroller.bar as MovieClip).buttonMode = true;
         (this._scroller.bg as MovieClip).useHandCursor = true;
         (this._scroller.bg as MovieClip).buttonMode = true;
         this._itemMcs = new Array();
         this._itemTitleTFs = new Array();
         this._paneTween = new JBGTween(this._listPane,Duration.fromSec(0.25),{},SineOut);
         this._paneTween.addEventListener(JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            _isTweening = false;
         });
         this._scrollerTween = new JBGTween(this._scroller.bar,Duration.fromSec(0.25),{},SineOut);
         this._closeBehaviors = new ButtonCallout(this._mc.close,["BACK","B"]);
      }
      
      public function setup(doneFn:Function = null) : void
      {
         var makeChangedValueFn:Function;
         var makeMouseOverFn:Function;
         var makeMouseDownFnForToggle:Function;
         var makeMouseDownFnForRange:Function;
         var makeMouseDownFnForList:Function;
         var maxLabelSize:int;
         var i:int;
         var touchClipBounds:Rectangle;
         var touchClip:Sprite;
         var item:Object = null;
         var clipClass:Class = null;
         var clip:MovieClip = null;
         var widgetClass:Class = null;
         var widget:MovieClip = null;
         var label:ExtendableTextField = null;
         var mcToHit:MovieClip = null;
         if(doneFn != null)
         {
            this._callback = doneFn;
         }
         if(this._config == null || this._callback == null)
         {
            return;
         }
         this._rowOrigin = 0;
         this._selectedRow = 0;
         this._selectedItem = 0;
         this._listenForInput = false;
         this._itemMcs = new Array();
         this._itemTitleTFs = new Array();
         makeChangedValueFn = function(index:int):Function
         {
            return function(evt:EventWithData):void
            {
               _setVisualsForItem(index);
            };
         };
         makeMouseOverFn = function(index:int):Function
         {
            return function(evt:Event):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               if(_isTweening)
               {
                  return;
               }
               _changeSelection(index);
            };
         };
         makeMouseDownFnForToggle = function(index:int):Function
         {
            return function(evt:Event):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               _changeSelection(index);
               SettingsManager.instance.getValue(_config.items[index].source).val = !SettingsManager.instance.getValue(_config.items[index].source).val;
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,_config.items[index].source));
            };
         };
         makeMouseDownFnForRange = function(mc:MovieClip):Function
         {
            var getPercentForRange:Function = function(mc:MovieClip, point:Point):Number
            {
               var newPoint:Point = mc.gizmo.hitbox.globalToLocal(point);
               var bounds:Rectangle = mc.gizmo.hitbox.getBounds(mc.gizmo.hitbox);
               return (newPoint.x - bounds.left) / (bounds.right - bounds.left);
            };
            return function(evt:MouseEvent):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               var percent:* = getPercentForRange(mc.widget.clip,new Point(evt.stageX,evt.stageY));
               if(percent < 0)
               {
                  percent = 0;
               }
               else if(percent > 1)
               {
                  percent = 1;
               }
               _changeSelection(_itemMcs.indexOf(mc));
               SettingsManager.instance.getValue(_config.items[_itemMcs.indexOf(mc)].source).val = percent;
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,_config.items[_itemMcs.indexOf(mc)].source));
            };
         };
         makeMouseDownFnForList = function(mc:MovieClip):Function
         {
            var getPercentForRange:Function = function(mc:MovieClip, point:Point):Number
            {
               var newPoint:Point = mc.hitbox.globalToLocal(point);
               var bounds:Rectangle = mc.hitbox.getBounds(mc.hitbox);
               return (newPoint.x - bounds.left) / (bounds.right - bounds.left);
            };
            return function(evt:MouseEvent):void
            {
               if(!_listeningForInput)
               {
                  return;
               }
               _changeSelection(_itemMcs.indexOf(mc));
               var item:* = _config.items[_itemMcs.indexOf(mc)];
               var percent:* = getPercentForRange(mc.widget.clip,new Point(evt.stageX,evt.stageY));
               var direction:* = percent < 0.5 ? -1 : 1;
               var s:* = SettingsManager.instance.getValue(item.source);
               var val:* = s.val == null ? item.options[item.defaultValueIndex] : s.val;
               var idx:* = item.options.indexOf(s.val);
               idx = Math.min(Math.max(idx + direction,0),item.options.length - 1);
               s.val = item.options[idx];
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,_config.items[_itemMcs.indexOf(mc)].source));
            };
         };
         maxLabelSize = this._config.hasOwnProperty("maxLabelSize") ? int(this._config.maxLabelSize) : 128;
         this._numRows = 0;
         for(i = 0; i < this._config.items.length; i++)
         {
            item = this._config.items[i];
            clipClass = getDefinitionByName(this._config.clip) as Class;
            clip = new clipClass();
            widgetClass = getDefinitionByName(item.clip) as Class;
            widget = new widgetClass();
            clip.widget.addChild(widget);
            clip.widget.clip = widget;
            if(item.type == ITEM_TYPE_RANGE || item.type == ITEM_TYPE_LIST)
            {
               JBGUtil.gotoFrame(clip.tf,"Short");
            }
            label = new ExtendableTextField(clip.tf,[],[PostEffectFactory.createDynamicResizerEffect(1,4,maxLabelSize),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            label.text = this._localized ? LocalizationManager.instance.getValueForKey(item.title) : String(item.title);
            label.setColor(item.hasOwnProperty("colorUnselected") ? uint(item.colorUnselected) : this._titleDefaultColor,1);
            this._itemTitleTFs.push(label);
            clip.x = 0;
            clip.y = this._numRows * this._config.cellHeight;
            ++this._numRows;
            JBGUtil.gotoFrame(clip.widget.clip,"Unhighlight");
            this._itemMcs.push(clip);
            this._setVisualsForItem(i);
            SettingsManager.instance.getValue(item.source).addEventListener(SettingsValue.EVENT_VALUE_CHANGED,makeChangedValueFn(i));
            clip.addEventListener(MouseEvent.MOUSE_OVER,makeMouseOverFn(i));
            clip.addEventListener(MouseEvent.MOUSE_MOVE,makeMouseOverFn(i));
            if(item.type == ITEM_TYPE_TOGGLE)
            {
               if(this._localized && Boolean(clip.widget.clip.toggle.hasOwnProperty("onTf")))
               {
                  LocalizedTextFieldManager.instance.add([clip.widget.clip.toggle.onTf.tf,clip.widget.clip.toggle.offTf.tf]);
               }
               mcToHit = Boolean(clip.widget.clip.hitbox) ? clip.widget.clip.hitbox : clip.widget.clip.toggle;
               mcToHit.useHandCursor = true;
               mcToHit.buttonMode = true;
               mcToHit.mouseChildren = false;
               mcToHit.addEventListener(MouseEvent.MOUSE_DOWN,makeMouseDownFnForToggle(i));
            }
            else if(item.type == ITEM_TYPE_RANGE)
            {
               mcToHit = Boolean(clip.widget.clip.hitbox) ? clip.widget.clip.hitbox : clip.widget.clip.gizmo.hitbox;
               mcToHit.useHandCursor = true;
               mcToHit.buttonMode = true;
               mcToHit.addEventListener(MouseEvent.MOUSE_DOWN,makeMouseDownFnForRange(clip));
            }
            else if(item.type == ITEM_TYPE_LIST)
            {
               mcToHit = clip.widget.clip.hitbox;
               mcToHit.useHandCursor = true;
               mcToHit.buttonMode = true;
               mcToHit.addEventListener(MouseEvent.MOUSE_DOWN,makeMouseDownFnForList(clip));
            }
            JBGUtil.arrayGotoFrame([clip,widget],"Appear");
            this._listPane.addChild(clip);
         }
         touchClipBounds = JBGUtil.combineRectangles(this._itemMcs.map(function(itemMC:MovieClip, ... args):Rectangle
         {
            return itemMC.getBounds(_listPane);
         }));
         touchClip = new Sprite();
         touchClip.graphics.beginFill(0,1);
         touchClip.graphics.drawRect(touchClipBounds.x,touchClipBounds.y,touchClipBounds.width,touchClipBounds.height);
         touchClip.graphics.endFill();
         touchClip.alpha = 0;
         this._listPane.addChildAt(touchClip,0);
         this._changeSelection(0);
         ExternalDisplayManager.instance.addEventListener(ExternalDisplayManager.EVENT_SCREEN_STATE_CHANGED,this._onDisplayChanged);
         this._onDisplayChanged(null);
         if(this._callback != null)
         {
            this._callback();
         }
      }
      
      public function reset() : void
      {
         this._listenForInput = false;
      }
      
      private function _setVisualsForItem(i:int) : void
      {
         var mcs:Array = null;
         var itemValue:* = undefined;
         var itemIndex:uint = 0;
         var expresion:String = null;
         var regex:RegExp = null;
         var source:String = null;
         var hasIcon:Boolean = false;
         if(this._config.items[i].type == ITEM_TYPE_TOGGLE)
         {
            mcs = [this._itemMcs[i].widget.clip.toggle];
            if(this._localized && Boolean(this._itemMcs[i].widget.clip.sticker))
            {
               mcs.push(this._itemMcs[i].widget.clip.sticker);
            }
            JBGUtil.arrayGotoFrame(mcs,SettingsManager.instance.getValue(this._config.items[i].source).val ? "ON" : "OFF");
            hasIcon = true;
         }
         else if(this._config.items[i].type == ITEM_TYPE_LIST)
         {
            hasIcon = true;
            itemValue = SettingsManager.instance.getValue(this._config.items[i].source).val;
            if(itemValue == null)
            {
               itemValue = this._config.items[i].options[this._config.items[i].defaultValueIndex];
            }
            itemIndex = uint((this._config.items[i].options as Array).indexOf(itemValue));
            this._itemMcs[i].widget.clip.tf.tf.text = itemValue;
         }
         else if(this._config.items[i].type == ITEM_TYPE_RANGE)
         {
            this._itemMcs[i].widget.clip.gizmo.amount.scaleX = SettingsManager.instance.getValue(this._config.items[i].source).val;
         }
         if(hasIcon)
         {
            expresion = "^" + BuildConfig.instance.configVal("gameName");
            regex = new RegExp(expresion);
            source = String(this._config.items[i].source.replace(regex,""));
            if(Boolean(this._itemMcs[i].widget.clip.icon) && MovieClipUtil.frameExists(this._itemMcs[i].widget.clip.icon.content,source))
            {
               JBGUtil.gotoFrame(this._itemMcs[i].widget.clip.icon.content,source);
               JBGUtil.gotoFrame(this._itemMcs[i].widget.clip.icon,SettingsManager.instance.getValue(this._config.items[i].source).val ? "Appear" : "Disappear");
            }
         }
      }
      
      public function show(doneFn:Function = null) : void
      {
         this._listenForInput = true;
         this._closeBehaviors.setShown(true,"CLOSE");
         JBGUtil.gotoFrameWithFn(this._mc.parent as MovieClip,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            _changeSelection(_selectedItem);
            if(doneFn != null)
            {
               doneFn();
            }
         });
      }
      
      public function dismiss(doneFn:Function = null) : void
      {
         this._listenForInput = false;
         this._closeBehaviors.setShown(false);
         JBGUtil.gotoFrameWithFn(this._mc.parent as MovieClip,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            dispatchEvent(new EventWithData(EVENT_CLOSED,null));
            if(doneFn != null)
            {
               doneFn();
            }
         });
      }
      
      private function _close() : void
      {
         this.dismiss(null);
         dispatchEvent(new EventWithData(EVENT_CLOSING,null));
      }
      
      private function _removeSelection() : void
      {
         this._description.text = "";
         JBGUtil.gotoFrame(this._itemMcs[this._selectedItem].widget.clip,"Unhighlight");
         (this._itemTitleTFs[this._selectedItem] as ExtendableTextField).setColor(Boolean(this._config.items[this._selectedItem].hasOwnProperty("colorUnselected")) ? uint(this._config.items[this._selectedItem].colorUnselected) : this._titleDefaultColor,1);
      }
      
      private function _changeSelection(newSelected:int) : void
      {
         if(!ExternalDisplayManager.instance.isOnExternalDisplay)
         {
            return;
         }
         if(newSelected != this._selectedItem)
         {
            JBGUtil.gotoFrame(this._itemMcs[this._selectedItem].widget.clip,"Unhighlight");
            (this._itemTitleTFs[this._selectedItem] as ExtendableTextField).setColor(Boolean(this._config.items[this._selectedItem].hasOwnProperty("colorUnselected")) ? uint(this._config.items[this._selectedItem].colorUnselected) : this._titleDefaultColor,1);
            dispatchEvent(new EventWithData(EVENT_HIGHLIGHTED_ITEM_CHANGED,{
               "newSelected":newSelected,
               "oldSelected":this._selectedItem
            }));
         }
         this._selectedItem = newSelected;
         JBGUtil.gotoFrame(this._itemMcs[this._selectedItem].widget.clip,"Highlight");
         (this._itemTitleTFs[this._selectedItem] as ExtendableTextField).setColor(Boolean(this._config.items[this._selectedItem].hasOwnProperty("colorSelected")) ? uint(this._config.items[this._selectedItem].colorSelected) : this._titleSelectColor,1);
         this._description.text = this._localized ? LocalizationManager.instance.getValueForKey(this._config.items[this._selectedItem].description) : String(this._config.items[this._selectedItem].description);
         this._selectedRow = Math.round(this._itemMcs[this._selectedItem].y / this._config.cellHeight);
         if(this._selectedRow < this._rowOrigin)
         {
            this._rowOrigin = this._selectedRow;
            this._paneTween.updateVars({"y":-(this._rowOrigin * this._config.cellHeight)});
            this._isTweening = true;
         }
         else if(this._selectedRow > this._rowOrigin + this._config.rows - 1)
         {
            this._rowOrigin = this._selectedRow - this._config.rows + 1;
            this._paneTween.updateVars({"y":-(this._rowOrigin * this._config.cellHeight)});
            this._isTweening = true;
         }
         this._updateScroller();
      }
      
      private function _moveDown() : void
      {
      }
      
      private function _moveUp() : void
      {
      }
      
      private function _updateScroller() : void
      {
         if(this._numRows <= this._config.rows)
         {
            this._scroller.visible = false;
            return;
         }
         if(this._paneTween.target.y == 0)
         {
            this._scroller.arrows.upArrow.alpha = 0.25;
         }
         else
         {
            this._scroller.arrows.upArrow.alpha = 1;
         }
         if(this._paneTween.target.y == -(this._numRows - this._config.rows) * this._config.cellHeight)
         {
            this._scroller.arrows.downArrow.alpha = 0.25;
         }
         else
         {
            this._scroller.arrows.downArrow.alpha = 1;
         }
         this._scroller.bar.height = this._scroller.bg.height / (this._numRows - this._config.rows + 1);
         this._scrollerTween.updateVars({"y":this._scroller.bg.y + this._scroller.bar.height * (this._paneTween.vars.y / -this._config.cellHeight)},true);
      }
      
      private function _onMobileScrolled() : void
      {
         var ratio:Number = (-this._listPane.y + this._listPaneContainerBounds.y) / (this._listPane.height - this._listPaneContainerBounds.height);
         this._scroller.bar.height = this._scroller.bg.height / (this._numRows - this._config.rows + 1);
         var newY:Number = this._scroller.bg.y + (this._scroller.bg.height - this._scroller.bar.height) * ratio;
         newY = Math.max(this._scroller.bg.y,Math.min(newY,this._scroller.bg.height - this._scroller.bar.height));
         this._scrollerTween.updateVars({"y":newY});
      }
      
      private function set _listenForInput(val:Boolean) : void
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
            this._scroller.bg.addEventListener(MouseEvent.CLICK,this._onScrollerClick);
            this._scroller.arrows.upArrow.addEventListener(MouseEvent.CLICK,this._onUpClick);
            this._scroller.arrows.downArrow.addEventListener(MouseEvent.CLICK,this._onDownClick);
            this._scroller.bar.addEventListener(MouseEvent.MOUSE_DOWN,this._onBarDragDown);
         }
         else
         {
            Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepad);
            MouseManager.instance.removeEventListener(MouseManager.EVENT_MOUSE_WHEEL,this._onMouseWheel);
            this._scroller.bg.removeEventListener(MouseEvent.CLICK,this._onScrollerClick);
            this._scroller.arrows.upArrow.removeEventListener(MouseEvent.CLICK,this._onUpClick);
            this._scroller.arrows.downArrow.removeEventListener(MouseEvent.CLICK,this._onDownClick);
            this._scroller.bar.removeEventListener(MouseEvent.MOUSE_DOWN,this._onBarDragDown);
         }
      }
      
      private function _onGamepad(evt:EventWithData) : void
      {
         var newSelected:int = 0;
         var s:SettingsValue = null;
         var step:Number = NaN;
         var dir:int = 0;
         var val:* = undefined;
         var idx:int = 0;
         var item:Object = this._config.items[this._selectedItem];
         var clip:MovieClip = this._itemMcs[this._selectedItem];
         if(ArrayUtil.arrayContainsElement(evt.data.inputs,"A") || ArrayUtil.arrayContainsElement(evt.data.inputs,"SELECT"))
         {
            if(item.type == ITEM_TYPE_TOGGLE)
            {
               SettingsManager.instance.getValue(item.source).val = !SettingsManager.instance.getValue(item.source).val;
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,item.source));
            }
         }
         else if(ArrayUtil.arrayContainsElement(evt.data.inputs,"B") || ArrayUtil.arrayContainsElement(evt.data.inputs,"BACK"))
         {
            this._close();
         }
         if(ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_LEFT") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_LEFT") || ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_RIGHT") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_RIGHT"))
         {
            s = SettingsManager.instance.getValue(item.source);
            if(item.type == ITEM_TYPE_RANGE)
            {
               step = ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_LEFT") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_LEFT") ? -item.step : Number(item.step);
               if(step + s.val < 0)
               {
                  s.val = 0;
               }
               else if(step + s.val > 1)
               {
                  s.val = 1;
               }
               else
               {
                  s.val += step;
               }
            }
            else if(item.type == ITEM_TYPE_TOGGLE)
            {
               SettingsManager.instance.getValue(item.source).val = !SettingsManager.instance.getValue(item.source).val;
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,item.source));
            }
            else if(item.type == ITEM_TYPE_LIST)
            {
               dir = ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_LEFT") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_LEFT") ? -1 : 1;
               val = s.val == null ? item.options[item.defaultValueIndex] : s.val;
               idx = int(item.options.indexOf(s.val));
               idx = Math.min(Math.max(idx + dir,0),item.options.length - 1);
               s.val = item.options[idx];
               dispatchEvent(new EventWithData(EVENT_ITEM_VALUE_CHANGED,item.source));
            }
         }
         if(ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_DOWN") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_DOWN"))
         {
            if(this._selectedItem < this._config.items.length - 1)
            {
               this._changeSelection(this._selectedItem + 1);
            }
         }
         else if(ArrayUtil.arrayContainsElement(evt.data.inputs,"DPAD_UP") || ArrayUtil.arrayContainsElement(evt.data.inputs,"LEFT_STICK_UP"))
         {
            if(this._selectedItem > 0)
            {
               this._changeSelection(this._selectedItem - 1);
            }
         }
      }
      
      private function _onMouseWheel(evt:EventWithData) : void
      {
         if(Boolean(evt.data.wheelUp))
         {
            if(this._selectedItem > 0)
            {
               this._changeSelection(this._selectedItem - 1);
            }
         }
         else if(this._selectedItem < this._config.items.length - 1)
         {
            this._changeSelection(this._selectedItem + 1);
         }
      }
      
      private function _onUpClick(evt:MouseEvent) : void
      {
         if(!ExternalDisplayManager.instance.isOnExternalDisplay)
         {
            return;
         }
         if(this._scroller.arrows.upArrow.alpha == 1)
         {
            this._changeSelection(Math.max(0,this._rowOrigin - 1));
         }
      }
      
      private function _onDownClick(evt:MouseEvent) : void
      {
         if(!ExternalDisplayManager.instance.isOnExternalDisplay)
         {
            return;
         }
         if(this._scroller.arrows.downArrow.alpha == 1)
         {
            this._changeSelection(Math.min(this._numRows - 1,this._rowOrigin + this._config.rows));
         }
      }
      
      private function _onScrollerClick(evt:MouseEvent) : void
      {
         if(!ExternalDisplayManager.instance.isOnExternalDisplay)
         {
            return;
         }
         if(evt.localY > this._scrollerTween.target.y + this._scroller.bar.height)
         {
            this._changeSelection(Math.min(this._numRows - 1,this._rowOrigin + this._config.rows));
         }
         else if(evt.localY < this._scrollerTween.target.y)
         {
            this._changeSelection(Math.max(0,this._rowOrigin - 1));
         }
      }
      
      private function _onBarDragDown(evt:MouseEvent) : void
      {
         if(!ExternalDisplayManager.instance.isOnExternalDisplay)
         {
            return;
         }
         this._scrollerTween.isActive = false;
         this._dragY = StageRef.mouseY;
         StageRef.addEventListener(Event.ENTER_FRAME,this._onBarMove);
         MouseManager.instance.addEventListener(MouseManager.EVENT_MOUSE_UP,this._onBarDragUp);
      }
      
      private function _onBarMove(evt:Event) : void
      {
         var dx:Number = StageRef.mouseY - this._dragY;
         this._dragY = StageRef.mouseY;
         this._scroller.bar.y += dx;
         if(this._scroller.bar.y < this._scroller.bg.y)
         {
            this._scroller.bar.y = this._scroller.bg.y;
         }
         else if(this._scroller.bar.y + this._scroller.bar.height > this._scroller.bg.y + this._scroller.bg.height)
         {
            this._scroller.bar.y = this._scroller.bg.y + this._scroller.bg.height - this._scroller.bar.height;
         }
      }
      
      private function _chooseNearestRow() : void
      {
         var diff1:Number = NaN;
         var diff2:Number = NaN;
         var targets:Array = [];
         var targetBarIndex:int = 0;
         var closestY:Number = int.MAX_VALUE;
         var closestIndex:Number = 0;
         for(var i:int = 0; i < this._numRows - this._config.rows; i++)
         {
            diff1 = Math.abs(this._scroller.bar.y - this._scroller.bar.height * i);
            diff2 = Math.abs(this._scroller.bar.y - this._scroller.bar.height * (i + 1));
            if(diff1 <= diff2)
            {
               targetBarIndex = i;
               break;
            }
            targetBarIndex = i + 1;
         }
         if(this._rowOrigin > targetBarIndex)
         {
            this._changeSelection(targetBarIndex);
         }
         else if(this._rowOrigin < targetBarIndex)
         {
            this._changeSelection(this._rowOrigin + this._config.rows + (targetBarIndex - this._rowOrigin) - 1);
         }
         else
         {
            this._changeSelection(this._selectedRow);
         }
      }
      
      private function _onBarDragUp(evt:EventWithData) : void
      {
         StageRef.removeEventListener(Event.ENTER_FRAME,this._onBarMove);
         MouseManager.instance.removeEventListener(MouseManager.EVENT_MOUSE_UP,this._onBarDragUp);
         this._scrollerTween.updateVars({"y":this._scroller.bar.y});
         this._scrollerTween.isActive = true;
         this._chooseNearestRow();
      }
      
      private function _onDisplayChanged(evt:EventWithData) : void
      {
         if(ExternalDisplayManager.instance.isOnExternalDisplay && !(Platform.instance.isHandheldAndroid || Platform.instance.PlatformIdUpperCase == "AFT" && Platform.instance.PlatformHasTouchscreen))
         {
            this._mobileScroller.isActive = false;
            this._scroller.arrows.upArrow.visible = true;
            this._scroller.arrows.downArrow.visible = true;
            this._chooseNearestRow();
         }
         else
         {
            this._mobileScroller.isActive = true;
            this._scroller.arrows.upArrow.visible = false;
            this._scroller.arrows.downArrow.visible = false;
            this._removeSelection();
         }
         this._scrollerTween.isActive = false;
         this._updateScroller();
      }
   }
}
