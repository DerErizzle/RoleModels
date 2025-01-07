package jackboxgames.talkshow.timing
{
   import jackboxgames.talkshow.actions.ActionRef;
   import jackboxgames.talkshow.actions.TemplateParamValue;
   
   public class CueTiming extends Timing
   {
      private var _cueName:String;
      
      private var _ref:ActionRef;
      
      private var _timing:Timing;
      
      private var _never:Boolean;
      
      public function CueTiming(cueName:String)
      {
         super(true,0);
         this._cueName = cueName;
         this._never = false;
      }
      
      override public function toString() : String
      {
         return "[CueTiming name=" + this._cueName + ": " + (this.getTiming().fromStart ? "S" : "E") + (this.getTiming().seconds >= 0 ? "+" : "") + this.getTiming().seconds + "]";
      }
      
      public function setRef(ref:ActionRef) : void
      {
         this._ref = ref;
      }
      
      public function reset() : void
      {
         this._timing = null;
      }
      
      private function getTiming() : Timing
      {
         var primary:ActionRef = null;
         var idx:int = 0;
         var value:* = undefined;
         var tplValue:TemplateParamValue = null;
         var timingText:String = null;
         var splits:Array = null;
         if(this._timing == null)
         {
            primary = this._ref.parent.primaryAction as ActionRef;
            idx = int(primary.action.getPrimaryMediaParameterIdx());
            value = primary.getValueByIndex(idx);
            if(value is TemplateParamValue)
            {
               tplValue = value as TemplateParamValue;
               timingText = tplValue.getCueTiming(this._cueName);
               if(timingText == null)
               {
                  splits = ["N"];
               }
               else
               {
                  splits = timingText.split("+");
               }
               if(splits[0] == "N")
               {
                  this._never = true;
                  this._timing = new Timing(true,0);
               }
               else
               {
                  this._never = false;
                  this._timing = new Timing(String(splits[0]) == "S",Number(splits[1]));
               }
            }
         }
         return this._timing;
      }
      
      override public function get fromStart() : Boolean
      {
         return this.getTiming().fromStart;
      }
      
      override public function get seconds() : Number
      {
         return this.getTiming().seconds;
      }
      
      override public function get never() : Boolean
      {
         this.getTiming();
         return this._never;
      }
   }
}

