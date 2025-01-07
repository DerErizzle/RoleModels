package jackboxgames.thewheel.actionpackages
{
   import com.greensock.*;
   import jackboxgames.animation.tween.*;
   import jackboxgames.events.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.ui.menu.*;
   import jackboxgames.utils.*;
   
   public class Menu extends JBGActionPackage
   {
      private var _mainMenu:TheWheelMenu;
      
      private var _loopingMcs:Array;
      
      public function Menu(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return "thewheel_menu.swf";
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            _mainMenu.init(TSUtil.createRefEndFn(ref));
         });
      }
      
      private function _onLoaded() : void
      {
         GameState.instance.screenOrganizer.addChild(_mc,1);
         this._mainMenu = new TheWheelMenu(_mc);
         addDelegate(this._mainMenu);
         this._loopingMcs = [_mc.clouds,_mc.bg.rays];
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         resetDelegates();
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         JBGUtil.gotoFrame(_mc.fade,"Park");
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Loop");
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         ref.end();
      }
      
      public function handleActionFadeToWhite(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.fade,"FadeToWhite",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.ui.menu.DefaultMainMenu;

class TheWheelMenu extends DefaultMainMenu
{
   public function TheWheelMenu(mc:MovieClip)
   {
      super(mc);
   }
   
   override protected function _getItemClass() : Class
   {
      return TheWheelMainMenuItem;
   }
}

import flash.display.MovieClip;
import jackboxgames.localizy.*;
import jackboxgames.model.*;
import jackboxgames.text.*;
import jackboxgames.ui.menu.*;
import jackboxgames.ui.menu.components.*;

class TheWheelMainMenuItem extends DefaultMainMenuItem
{
   private var _title2:ExtendableTextField;
   
   public function TheWheelMainMenuItem(mc:MovieClip)
   {
      super(mc);
      this._title2 = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.txt2);
   }
   
   override public function setup(item:Object, source:String = null) : void
   {
      super.setup(item,source);
      this._title2.text = title.text;
   }
}

import jackboxgames.ui.menu.DefaultMainMenu;
import jackboxgames.ui.menu.components.DefaultMainMenuItem;

