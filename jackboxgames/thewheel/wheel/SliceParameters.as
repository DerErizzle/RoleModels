package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.SliceType;
   
   public class SliceParameters
   {
      private var _type:SliceType;
      
      private var _data:ISliceData;
      
      public function SliceParameters()
      {
         super();
      }
      
      public static function CREATE(type:SliceType) : SliceParameters
      {
         return CREATE_WITH_OWNER(type,null);
      }
      
      public static function CREATE_WITH_OWNER(type:SliceType, owner:Player) : SliceParameters
      {
         var data:ISliceData = new type.dataClass();
         data.setup(owner);
         return CREATE_WITH_DATA(type,data);
      }
      
      private static function CREATE_WITH_DATA(type:SliceType, data:ISliceData) : SliceParameters
      {
         var sp:SliceParameters = new SliceParameters();
         sp._type = type;
         sp._data = data;
         return sp;
      }
      
      public function get type() : SliceType
      {
         return this._type;
      }
      
      public function get data() : ISliceData
      {
         return this._data;
      }
      
      public function clone() : SliceParameters
      {
         return CREATE_WITH_DATA(this.type,this._data.clone());
      }
   }
}

