package jackboxgames.localizy
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import flash.utils.*;
   import jackboxgames.flash.*;
   import jackboxgames.logger.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class LocalizedTextFieldManager
   {
      private static var _instance:LocalizedTextFieldManager;
      
      private var _tfsPerSource:Dictionary;
      
      public function LocalizedTextFieldManager()
      {
         super();
         this._tfsPerSource = new Dictionary();
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOAD_COMPLETE,this._onUpdateText);
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onUpdateText);
      }
      
      public static function get instance() : LocalizedTextFieldManager
      {
         if(!_instance)
         {
            _instance = new LocalizedTextFieldManager();
         }
         return _instance;
      }
      
      private function _onUpdateText(evt:Event) : void
      {
         var source:String = null;
         for(source in this._tfsPerSource)
         {
            this._tfsPerSource[source].forEach(function(tf:LocalizedTextField, ... args):void
            {
               tf.updateText();
            });
         }
      }
      
      public function addFromRoot(root:DisplayObjectContainer, source:String = null) : void
      {
         var helpersWithTextKeys:Array;
         if(!source)
         {
            source = LocalizationManager.GameSource;
         }
         if(!(source in this._tfsPerSource))
         {
            this._tfsPerSource[source] = [];
         }
         helpersWithTextKeys = ETFHelperUtil.findETFHelpersInChildren(root,true).filter(function(h:ETFHelperComponent, ... args):Boolean
         {
            return Boolean(h.textKey);
         });
         helpersWithTextKeys.forEach(function(h:ETFHelperComponent, ... args):void
         {
            _tfsPerSource[source].push(new LocalizedTextField(root,h,source));
         });
      }
      
      public function removeFromRoot(root:DisplayObjectContainer, source:String = null) : void
      {
         if(!source)
         {
            source = LocalizationManager.GameSource;
         }
         if(!(source in this._tfsPerSource))
         {
            return;
         }
         this._tfsPerSource[source] = this._tfsPerSource[source].filter(function(tf:LocalizedTextField, ... args):Boolean
         {
            return tf.fromRoot != root;
         });
      }
      
      public function clear(source:String) : void
      {
         if(!(source in this._tfsPerSource))
         {
            return;
         }
         this._tfsPerSource[source].forEach(function(tf:LocalizedTextField, ... args):void
         {
         });
         delete this._tfsPerSource[source];
      }
   }
}

import flash.display.DisplayObjectContainer;
import jackboxgames.engine.GameEngine;
import jackboxgames.flash.ETFHelperComponent;
import jackboxgames.text.ETFHelperUtil;
import jackboxgames.text.ExtendableTextField;

class LocalizedTextField
{
   private var _source:String;
   
   private var _fromRoot:DisplayObjectContainer;
   
   private var _stringId:String;
   
   private var _tf:ExtendableTextField;
   
   public function LocalizedTextField(fromRoot:DisplayObjectContainer, helper:ETFHelperComponent, source:String)
   {
      super();
      this._source = source;
      this._fromRoot = fromRoot;
      this._stringId = helper.textKey.replace(/[^A-Za-z_0-9]+/g,"").toUpperCase();
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromHelper(helper);
      this.updateText();
   }
   
   public function get fromRoot() : DisplayObjectContainer
   {
      return this._fromRoot;
   }
   
   public function updateText() : void
   {
      var newString:String = null;
      if(this._stringId.toUpperCase() == "QUIT_BACK_PROMPT")
      {
         newString = LocalizationManager.instance.getValueForKey(GameEngine.instance.supportsExit ? "EXIT" : "BACK",this._source);
      }
      else
      {
         newString = LocalizationManager.instance.getValueForKey(this._stringId,this._source);
      }
      if(!newString)
      {
         return;
      }
      this._tf.text = newString;
   }
}

