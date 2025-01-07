package jackboxgames.thewheel.wheel
{
   import flash.display.MovieClip;
   import flash.utils.getDefinitionByName;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.utils.*;
   
   public class Slice
   {
      public static const STATE_DEFAULT:String = "default";
      
      public static const STATE_HIGHLIGHTED:String = "highlighted";
      
      public static const STATE_DIMMED:String = "dimmed";
      
      public static const STATE_SELECTABLE:String = "selectable";
      
      public static const STATE_SELECTED:String = "selected";
      
      private var _params:SliceParameters;
      
      private var _mc:MovieClip;
      
      private var _mcStateMachine:FrameStateMachine;
      
      private var _subWidget:ISliceSubWidget;
      
      private var _catchMe:SliceCatchMeWidget;
      
      private var _position:int;
      
      private var _size:int;
      
      private var _isOnScreen:Boolean;
      
      public function Slice(params:SliceParameters, position:int, size:int)
      {
         super();
         this._params = params;
         this._position = position;
         this._size = size;
         var className:String = this._params.type.baseSymbolName + size + "Degree";
         var sliceClass:Class = Class(getDefinitionByName(className));
         Assert.assert(sliceClass != null);
         this._mc = new sliceClass();
         this._mcStateMachine = new FrameStateMachine().withNode(STATE_DEFAULT).withNode(STATE_HIGHLIGHTED).withNode(STATE_DIMMED).withNode(STATE_SELECTABLE).withNode(STATE_SELECTED).withTransition(STATE_DEFAULT,STATE_HIGHLIGHTED,"Highlight").withTransition(STATE_HIGHLIGHTED,STATE_DEFAULT,"Unhighlight").withTransition(STATE_DEFAULT,STATE_DIMMED,"Dim").withTransition(STATE_DIMMED,STATE_DEFAULT,"Undim").withTransition(STATE_DEFAULT,STATE_SELECTABLE,"Selectable").withTransition(STATE_SELECTABLE,STATE_SELECTED,"Selected").withTransition(STATE_SELECTED,STATE_SELECTABLE,"Selectable").withTransition(STATE_SELECTABLE,STATE_DEFAULT,"Default").withTransition(STATE_SELECTED,STATE_DEFAULT,"Default");
         this._subWidget = new this._params.type.subWidgetClass(this._mc,this._params);
         Assert.assert(this._subWidget is ISliceSubWidget);
         if(Boolean(this._mc.catchMe))
         {
            this._catchMe = new SliceCatchMeWidget(this._mc.catchMe);
         }
         LocalizedTextFieldManager.instance.addFromRoot(this._mc);
         this.updateVisuals();
      }
      
      public static function GENERATE_FIND_FN_FOR_TYPE(sliceType:SliceType) : Function
      {
         return function(s:Slice, ... args):Boolean
         {
            return s.params.type == sliceType;
         };
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function get subWidget() : ISliceSubWidget
      {
         return this._subWidget;
      }
      
      public function get catchMe() : SliceCatchMeWidget
      {
         return this._catchMe;
      }
      
      public function get params() : SliceParameters
      {
         return this._params;
      }
      
      public function get position() : int
      {
         return this._position;
      }
      
      public function get size() : int
      {
         return this._size;
      }
      
      public function get isOnScreen() : Boolean
      {
         return this._isOnScreen;
      }
      
      public function dispose() : void
      {
         LocalizedTextFieldManager.instance.removeFromRoot(this._mc);
         if(Boolean(this._catchMe))
         {
            this._catchMe.dispose();
         }
         this._subWidget.dispose();
         JBGUtil.gotoFrame(this._mc,"Park");
         this._isOnScreen = false;
         this._mc = null;
      }
      
      public function updateVisuals() : void
      {
         this._subWidget.updateVisuals();
      }
      
      public function slideIn(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"SlideIn",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         this._isOnScreen = true;
      }
      
      public function instantOn() : void
      {
         JBGUtil.gotoFrame(this._mc,"SlideIn");
         this._isOnScreen = true;
      }
      
      public function flipOff(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"FlipOff",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         this._isOnScreen = false;
      }
      
      public function flipOn(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,"FlipOn",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         this._isOnScreen = true;
      }
      
      public function setVisualState(state:String) : void
      {
         var frame:String = this._mcStateMachine.transition(state);
         if(!frame)
         {
            return;
         }
         JBGUtil.gotoFrame(this._mc,frame);
      }
   }
}

