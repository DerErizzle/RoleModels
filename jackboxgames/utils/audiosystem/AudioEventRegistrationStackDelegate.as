package jackboxgames.utils.audiosystem
{
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class AudioEventRegistrationStackDelegate
   {
      private var _stack:AudioEventRegistrationStack;
      
      public function AudioEventRegistrationStackDelegate(stack:AudioEventRegistrationStack)
      {
         super();
         this._stack = stack;
      }
      
      public function reset() : void
      {
         this._stack.reset();
      }
      
      public function handleActionPushAudioKeys(ref:IActionRef, params:Object) : void
      {
         var audioDictionary:Object = null;
         var keys:Array = JBGUtil.getPropertiesOfNameInOrder(params,"key").filter(function(k:String, ... args):Boolean
         {
            return k != null;
         });
         var values:Array = JBGUtil.getPropertiesOfNameInOrder(params,"value").filter(function(v:String, ... args):Boolean
         {
            return v != null;
         });
         Assert.assert(keys.length == values.length);
         audioDictionary = {};
         ArrayUtil.parallelForEach(function(key:String, value:String):void
         {
            audioDictionary[key] = value;
         },keys,values);
         this._stack.push(audioDictionary);
         ref.end();
      }
      
      public function handleActionPushEntireMediaAudioKeys(ref:IActionRef, params:Object) : void
      {
         var v:* = undefined;
         var mpv:MediaParamValue = null;
         var media:IMedia = null;
         var j:int = 0;
         var version:IMediaVersion = null;
         var audioDictionary:Object = {};
         for(var i:int = 0; i < ref.action.numParameters; i++)
         {
            v = ref.getValueByIndex(i);
            if(v)
            {
               if(v is MediaParamValue)
               {
                  mpv = MediaParamValue(v);
                  media = mpv.media;
                  if(media)
                  {
                     for(j = 0; j < media.numVersions; j++)
                     {
                        version = media.getVersionByIndex(j);
                        if(version.tag.length != 0)
                        {
                           audioDictionary[version.tag] = version.text;
                        }
                     }
                  }
               }
            }
         }
         this._stack.push(audioDictionary);
         ref.end();
      }
      
      public function handleActionPopAudioKeys(ref:IActionRef, params:Object) : void
      {
         this._stack.pop();
         ref.end();
      }
   }
}

