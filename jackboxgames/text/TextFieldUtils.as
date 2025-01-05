package jackboxgames.text
{
   import flash.display.MovieClip;
   import jackboxgames.utils.TextUtils;
   
   public final class TextFieldUtils
   {
       
      
      public function TextFieldUtils()
      {
         super();
      }
      
      public static function buildExtendableTextField(mc:MovieClip, resize:int = 0, balance:Boolean = false, extraMappers:Array = null, extraPostEffects:Array = null) : ExtendableTextField
      {
         var mappers:Array = [];
         if(extraMappers != null)
         {
            mappers = mappers.concat(extraMappers);
         }
         var postEffects:Array = [];
         if(resize > 0)
         {
            postEffects.push(PostEffectFactory.createDynamicResizerEffect(resize));
         }
         if(balance)
         {
            postEffects.push(PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER));
         }
         if(extraPostEffects != null)
         {
            postEffects = postEffects.concat(extraPostEffects);
         }
         return new ExtendableTextField(mc,mappers,postEffects);
      }
   }
}
