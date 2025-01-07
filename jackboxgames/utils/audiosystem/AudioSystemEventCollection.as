package jackboxgames.utils.audiosystem
{
   import flash.geom.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class AudioSystemEventCollection
   {
      private var _audioDictionary:Object;
      
      private var _isLoaded:Boolean;
      
      public function AudioSystemEventCollection(audioDictionary:Object)
      {
         var key:String = null;
         super();
         this._audioDictionary = {};
         for(key in audioDictionary)
         {
            if(audioDictionary[key])
            {
               if(audioDictionary[key] is String)
               {
                  this._audioDictionary[key] = new AudioSystemEventPlayer(audioDictionary[key]);
               }
            }
         }
         this._isLoaded = false;
      }
      
      public function dispose() : void
      {
         var key:String = null;
         var e:AudioSystemEventPlayer = null;
         for(key in this._audioDictionary)
         {
            e = this._audioDictionary[key];
            e.dispose();
         }
         this._audioDictionary = {};
      }
      
      public function setLoaded(isLoaded:Boolean, completeFn:Function) : void
      {
         var numToLoad:int = 0;
         var successful:Boolean = false;
         var key:String = null;
         var e:AudioSystemEventPlayer = null;
         if(this._isLoaded == isLoaded)
         {
            return;
         }
         this._isLoaded = isLoaded;
         numToLoad = ObjectUtil.countProperties(this._audioDictionary);
         if(numToLoad == 0)
         {
            completeFn(true);
            return;
         }
         successful = true;
         for(key in this._audioDictionary)
         {
            e = this._audioDictionary[key];
            e.setLoaded(this._isLoaded,function(success:Boolean):void
            {
               --numToLoad;
               successful = successful && success;
               if(numToLoad == 0)
               {
                  completeFn(successful);
               }
            });
         }
      }
      
      public function hasAudio(key:String) : Boolean
      {
         return this._audioDictionary.hasOwnProperty(key);
      }
      
      public function play(key:String, doneFn:Function = null) : void
      {
         var audioIsDoneFn:Function = Nullable.convertToNullableIfNecessary(doneFn,Function);
         if(!this.hasAudio(key))
         {
            Logger.warning("Attempting to play event in AudioSystemEventCollection with non-existent key = " + key);
            audioIsDoneFn();
            return;
         }
         var e:AudioSystemEventPlayer = this._audioDictionary[key];
         e.play(audioIsDoneFn);
      }
      
      public function stop(key:String) : void
      {
         if(!this.hasAudio(key))
         {
            return;
         }
         var e:AudioSystemEventPlayer = this._audioDictionary[key];
         e.stop();
      }
      
      public function setParameterValue(key:String, name:String, val:Number) : void
      {
         if(!this.hasAudio(key))
         {
            return;
         }
         var e:AudioSystemEventPlayer = this._audioDictionary[key];
         e.setParameterValue(name,val);
      }
      
      public function triggerCue(key:String) : void
      {
         if(!this.hasAudio(key))
         {
            return;
         }
         var e:AudioSystemEventPlayer = this._audioDictionary[key];
         e.triggerCue();
      }
      
      public function setLocation(key:String, flashLocation:Point) : void
      {
         if(!this.hasAudio(key))
         {
            return;
         }
         var e:AudioSystemEventPlayer = this._audioDictionary[key];
         e.setLocation(flashLocation);
      }
   }
}

