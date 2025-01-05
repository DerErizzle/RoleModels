package jackboxgames.rolemodels.actionpackages.delegates
{
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.model.*;
   import jackboxgames.rolemodels.utils.drawing.*;
   import jackboxgames.rolemodels.widgets.lobby.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class RoleModelsLobby extends Lobby
   {
       
      
      private var _playerWidgets:Array;
      
      private var _playerControllerStates:PerPlayerContainer;
      
      private const _drawingBlob:Object = {
         "state":"Draw",
         "prompt":{"html":"Draw a self portrait!"},
         "thicknesses":[10],
         "colors":["#000000"],
         "size":{
            "width":GameConstants.AVATAR_DRAWING_SIZE_X,
            "height":GameConstants.AVATAR_DRAWING_SIZE_Y
         },
         "viewport":{
            "width":GameConstants.AVATAR_DRAWING_SIZE_X,
            "height":GameConstants.AVATAR_DRAWING_SIZE_Y
         },
         "submitAsBitmap":false,
         "sketchOptions":{
            "minThickness":0.3,
            "thicknessFactor":0,
            "smoothingFactor":0.55,
            "thicknessSmoothingFactor":0.6,
            "dotMultiplier":2,
            "tipTaperFactor":0.7
         }
      };
      
      private const _cameraBlob:Object = {"state":"Camera"};
      
      public function RoleModelsLobby(mc:MovieClip, gameState:GameState, minPlayers:int)
      {
         super(mc,gameState,minPlayers);
         setAudioHandler(new AudioEventLobbyAudioHandler(true));
         this._playerControllerStates = new PerPlayerContainer();
         this._playerWidgets = _playerMCs.map(function(element:MovieClip, index:int, array:Array):LobbyPlayer
         {
            return new LobbyPlayer(element);
         });
         _lobbyAudience.showCountWithAudience = true;
         this.updateCustomerBlob = function(p:Player, lobbyState:String = null):void
         {
            handleUpdateCustomerBlob(p,lobbyState);
         };
         this.updateRoomBlob = function(lobbyState:String = null):void
         {
            handleUpdateRoomBlob(lobbyState,{});
         };
         this.onPlayerJoinedFn = function(p:Player):void
         {
            _playerWidgets[p.index.val].setup(p);
            JBGUtil.gotoFrameWithFn(_playerMCs[p.index.val],"AppearPlayer",MovieClipEvent.EVENT_APPEAR_DONE,function():void
            {
               JBGUtil.gotoFrame(_playerMCs[p.index.val],"BlobLoop");
            });
         };
         this.onMessageReceivedFn = function(evt:EventWithData):void
         {
            var p:Player = null;
            var callback:Function = null;
            p = evt.data.player;
            if(p.isCensored.val)
            {
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               updateCustomerBlob(p);
               return;
            }
            if(evt.data.message.action == "cancel")
            {
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               updateCustomerBlob(p);
            }
            else if(evt.data.message.action == "censor")
            {
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               _handleCensor(p,Player(GameState.instance.getPlayerByUserId(evt.data.message.id)));
            }
            else if(evt.data.message.action == "toDraw")
            {
               _playerControllerStates.setDataForPlayer(p,"Draw");
               _gameState.setCustomerBlobWithMetadata(p,_drawingBlob);
            }
            else if(evt.data.message.action == "toCamera")
            {
               if(!_picturesAreAllowed)
               {
                  return;
               }
               _playerControllerStates.setDataForPlayer(p,"Camera");
               _gameState.setCustomerBlobWithMetadata(p,_cameraBlob);
            }
            else if(Boolean(evt.data.message.name))
            {
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               _handleNameChange(p,evt.data.message.name.toUpperCase());
            }
            else if(Boolean(evt.data.message.lines))
            {
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               _handleDrawing(p,evt.data.message.lines);
            }
            else if(Boolean(evt.data.message.picture))
            {
               if(!_picturesAreAllowed)
               {
                  return;
               }
               _playerControllerStates.setDataForPlayer(p,"Lobby");
               callback = function(bd:BitmapData):void
               {
                  _handleSelfie(p,bd);
               };
               if(evt.data.message.picture is String)
               {
                  JBGUtil.loadBitmapDataFromBase64("PLAYER_" + p.index.val,evt.data.message.picture,callback);
               }
               else if(evt.data.message.picture is ByteArray)
               {
                  JBGUtil.loadBitmapDataFromByteArray("PLAYER_" + p.index.val,evt.data.message.picture,callback);
               }
            }
         };
      }
      
      private function get _picturesAreAllowed() : Boolean
      {
         return !SettingsManager.instance.getValue(GameConstants.SETTING_PREVENT_PICTURES).val && !BuildConfig.instance.configVal("preventPictures");
      }
      
      private function _handleNameChange(p:Player, newName:String) : void
      {
         p.name.val = newName;
         playerNameTfs[p.index.val].text = p.name.val;
         updateCustomerBlob(p);
         updateCustomerBlob(_gameState.players[0]);
      }
      
      private function _handleCensor(vip:Player, p:Player) : void
      {
         p.isCensored.val = true;
         GameState.instance.audioRegistrationStack.play("AppearDrawing",Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrameWithFn(_playerMCs[p.index.val],"AppearSelfie",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            JBGUtil.gotoFrame(_playerMCs[p.index.val],"SelfieLoop");
         });
         updateCustomerBlob(p);
         updateCustomerBlob(vip);
      }
      
      private function _handleSelfie(p:Player, bd:BitmapData) : void
      {
         p.avatarSource = Player.AVATAR_SOURCE.PICTURE;
         p.picture = bd;
         GameState.instance.audioRegistrationStack.play("AppearSelfie",Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrameWithFn(_playerMCs[p.index.val],"AppearSelfie",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            JBGUtil.gotoFrame(_playerMCs[p.index.val],"SelfieLoop");
         });
         updateCustomerBlob(p);
      }
      
      private function _handleDrawing(p:Player, lines:Array) : void
      {
         var _bounds:Ellipse;
         var _maxPoints:int;
         var canvas:SmoothDrawingCanvas;
         var drawingDisplayObject:DisplayObject;
         var bmd:BitmapData;
         lines = DrawingUtils.UNCOMPRESS_LINES(lines);
         if(!DrawingUtils.LINES_ARE_VALID(lines))
         {
            updateCustomerBlob(p);
            return;
         }
         _bounds = new Ellipse(GameConstants.AVATAR_DRAWING_SIZE_X / 2,GameConstants.AVATAR_DRAWING_SIZE_Y / 2,GameConstants.AVATAR_DRAWING_SIZE_X / 2,GameConstants.AVATAR_DRAWING_SIZE_Y / 2);
         _maxPoints = 25000;
         lines = DrawingUtils.PREPARE_LINES_USING_ELLIPSE(lines,_maxPoints,_bounds);
         canvas = new SmoothDrawingCanvas(new Rectangle(0,0,GameConstants.AVATAR_DRAWING_SIZE_X,GameConstants.AVATAR_DRAWING_SIZE_Y));
         canvas.drawStartingLines(lines,0);
         drawingDisplayObject = canvas;
         bmd = new BitmapData(GameConstants.AVATAR_DRAWING_SIZE_X,GameConstants.AVATAR_DRAWING_SIZE_Y,true,0);
         bmd.draw(drawingDisplayObject);
         canvas.reset();
         p.avatarSource = Player.AVATAR_SOURCE.DRAWING;
         p.picture = bmd;
         GameState.instance.audioRegistrationStack.play("AppearDrawing",Nullable.NULL_FUNCTION);
         JBGUtil.gotoFrameWithFn(_playerMCs[p.index.val],"AppearSelfie",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            JBGUtil.gotoFrame(_playerMCs[p.index.val],"SelfieLoop");
         });
         updateCustomerBlob(p);
      }
      
      override public function reset() : void
      {
         super.reset();
         JBGUtil.reset(this._playerWidgets);
         this._playerControllerStates.reset();
      }
      
      override public function handleUpdateCustomerBlob(p:BlobCastPlayer, lobbyState:String = null) : void
      {
         var blob:Object;
         if(lobbyState == null)
         {
            lobbyState = _lastLobbyState;
         }
         blob = {
            "state":"Lobby",
            "allowDrawingsIfCameraDisabled":true,
            "playerIsVIP":p.isVIP,
            "playerCanStartGame":p.isVIP && !SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val,
            "playerCanCensor":SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val && p.isVIP,
            "playerCanReport":p.isVIP,
            "canChangeName":!p.isCensored.val,
            "choices":[]
         };
         if(this._picturesAreAllowed && !p.isCensored.val)
         {
            blob.choices.push({
               "action":"toCamera",
               "html":"<div class=\'pictureImage\'></div><div>Take a Picture</div>",
               "className":"pictureButton"
            });
         }
         if(!p.isCensored.val)
         {
            blob.choices.push({
               "action":"toDraw",
               "html":"<div class=\'drawImage\'></div><div>Draw Yourself</div>",
               "className":"drawButton"
            });
         }
         if(p.isVIP)
         {
            if(SettingsManager.instance.getValue(SettingsConstants.SETTING_CENSORABLE).val)
            {
               blob.censorablePlayers = _gameState.players.filter(function(p:BlobCastPlayer, i:int, a:Array):Boolean
               {
                  return !p.isVIP && !p.isCensored.val;
               }).map(function(p:BlobCastPlayer, i:int, a:Array):Object
               {
                  return {
                     "id":p.userId.val,
                     "name":p.name.val
                  };
               });
            }
         }
         if(this._playerControllerStates.hasDataForPlayer(p))
         {
            if(this._playerControllerStates.getDataForPlayer(p) == "Draw")
            {
               _gameState.setCustomerBlobWithMetadata(p,this._drawingBlob);
            }
            else if(this._playerControllerStates.getDataForPlayer(p) == "Camera")
            {
               _gameState.setCustomerBlobWithMetadata(p,this._cameraBlob);
            }
            else
            {
               _gameState.setCustomerBlobWithMetadata(p,blob);
            }
         }
         else
         {
            this._playerControllerStates.setDataForPlayer(p,"Lobby");
            _gameState.setCustomerBlobWithMetadata(p,blob);
         }
         _lastLobbyState = lobbyState;
      }
      
      override public function handleUpdateRoomBlob(lobbyState:String = null, options:Object = null) : void
      {
         if(!lobbyState)
         {
            lobbyState = _lastLobbyState;
         }
         if(!options)
         {
            options = {};
         }
         var activeContentId:String = null;
         var isLocal:Boolean = true;
         options.state = "Lobby";
         options.lobbyState = lobbyState;
         options.activeContentId = activeContentId;
         options.isLocal = isLocal;
         options.gameCanStart = false;
         options.gameIsStarting = false;
         options.gameFinished = false;
         if(lobbyState == "CanStart")
         {
            options.gameCanStart = true;
            options.gameIsStarting = false;
         }
         else if(lobbyState == "Countdown")
         {
            options.gameCanStart = true;
            options.gameIsStarting = true;
         }
         _gameState.setRoomBlob(options);
         _lastLobbyState = lobbyState;
      }
   }
}
