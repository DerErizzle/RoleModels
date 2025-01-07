package jackboxgames.thewheel.utils
{
   import jackboxgames.utils.*;
   
   public class FrameStateMachine
   {
      private var _nodes:Object;
      
      private var _resetNodeId:String;
      
      private var _currentStateId:String;
      
      public function FrameStateMachine()
      {
         super();
         this._nodes = {};
      }
      
      public function reset() : void
      {
         this._currentStateId = this._resetNodeId;
      }
      
      private function _getNode(id:String) : FrameStateMachineNode
      {
         return this._nodes[id];
      }
      
      public function withNode(id:String) : FrameStateMachine
      {
         Assert.assert(this._getNode(id) == null);
         if(!this._resetNodeId)
         {
            this._currentStateId = this._resetNodeId = id;
         }
         this._nodes[id] = new FrameStateMachineNode(id);
         return this;
      }
      
      public function withTransition(from:String, to:String, frame:String) : FrameStateMachine
      {
         this._getNode(from).addransition(to,frame);
         return this;
      }
      
      public function transition(to:String) : String
      {
         if(this._currentStateId == to)
         {
            return null;
         }
         var node:FrameStateMachineNode = this._getNode(this._currentStateId);
         Assert.assert(node != null,"Tried to transition to non existant state");
         Assert.assert(node.canTransitionTo(to),"Cannot transition from " + this._currentStateId + " to " + to);
         this._currentStateId = to;
         return node.getFrameToTransitionTo(to);
      }
   }
}

class FrameStateMachineNode
{
   private var _id:String;
   
   private var _transitions:Object;
   
   public function FrameStateMachineNode(id:String)
   {
      super();
      this._id = id;
      this._transitions = {};
   }
   
   public function get id() : String
   {
      return this._id;
   }
   
   public function addransition(otherId:String, byFrame:String) : void
   {
      this._transitions[otherId] = byFrame;
   }
   
   public function canTransitionTo(otherId:String) : Boolean
   {
      return otherId in this._transitions;
   }
   
   public function getFrameToTransitionTo(otherId:String) : String
   {
      return this._transitions[otherId];
   }
}

