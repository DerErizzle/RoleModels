package jackboxgames.audio
{
   import flash.media.Sound;
   import jackboxgames.utils.BuildConfig;
   
   public class JBGSoundPlayer
   {
      private static var _instance:JBGSoundPlayer;
      
      private var _sounds:Array;
      
      public function JBGSoundPlayer()
      {
         super();
         this._sounds = new Array();
      }
      
      public static function get instance() : JBGSoundPlayer
      {
         return Boolean(_instance) ? _instance : (_instance = new JBGSoundPlayer());
      }
      
      public function createFromUrl(sfxUrlNoExtension:String, autoPlay:Boolean = true, loop:Boolean = false, getPositionFn:Function = null, onLoadComplete:Function = null, onLoadError:Function = null) : JBGSound
      {
         var filename:String = sfxUrlNoExtension;
         filename += BuildConfig.instance.configVal("audio-extension");
         var sound:JBGSound = new JBGSound(loop,autoPlay);
         sound.loadFromUrl(filename,getPositionFn,onLoadComplete,onLoadError);
         this.registerSound(sound);
         return sound;
      }
      
      public function createFromSound(s:Sound, autoPlay:Boolean = true, loop:Boolean = false, getPositionFn:Function = null, onLoadComplete:Function = null, onLoadError:Function = null) : JBGSound
      {
         var sound:JBGSound = new JBGSound(loop,autoPlay);
         sound.loadFromSound(s,getPositionFn,onLoadComplete,onLoadError);
         this.registerSound(sound);
         return sound;
      }
      
      public function createLoopingSoundPlayer() : JBGLoopingSoundPlayer
      {
         return new JBGLoopingSoundPlayer();
      }
      
      public function pause() : void
      {
         var sound:JBGSound = null;
         for each(sound in this._sounds)
         {
            if(sound.isPlaying)
            {
               sound.pause();
            }
         }
      }
      
      public function resume() : void
      {
         var sound:JBGSound = null;
         for each(sound in this._sounds)
         {
            if(sound.isPlaying)
            {
               sound.resume();
            }
         }
      }
      
      public function stop() : void
      {
         var sound:JBGSound = null;
         for each(sound in this._sounds)
         {
            if(sound.isPlaying)
            {
               sound.stop();
            }
         }
      }
      
      public function registerSound(sound:JBGSound) : void
      {
         if(this._sounds.indexOf(sound) < 0)
         {
            this._sounds.push(sound);
         }
      }
      
      public function unregisterSound(sound:JBGSound) : void
      {
         var index:int = int(this._sounds.indexOf(sound));
         if(index >= 0)
         {
            this._sounds.splice(index,1);
         }
      }
   }
}

