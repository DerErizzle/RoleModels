package jackboxgames.talkshow.export
{
   internal class CellFactory
   {
      private static const DELIMITER_CELLS:String = "^";
      
      private static const DELIMITER_CELL_DATA:String = "|";
      
      private static const DELIMITER_ACTION_DATA:String = "!";
      
      private static const DELIMITER_SECONDARY_DATA:String = ",";
      
      private static const DELIMITER_ACTIONREFS_DATA:String = "~";
      
      private static const DELIMITER_PARAMS:String = "#";
      
      private static const DELIMITER_PARAM_DATA:String = "*";
      
      private static const DELIMITER_BRANCHES:String = "~";
      
      private static const DELIMITER_BRANCH_DATA:String = "!";
      
      private static const DELIMITER_SUBROUTINE_VALUES:String = "!";
      
      private static const DELIMITER_TEMPLATE_VALUES:String = "!";
      
      private static const AT_START_NEXT:String = "N";
      
      public function CellFactory()
      {
         super();
      }
      
      public static function buildCells(flowchart:Flowchart, cellData:String, dict:ExportDictionary) : void
      {
         var cellString:String = null;
         var data:Array = null;
         var id:uint = 0;
         var target:String = null;
         var type:String = null;
         var cell:AbstractCell = null;
         var tFC:uint = 0;
         var cells:Array = cellData.split(DELIMITER_CELLS);
         for each(cellString in cells)
         {
            data = cellString.split(DELIMITER_CELL_DATA);
            id = uint(data.shift());
            target = dict.lookup(data.shift());
            type = data.shift();
            switch(type)
            {
               case Constants.CELL_ACTION:
                  cell = buildActionCell(flowchart,id,target,data,dict);
                  break;
               case Constants.CELL_CALL:
                  cell = buildCallCell(flowchart,id,target,data,dict);
                  break;
               case Constants.CELL_CODE:
                  cell = new CodeCell(flowchart,id,target,data[0]);
                  break;
               case Constants.CELL_GOTO:
                  tFC = flowchart.id;
                  if((data[0] as String).length > 0)
                  {
                     tFC = uint(data[0]);
                  }
                  cell = new GotoCell(flowchart,id,target,data[1],tFC);
                  break;
               case Constants.CELL_INPUT:
                  cell = buildInputCell(flowchart,id,target,data,dict);
                  break;
               case Constants.CELL_LABEL:
                  cell = new LabelCell(flowchart,id,target,data[0]);
                  break;
               case Constants.CELL_REFERENCE:
                  cell = buildReferenceCell(flowchart,id,target,data,dict);
                  break;
               case Constants.CELL_RETURN:
                  cell = new ReturnCell(flowchart,id,target,dict.lookup(data[0]));
                  break;
               case Constants.CELL_TEMPLATE:
                  cell = buildTemplateCell(flowchart,id,target,data,dict);
                  break;
               case Constants.CELL_STOP_LISTENING:
                  cell = new StopListeningCell(flowchart,id,target,data[0]);
                  break;
               default:
                  cell = null;
            }
            if(cell != null)
            {
               flowchart.addCell(cell);
            }
         }
      }
      
      private static function buildActionCell(f:Flowchart, id:uint, target:String, data:Array, dict:ExportDictionary) : ActionCell
      {
         var mode:uint = 0;
         var actions:Array = null;
         var actionString:String = null;
         var actionSets:Array = null;
         var i:uint = 0;
         var ver:uint = 0;
         var export:IExport = f.getParentExport();
         var primary:ActionRef = buildActionReference(export,f,data[1],dict);
         if(data[2] == "L")
         {
            mode = ActionCell.MODE_LOCKED;
         }
         else if(data[2] == "T")
         {
            mode = ActionCell.MODE_TIMING;
         }
         else
         {
            mode = ActionCell.MODE_ACTION;
         }
         var cell:ActionCell = new ActionCell(f,id,target,data[0],mode,primary);
         if((data[3] as String).length > 0)
         {
            if(mode == ActionCell.MODE_LOCKED)
            {
               actions = data[3].split(DELIMITER_ACTIONREFS_DATA);
               for each(actionString in actions)
               {
                  cell.addSecondaryAction(buildActionReference(export,f,actionString,dict));
               }
            }
            else if(mode == ActionCell.MODE_ACTION || mode == ActionCell.MODE_TIMING)
            {
               actionSets = data[3].split(DELIMITER_SECONDARY_DATA);
               for(i = 0; i < actionSets.length; i++)
               {
                  ver = uint(actionSets[i++]);
                  actions = actionSets[i].split(DELIMITER_ACTIONREFS_DATA);
                  for each(actionString in actions)
                  {
                     cell.addSecondaryAction(buildActionReference(export,f,actionString,dict),ver);
                  }
               }
            }
         }
         return cell;
      }
      
      private static function buildActionReference(export:IExport, flow:Flowchart, data:String, dict:ExportDictionary) : ActionRef
      {
         var ref:ActionRef = null;
         var timing:Timing = null;
         var actionData:Array = data.split(DELIMITER_ACTION_DATA);
         if(actionData[0] as String == AT_START_NEXT)
         {
            timing = new Timing(actionData[3] == "S",actionData[4]);
            ref = new StartNextActionRef(actionData[1].length == 0 ? flow.id : uint(actionData[1]),actionData[2],timing);
         }
         else
         {
            if(actionData[2] == "C")
            {
               timing = new CueTiming(dict.lookup(uint(actionData[3])));
            }
            else
            {
               timing = new Timing(actionData[2] == null ? true : actionData[2] as String == "S",actionData[3] == null ? 0 : Number(actionData[3]));
            }
            ref = new ActionRef(export.getAction(actionData[0]),timing);
            if(actionData[1] != null && (actionData[1] as String).length > 0)
            {
               setActionProperties(ref,actionData[1],dict);
            }
            if(actionData[2] == "C")
            {
               (timing as CueTiming).setRef(ref);
            }
         }
         return ref;
      }
      
      private static function setActionProperties(a:ActionRef, paramData:String, dict:ExportDictionary) : void
      {
         var params:Array = null;
         var i:uint = 0;
         var tData:Array = null;
         var p:IParameter = null;
         var value:* = undefined;
         var mediaData:Array = null;
         params = paramData.split(DELIMITER_PARAMS);
         for(i = 0; i < params.length; i++)
         {
            if(params[i].indexOf("T") === 0)
            {
               tData = params[i].split(DELIMITER_PARAM_DATA);
               a.setValue(i,new TemplateParamValue(int(tData[1]),int(tData[2])));
            }
            else
            {
               p = a.action.getParameter(i);
               switch(p.type)
               {
                  case Parameter.TYPE_AUDIO:
                  case Parameter.TYPE_GRAPHIC:
                  case Parameter.TYPE_TEXT:
                     mediaData = params[i].split(DELIMITER_PARAM_DATA);
                     value = new MediaParamValue(a,mediaData[0],mediaData[1],dict.lookup(mediaData[2]));
                     break;
                  case Parameter.TYPE_BOOLEAN:
                     value = params[i] == 1;
                     break;
                  case Parameter.TYPE_LIST:
                  case Parameter.TYPE_STRING:
                     value = dict.lookup(params[i]);
                     break;
                  default:
                     value = params[i];
               }
               a.setValue(i,value);
            }
         }
      }
      
      private static function buildReferenceCell(f:Flowchart, id:uint, target:String, data:Array, dict:ExportDictionary) : ReferenceCell
      {
         var branchString:String = null;
         var b:Array = null;
         var type:uint = 0;
         var hitlist:String = null;
         var branch:IBranch = null;
         var cell:ReferenceCell = new ReferenceCell(f,id,target,dict.lookup(data[0]));
         var branches:Array = data[1].split(DELIMITER_BRANCHES);
         for each(branchString in branches)
         {
            b = branchString.split(DELIMITER_BRANCH_DATA);
            if(b[2] == "N")
            {
               type = Constants.BR_NOMATCH;
            }
            else if(b[2] == "C")
            {
               type = Constants.BR_CODE;
            }
            else
            {
               type = Constants.BR_LIST;
            }
            hitlist = type == Constants.BR_LIST ? dict.lookup(b[3]) : null;
            branch = new ReferenceBranch(cell,b[0],b[1],type,hitlist);
         }
         return cell;
      }
      
      private static function buildInputCell(f:Flowchart, id:uint, target:String, data:Array, dict:ExportDictionary) : InputCell
      {
         var branchString:String = null;
         var b:Array = null;
         var type:uint = 0;
         var branch:IBranch = null;
         var cell:InputCell = new InputCell(f,id,target,dict.lookup(data[0]),dict.lookup(data[1]));
         var branches:Array = data[2].split(DELIMITER_BRANCHES);
         for each(branchString in branches)
         {
            b = branchString.split(DELIMITER_BRANCH_DATA);
            if(b[2] == "M")
            {
               type = Constants.BR_MC;
            }
            else if(b[2] == "F")
            {
               type = Constants.BR_FIB;
            }
            else if(b[2] == "T")
            {
               type = Constants.BR_TIMEOUT;
            }
            else
            {
               type = Constants.BR_NOMATCH;
            }
            branch = new InputBranch(cell,b[0],b[1],type,b[3] == null ? null : dict.lookup(b[3]),b[4] == null ? -1 : int(b[4]));
         }
         return cell;
      }
      
      private static function buildCallCell(f:Flowchart, id:uint, target:String, data:Array, dict:ExportDictionary) : CallCell
      {
         var parameterValues:Array = null;
         var value:String = null;
         var cell:CallCell = new CallCell(f,id,target,data[0],data[1],dict.lookup(data[2]));
         if(data[3] != null)
         {
            parameterValues = data[3].split(DELIMITER_SUBROUTINE_VALUES);
            for each(value in parameterValues)
            {
               cell.addParameterValue(dict.lookup(uint(value)));
            }
         }
         return cell;
      }
      
      private static function buildTemplateCell(f:Flowchart, id:uint, target:String, data:Array, dict:ExportDictionary) : TemplateCell
      {
         var parameterValues:Array = null;
         var value:String = null;
         var cell:TemplateCell = new TemplateCell(f,id,target,data[0],data[1]);
         if(data[2] != null)
         {
            parameterValues = data[2] == null || data[2].length == 0 ? [] : data[2].split(DELIMITER_TEMPLATE_VALUES);
            for each(value in parameterValues)
            {
               cell.addParameterValue(dict.lookup(uint(value)));
            }
         }
         return cell;
      }
   }
}

