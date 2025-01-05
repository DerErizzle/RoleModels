package jackboxgames.utils
{
   import flash.display.*;
   import flash.geom.*;
   import jackboxgames.events.*;
   import jackboxgames.flash.*;
   import jackboxgames.logger.*;
   import jackboxgames.mobile.*;
   import jackboxgames.nativeoverride.*;
   
   public class PlatformButton extends JBGMovieClip
   {
       
      
      private var _buttonId:String;
      
      private var _skinId:String;
      
      private var _skinContainer:MovieClip;
      
      private var _skin:MovieClip;
      
      private var _resize:Boolean;
      
      private var _usePlatformSkinner:Boolean;
      
      private var _skinner:PlatformSkinner;
      
      private var _logic:ButtonLogic;
      
      private var _canTouchPaused:Boolean = false;
      
      public function PlatformButton(touchClip:MovieClip, skinClip:MovieClip, buttonIds:Array, resize:Boolean = true, skin:Boolean = true, usePlatformSkinner:Boolean = true, forceSkin:String = null)
      {
         var mcToHit:MovieClip = null;
         super(touchClip);
         if(EnvUtil.isAIR() || BuildConfig.instance.configVal("supportsMouse") == true)
         {
            if(Boolean(touchClip.hitbox))
            {
               mcToHit = touchClip.hitbox;
            }
            else if(Boolean(touchClip.container))
            {
               if(Boolean(touchClip.container.hitbox))
               {
                  mcToHit = touchClip.container.hitbox;
               }
               else
               {
                  mcToHit = this._addHitBox(touchClip);
               }
            }
            else
            {
               mcToHit = this._addHitBox(touchClip);
            }
            mcToHit.useHandCursor = true;
            mcToHit.buttonMode = true;
         }
         skinClip.useHandCursor = true;
         skinClip.buttonMode = true;
         this._skinContainer = skinClip;
         this._reskin(buttonIds,resize,skin,usePlatformSkinner,forceSkin);
         this._logic = new ButtonLogic(_mc,function(b:ButtonLogic):void
         {
         },function(b:ButtonLogic, inside:Boolean):void
         {
            if(inside)
            {
               if(canTouchPaused)
               {
                  Gamepad.instance.dispatchEvent(new EventWithData(Gamepad.EVENT_RECEIVED_INPUT,{
                     "index":0,
                     "id":"touch",
                     "type":InputManager.INPUT_TYPE_MOUSE,
                     "inputs":[_buttonId]
                  }));
                  Gamepad.instance.dispatchEvent(new EventWithData(_buttonId,{
                     "index":0,
                     "id":"touch",
                     "type":InputManager.INPUT_TYPE_MOUSE
                  }));
               }
               else
               {
                  Gamepad.instance.dispatchEvent(new EventWithData(Gamepad.EVENT_RECEIVED_INPUT,{
                     "index":0,
                     "id":"touch",
                     "type":InputManager.INPUT_TYPE_MOUSE,
                     "inputs":[_buttonId]
                  }));
                  Gamepad.instance.dispatchEvent(new EventWithData(_buttonId,{
                     "index":0,
                     "id":"touch",
                     "type":InputManager.INPUT_TYPE_MOUSE
                  }));
               }
            }
         },null);
      }
      
      public static function getPlatformSkin(button:String) : String
      {
         switch(button)
         {
            case "A":
               return "Console_AButton";
            case "B":
               return "Console_BButton";
            case "X":
               return "Console_XButton";
            case "Y":
               return "Console_YButton";
            default:
               if(EnvUtil.isAIR() || BuildConfig.instance.configVal("supportsKeyboard") == true)
               {
                  switch(button)
                  {
                     case "H":
                        return "Menu_YButton";
                     case "Q":
                        return "Menu_BButton";
                     case "P":
                        return "Menu_AButton";
                     case "DPAD_UP":
                        return "Menu_UpButton";
                     case "DPAD_DOWN":
                        return "Menu_DownButton";
                     case "DPAD_LEFT":
                        return "Menu_LeftButton";
                     case "DPAD_RIGHT":
                        return "Menu_RightButton";
                     case "BACK":
                        return "Menu_BackButton";
                     case "SELECT":
                        return "Menu_SelectButton";
                     case "SPACE":
                        return "JA_BuzzButton";
                     case "DELETE":
                        return "Menu_DelButton";
                  }
               }
               if(EnvUtil.isMobile())
               {
                  switch(button)
                  {
                     case "BACK":
                        return "Console_BackButton";
                     case "SELECT":
                        return "Console_StartButton";
                     case "YRIGHT":
                        return "Console_Alt1Button";
                     case "XLEFT":
                        return "Console_Alt3Button";
                     case "YUP":
                        return "Console_Alt4Button";
                  }
               }
               return "";
         }
      }
      
      public function get canTouchPaused() : Boolean
      {
         return this._canTouchPaused;
      }
      
      public function set canTouchPaused(val:Boolean) : void
      {
         this._canTouchPaused = val;
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
      
      private function _reskin(buttonIds:Array, resize:Boolean = true, skin:Boolean = true, usePlatformSkinner:Boolean = true, forceSkin:String = null) : void
      {
         var buttonId:String = null;
         var skinId:String = null;
         this._resize = resize;
         this._usePlatformSkinner = usePlatformSkinner;
         for(var i:int = 0; i < buttonIds.length; i++)
         {
            buttonId = String(buttonIds[i]);
            skinId = getPlatformSkin(buttonId);
            if(forceSkin != null && PlatformMovieClipManager.instance.hasMovieClip(forceSkin))
            {
               skinId = forceSkin;
            }
            if(!skin || PlatformMovieClipManager.instance.hasMovieClip(skinId))
            {
               this._skinId = skinId;
               this._buttonId = this.GamepadId(buttonId);
               break;
            }
         }
         if(skin && this._skinId && this._skinId.length > 0)
         {
            if(Boolean(this._skin) && Boolean(this._skinContainer) && this._skinContainer.contains(this._skin))
            {
               this._skinContainer.removeChild(this._skin);
            }
            this._skin = PlatformMovieClipManager.instance.getMovieClip(this._skinId);
            if(this._usePlatformSkinner)
            {
               this._skinner = new PlatformSkinner(this._skin);
               this._skinner.addEventListener(PlatformSkinner.EVENT_STATE_CHANGED,this._onSkinChanged);
            }
            if(resize && Boolean(this._skinContainer.size))
            {
               MovieClipUtil.addChildWithResizeKeepRatio(this._skinContainer,this._skin);
            }
            else
            {
               this._skinContainer.addChild(this._skin);
            }
            this._skin.useHandCursor = true;
            this._skin.buttonMode = true;
         }
         else
         {
            Logger.error("PlatformButton::_reskin is missing a skin for \"" + buttonId + "\"");
         }
      }
      
      private function _onSkinChanged(evt:EventWithData) : void
      {
         if(this._resize && Boolean(this._skinContainer.size))
         {
            this._skin.scaleX = 1;
            this._skin.scaleY = 1;
            MovieClipUtil.addChildWithResizeKeepRatio(this._skinContainer,this._skin);
         }
      }
      
      public function setEnable(value:Boolean) : void
      {
         this._logic.enabled = value;
      }
      
      private function GamepadId(button:String) : String
      {
         switch(button)
         {
            case "YUP":
            case "YRIGHT":
               return "Y";
            case "XLEFT":
               return "X";
            default:
               return button;
         }
      }
      
      override public function dispose() : void
      {
         this._logic.enabled = false;
         this._logic.clear();
         if(Boolean(this._skin) && Boolean(this._skin.parent))
         {
            this._skin.parent.removeChild(this._skin);
         }
         if(Boolean(this._skinner))
         {
            this._skinner.removeEventListener(PlatformSkinner.EVENT_STATE_CHANGED,this._onSkinChanged);
         }
         super.dispose();
      }
   }
}
