package jackboxgames.talkshow.api
{
   public class QualifiedID
   {
      private var _eid:String;
      
      private var _fid:String;
      
      private var _id:uint;
      
      public function QualifiedID(exportID:String, fcFileID:String = null, fcIntID:uint = 0)
      {
         super();
         if(exportID == null || exportID == "")
         {
            throw new ArgumentError("EXPORT ID REQUIRED");
         }
         if(fcFileID != null && fcIntID == 0)
         {
            throw new ArgumentError("INTERNAL ID REQUIRED FOR FLOWCHARTS/SUBROUTINES");
         }
         this._eid = exportID;
         this._fid = fcFileID;
         this._id = fcIntID;
      }
      
      public function get value() : String
      {
         if(this._fid == null)
         {
            return this._eid;
         }
         return this._eid + ":" + this._fid;
      }
      
      public function get eID() : String
      {
         return this._eid;
      }
      
      public function get fcFileID() : String
      {
         return this._fid;
      }
      
      public function get fcInternalID() : uint
      {
         return this._id;
      }
      
      public function toString() : String
      {
         return "[QualID: " + this.value + " ]";
      }
   }
}

