import Cart from "../models/cart.js";
import Product from "../models/Product.js";

const normalizeId = (value) => {
  if (!value) return "";
  if (typeof value === "string") return value;
  if (value._id) return value._id.toString();
  return value.toString();
};

// 1. Get My Cart
export const getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ userId: req.user.id })
        .populate("items.productId", "title images price"); 

    if (!cart) {
      // If no cart exists, return an empty one logic (or create one)
      return res.json({ items: [], totalPrice: 0 });
    }
    res.json(cart);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// 2. Add Item to Cart
export const addToCart = async (req, res) => {
  try {
    const { productId, quantity } = req.body;

    if (!productId) {
      return res.status(400).json({ msg: "productId is required" });
    }

    if(!quantity || quantity <= 0) {
      return res.status(400).json({ msg: "Quantity must be at least 1" });
    }
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ msg: "Product not found" });

    if(product.stock < quantity) {
      return res.status(400).json({ msg: "Not enough stock available" });
    }
  

    let cart = await Cart.findOne({ userId: req.user.id });

    if (cart) {
      
      const itemIndex = cart.items.findIndex(
        (p) => normalizeId(p.productId) === normalizeId(productId),
      );

      if (itemIndex > -1) {
        
        let productItem = cart.items[itemIndex];
        productItem.quantity += quantity;
        cart.items[itemIndex] = productItem;
      } else {
        
        cart.items.push({ productId, quantity, price: product.price });
      }
      
      
      cart.totalPrice += product.price * quantity;
      cart = await cart.save();
      return res.json(cart);
    } else {
      
      const newCart = await Cart.create({
        userId: req.user.id,
        items: [{ productId, quantity, price: product.price }],
        totalPrice: product.price * quantity
      });
      return res.status(201).json(newCart);
    }
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// 3. Remove Item from Cart
export const removeFromCart = async (req, res) => {
  try {
    const productId =
      req.body?.productId || req.query?.productId || req.params?.productId;
    if (!productId) {
      return res.status(400).json({ msg: "productId is required" });
    }

    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) return res.status(404).json({ msg: "Cart not found" });

    // Find item to remove to subtract price
    const itemIndex = cart.items.findIndex(
      (p) => normalizeId(p.productId) === normalizeId(productId),
    );

    if (itemIndex === -1) {
      return res.status(404).json({ msg: "Item not found in cart" });
    }

    let productItem = cart.items[itemIndex];
    cart.totalPrice -= productItem.price * productItem.quantity;
    cart.items.splice(itemIndex, 1);

    if (cart.totalPrice < 0) {
      cart.totalPrice = 0;
    }

    cart = await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};