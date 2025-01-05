package jackboxgames.rolemodels.actionpackages
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.widgets.menu.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class Menu extends JBGActionPackage
   {
       
      
      private var _mainMenu:RoleModelsMainMenu;
      
      private var _titleShower:MovieClipShower;
      
      private var _titleMC:MovieClip;
      
      private var _cube:CubeWidget;
      
      public function Menu(sourceURL:String)
      {
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         this._mainMenu = new RoleModelsMainMenu(mc);
         addDelegate(this._mainMenu);
         this._mainMenu.init(function():void
         {
         });
         this._titleShower = new MovieClipShower(mc.titleAnimation);
         this._titleMC = mc.titleAnimation.logo;
         this._cube = new CubeWidget(mc.cube);
      }
      
      private function parkEverything() : void
      {
         resetDelegates();
         _mc.visible = false;
         this._titleShower.reset();
         JBGUtil.gotoFrame(this._titleMC,"Park");
         this._cube.reset();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         JBGUtil.safeRemoveChild(DisplayObjectContainer(_ts.background),_mc);
         this.parkEverything();
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         _ts.background.addChild(_mc);
         _mc.visible = true;
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         this.parkEverything();
         JBGUtil.safeRemoveChild(DisplayObjectContainer(_ts.background),_mc);
         ref.end();
      }
      
      public function handleActionSetTitleShown(ref:IActionRef, params:Object) : void
      {
         this._titleShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoTitleAnimation(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._titleMC,params.animation,MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetCubeShown(ref:IActionRef, params:Object) : void
      {
         this._cube.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoCubeAnimation(ref:IActionRef, params:Object) : void
      {
         this._cube.shower.doAnimation(params.animation,TSUtil.createRefEndFn(ref));
      }
   }
}
