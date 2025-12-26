import mongoose from "mongoose";

const userSchema = mongoose.Schema({
    name:{
required:true,
type:String,
trim:true,
    },
     email:{
required:true,
type:String,
trim:true,
validate:{
    validator:(value) =>{
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return value.match(regex);
    },
    message: "Please enter a valid email address"
}
    },password:{
        required:false,
        type:String,

    },
    name:{
        type:String,
        required:false,

    },googleId:{
        type:String,
        unique:true,
        sparce:true,

    },profilePicture:{
        type:String,
        default:null,

    } ,isEmailVerified: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});
const User = mongoose.model("User",userSchema);
export default User;
