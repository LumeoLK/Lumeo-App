import { Queue } from "bullmq";
import Redis from "ioredis";

// 1. Connect to Upstash Redis
// BullMQ requires maxRetriesPerRequest to be null

const redisConnection = new Redis(
  process.env.REDIS_URL || "redis://127.0.0.1:6379",
  {
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
  },
);

// 2. Create the "Order Rail" (The Queue)
// We are naming this queue 'meshy-3d-queue'
export const meshyQueue = new Queue("meshy-3d-queue", {
  connection: redisConnection,
});

console.log("🚀 BullMQ Queue initialized and connected to Redis!");
