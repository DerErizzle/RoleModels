package jackboxgames.localizy
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import jackboxgames.text.ExtendableTextField;
   
   public class LocalizedTextField
   {
       
      
      private var _tf:ExtendableTextField;
      
      private var _stringId:String;
      
      public function LocalizedTextField(mc:MovieClip, mappers:Array = null, postEffects:Array = null)
      {
         super();
         this._tf = new ExtendableTextField(mc,this._makeArrayIfNecessary(mappers),this._makeArrayIfNecessary(postEffects));
         this._stringId = this._tf.text.replace(/[^A-Z_0-9]+/g,"");
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,this._onUpdateText);
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onUpdateText);
         this._onUpdateText(null);
      }
      
      private function _makeArrayIfNecessary(source:Array) : Array
      {
         return source == null ? [] : source;
      }
      
      public function destroy() : void
      {
         LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,this._onUpdateText);
         LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onUpdateText);
      }
      
      private function _onUpdateText(evt:Event) : void
      {
         var newString:String = LocalizationManager.instance.getValueForKey(this._stringId);
         if(!newString)
         {
            return;
         }
         this._tf.text = newString;
      }
   }
}
