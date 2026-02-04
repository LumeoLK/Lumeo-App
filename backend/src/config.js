import mongoose from "mongoose";

const connectDB = async (mongoURI) => {
    try {
        const conn = await mongoose.connect(`${process.env.MONGODB_URL}`);
        console.log("connected to the database")
    }
    catch (error) {
        console.error("MongoDB connection error:", error);
        
    }
}
export default connectDB;