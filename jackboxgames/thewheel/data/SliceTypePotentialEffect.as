package jackboxgames.thewheel.data
{
   import jackboxgames.expressionparser.*;
   import jackboxgames.localizy.*;
   import jackboxgames.utils.*;
   
   public class SliceTypePotentialEffect
   {
      private var _data:Object;
      
      private var _isValid:IExpression;
      
      public function SliceTypePotentialEffect(data:Object)
      {
         var parser:ExpressionParser = null;
         var res:Result = null;
         super();
         this._data = data;
         if(this._data.hasOwnProperty("isValid"))
         {
            parser = new ExpressionParser();
            res = parser.parse(this._data.isValid);
            if(res.succeeded)
            {
               this._isValid = res.payload;
            }
            else
            {
               Assert.assert(false,res.payload);
            }
         }
      }
      
      public function get isValid() : IExpression
      {
         return this._isValid;
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get name() : String
      {
         return LocalizationManager.instance.getText("SLICE_EFFECT_" + this.id.toUpperCase() + "_NAME");
      }
      
      public function get description() : String
      {
         return LocalizationManager.instance.getText("SLICE_EFFECT_" + this.id.toUpperCase() + "_DESCRIPTION");
      }
      
      public function get prompt() : String
      {
         return LocalizationManager.instance.getText("SLICE_EFFECT_" + this.id.toUpperCase() + "_PROMPT");
      }
      
      public function get effectClass() : Class
      {
         return this._data.effectClass;
      }
      
      public function get actionPackageName() : String
      {
         return TextUtils.capitalizeFirstCharacter(this.id);
      }
      
      public function get actionPackageClass() : Class
      {
         return this._data.actionPackageClass;
      }
      
      public function getIsValid(delegate:IExpressionDataDelegate) : Boolean
      {
         return Boolean(this._isValid) ? Boolean(this._isValid.evaluate(delegate)) : true;
      }
   }
}

