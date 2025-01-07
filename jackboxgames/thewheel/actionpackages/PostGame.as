package jackboxgames.thewheel.actionpackages
{
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.postgame.*;
   
   public class PostGame extends JBGActionPackage
   {
      private var _loopingMcs:Array;
      
      public function PostGame(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return "thewheel_postgame.swf";
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
         GameState.instance.screenOrganizer.addChild(_mc,1);
         addDelegate(new TheWheelPostGame(_mc,GameState.instance));
         this._loopingMcs = [_mc.clouds,_mc.bg.rays];
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         resetDelegates();
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Loop");
         ref.end();
      }
      
      public function handleActionSendArtifact(ref:IActionRef, params:Object) : void
      {
         GameState.instance.sendGameArtifacts(function(result:Boolean):void
         {
            ref.end();
         });
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         ref.end();
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.model.JBGGameState;
import jackboxgames.widgets.postgame.PostGame;
import jackboxgames.widgets.postgame.PostGameCredits;
import jackboxgames.widgets.postgame.audio.AudioEventPostGameAudioHandler;
import jackboxgames.widgets.postgame.audio.IPostGameAudioHandler;

class TheWheelPostGame extends jackboxgames.widgets.postgame.PostGame
{
   public function TheWheelPostGame(mc:MovieClip, gs:JBGGameState)
   {
      super(mc,gs);
   }
   
   override protected function _createAudioHandler() : IPostGameAudioHandler
   {
      return new AudioEventPostGameAudioHandler();
   }
   
   override protected function _createCredits() : PostGameCredits
   {
      return new TheWheelCredits(_mc,_gs);
   }
}

import flash.display.MovieClip;
import jackboxgames.model.JBGGameState;
import jackboxgames.thewheel.GameState;
import jackboxgames.thewheel.Player;
import jackboxgames.thewheel.utils.TheWheelTextUtil;
import jackboxgames.utils.ArrayUtil;
import jackboxgames.utils.LocalizationUtil;
import jackboxgames.widgets.postgame.PostGameCredits;

class TheWheelCredits extends PostGameCredits
{
   public function TheWheelCredits(mc:MovieClip, gs:JBGGameState)
   {
      super(mc,gs);
   }
   
   override protected function _getPreCreditsString() : String
   {
      var pre:String = null;
      pre = "";
      pre += "<font " + (Boolean(_getStyle()) ? "face=\'" + _getStyle() + "\'" : "") + " color=\'#fdb138\'>" + LocalizationUtil.getPrintfText("CREDITS_WINNER") + "</font>";
      pre += "\n";
      pre += GameState.instance.winner.name.val + "\n";
      pre += "\n\n";
      pre += "<font color=\'#fdb138\'>" + LocalizationUtil.getPrintfText("CREDITS_UNANSWERED_HEADER") + "</font>\n";
      GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(GameState.instance.winner)).forEach(function(p:Player, ... args):void
      {
         pre += TheWheelTextUtil.formattedPlayerName(p) + "\n";
         pre += p.question + "\n\n";
      });
      pre += "\n\n\n";
      return pre;
   }
}

import jackboxgames.widgets.postgame.PostGame;
import jackboxgames.widgets.postgame.PostGameCredits;

