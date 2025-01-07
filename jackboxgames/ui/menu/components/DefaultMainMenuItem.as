package jackboxgames.ui.menu.components
{
   import flash.display.*;
   import jackboxgames.localizy.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class DefaultMainMenuItem implements IMainMenuItem
   {
      private static const DEFAULT_ACTION:String = "doNothing";
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _title:ExtendableTextField;
      
      private var _description:ExtendableTextField;
      
      private var _action:String;
      
      public function DefaultMainMenuItem(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._mc.useHandCursor = true;
         this._mc.buttonMode = true;
         this._mc.mouseChildren = false;
         this._action = DEFAULT_ACTION;
         this._shower = new MovieClipShower(this._mc);
         this._title = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.txt);
         this._description = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.descTxt);
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get title() : ExtendableTextField
      {
         return this._title;
      }
      
      public function get description() : ExtendableTextField
      {
         return this._description;
      }
      
      public function get action() : String
      {
         return this._action;
      }
      
      public function dispose() : void
      {
         this.reset();
         JBGUtil.dispose([this._title,this._description,this._shower]);
         this._title = null;
         this._description = null;
         this._shower = null;
         this._action = null;
         this._mc = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower]);
         this._shower.behaviorTranslator = null;
      }
      
      public function setup(item:Object, source:String = null) : void
      {
         this._title.text = LocalizationManager.instance.getValueForKey(item.title,source);
         this._description.text = LocalizationManager.instance.getValueForKey(item.description,source);
         this._action = Boolean(item.action) ? item.action : DEFAULT_ACTION;
      }
      
      public function show(doneFn:Function) : void
      {
         this._shower.behaviorTranslator = null;
         this._shower.setShown(true,doneFn);
      }
      
      public function dismiss(isSelected:Boolean, doneFn:Function) : void
      {
         if(isSelected)
         {
            this._shower.behaviorTranslator = function(label:String):String
            {
               return label + "High";
            };
         }
         this._shower.setShown(false,doneFn);
      }
      
      public function highlight(doneFn:Function) : void
      {
         this._shower.doAnimation("Highlight",doneFn);
      }
      
      public function unhighlight(doneFn:Function) : void
      {
         this._shower.doAnimation("Unhighlight",doneFn);
      }
      
      public function select(doneFn:Function) : void
      {
         this._shower.doAnimation("Press",doneFn);
      }
   }
}

