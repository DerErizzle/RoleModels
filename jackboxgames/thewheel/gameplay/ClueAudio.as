package jackboxgames.thewheel.gameplay
{
   import jackboxgames.algorithm.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.templates.*;
   import jackboxgames.utils.*;
   
   public class ClueAudio
   {
      private var _ts:IEngineAPI;
      
      private var _audio:Array;
      
      public function ClueAudio(ts:IEngineAPI)
      {
         super();
         this._ts = ts;
      }
      
      public function reset() : void
      {
         this._audio = [];
      }
      
      public function setup() : Boolean
      {
         var tf:TemplateField = null;
         var index:int = 0;
         var t:ITemplate = this._ts.activeExport.getTemplateByName("Trivia");
         this._audio = [];
         var loadedAudio:Boolean = false;
         for each(tf in t.fields)
         {
            if(tf.name.indexOf("ClueAudio") == 0)
            {
               index = int(tf.name.slice("ClueAudio".length));
               while(this._audio.length < index + 1)
               {
                  this._audio.push(null);
               }
               this._audio[index] = t.getValue(tf.id);
               if(Boolean(this._audio[index]) && !this._audio[index].isLoaded())
               {
                  this._audio[index].load();
                  loadedAudio = true;
               }
            }
         }
         return loadedAudio;
      }
      
      public function getAudioFor(i:int) : IAudioVersion
      {
         return this._audio[i];
      }
   }
}

