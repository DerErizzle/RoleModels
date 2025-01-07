package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuRangeItem extends SettingsMenuItemForSetting
   {
      private var _gizmoTickMcs:Array;
      
      private var _amountPerGizmo:int;
      
      private var _internalAmount:int;
      
      public function SettingsMenuRangeItem(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super(mc,data,menuDelegate);
         this._gizmoTickMcs = JBGUtil.getPropertiesOfNameInOrder(_mc.gizmo.amount,"b");
         Assert.assert(100 % this._gizmoTickMcs.length == 0);
         this._amountPerGizmo = 100 / this._gizmoTickMcs.length;
         this._internalAmount = Math.floor(_settingValue.val * 100);
      }
      
      protected function _updateGizmo() : void
      {
         this._gizmoTickMcs.forEach(function(tickMc:MovieClip, i:int, a:Array):void
         {
            var amountForThisTick:Number = i * _amountPerGizmo;
            tickMc.visible = _internalAmount == 100 ? true : amountForThisTick < _internalAmount;
         });
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         this._updateGizmo();
      }
      
      override public function onGamepadInput(inputs:Array) : void
      {
         var step:Number = NaN;
         if(!_isInteractable)
         {
            return;
         }
         if(UserInputUtil.inputsContain(inputs,[UserInputDirector.INPUT_LEFT,UserInputDirector.INPUT_RIGHT]))
         {
            step = UserInputUtil.inputsContain(inputs,UserInputDirector.INPUT_LEFT) ? -this._amountPerGizmo : this._amountPerGizmo;
            if(step + this._internalAmount < 0)
            {
               this._internalAmount = 0;
            }
            else if(step + this._internalAmount > 100)
            {
               this._internalAmount = 100;
            }
            else
            {
               this._internalAmount += step;
            }
            this._updateSetting();
         }
      }
      
      private function _updateSetting() : void
      {
         _settingValue.val = Number(this._internalAmount) / 100;
      }
      
      override protected function _onMouseDown(evt:MouseEvent) : void
      {
         if(!_isInteractable)
         {
            return;
         }
         _menuDelegate.handleSelectionRequest(this);
         var ratio:Number = Math.min(Math.max(_getRatioForRange(new Point(evt.stageX,evt.stageY)),0),1);
         this._internalAmount = Math.round(100 * ratio);
         this._updateSetting();
      }
   }
}

