package jackboxgames.widgets.postgame
{
   import com.greensock.*;
   import com.greensock.easing.*;
   import com.greensock.events.*;
   import flash.display.*;
   import flash.geom.*;
   import flash.text.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class PostGameCredits
   {
      protected static const TOTAL_GUTTER_HEIGHT:Number = 4;
      
      protected var _mc:MovieClip;
      
      protected var _gs:JBGGameState;
      
      protected var _loader:ILoader;
      
      protected var _tween:TweenMax;
      
      protected var _canceler:Function;
      
      protected var _initialRectangle:Rectangle;
      
      public function PostGameCredits(mc:MovieClip, gs:JBGGameState)
      {
         super();
         this._mc = mc;
         this._gs = gs;
         this._canceler = Nullable.NULL_FUNCTION;
         this._initialRectangle = new Rectangle(this._mc.credits.container.tf.x,this._mc.credits.container.tf.y,this._mc.credits.container.tf.width,this._mc.credits.container.tf.height - TOTAL_GUTTER_HEIGHT);
      }
      
      public function dispose() : void
      {
         this._mc = null;
      }
      
      public function reset() : void
      {
         if(Boolean(this._loader))
         {
            this._loader.dispose();
            this._loader = null;
         }
         if(Boolean(this._tween))
         {
            TweenMax.killTweensOf(this._mc.credits.container.tf);
            this._tween = null;
         }
         JBGUtil.arrayGotoFrame([this._getBehaviorMC()],"Park");
         this._canceler();
         this._canceler = Nullable.NULL_FUNCTION;
      }
      
      protected function _getSpeed() : Number
      {
         return 55;
      }
      
      protected function _getColor() : String
      {
         return "#e8b32b";
      }
      
      protected function _getOffset() : Number
      {
         return 0;
      }
      
      protected function _getStyle() : String
      {
         return "";
      }
      
      protected function _getSourceFile() : String
      {
         return "Credits.html";
      }
      
      protected function _getPreCreditsString() : String
      {
         var winningScore:int = 0;
         var winner:JBGPlayer = null;
         winningScore = MapFold.process(this._gs.players,function(p:JBGPlayer, index:int, array:Array):int
         {
            return p.score.val;
         },function(previousValue:int, currentValue:int):int
         {
            return Math.max(previousValue,currentValue);
         });
         var winners:Array = this._gs.players.filter(function(p:JBGPlayer, index:int, array:Array):Boolean
         {
            return p.score.val >= winningScore;
         });
         var credits:String = "<font " + (Boolean(this._getStyle()) ? "face=\'" + this._getStyle() + "\'" : "") + " color=\'" + this._getColor() + "\'>" + (winners.length == 1 ? "WINNER" : "WINNERS") + "</font>";
         credits += "\n";
         for each(winner in winners)
         {
            credits += winner.name.val + "\n";
         }
         credits += "\n\n\n";
         return credits;
      }
      
      protected function _getPostCreditsString() : String
      {
         return "";
      }
      
      protected function _formatText(text:String) : String
      {
         return this._getPreCreditsString() + TextUtils.filter(text,[TextUtils.replaceFilter("\r\n","\n")]) + this._getPostCreditsString();
      }
      
      protected function _getCreditsTF() : TextField
      {
         return this._mc.credits.container.tf.tf;
      }
      
      protected function _setText(text:String) : void
      {
         var credits:String = this._formatText(text);
         var tf:TextField = this._getCreditsTF();
         tf.autoSize = TextFieldAutoSize.CENTER;
         tf.htmlText = credits;
      }
      
      protected function _getBehaviorMC() : MovieClip
      {
         return this._mc.credits;
      }
      
      protected function _loadCredits(doneFn:Function) : void
      {
         this._loader = JBGLoader.instance.loadFile(this._getSourceFile(),function(result:Object):void
         {
            _loader.dispose();
            _loader = null;
            if(Boolean(result.success))
            {
               _setText(result.loader.contentAsString);
            }
            doneFn();
         });
      }
      
      protected function _onCreditsLoaded(doneFn:Function) : void
      {
         this._runCredits();
         JBGUtil.gotoFrameWithFn(this._getBehaviorMC(),"Appear",MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
      }
      
      public function show(doneFn:Function) : void
      {
         this._loadCredits(function():void
         {
            _onCreditsLoaded(doneFn);
         });
      }
      
      public function dismiss(doneFn:Function) : void
      {
         if(Boolean(this._tween))
         {
            TweenMax.killTweensOf(this._getTweenTarget());
            this._tween = null;
         }
         JBGUtil.gotoFrameWithFn(this._getBehaviorMC(),"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,doneFn);
      }
      
      protected function _getTweenTarget() : MovieClip
      {
         return this._mc.credits.container.tf;
      }
      
      protected function _getInitialY() : Number
      {
         return this._initialRectangle.y + this._initialRectangle.height - this._getOffset();
      }
      
      protected function _getFullHeight() : Number
      {
         return this._mc.credits.container.tf.tf.textHeight;
      }
      
      protected function _getTop() : Number
      {
         return this._initialRectangle.y;
      }
      
      protected function _runCredits() : void
      {
         if(Boolean(this._tween))
         {
            this._canceler();
            this._canceler = Nullable.NULL_FUNCTION;
            TweenMax.killTweensOf(this._getTweenTarget());
         }
         this._getTweenTarget().y = this._getInitialY();
         this._tween = TweenMax.to(this._getTweenTarget(),Duration.fromSec(this._getFullHeight() / this._getSpeed()).inSec,{
            "y":this._getTop() - this._getFullHeight(),
            "ease":Linear.easeNone
         });
         this._canceler = JBGUtil.eventOnce(this._tween,TweenEvent.COMPLETE,function(evt:TweenEvent):void
         {
            _canceler = Nullable.NULL_FUNCTION;
            _runCredits();
         });
      }
   }
}

