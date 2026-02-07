import Cart from "../models/cart.js";
import Product from "../models/Product.js";

// 1. Get My Cart
export const getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ userId: req.user.id })
        .populate("items.productId", "title images price"); // Show product details

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

    // Fetch product to get the REAL price (Security)
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ msg: "Product not found" });

    let cart = await Cart.findOne({ userId: req.user.id });

    if (cart) {
      // Cart exists for user
      const itemIndex = cart.items.findIndex(p => p.productId == productId);

      if (itemIndex > -1) {
        // Product exists in cart, update quantity
        let productItem = cart.items[itemIndex];
        productItem.quantity += quantity;
        cart.items[itemIndex] = productItem;
      } else {
        // Product does not exist in cart, add new item
        cart.items.push({ productId, quantity, price: product.price });
      }
      
      // Recalculate Total Price
      cart.totalPrice += product.price * quantity;
      cart = await cart.save();
      return res.json(cart);
    } else {
      // No cart for user, create new cart
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
    const { productId } = req.body;
    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) return res.status(404).json({ msg: "Cart not found" });

    // Find item to remove to subtract price
    const itemIndex = cart.items.findIndex(p => p.productId == productId);
    if (itemIndex > -1) {
        let productItem = cart.items[itemIndex];
        cart.totalPrice -= productItem.price * productItem.quantity;
        cart.items.splice(itemIndex, 1);
    }

    cart = await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};