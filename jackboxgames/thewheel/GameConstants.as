package jackboxgames.thewheel
{
   import jackboxgames.thewheel.actionpackages.triviatypes.Guessing;
   import jackboxgames.thewheel.actionpackages.triviatypes.Matching;
   import jackboxgames.thewheel.actionpackages.triviatypes.NumberTarget;
   import jackboxgames.thewheel.actionpackages.triviatypes.RapidFire;
   import jackboxgames.thewheel.actionpackages.triviatypes.TappingList;
   import jackboxgames.thewheel.actionpackages.triviatypes.TypingList;
   import jackboxgames.thewheel.data.GuessingData;
   import jackboxgames.thewheel.data.MatchingData;
   import jackboxgames.thewheel.data.NumberTargetData;
   import jackboxgames.thewheel.data.RapidFireData;
   import jackboxgames.thewheel.data.SliceType;
   import jackboxgames.thewheel.data.TappingListData;
   import jackboxgames.thewheel.data.TriviaType;
   import jackboxgames.thewheel.data.TypingListData;
   import jackboxgames.thewheel.wheel.actionpackages.CatchMeChallengeActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.ChainStealActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.ConsensusChallengeActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.ExpandActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.RainbowActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.ReplaceSliceActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.StealFromPlayerSliceActionPackage;
   import jackboxgames.thewheel.wheel.actionpackages.SwapPointsActionPackage;
   import jackboxgames.thewheel.wheel.effects.AudienceNeighborEffect;
   import jackboxgames.thewheel.wheel.effects.AudienceNumSpinsEffect;
   import jackboxgames.thewheel.wheel.effects.AudienceReplaceSlicesEffect;
   import jackboxgames.thewheel.wheel.effects.AudienceSkullSwapperEffect;
   import jackboxgames.thewheel.wheel.effects.AudienceSliceCountEffect;
   import jackboxgames.thewheel.wheel.effects.AudienceSliceEnhancementEffect;
   import jackboxgames.thewheel.wheel.effects.BadSplitEffect;
   import jackboxgames.thewheel.wheel.effects.CatchMeChallengeEffect;
   import jackboxgames.thewheel.wheel.effects.ChainStealEffect;
   import jackboxgames.thewheel.wheel.effects.ConsensusChallengeEffect;
   import jackboxgames.thewheel.wheel.effects.ExpandEffect;
   import jackboxgames.thewheel.wheel.effects.NeighborSliceEffect;
   import jackboxgames.thewheel.wheel.effects.PlayerSliceEffect;
   import jackboxgames.thewheel.wheel.effects.PointsForPlayerSliceEffect;
   import jackboxgames.thewheel.wheel.effects.PointsSliceEffect;
   import jackboxgames.thewheel.wheel.effects.RainbowSliceEffect;
   import jackboxgames.thewheel.wheel.effects.ReplaceSliceEffect;
   import jackboxgames.thewheel.wheel.effects.StealFromPlayerSliceEffect;
   import jackboxgames.thewheel.wheel.effects.SwapPointsEffect;
   import jackboxgames.thewheel.wheel.effects.WinnerSliceEffect;
   import jackboxgames.thewheel.wheel.slicedata.AnswerSliceData;
   import jackboxgames.thewheel.wheel.slicedata.AudienceSliceData;
   import jackboxgames.thewheel.wheel.slicedata.BadSliceData;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.thewheel.wheel.slicedata.MultiplierSliceData;
   import jackboxgames.thewheel.wheel.slicedata.NeighborSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PointsForPlayerSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PointsSliceData;
   import jackboxgames.thewheel.wheel.slicedata.ReservedSliceData;
   import jackboxgames.thewheel.wheel.slicedata.WinnerSliceData;
   import jackboxgames.thewheel.wheel.subwidgets.AnswerSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.AudienceSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.BadSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.BonusSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.MultiplierSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.NeighborSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.PlayerSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.PointsForPlayerSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.PointsSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.ReservedSliceSubWidget;
   import jackboxgames.thewheel.wheel.subwidgets.WinnerSliceSubWidget;
   import jackboxgames.utils.ArrayUtil;
   
   public final class GameConstants
   {
      public static const MIN_PLAYERS:int = 2;
      
      public static const MAX_PLAYERS:int = 8;
      
      public static const SETTING_ALLOW_PLAYER_CONTENT_ON_SCREEN:String = "AllowPlayerContentOnScreen";
      
      public static const TROPHY_SPIN_WHEN_EVERYONE_CAN_WIN:String = "THEWHEEL_SPIN_WHEN_EVERYONE_CAN_WIN";
      
      public static const TROPHY_EARN_EVERY_POWER_SLICE:String = "THEWHEEL_EARN_EVERY_POWER_SLICE";
      
      public static const TROPHY_LOTS_OF_POINTS_FROM_ONE_SLICE:String = "THEWHEEL_LOTS_OF_POINTS_FROM_ONE_SLICE";
      
      public static const TROPHY_BACK_TO_BACK_WINNER:String = "THEWHEEL_BACK_TO_BACK_WINNER";
      
      public static const NUM_POINTS_FOR_LOTS_OF_POINTS_TROPHY:int = 10000;
      
      public static const OPTION_A:String = "A";
      
      public static const OPTION_B:String = "B";
      
      public static const OPTION_NONE:String = "NONE";
      
      public static const TRIVIA_TYPE_TYPING_LIST:TriviaType = new TriviaType({
         "id":"typingList",
         "actionPackageClass":TypingList,
         "contentType":"TheWheelTypingList",
         "contentClass":TypingListData
      });
      
      public static const TRIVIA_TYPE_TAPPING_LIST:TriviaType = new TriviaType({
         "id":"tappingList",
         "actionPackageClass":TappingList,
         "contentType":"TheWheelTappingList",
         "contentClass":TappingListData
      });
      
      public static const TRIVIA_TYPE_NUMBER_TARGET:TriviaType = new TriviaType({
         "id":"numberTarget",
         "actionPackageClass":NumberTarget,
         "contentType":"TheWheelNumberTarget",
         "contentClass":NumberTargetData
      });
      
      public static const TRIVIA_TYPE_MATCHING:TriviaType = new TriviaType({
         "id":"matching",
         "actionPackageClass":Matching,
         "contentType":"TheWheelMatching",
         "contentClass":MatchingData
      });
      
      public static const TRIVIA_TYPE_RAPID_FIRE:TriviaType = new TriviaType({
         "id":"rapidFire",
         "actionPackageClass":RapidFire,
         "contentType":"TheWheelRapidFire",
         "contentClass":RapidFireData
      });
      
      public static const TRIVIA_TYPE_GUESSING:TriviaType = new TriviaType({
         "id":"guessing",
         "actionPackageClass":Guessing,
         "contentType":"TheWheelGuessing",
         "contentClass":GuessingData
      });
      
      public static const TRIVIA_TYPES_ALL:Array = [TRIVIA_TYPE_TYPING_LIST,TRIVIA_TYPE_TAPPING_LIST,TRIVIA_TYPE_NUMBER_TARGET,TRIVIA_TYPE_MATCHING,TRIVIA_TYPE_RAPID_FIRE,TRIVIA_TYPE_GUESSING];
      
      public static const SLICE_TYPE_RESERVED:SliceType = new SliceType({
         "id":"reserved",
         "baseSymbolName":"Reserved",
         "dataClass":ReservedSliceData,
         "subWidgetClass":ReservedSliceSubWidget
      });
      
      public static const SLICE_TYPE_MULTIPLIER:SliceType = new SliceType({
         "id":"multiplier",
         "baseSymbolName":"Reserved",
         "dataClass":MultiplierSliceData,
         "subWidgetClass":MultiplierSliceSubWidget
      });
      
      public static const SLICE_TYPE_PLAYER:SliceType = new SliceType({
         "id":"player",
         "baseSymbolName":"Player",
         "dataClass":PlayerSliceData,
         "subWidgetClass":PlayerSliceSubWidget,
         "potentialEffects":[{
            "id":"player",
            "effectClass":PlayerSliceEffect
         }]
      });
      
      public static const SLICE_TYPE_WINNER:SliceType = new SliceType({
         "id":"winner",
         "baseSymbolName":"Winner",
         "dataClass":WinnerSliceData,
         "subWidgetClass":WinnerSliceSubWidget,
         "potentialEffects":[{
            "id":"winner",
            "effectClass":WinnerSliceEffect
         }]
      });
      
      public static const SLICE_TYPE_POINTS:SliceType = new SliceType({
         "id":"points",
         "baseSymbolName":"Points",
         "dataClass":PointsSliceData,
         "subWidgetClass":PointsSliceSubWidget,
         "potentialEffects":[{
            "id":"points",
            "effectClass":PointsSliceEffect
         }]
      });
      
      public static const SLICE_TYPE_POINTS_FOR_PLAYER:SliceType = new SliceType({
         "id":"pointsForPlayer",
         "baseSymbolName":"Rainbow",
         "dataClass":PointsForPlayerSliceData,
         "subWidgetClass":PointsForPlayerSliceSubWidget,
         "potentialEffects":[{
            "id":"pointsForPlayer",
            "effectClass":PointsForPlayerSliceEffect
         }]
      });
      
      public static const SLICE_TYPE_NEIGHBOR:SliceType = new SliceType({
         "id":"neighbor",
         "baseSymbolName":"Neighbor",
         "dataClass":NeighborSliceData,
         "subWidgetClass":NeighborSliceSubWidget,
         "potentialEffects":[{
            "id":"neighbor",
            "effectClass":NeighborSliceEffect
         }]
      });
      
      public static const SLICE_TYPE_ANSWER:SliceType = new SliceType({
         "id":"answer",
         "baseSymbolName":"Answer",
         "dataClass":AnswerSliceData,
         "subWidgetClass":AnswerSliceSubWidget
      });
      
      public static const SLICE_TYPE_BAD:SliceType = new SliceType({
         "id":"bad",
         "baseSymbolName":"Bad",
         "dataClass":BadSliceData,
         "potentialEffects":[{
            "id":"badSplit",
            "effectClass":BadSplitEffect,
            "isValid":"true"
         }],
         "subWidgetClass":BadSliceSubWidget
      });
      
      public static const SLICE_TYPE_BONUS:SliceType = new SliceType({
         "id":"bonus",
         "baseSymbolName":"Bonus",
         "dataClass":BonusSliceData,
         "potentialEffects":[{
            "id":"swapPoints",
            "effectClass":SwapPointsEffect,
            "actionPackageClass":SwapPointsActionPackage,
            "isValid":"players.length > 3 AND lowestScore > 0"
         },{
            "id":"expand",
            "effectClass":ExpandEffect,
            "actionPackageClass":ExpandActionPackage,
            "isValid":"spinMeterRatio < 0.75"
         },{
            "id":"replaceSlice",
            "effectClass":ReplaceSliceEffect,
            "actionPackageClass":ReplaceSliceActionPackage,
            "isValid":"spinMeterRatio < 0.75"
         },{
            "id":"stealFromPlayerSlice",
            "effectClass":StealFromPlayerSliceEffect,
            "actionPackageClass":StealFromPlayerSliceActionPackage,
            "isValid":"playerSlicesOnMainWheel.length > 0"
         },{
            "id":"rainbow",
            "effectClass":RainbowSliceEffect,
            "actionPackageClass":RainbowActionPackage,
            "isValid":"true"
         },{
            "id":"consensusChallenge",
            "effectClass":ConsensusChallengeEffect,
            "actionPackageClass":ConsensusChallengeActionPackage,
            "isValid":"players.length > 3"
         },{
            "id":"catchMeChallenge",
            "effectClass":CatchMeChallengeEffect,
            "actionPackageClass":CatchMeChallengeActionPackage,
            "isValid":"players.length >= 3"
         },{
            "id":"chainSteal",
            "effectClass":ChainStealEffect,
            "actionPackageClass":ChainStealActionPackage,
            "isValid":"spinMeterRatio < 0.75 AND playerSlicesOnMainWheel.length > 0"
         }],
         "subWidgetClass":BonusSliceSubWidget
      });
      
      public static const SLICE_TYPE_AUDIENCE:SliceType = new SliceType({
         "id":"audience",
         "baseSymbolName":"Audience",
         "dataClass":AudienceSliceData,
         "potentialEffects":[{
            "id":"audienceReplaceSlices",
            "effectClass":AudienceReplaceSlicesEffect,
            "isValid":"spinMeterRatio < 0.75"
         },{
            "id":"audienceNumSpins",
            "effectClass":AudienceNumSpinsEffect,
            "isValid":"!isFinalSpin AND roundNum > 1"
         },{
            "id":"audienceNeighbor",
            "effectClass":AudienceNeighborEffect,
            "isValid":"playerSlicesOnMainWheel.length > 0"
         },{
            "id":"audienceSliceCount",
            "effectClass":AudienceSliceCountEffect,
            "isValid":"true"
         },{
            "id":"audienceSkullSwapper",
            "effectClass":AudienceSkullSwapperEffect,
            "isValid":"spinMeterRatio < 0.75 AND playerSlicesOnMainWheel.length > 0"
         },{
            "id":"audienceSliceEnhancement",
            "effectClass":AudienceSliceEnhancementEffect,
            "isValid":"spinMeterRatio < 0.75 AND playerSlicesOnMainWheel.length > 0"
         }],
         "subWidgetClass":AudienceSliceSubWidget
      });
      
      public static const SLICE_TYPES_ALL:Array = [SLICE_TYPE_RESERVED,SLICE_TYPE_MULTIPLIER,SLICE_TYPE_PLAYER,SLICE_TYPE_WINNER,SLICE_TYPE_POINTS,SLICE_TYPE_POINTS_FOR_PLAYER,SLICE_TYPE_NEIGHBOR,SLICE_TYPE_ANSWER,SLICE_TYPE_BAD,SLICE_TYPE_BONUS,SLICE_TYPE_AUDIENCE];
      
      public static const SLICE_TYPES_FILLER:Array = [SLICE_TYPE_POINTS];
      
      public static const WHEEL_CONTROLLER_MODE_DEFAULT:String = "default";
      
      public static const WHEEL_CONTROLLER_MODE_SECRETIVE:String = "secretive";
      
      public function GameConstants()
      {
         super();
      }
      
      public static function GET_TRIVIA_TYPE_BY_ID(id:String) : TriviaType
      {
         return ArrayUtil.find(TRIVIA_TYPES_ALL,function(tt:TriviaType, ... args):Boolean
         {
            return tt.id == id;
         });
      }
      
      public static function GET_SLICE_TYPE_BY_ID(id:String) : SliceType
      {
         return ArrayUtil.find(SLICE_TYPES_ALL,function(s:SliceType, ... args):Boolean
         {
            return s.id == id;
         });
      }
   }
}

