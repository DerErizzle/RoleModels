package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.IMedia;
   import jackboxgames.talkshow.api.IMediaParamValue;
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class MediaParamValue implements IMediaParamValue
   {
      public static const SEL_RANDOM:uint = 0;
      
      public static const SEL_ORDER:uint = 1;
      
      public static const SEL_INDEX:uint = 2;
      
      public static const SEL_TAG:uint = 3;
      
      public static const SEL_PRIMARY:uint = 4;
      
      public static const ORDER_LOOP:String = "Loop";
      
      private var _selType:uint;
      
      private var _selVal:*;
      
      private var _actionRef:ActionRef;
      
      private var _myMedia:IMedia;
      
      private var _mediaId:uint;
      
      private var _previous:IMediaVersion;
      
      public function MediaParamValue(ar:ActionRef, mediaId:uint, selType:uint, selValue:*, myMedia:IMedia = null)
      {
         super();
         this._mediaId = mediaId;
         this._actionRef = ar;
         this._selType = selType;
         this._selVal = selValue;
         this._myMedia = myMedia;
         this._previous = null;
      }
      
      public function get selType() : uint
      {
         return this._selType;
      }
      
      public function get selValue() : *
      {
         return this._selVal;
      }
      
      public function get mediaId() : uint
      {
         return this._mediaId;
      }
      
      public function get media() : IMedia
      {
         if(this._myMedia == null)
         {
            this._myMedia = this._actionRef.parent.flowchart.getParentExport().getMedia(this._mediaId);
         }
         return this._myMedia;
      }
      
      public function get previous() : IMediaVersion
      {
         return this._previous;
      }
      
      public function getCurrentVersion(commit:Boolean = false) : IMediaVersion
      {
         var primaryMedia:IMediaParamValue = null;
         var primaryVersion:IMediaVersion = null;
         var ver:IMediaVersion = null;
         if(this.media != null)
         {
            switch(this._selType)
            {
               case MediaParamValue.SEL_INDEX:
                  ver = this.media.getVersionByIndex(int(VariableUtil.replaceVariables(this._selVal)) - 1);
                  break;
               case MediaParamValue.SEL_ORDER:
                  ver = this.media.getNextOrderedVersion(commit,this._selVal == ORDER_LOOP);
                  break;
               case MediaParamValue.SEL_PRIMARY:
                  primaryMedia = this._actionRef.getPrimaryMediaParamValue();
                  if(commit)
                  {
                     primaryVersion = primaryMedia.previous;
                  }
                  else
                  {
                     primaryVersion = primaryMedia.getCurrentVersion();
                  }
                  ver = this.media.getVersionByIndex(primaryVersion.idx);
                  break;
               case MediaParamValue.SEL_RANDOM:
                  ver = this.media.getNextRandomVersion(commit);
                  break;
               case MediaParamValue.SEL_TAG:
                  ver = this.media.getVersionByTag(String(VariableUtil.replaceVariables(this._selVal)),commit);
            }
         }
         if(commit)
         {
            this._previous = ver;
         }
         return ver;
      }
   }
}

