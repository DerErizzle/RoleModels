package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.utils.*;
   
   public class SpinWheelBehavior implements IEntityInteractionBehavior
   {
      private var _delegate:ISpinWheelBehaviorDelegate;
      
      private var _wheelDelegate:IWheelControllerDelegate;
      
      private var _ws:WSClient;
      
      private var _hasSpun:Boolean;
      
      public function SpinWheelBehavior(delegate:ISpinWheelBehaviorDelegate, wheelDelegate:IWheelControllerDelegate)
      {
         super();
         this._delegate = delegate;
         this._wheelDelegate = wheelDelegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._hasSpun = false;
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         var e:PlayerEntities = new PlayerEntities(p);
         if(p == this._delegate.spinWheelSpinner)
         {
            e.withInput("main",new ObjectEntity(this._ws,"spin:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
         }
         return e;
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var power:Number = NaN;
         var type:SpinType = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("power"))
            {
               power = Number(mainInput.getValue().power);
               if(isNaN(power))
               {
                  return null;
               }
               type = GameState.instance.jsonData.getSpinType(this._delegate.spinWheelSpinTypeCategory,power);
               this._hasSpun = true;
               this._delegate.onWheelSpun(Player(p),type);
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
         }
         return null;
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         if(entityKey == "main")
         {
            if(p == this._delegate.spinWheelSpinner)
            {
               return {
                  "kind":"spin",
                  "category":this._wheelDelegate.wheelId,
                  "initialDegrees":this._wheelDelegate.getControllerWheelSpin(),
                  "slices":this._wheelDelegate.getControllerSlices(Player(p)),
                  "responseKey":"spin:" + p.sessionId.val
               };
            }
            return {
               "kind":"waiting",
               "category":"spin",
               "spinner":this._delegate.spinWheelSpinner.sessionId.val
            };
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._hasSpun;
      }
   }
}

