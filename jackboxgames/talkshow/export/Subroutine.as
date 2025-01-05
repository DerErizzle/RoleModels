package jackboxgames.talkshow.export
{
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.ISubroutine;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.talkshow.utils.ExportDictionary;
   
   internal class Subroutine extends Flowchart implements ISubroutine
   {
      
      private static const DELIMITER_PARAMS:String = "^";
       
      
      protected var _firstCellId:uint;
      
      protected var _params:Array;
      
      public function Subroutine(exp:Export, id:uint, cfg:ConfigInfo, name:String, pid:int)
      {
         super(exp,id,cfg,name,pid);
         this._params = new Array();
      }
      
      override public function toString() : String
      {
         return "[Subroutine id=" + _id + " name=" + _name + "]";
      }
      
      override protected function parseAdditionalData(data:Object, dict:ExportDictionary) : void
      {
         var p:String = null;
         this._firstCellId = data.c;
         var paramList:Array = data.params.split(DELIMITER_PARAMS);
         for each(p in paramList)
         {
            this._params.push(dict.lookup(int(p)));
         }
      }
      
      public function getSubroutineParams() : Array
      {
         return this._params;
      }
      
      public function get firstCell() : ICell
      {
         return getCellByID(this._firstCellId);
      }
      
      public function setLocalVariableObject(obj:Object) : void
      {
         if(_code != null)
         {
            _code.setL(obj);
         }
      }
   }
}
