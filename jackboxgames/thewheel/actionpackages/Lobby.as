package jackboxgames.thewheel.actionpackages
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   import jackboxgames.widgets.lobby.*;
   
   public class Lobby extends JBGActionPackage
   {
      private var _connecting:Connecting;
      
      private var _lobby:TheWheelLobby;
      
      private var _loopingMcs:Array;
      
      public function Lobby(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return "thewheel_lobby.swf";
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
         this._connecting = new Connecting(_mc,GameState.instance.goBackToMenu);
         addDelegate(this._connecting);
         this._lobby = new TheWheelLobby(_mc,GameState.instance);
         addDelegate(this._lobby);
         this._loopingMcs = [_mc.cloud0,_mc.rays];
      }
      
      private function _resetLoopingMcs() : void
      {
         this._loopingMcs.forEach(function(loopingMc:MovieClip, ... args):void
         {
            if(MovieClipUtil.frameExists(loopingMc,"Default"))
            {
               JBGUtil.gotoFrame(loopingMc,"Default");
            }
            else if(MovieClipUtil.frameExists(loopingMc,"Park"))
            {
               JBGUtil.gotoFrame(loopingMc,"Park");
            }
            else
            {
               Assert.assert(false,"The looping MCs in the lobby need either a Default or a Park!");
            }
         });
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         resetDelegates();
         this._resetLoopingMcs();
         JBGUtil.gotoFrame(_mc.fade,"Park");
         ref.end();
      }
      
      public function handleActionFadeFromWhite(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.fade,"FadeFromWhite",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         this._lobby.start();
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Loop");
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         this._resetLoopingMcs();
         ref.end();
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.model.JBGGameState;
import jackboxgames.widgets.lobby.Lobby;
import jackboxgames.widgets.lobby.LobbyPlayers;
import jackboxgames.widgets.lobby.audio.ILobbyAudioHandler;

class TheWheelLobby extends jackboxgames.widgets.lobby.Lobby
{
   public function TheWheelLobby(mc:MovieClip, gs:JBGGameState)
   {
      super(mc,gs);
   }
   
   override protected function _createPlayers() : LobbyPlayers
   {
      return new TheWheelLobbyPlayers(_mc,_gs);
   }
   
   override protected function _createAudioHandler() : ILobbyAudioHandler
   {
      return new TheWheelLobbyAudioHandler();
   }
}

import flash.display.MovieClip;
import jackboxgames.model.JBGGameState;
import jackboxgames.widgets.lobby.LobbyPlayers;

class TheWheelLobbyPlayers extends LobbyPlayers
{
   public function TheWheelLobbyPlayers(mc:MovieClip, gs:JBGGameState)
   {
      super(mc,gs);
   }
   
   override protected function _getPlayerClass() : Class
   {
      return TheWheelLobbyPlayer;
   }
}

import flash.display.MovieClip;
import jackboxgames.model.JBGPlayer;
import jackboxgames.thewheel.Player;
import jackboxgames.widgets.lobby.LobbyPlayer;

class TheWheelLobbyPlayer extends LobbyPlayer
{
   public function TheWheelLobbyPlayer(mc:MovieClip)
   {
      super(mc);
   }
   
   override protected function _getAvatarFrameForPlayer(slotIndex:int, p:JBGPlayer) : String
   {
      var wheelPlayer:Player = Player(p);
      return "Avatar" + wheelPlayer.avatar.index;
   }
}

import jackboxgames.model.JBGPlayer;
import jackboxgames.thewheel.Player;
import jackboxgames.widgets.lobby.audio.AudioEventLobbyAudioHandler;

class TheWheelLobbyAudioHandler extends AudioEventLobbyAudioHandler
{
   public function TheWheelLobbyAudioHandler()
   {
      super(false);
   }
   
   override public function playPlayerJoinedAudio(p:JBGPlayer, doneFn:Function) : void
   {
      _events.play("playerJoined" + Player(p).avatar.index);
      doneFn();
   }
}

import jackboxgames.widgets.lobby.Lobby;
import jackboxgames.widgets.lobby.LobbyPlayer;
import jackboxgames.widgets.lobby.LobbyPlayers;
import jackboxgames.widgets.lobby.audio.AudioEventLobbyAudioHandler;

