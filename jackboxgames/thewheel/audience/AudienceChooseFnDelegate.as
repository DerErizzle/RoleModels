package jackboxgames.thewheel.audience
{
   public class AudienceChooseFnDelegate implements IAudienceChooseDataDelegate, IAudienceChooseEventDelegate
   {
      private var _categoryFn:Function;
      
      private var _promptFn:Function;
      
      private var _choicesFn:Function;
      
      private var _onVotesUpdated:Function;
      
      private var _onDoneFn:Function;
      
      public function AudienceChooseFnDelegate()
      {
         super();
         this._categoryFn = function():String
         {
            return "";
         };
         this._promptFn = function():String
         {
            return "";
         };
         this._choicesFn = function():Array
         {
            return [];
         };
         this._onVotesUpdated = function(counts:Object):void
         {
         };
         this._onDoneFn = function(counts:Object):void
         {
         };
      }
      
      public function withCategoryFn(categoryFn:Function) : AudienceChooseFnDelegate
      {
         this._categoryFn = categoryFn;
         return this;
      }
      
      public function withPromptFn(promptFn:Function) : AudienceChooseFnDelegate
      {
         this._promptFn = promptFn;
         return this;
      }
      
      public function withChoicesFn(choicesFn:Function) : AudienceChooseFnDelegate
      {
         this._choicesFn = choicesFn;
         return this;
      }
      
      public function withVotesUpdated(onVotesUpdated:Function) : AudienceChooseFnDelegate
      {
         this._onVotesUpdated = onVotesUpdated;
         return this;
      }
      
      public function withDoneFn(onDoneFn:Function) : AudienceChooseFnDelegate
      {
         this._onDoneFn = onDoneFn;
         return this;
      }
      
      public function getAudienceChooseCategory() : String
      {
         return this._categoryFn();
      }
      
      public function getAudienceChoosePrompt() : String
      {
         return this._promptFn();
      }
      
      public function getAudienceChooseChoices() : Array
      {
         return this._choicesFn();
      }
      
      public function onAudienceVotesUpdated(counts:Object) : void
      {
         this._onVotesUpdated(counts);
      }
      
      public function onAudienceChooseDone(counts:Object) : void
      {
         this._onDoneFn(counts);
      }
   }
}

