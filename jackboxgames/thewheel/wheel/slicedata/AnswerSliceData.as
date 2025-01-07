package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.ISliceData;
   
   public class AnswerSliceData implements ISliceData
   {
      private var _index:int;
      
      private var _answer:String;
      
      public function AnswerSliceData()
      {
         super();
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(val:int) : void
      {
         this._index = val;
      }
      
      public function get answer() : String
      {
         return this._answer;
      }
      
      public function set answer(val:String) : void
      {
         this._answer = val;
      }
      
      public function setup(owner:Player) : void
      {
      }
      
      public function get name() : String
      {
         return "";
      }
      
      public function get description() : String
      {
         return "";
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         return true;
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         return undefined;
      }
      
      public function clone() : *
      {
         var newData:AnswerSliceData = new AnswerSliceData();
         newData._index = this._index;
         newData._answer = this._answer;
         return newData;
      }
   }
}

