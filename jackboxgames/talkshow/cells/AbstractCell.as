package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class AbstractCell implements ICell
   {
      protected var _id:uint;
      
      protected var _target:String;
      
      protected var _f:IFlowchart;
      
      protected var _loadStatus:int;
      
      protected var _type:String;
      
      public function AbstractCell(f:IFlowchart, id:uint, target:String, type:String)
      {
         super();
         this._f = f;
         this._id = id;
         this._type = type;
         this._loadStatus = LoadStatus.STATUS_LOADED;
         if(target.length > 0)
         {
            this._target = target;
         }
      }
      
      public function toString() : String
      {
         return "[Cell id=" + this._id + " fid=" + this._f.id + "]";
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get target() : String
      {
         return this._target;
      }
      
      public function get flowchart() : IFlowchart
      {
         return this._f;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function start() : void
      {
         Logger.info("Start Cell: " + this,"Cell");
         PlaybackEngine.getInstance().dispatchEvent(new CellEvent(CellEvent.CELL_STARTED,this));
      }
      
      public function load(data:ILoadData = null) : void
      {
      }
      
      public function isLoaded() : Boolean
      {
         return true;
      }
      
      public function get loadStatus() : int
      {
         return LoadStatus.STATUS_LOADED;
      }
   }
}

