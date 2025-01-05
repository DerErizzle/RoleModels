package jackboxgames.rolemodels.actionpackages.delegates
{
   import flash.display.*;
   import jackboxgames.loader.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class VideoPlayerDelegate
   {
       
      
      private var _containerMC:MovieClip;
      
      private var _isInBackground:Boolean;
      
      private var _videoCanceller:Function;
      
      public function VideoPlayerDelegate(containerMC:MovieClip, isInBackground:Boolean)
      {
         super();
         this._containerMC = containerMC;
         this._isInBackground = isInBackground;
         this._videoCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function reset() : void
      {
         this._videoCanceller();
         this._videoCanceller = Nullable.NULL_FUNCTION;
      }
      
      private function _setVideoContainerVisible(val:Boolean) : void
      {
         this._containerMC.visible = val;
      }
      
      private function playVideo(url:String, looping:Boolean, onLoadedFn:Function, onCompleteFn:Function) : void
      {
         VideoPlayerFactory.Parent = this._containerMC;
         this._videoCanceller();
         this._setVideoContainerVisible(true);
         this._videoCanceller = JBGUtil.PlayVideoFrame(JBGLoader.instance.getMediaUrl(url),this._containerMC,looping,1,function(success:Boolean):void
         {
            if(!success)
            {
               _videoCanceller = Nullable.NULL_FUNCTION;
            }
            onLoadedFn(success);
         },function(success:Boolean):void
         {
            _videoCanceller = Nullable.NULL_FUNCTION;
            _setVideoContainerVisible(false);
            onCompleteFn(success);
         },this._isInBackground);
      }
      
      private function stopVideo() : void
      {
         this._videoCanceller();
         this._videoCanceller = Nullable.NULL_FUNCTION;
         this._setVideoContainerVisible(false);
      }
      
      public function handleActionPlayVideo(ref:IActionRef, params:Object) : void
      {
         this.playVideo("videos/" + params.video,params.loop,function(success:Boolean):void
         {
            if(Boolean(params.endRefOnVideoLoaded))
            {
               ref.end();
            }
         },function(success:Boolean):void
         {
            if(!params.endRefOnVideoLoaded)
            {
               ref.end();
            }
         });
      }
      
      public function handleActionStopVideo(ref:IActionRef, params:Object) : void
      {
         this.stopVideo();
         ref.end();
      }
   }
}
