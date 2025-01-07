package jackboxgames.thewheel.utils
{
   import flash.utils.getDefinitionByName;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class LibraryActionPackage extends JBGActionPackage
   {
      protected var _gs:JBGGameState;
      
      protected var _shower:MovieClipShower;
      
      public function LibraryActionPackage(apRef:IActionPackageRef, gs:JBGGameState)
      {
         super(apRef);
         this._gs = gs;
      }
      
      protected function get _linkage() : String
      {
         return null;
      }
      
      protected function get _displayIndex() : int
      {
         return 0;
      }
      
      protected function get _propertyName() : String
      {
         return null;
      }
      
      protected function get _setShowerOnActive() : Boolean
      {
         return true;
      }
      
      override protected function get _sourceURL() : String
      {
         return null;
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      override protected function _createReferences() : void
      {
         Assert.assert(this._linkage != null);
         var c:Class = Class(getDefinitionByName(this._linkage));
         _mc = new c();
         LocalizedTextFieldManager.instance.addFromRoot(_mc);
      }
      
      override protected function _disposeOfReferences() : void
      {
         LocalizedTextFieldManager.instance.removeFromRoot(_mc);
         _mc = null;
      }
      
      protected function _onLoaded() : void
      {
         Assert.assert(this._propertyName != null);
         _ts.g[this._propertyName] = this;
         this._gs.screenOrganizer.addChild(_mc,this._displayIndex);
         this._shower = new MovieClipShower(_mc);
      }
      
      protected function _onActiveChanged(isActive:Boolean) : void
      {
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         this._onReset();
         ref.end();
      }
      
      protected function _onReset() : void
      {
         JBGUtil.reset([this._shower]);
      }
      
      public function handleActionSetActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            this._onActiveChanged(true);
            this._gs.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
            if(this._setShowerOnActive)
            {
               this._shower.setShown(true,TSUtil.createRefEndFn(ref));
            }
            else
            {
               ref.end();
            }
         }
         else if(this._setShowerOnActive)
         {
            this._shower.setShown(false,function():void
            {
               _gs.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
               _onActiveChanged(false);
               ref.end();
            });
         }
         else
         {
            this._gs.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
            this._onActiveChanged(false);
            ref.end();
         }
      }
   }
}

