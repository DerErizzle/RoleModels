package jackboxgames.talkshow.media
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.IMedia;
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.talkshow.utils.RandomLowRepeat;
   import jackboxgames.utils.ArrayUtil;
   
   public class AbstractMedia implements IMedia
   {
      protected var _id:int;
      
      protected var _allVersions:Array;
      
      protected var _versions:Array;
      
      protected var _container:IExport;
      
      private var _lastOrdered:int = -1;
      
      private var _currentOrdered:int = -1;
      
      private var _rnr:RandomLowRepeat;
      
      private var _tags:Object;
      
      private var _parentFlowchart:IFlowchart;
      
      public function AbstractMedia(id:int, container:IExport, fl:IFlowchart)
      {
         super();
         this._id = id;
         this._container = container;
         this._parentFlowchart = fl;
         this._allVersions = new Array();
         this._versions = new Array();
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get allVersions() : Array
      {
         return this._allVersions;
      }
      
      public function get container() : IExport
      {
         return this._container;
      }
      
      public function get numVersions() : uint
      {
         return this._versions.length;
      }
      
      public function get type() : String
      {
         return null;
      }
      
      public function addVersion(idx:uint, id:int, locale:String, tag:String, script:String, ... vinfo) : void
      {
      }
      
      public function onMediaLoaded(fl:IFlowchart = null) : void
      {
         this._container.onMediaLoaded(this,fl != null ? fl : this._parentFlowchart);
      }
      
      public function unloadAllVersions() : void
      {
         var v:* = undefined;
         for(var i:int = 0; i < this._allVersions.length; i++)
         {
            v = this._allVersions[i];
            if(v is AbstractLoadableVersion)
            {
               v.unload();
            }
         }
      }
      
      public function filterVersionsForLocale(newLocale:String) : void
      {
         this._versions = this._allVersions.filter(function(v:*, ... args):Boolean
         {
            return v.locale == "" || v.locale == newLocale;
         });
         this._tags = null;
         this._rnr = null;
         this._currentOrdered = -1;
      }
      
      public function getNextRandomVersion(commit:Boolean = false) : IMediaVersion
      {
         if(this._rnr == null)
         {
            this._rnr = new RandomLowRepeat(this._versions.length);
         }
         var current:uint = this._rnr.getNextIndex();
         if(commit)
         {
            this._rnr.commit();
         }
         return this._versions[current];
      }
      
      public function getNextOrderedVersion(commit:Boolean = false, loop:Boolean = true) : IMediaVersion
      {
         var v:AbstractVersion = null;
         if(this._currentOrdered >= 0)
         {
            v = this._versions[this._currentOrdered];
         }
         else
         {
            if(++this._lastOrdered >= this._versions.length)
            {
               if(loop)
               {
                  this._lastOrdered = 0;
               }
               else
               {
                  this._lastOrdered = this._versions.length - 1;
               }
            }
            v = this._versions[this._lastOrdered];
            this._currentOrdered = this._lastOrdered;
         }
         if(commit)
         {
            this._currentOrdered = -1;
         }
         return v;
      }
      
      public function getVersionByIndex(index:*) : IMediaVersion
      {
         if(this._versions.length == 1)
         {
            return this._versions[0];
         }
         if(isNaN(index) || int(index) < 0 || int(index) >= this._versions.length || index == null)
         {
            Logger.warning("AbstractMedia: No matching version for: " + index + " -- using default","Media");
            return this._versions[this._versions.length - 1];
         }
         return this._versions[int(index)];
      }
      
      public function getVersionByTag(tag:String, commit:Boolean = false) : IMediaVersion
      {
         var matches:Array = null;
         var item:AbstractVersion = null;
         var tags:Array = null;
         var t:String = null;
         var rnr:RandomLowRepeat = null;
         var index:uint = 0;
         if(this._versions.length == 1)
         {
            return this._versions[0];
         }
         if(this._tags == null)
         {
            this._tags = new Object();
         }
         if(this._tags[tag] == null)
         {
            matches = new Array();
            for each(item in this._versions)
            {
               tags = item.tag.split(",");
               for each(t in tags)
               {
                  if(t == tag)
                  {
                     matches.push(item);
                  }
               }
            }
            if(matches.length == 1)
            {
               this._tags[tag] = {
                  "n":1,
                  "v":matches[0]
               };
            }
            else
            {
               if(matches.length <= 1)
               {
                  Logger.warning("AbstractMedia: No matching version for: " + tag + " -- using default","Media");
                  return this._versions[this._versions.length - 1];
               }
               rnr = new RandomLowRepeat(matches.length);
               this._tags[tag] = {
                  "n":matches.length,
                  "v":matches,
                  "rnr":rnr
               };
            }
         }
         if(this._tags[tag].n > 1)
         {
            index = uint(this._tags[tag].rnr.getNextIndex());
            if(commit)
            {
               this._tags[tag].rnr.commit();
            }
            return this._tags[tag].v[index];
         }
         return this._tags[tag].v;
      }
      
      public function versionIsInMedia(v:IMediaVersion) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._versions,v);
      }
   }
}

