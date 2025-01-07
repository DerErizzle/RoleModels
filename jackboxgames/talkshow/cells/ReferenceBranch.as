package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   
   public class ReferenceBranch extends AbstractBranch
   {
      private var _hitlist:Array;
      
      public function ReferenceBranch(cell:ReferenceCell, branchId:uint, targetId:int, type:uint, hitlist:String = null)
      {
         super(cell,branchId,targetId,type);
         if(hitlist != null)
         {
            this._hitlist = [hitlist];
         }
      }
      
      public function get hitlist() : Array
      {
         return this._hitlist;
      }
      
      override public function evaluate(x:*) : Boolean
      {
         var exp:String = null;
         if(_type == Constants.BR_NOMATCH)
         {
            return true;
         }
         if(_type == Constants.BR_CODE)
         {
            try
            {
               return _cell.flowchart.evalBranch(_cell.id,_branchId,x);
            }
            catch(error:Error)
            {
               Logger.warning("Error evaluating reference branch: " + this + " error=" + error,"Code");
               return false;
            }
         }
         else
         {
            if(_type == Constants.BR_LIST)
            {
               if(this._hitlist == null)
               {
                  return false;
               }
               for each(exp in this._hitlist)
               {
                  if(exp == x)
                  {
                     return true;
                  }
                  if((exp === "true" || exp === true) && (x === "true" || x === true))
                  {
                     return true;
                  }
                  if((exp === "false" || exp === false) && (x === "false" || x === false))
                  {
                     return true;
                  }
                  if((x == null || x == undefined) && (exp === "false" || exp === "null" || exp === "undefined"))
                  {
                     return true;
                  }
               }
               return false;
            }
            return false;
         }
      }
   }
}

