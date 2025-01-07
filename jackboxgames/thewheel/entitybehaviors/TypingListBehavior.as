package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.utils.*;
   
   public class TypingListBehavior implements IEntityInteractionBehavior
   {
      private static const RESULT_CORRECT:String = "correct";
      
      private static const RESULT_INCORRECT:String = "incorrect";
      
      private static const RESULT_CORRECT_BUT_GUESSED_ALREADY:String = "correct-but-guessed-already";
      
      private var _delegate:ITypingListBehaviorDelegate;
      
      private var _ws:WSClient;
      
      private var _lastResults:PerPlayerContainer;
      
      public function TypingListBehavior(delegate:ITypingListBehaviorDelegate)
      {
         super();
         this._delegate = delegate;
      }
      
      public function setup(ws:WSClient, players:Array) : void
      {
         this._ws = ws;
         this._lastResults = new PerPlayerContainer();
      }
      
      public function shutdown(finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
         this._ws = null;
         this._lastResults = null;
      }
      
      public function generateSharedEntities() : SharedEntities
      {
         return new SharedEntities();
      }
      
      public function generatePlayerEntities(p:JBGPlayer) : PlayerEntities
      {
         return new PlayerEntities(p).withInput("main",new ObjectEntity(this._ws,"typinglist:" + p.sessionId.val,{},["rw id:" + p.sessionId.val]));
      }
      
      public function onPlayerInputEntityUpdated(p:JBGPlayer, pe:PlayerEntities, se:SharedEntities, key:String, e:IEntity) : EntityUpdateRequest
      {
         var mainInput:ObjectEntity = null;
         var answer:String = null;
         var result:String = null;
         var correctAnswerIndex:int = 0;
         var i:int = 0;
         var ans:TypingListAnswerData = null;
         if(key == "main")
         {
            mainInput = ObjectEntity(e);
            if(mainInput.getValue().hasOwnProperty("answer"))
            {
               answer = mainInput.getValue().answer;
               result = RESULT_INCORRECT;
               correctAnswerIndex = -1;
               for(i = 0; i < this._delegate.content.answers.length; i++)
               {
                  ans = this._delegate.content.answers[i];
                  if(ans.isValid(answer))
                  {
                     if(!this._delegate.playerHasGuessed(Player(p),i))
                     {
                        result = RESULT_CORRECT;
                        correctAnswerIndex = i;
                        break;
                     }
                     result = RESULT_CORRECT_BUT_GUESSED_ALREADY;
                     correctAnswerIndex = i;
                  }
               }
               this._lastResults.setDataForPlayer(p,result);
               if(result == RESULT_CORRECT)
               {
                  this._delegate.onPlayerGuessedCorrect(Player(p),correctAnswerIndex);
               }
               else if(result == RESULT_INCORRECT)
               {
                  this._delegate.onPlayerGuessedIncorrect(Player(p),answer);
               }
               else if(result == RESULT_CORRECT_BUT_GUESSED_ALREADY)
               {
                  this._delegate.onPlayerGuessedCorrectButGuessedAlready(Player(p),correctAnswerIndex);
               }
               return new EntityUpdateRequest().withPlayerMainEntity(p);
            }
         }
         return null;
      }
      
      public function getSharedEntityValue(entityKey:String, entity:IEntity) : *
      {
         return undefined;
      }
      
      public function getPlayerEntityValue(p:JBGPlayer, entityKey:String, entity:IEntity) : *
      {
         var e:Object = null;
         if(entityKey == "main")
         {
            e = {
               "kind":"typingList",
               "prompt":this._delegate.content.prompt,
               "subtype":this._delegate.content.subtype,
               "answers":this._delegate.getMappedGuesses(Player(p)),
               "responseKey":"typinglist:" + p.sessionId.val
            };
            if(this._lastResults.hasDataForPlayer(p))
            {
               e.lastResult = this._lastResults.getDataForPlayer(p);
            }
            return e;
         }
         return null;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         for(var i:int = 0; i < this._delegate.content.answers.length; i++)
         {
            if(!this._delegate.playerHasGuessed(Player(p),i))
            {
               return false;
            }
         }
         return true;
      }
   }
}

