package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import jackboxgames.animation.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuItem extends PausableEventDispatcher
   {
      protected var _mc:MovieClip;
      
      protected var _data:ISettingsMenuElementData;
      
      protected var _menuDelegate:ISettingsMenuItemDelegate;
      
      protected var _title:ExtendableTextField;
      
      protected var _hitbox:MovieClip;
      
      protected var _isEnabled:Boolean;
      
      protected var _isHighlighted:Boolean;
      
      protected var _isSelected:Boolean;
      
      public function SettingsMenuItem(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super();
         this._mc = mc;
         this._data = data;
         this._menuDelegate = menuDelegate;
         this._title = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.label);
         this._hitbox = this._mc.hitbox;
         JBGUtil.gotoFrame(this._mc,"Default");
         this._isEnabled = true;
         this._updateEnabledLogic();
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function get hitbox() : MovieClip
      {
         return this._hitbox;
      }
      
      public function get data() : ISettingsMenuElementData
      {
         return this._data;
      }
      
      public function get height() : Number
      {
         return this._hitbox.y + this._hitbox.height;
      }
      
      public function get width() : Number
      {
         return this._hitbox.x + this._hitbox.width;
      }
      
      protected function _updateTitle() : void
      {
         this._title.text = this._data.title;
      }
      
      protected function _getRatioForRange(point:Point) : Number
      {
         var newPoint:Point = this._hitbox.globalToLocal(point);
         var bounds:Rectangle = this._hitbox.getBounds(this._hitbox);
         return (newPoint.x - bounds.left) / (bounds.right - bounds.left);
      }
      
      public function onLocaleChanged() : void
      {
         this._updateTitle();
      }
      
      public function dispose() : void
      {
         this._title.dispose();
         this._title = null;
         this._menuDelegate = null;
         this._data = null;
         this._mc.removeEventListener(MouseEvent.MOUSE_OVER,this._onMouseOver);
         this._hitbox.removeEventListener(MouseEvent.MOUSE_DOWN,this._onMouseDown);
         this._hitbox = null;
         this._mc = null;
      }
      
      public function update(instant:Boolean = false) : void
      {
         this._updateTitle();
      }
      
      private function _updateMcFrame() : void
      {
         if(!this._isEnabled)
         {
            JBGUtil.gotoFrame(this._mc,"Disabled");
         }
         else if(this._isSelected)
         {
            JBGUtil.gotoFrame(this._mc,this._isHighlighted ? "SelectedAndHighlighted" : "SelectedAndUnhighlighted");
         }
         else
         {
            JBGUtil.gotoFrame(this._mc,this._isHighlighted ? "Highlight" : "Unhighlight");
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._isEnabled;
      }
      
      private function _updateEnabledLogic() : void
      {
         if(this._isEnabled)
         {
            this._hitbox.useHandCursor = true;
            this._hitbox.buttonMode = true;
            this._hitbox.mouseChildren = false;
            this._mc.addEventListener(MouseEvent.MOUSE_OVER,this._onMouseOver);
            this._hitbox.addEventListener(MouseEvent.MOUSE_DOWN,this._onMouseDown);
         }
         else
         {
            this._hitbox.useHandCursor = false;
            this._hitbox.buttonMode = false;
            this._hitbox.mouseChildren = false;
            this._mc.removeEventListener(MouseEvent.MOUSE_OVER,this._onMouseOver);
            this._hitbox.removeEventListener(MouseEvent.MOUSE_DOWN,this._onMouseDown);
         }
      }
      
      public function setEnabled(isEnabled:Boolean) : void
      {
         if(this._isEnabled == isEnabled)
         {
            return;
         }
         this._isEnabled = isEnabled;
         this._updateMcFrame();
         this._updateEnabledLogic();
      }
      
      public function setHighlighted(isHighlighted:Boolean) : void
      {
         if(this._isHighlighted == isHighlighted)
         {
            return;
         }
         this._isHighlighted = isHighlighted;
         this._updateMcFrame();
      }
      
      public function setSelected(isSelected:Boolean) : void
      {
         if(this._isSelected == isSelected)
         {
            return;
         }
         this._isSelected = isSelected;
         this._updateMcFrame();
      }
      
      protected function get _isInteractable() : Boolean
      {
         if(!this._isEnabled)
         {
            return false;
         }
         return this._menuDelegate.isListeningForInput;
      }
      
      public function onGamepadInput(inputs:Array) : void
      {
      }
      
      protected function _onMouseDown(evt:MouseEvent) : void
      {
      }
      
      protected function _onMouseOver(evt:MouseEvent) : void
      {
         if(!this._isInteractable)
         {
            return;
         }
         this._menuDelegate.handleSelectionRequest(this);
      }
      
      protected function _onSettingUpdated(evt:EventWithData) : void
      {
         this.update();
      }
   }
}

