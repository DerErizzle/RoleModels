package jackboxgames.text
{
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class CensorableTextField
   {
      
      public static function GENERATE_BLACK_BAR():MovieClip
      {
         var mc:MovieClip = new MovieClip();
         mc.graphics.lineStyle(0,0);
         mc.graphics.beginFill(0);
         mc.graphics.drawRect(-50,-50,100,100);
         mc.graphics.endFill();
         return mc;
      } 
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _text:String;
      
      private var _ambiguousText:String;
      
      private var _players:Array;
      
      private var _sourceStrings:Array;
      
      private var _isCensored:Boolean;
      
      private var _censorBar:MovieClip;
      
      public function CensorableTextField(mc:MovieClip, generateCensorBarFn:Function, numLines:int = 1, minSize:int = 4, maxSize:int = 100, stepSize:int = 2, splitWords:Boolean = true, balanceType:String = null, additionalMappers:Array = null, additionalPostEffects:Array = null)
      {
         super();
         this._mc = mc;
         additionalMappers = ArrayUtil.makeArrayIfNecessary(additionalMappers);
         additionalPostEffects = ArrayUtil.makeArrayIfNecessary(additionalPostEffects);
         this._tf = new ExtendableTextField(this._mc,[].concat(additionalMappers),[PostEffectFactory.createDynamicResizerEffect(numLines,minSize,maxSize,stepSize,splitWords),PostEffectFactory.createBalancerEffect(balanceType != null ? balanceType : TextUtils.BALANCE_CENTER)].concat(additionalPostEffects));
         this._players = [];
         this._sourceStrings = [];
         this._isCensored = false;
         this._censorBar = generateCensorBarFn();
         this._tryToSetFrameOnOrVisibilityOnCensorBar("Park",false);
         this.text = this._tf.text;
         this._mc.addChild(this._censorBar);
      }
      
      private function _tryToSetFrameOnOrVisibilityOnCensorBar(frame:String, visible:Boolean) : void
      {
         if(this._censorBar is MovieClip && MovieClipUtil.frameExists(this._censorBar,frame))
         {
            JBGUtil.gotoFrame(this._censorBar,frame);
         }
         else
         {
            this._censorBar.visible = visible;
         }
      }
      
      public function get text() : *
      {
         return this._text;
      }
      
      private function _createAmbiguousString() : String
      {
         var POSSIBLE:String = "@!%$#";
         var ambiguous:String = "";
         for(var i:int = 0; i < this._text.length; i++)
         {
            ambiguous += POSSIBLE.charAt(Math.floor(Math.random() * POSSIBLE.length));
         }
         return ambiguous;
      }
      
      public function set text(val:*) : void
      {
         var tf:TextField = null;
         this._text = val;
         this._ambiguousText = this._createAmbiguousString();
         this._setText();
         var rect:Rectangle = new Rectangle();
         if(this._mc.hasOwnProperty("balancer"))
         {
            rect = new Rectangle(this._mc.balancer.x,this._mc.balancer.y,this._mc.tf.width,this._mc.balancer.height);
         }
         else if(this._mc.hasOwnProperty("tf"))
         {
            tf = this._mc.tf;
            rect = tf.getBounds(this._mc);
         }
         this._censorBar.x = rect.x + rect.width / 2;
         this._censorBar.y = rect.y + rect.height / 2;
         this._censorBar.width = rect.width;
         this._censorBar.height = rect.height;
      }
      
      public function setColor(c:uint, a:Number) : void
      {
         this._tf.setColor(c,a);
      }
      
      public function reset() : void
      {
         var p:* = undefined;
         var s:UserString = null;
         for each(p in this._players)
         {
            p.isCensored.removeEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onPlayerCensoredChanged);
         }
         for each(s in this._sourceStrings)
         {
            s.isCensored.removeEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onStringCensoredChanged);
         }
         this._players = [];
         this._sourceStrings = [];
         this._isCensored = false;
         this._tryToSetFrameOnOrVisibilityOnCensorBar("Park",false);
      }
      
      public function setup(players:*, sourceStrings:*) : void
      {
         var p:* = undefined;
         var s:UserString = null;
         this.reset();
         this._players = ArrayUtil.makeArrayIfNecessary(players);
         this._sourceStrings = ArrayUtil.makeArrayIfNecessary(sourceStrings);
         for each(p in this._players)
         {
            p.isCensored.addEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._updateCensored);
         }
         for each(s in this._sourceStrings)
         {
            s.isCensored.addEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onStringCensoredChanged);
         }
         this._updateCensored(false);
      }
      
      public function setupWithUserString(s:UserString) : void
      {
         this.setup([s.author],[s]);
         this.text = s.filtered;
      }
      
      private function _setText() : void
      {
         this._tf.text = this._isCensored ? this._ambiguousText : this._text;
      }
      
      private function _onPlayerCensoredChanged(evt:EventWithData) : void
      {
         this._updateCensored(true);
      }
      
      private function _onStringCensoredChanged(evt:EventWithData) : void
      {
         this._updateCensored(true);
      }
      
      private function _updateCensored(animate:Boolean) : void
      {
         var isCensored:Boolean = (function():Boolean
         {
            var p:* = undefined;
            var s:* = undefined;
            for each(p in _players)
            {
               if(Boolean(p.isCensored.val))
               {
                  return true;
               }
            }
            for each(s in _sourceStrings)
            {
               if(Boolean(s.isCensored.val))
               {
                  return true;
               }
            }
            return false;
         })();
         if(this._isCensored == isCensored)
         {
            return;
         }
         this._isCensored = isCensored;
         if(this._isCensored)
         {
            this._tryToSetFrameOnOrVisibilityOnCensorBar(animate ? "Appear" : "AppearDone",true);
         }
         else
         {
            this._tryToSetFrameOnOrVisibilityOnCensorBar(animate ? "Disappear" : "DisappearDone",false);
         }
         this._setText();
      }
   }
}
