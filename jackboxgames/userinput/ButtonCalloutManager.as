package jackboxgames.userinput
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import jackboxgames.flash.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public final class ButtonCalloutManager
   {
      private static var _instance:ButtonCalloutManager;
      
      private var _buttonCalloutsPerSource:Dictionary;
      
      public function ButtonCalloutManager()
      {
         super();
         this._buttonCalloutsPerSource = new Dictionary();
      }
      
      public static function get instance() : ButtonCalloutManager
      {
         if(!_instance)
         {
            _instance = new ButtonCalloutManager();
         }
         return _instance;
      }
      
      public static function buildButtonCalloutFromHelper(helper:ButtonCalloutHelperComponent) : PlatformButton
      {
         var mc:MovieClip = MovieClip(helper.parent);
         return new PlatformButton(mc,mc.button,helper.userInputKey);
      }
      
      private static function _findButtonCalloutHelpersInChildren(root:DisplayObjectContainer, deep:Boolean) : Array
      {
         var child:DisplayObject = null;
         var helpers:Array = [];
         if(!root)
         {
            return helpers;
         }
         for(var i:int = 0; i < root.numChildren; i++)
         {
            child = root.getChildAt(i);
            if(child is ButtonCalloutHelperComponent)
            {
               helpers.push(child);
            }
            if(deep && child is DisplayObjectContainer)
            {
               helpers = helpers.concat(_findButtonCalloutHelpersInChildren(DisplayObjectContainer(child),true));
            }
         }
         return helpers;
      }
      
      public function addFromRoot(root:DisplayObjectContainer, source:String = null) : void
      {
         var helpersWithInputKey:Array;
         if(!source)
         {
            source = BuildConfig.instance.configVal("gameName");
         }
         if(!(source in this._buttonCalloutsPerSource))
         {
            this._buttonCalloutsPerSource[source] = [];
         }
         helpersWithInputKey = _findButtonCalloutHelpersInChildren(root,true);
         helpersWithInputKey.forEach(function(h:ButtonCalloutHelperComponent, ... args):void
         {
            _buttonCalloutsPerSource[source].push(buildButtonCalloutFromHelper(h));
         });
      }
   }
}

import flash.display.MovieClip;
import flash.geom.Rectangle;
import jackboxgames.events.*;
import jackboxgames.mobile.*;
import jackboxgames.utils.*;

class PlatformButton extends JBGMovieClip
{
   private var _input:String;
   
   private var _calloutContainerMc:MovieClip;
   
   private var _calloutMc:MovieClip;
   
   private var _skinner:PlatformSkinner;
   
   private var _logic:ButtonLogic;
   
   public function PlatformButton(touchMc:MovieClip, calloutContainerMc:MovieClip, input:String)
   {
      var mcToHit:MovieClip = null;
      super(touchMc);
      this._input = input;
      if(BuildConfig.instance.configVal("supportsMouse") == true)
      {
         if(Boolean(touchMc.hitbox))
         {
            mcToHit = touchMc.hitbox;
         }
         else if(Boolean(touchMc.container))
         {
            if(Boolean(touchMc.container.hitbox))
            {
               mcToHit = touchMc.container.hitbox;
            }
            else
            {
               mcToHit = this._addHitBox(touchMc);
            }
         }
         else
         {
            mcToHit = this._addHitBox(touchMc);
         }
         mcToHit.useHandCursor = true;
         mcToHit.buttonMode = true;
      }
      this._calloutContainerMc = calloutContainerMc;
      this._calloutContainerMc.useHandCursor = true;
      this._calloutContainerMc.buttonMode = true;
      if(PlatformMovieClipManager.instance.hasMovieClip(this._input))
      {
         this._calloutMc = PlatformMovieClipManager.instance.getMovieClip(this._input);
         this._calloutMc.useHandCursor = true;
         this._calloutMc.buttonMode = true;
         this._skinner = new PlatformSkinner(this._calloutMc);
         this._skinner.addEventListener(PlatformSkinner.EVENT_STATE_CHANGED,this._onSkinChanged);
         this._calloutContainerMc.addChild(this._calloutMc);
         MovieClipUtil.resizeKeepRatio(this._calloutMc);
      }
      this._logic = new ButtonLogic(_mc,function(b:ButtonLogic):void
      {
      },function(b:ButtonLogic, inside:Boolean):void
      {
         if(inside)
         {
            UserInputDirector.instance.forceInputs([input]);
         }
      },null);
   }
   
   private function _onSkinChanged(evt:EventWithData) : void
   {
      if(Boolean(this._calloutMc))
      {
         MovieClipUtil.resizeKeepRatio(this._calloutMc);
      }
   }
   
   override public function dispose() : void
   {
      this._logic.enabled = false;
      this._logic.clear();
      if(Boolean(this._calloutMc))
      {
         DisplayObjectUtil.removeFromParent(this._calloutMc);
         this._calloutMc = null;
      }
      if(Boolean(this._skinner))
      {
         this._skinner.removeEventListener(PlatformSkinner.EVENT_STATE_CHANGED,this._onSkinChanged);
      }
      super.dispose();
   }
   
   private function _addHitBox(clip:MovieClip) : MovieClip
   {
      var touchClipBounds:Rectangle = clip.getBounds(clip);
      var hitBox:MovieClip = new MovieClip();
      hitBox.graphics.beginFill(0,1);
      hitBox.graphics.drawRect(touchClipBounds.x,touchClipBounds.y,touchClipBounds.width,touchClipBounds.height);
      hitBox.graphics.endFill();
      hitBox.alpha = 0;
      hitBox.name = "hitbox";
      clip.addChild(hitBox);
      return hitBox;
   }
}

import flash.events.EventDispatcher;
import jackboxgames.utils.JBGMovieClip;
import jackboxgames.utils.PausableEventDispatcher;

