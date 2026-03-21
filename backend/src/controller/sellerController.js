import Seller from "../models/seller.js";
import User from "../models/User.js";
import Product from "../models/Product.js";
import Order from "../models/order.js";
import jwt from "jsonwebtoken";
import { uploadToCloudinary } from "../lib/cloudinary.js";

const DEFAULT_LISTING_LIMIT = 10;
const DEFAULT_ORDER_LIMIT = 10;
const DAY_IN_MS = 24 * 60 * 60 * 1000;
const WEEK_DAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

const clampPositiveInt = (value, fallback) => {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

const roundToOneDecimal = (value = 0) =>
  Math.round(Number(value || 0) * 10) / 10;

const formatAmount = (value = 0) =>
  Number(value || 0).toLocaleString("en-US", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });

const getStartOfDay = (date) => {
  const normalized = new Date(date);
  normalized.setHours(0, 0, 0, 0);
  return normalized;
};

const addDays = (date, days) => {
  const nextDate = new Date(date);
  nextDate.setDate(nextDate.getDate() + days);
  return nextDate;
};

const getStartOfWeek = (date = new Date()) => {
  const weekStart = getStartOfDay(date);
  const day = weekStart.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  weekStart.setDate(weekStart.getDate() + diff);
  return weekStart;
};

const buildHandle = (shopName = "") =>
  shopName
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "")
    .replace(/^@+/, "");

const getItemProductId = (item) => {
  if (!item?.productId) return "";
  if (typeof item.productId === "object" && item.productId._id) {
    return item.productId._id.toString();
  }

  return item.productId.toString();
};

const getSellerItemTotal = (item) =>
  Number(item?.priceAtPurchase || item?.productId?.price || 0) *
  Number(item?.quantity || 0);

const createHttpError = (statusCode, message) => {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
};

const getSellerContext = async (userId) => {
  const seller = await Seller.findOne({ userId }).populate(
    "userId",
    "name email profilePicture",
  );

  if (!seller) {
    throw createHttpError(404, "Seller profile not found.");
  }

  const products = await Product.find({ sellerId: seller._id }).sort({
    createdAt: -1,
  });

  const productIdSet = new Set(products.map((product) => product._id.toString()));

  return { seller, products, productIdSet };
};

const getSellerOrders = async (productIds) => {
  if (!productIds.length) {
    return [];
  }

  return Order.find({
    "items.productId": { $in: productIds },
  })
    .select("buyerId items status totalAmount createdAt")
    .populate("buyerId", "name email")
    .populate("items.productId", "title images price sellerId")
    .sort({ createdAt: -1 });
};

const mapSellerOrders = (orders, productIdSet) =>
  orders
    .map((order) => {
      const sellerItems = order.items.filter((item) =>
        productIdSet.has(getItemProductId(item)),
      );

      return {
        order,
        sellerItems,
        sellerTotal: sellerItems.reduce(
          (sum, item) => sum + getSellerItemTotal(item),
          0,
        ),
      };
    })
    .filter(({ sellerItems }) => sellerItems.length > 0);

const buildSellerProfile = (seller) => ({
  sellerId: seller._id,
  displayName: seller.displayName,
  shopName: seller.shopName,
  handle: `@${buildHandle(seller.shopName)}`,
  logo: seller.logo || seller.userId?.profilePicture || "",
  coverPhoto: "",
  isVerified: seller.isVerified,
  businessAddress: seller.businessAddress,
  phoneNumber: seller.phoneNumber,
  rating: roundToOneDecimal(seller.rating),
  totalSales: seller.totalSales || 0,
  joinedAt: seller.createdAt,
  owner: seller.userId
    ? {
        id: seller.userId._id,
        name: seller.userId.name,
        email: seller.userId.email,
        profilePicture: seller.userId.profilePicture || "",
      }
    : null,
});

const buildSellerSummary = (seller, products, sellerOrders) => {
  const startOfThisWeek = getStartOfWeek(new Date());
  const endOfThisWeek = addDays(startOfThisWeek, 7);

  const activeListings = products.filter((product) => Number(product.stock) > 0)
    .length;

  const totalReviews = products.reduce(
    (sum, product) => sum + Number(product.numReviews || 0),
    0,
  );

  const ratingSum = products.reduce(
    (sum, product) =>
      sum +
      Number(product.averageRating || 0) * Number(product.numReviews || 0),
    0,
  );

  const averageRating =
    totalReviews > 0 ? ratingSum / totalReviews : Number(seller.rating || 0);

  const earningsThisWeek = sellerOrders.reduce((sum, sellerOrder) => {
    const orderDate = new Date(sellerOrder.order.createdAt);
    const isThisWeek =
      orderDate >= startOfThisWeek && orderDate < endOfThisWeek;
    const isCancelled = sellerOrder.order.status === "cancelled";

    if (!isThisWeek || isCancelled) {
      return sum;
    }

    return sum + sellerOrder.sellerTotal;
  }, 0);

  const totalRevenue = sellerOrders.reduce((sum, sellerOrder) => {
    if (sellerOrder.order.status === "cancelled") {
      return sum;
    }

    return sum + sellerOrder.sellerTotal;
  }, 0);

  return {
    earningsThisWeek,
    earningsThisWeekFormatted: formatAmount(earningsThisWeek),
    activeListings,
    averageRating: roundToOneDecimal(averageRating),
    totalReviews,
    totalRevenue,
    totalRevenueFormatted: formatAmount(totalRevenue),
    totalOrders: sellerOrders.length,
  };
};

const buildSellerPerformance = (sellerOrders) => {
  const startOfThisWeek = getStartOfWeek(new Date());
  const startOfLastWeek = addDays(startOfThisWeek, -7);
  const endOfThisWeek = addDays(startOfThisWeek, 7);
  const thisWeek = Array(7).fill(0);
  const lastWeek = Array(7).fill(0);
  const thisWeekRevenue = Array(7).fill(0);
  const lastWeekRevenue = Array(7).fill(0);

  sellerOrders.forEach((sellerOrder) => {
    if (sellerOrder.order.status === "cancelled") {
      return;
    }

    const orderDay = getStartOfDay(sellerOrder.order.createdAt);

    if (orderDay >= startOfThisWeek && orderDay < endOfThisWeek) {
      const dayIndex = Math.floor((orderDay - startOfThisWeek) / DAY_IN_MS);
      thisWeek[dayIndex] += 1;
      thisWeekRevenue[dayIndex] += sellerOrder.sellerTotal;
      return;
    }

    if (orderDay >= startOfLastWeek && orderDay < startOfThisWeek) {
      const dayIndex = Math.floor((orderDay - startOfLastWeek) / DAY_IN_MS);
      lastWeek[dayIndex] += 1;
      lastWeekRevenue[dayIndex] += sellerOrder.sellerTotal;
    }
  });

  return {
    metric: "orders",
    days: WEEK_DAY_LABELS,
    thisWeek,
    lastWeek,
    revenue: {
      thisWeek: thisWeekRevenue.map((value) => roundToOneDecimal(value)),
      lastWeek: lastWeekRevenue.map((value) => roundToOneDecimal(value)),
    },
  };
};

const buildActiveListings = (seller, products, limit) =>
  products
    .map((product) => ({
      id: product._id,
      name: product.title,
      brand: seller.shopName,
      price: product.price,
      formattedPrice: formatAmount(product.price),
      views: product.views || 0,
      likes: 0,
      comments: product.numReviews || 0,
      active: Number(product.stock) > 0,
      stock: product.stock,
      category: product.category,
      images: product.images|| "",
      averageRating: roundToOneDecimal(product.averageRating),
      numReviews: product.numReviews || 0,
      model3DStatus: product.model3D?.status || "pending",
      modelurl: product.model3D?.url || "",
      createdAt: product.createdAt,
    }));

const buildRecentOrders = (sellerOrders, limit) =>
  sellerOrders
    .filter(({ order }) => order.status !== "cancelled")
    .flatMap(({ order, sellerItems }) =>
      sellerItems.map((item) => ({
        id: `${order._id}-${getItemProductId(item)}`,
        orderId: order._id,
        orderNumber: `Order #${order._id.toString().slice(-6).toUpperCase()}`,
        productId: getItemProductId(item),
        name: item.productId?.title || "Product unavailable",
        price: Number(item.priceAtPurchase || item.productId?.price || 0),
        formattedPrice: formatAmount(
          Number(item.priceAtPurchase || item.productId?.price || 0),
        ),
        totalPrice: getSellerItemTotal(item),
        formattedTotalPrice: formatAmount(getSellerItemTotal(item)),
        quantity: item.quantity || 0,
        image: item.productId?.images?.[0] || "",
        status: order.status,
        createdAt: order.createdAt,
        buyer: order.buyerId
          ? {
              id: order.buyerId._id,
              name: order.buyerId.name,
              email: order.buyerId.email,
            }
          : null,
      })),
    )
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, limit);

const buildSellerDashboardData = async (
  userId,
  {
    listingsLimit = DEFAULT_LISTING_LIMIT,
    ordersLimit = DEFAULT_ORDER_LIMIT,
  } = {},
) => {
  const { seller, products } = await getSellerContext(userId);
  const sellerOrders = mapSellerOrders(
    await getSellerOrders(products.map((product) => product._id)),
    new Set(products.map((product) => product._id.toString())),
  );

  return {
    profile: buildSellerProfile(seller),
    summary: buildSellerSummary(seller, products, sellerOrders),
    performance: buildSellerPerformance(sellerOrders),
    activeListings: buildActiveListings(seller, products, listingsLimit),
    newOrders: buildRecentOrders(sellerOrders, ordersLimit),
  };
};

const handleSellerError = (res, error) => {
  res
    .status(error.statusCode || 500)
    .json({ success: false, msg: error.message });
};
//----------------------------------------------
export const becomeSeller = async (req, res) => {
  try {
    const { shopName, displayName, businessAddress, phoneNumber, businessRegNumber } = req.body;

    if (!shopName || !displayName || !businessAddress || !phoneNumber || !businessRegNumber) {
      return res.status(400).json({ success: false, msg: "Please provide all the required fields" });
    }

    const existingShop = await Seller.findOne({ userId: req.user.id });
    if (existingShop) {
      return res.status(400).json({ success: false, msg: "You have already applied to be a seller." });
    }

    const existingSeller = await Seller.findOne({ businessRegNumber });
    if (existingSeller) {
      return res.status(400).json({ success: false, msg: "Seller with same Business Registration Number already exist" });
    }

    // ← Check file existence using buffers, not .path
    if (!req.files?.logo || !req.files?.NICfront || !req.files?.NICback) {
      return res.status(400).json({ success: false, msg: "Please upload Logo, NIC Front, and NIC Back images." });
    }

    // ← Upload all 3 to Cloudinary in parallel
    const [logoResult, nicFrontResult, nicBackResult] = await Promise.all([
      uploadToCloudinary(req.files["logo"][0].buffer, "lumeo_sellers"),
      uploadToCloudinary(req.files["NICfront"][0].buffer, "lumeo_sellers"),
      uploadToCloudinary(req.files["NICback"][0].buffer, "lumeo_sellers"),
    ]);

    const user = await User.findOne({ _id: req.user.id }).select("+password");
    user.role = "seller";
    await user.save();

    const seller = new Seller({
      userId: req.user.id,
      shopName,
      displayName,
      logo: logoResult.secure_url,        // ← secure_url not .path
      businessAddress,
      phoneNumber,
      NICfront: nicFrontResult.secure_url,
      NICback: nicBackResult.secure_url,
      businessRegNumber,
      isVerified: false,
    });

    await seller.save();

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({ success: true, token, seller });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }

};
//----------------------------------------------
export const createProduct = async (req, res) => {
  try {
    const { title, description, price, category, stock, length, width, height } = req.body;

    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res.status(404).json({ success: false, msg: "Seller profile not found." });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, msg: "Please upload at least one image." });
    }

    const imageUrls = req.files.map((file) => file.path);

    const newProduct = new Product({
      sellerId: seller._id,
      title, description, price, category, stock,
      images: imageUrls,
      dimensions: { length, width, height },
    });

    await newProduct.save();

    res.status(201).json({ success: true, msg: "Product created successfully!", product: newProduct });
  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};


export const searchProducts = async (req, res) => {
  try {
    const { keyword, category, minPrice, maxPrice, sortBy, page = 1, limit = 10 } = req.query;

    let query = {};
    if (keyword) query.title = { $regex: keyword, $options: "i" };
    if (category) query.category = category;
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    let sortOptions = {};
    if (sortBy === "price-low") sortOptions.price = 1;
    else if (sortBy === "price-high") sortOptions.price = -1;
    else sortOptions.createdAt = -1;

    const skip = (Number(page) - 1) * Number(limit);

    const products = await Product.find(query)
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit))
      .select("title price images category");

    const total = await Product.countDocuments(query);

    res.json({ success: true, count: products.length, total, page: Number(page), pages: Math.ceil(total / Number(limit)), data: products });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

export const getSellerProfile = async (req, res) => {
  try {
    const { seller } = await getSellerContext(req.user.id);
    res.json({ success: true, data: buildSellerProfile(seller) });
  } catch (error) {
    handleSellerError(res, error);
  }
};

export const getSellerSummary = async (req, res) => {
  try {
    const { seller, products } = await getSellerContext(req.user.id);
    const sellerOrders = mapSellerOrders(
      await getSellerOrders(products.map((product) => product._id)),
      new Set(products.map((product) => product._id.toString())),
    );

    res.json({
      success: true,
      data: buildSellerSummary(seller, products, sellerOrders),
    });
  } catch (error) {
    handleSellerError(res, error);
  }
};

export const getSellerPerformance = async (req, res) => {
  try {
    const { products } = await getSellerContext(req.user.id);
    const sellerOrders = mapSellerOrders(
      await getSellerOrders(products.map((product) => product._id)),
      new Set(products.map((product) => product._id.toString())),
    );

    res.json({
      success: true,
      data: buildSellerPerformance(sellerOrders),
    });
  } catch (error) {
    handleSellerError(res, error);
  }
};

export const getSellerActiveListings = async (req, res) => {
  try {
    const limit = clampPositiveInt(req.query.limit, DEFAULT_LISTING_LIMIT);
    const { seller, products } = await getSellerContext(req.user.id);

    res.json({
      success: true,
      count: products.filter((product) => Number(product.stock) > 0).length,
      data: buildActiveListings(seller, products, limit),
    });
  } catch (error) {
    handleSellerError(res, error);
  }
};

export const getSellerRecentOrders = async (req, res) => {
  try {
    const limit = clampPositiveInt(req.query.limit, DEFAULT_ORDER_LIMIT);
    const { products } = await getSellerContext(req.user.id);
    const sellerOrders = mapSellerOrders(
      await getSellerOrders(products.map((product) => product._id)),
      new Set(products.map((product) => product._id.toString())),
    );

    const recentOrders = buildRecentOrders(sellerOrders, limit);

    res.json({
      success: true,
      count: recentOrders.length,
      data: recentOrders,
    });
  } catch (error) {
    handleSellerError(res, error);
  }
};

export const getSellerDashboard = async (req, res) => {
  try {
    const listingsLimit = clampPositiveInt(
      req.query.listingsLimit,
      DEFAULT_LISTING_LIMIT,
    );
    const ordersLimit = clampPositiveInt(
      req.query.ordersLimit,
      DEFAULT_ORDER_LIMIT,
    );

    const dashboard = await buildSellerDashboardData(req.user.id, {
      listingsLimit,
      ordersLimit,
    });

    res.json({ success: true, data: dashboard });
  } catch (error) {
    handleSellerError(res, error);
  }
};

