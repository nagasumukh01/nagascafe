const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const { body, validationResult } = require('express-validator');

// Get all orders
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ date: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get orders by date
router.get('/date/:date', async (req, res) => {
  try {
    const date = new Date(req.params.date);
    const startOfDay = new Date(date.setHours(0, 0, 0, 0));
    const endOfDay = new Date(date.setHours(23, 59, 59, 999));

    const orders = await Order.find({
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    }).sort({ date: -1 });

    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create new order
router.post('/', [
  body('customer').notEmpty().trim(),
  body('phone').notEmpty().trim(),
  body('items').isArray().notEmpty(),
  body('items.*.name').notEmpty().trim(),
  body('items.*.quantity').isInt({ min: 1 }),
  body('items.*.price').isFloat({ min: 0 }),
  body('subtotal').isFloat({ min: 0 }),
  body('total').isFloat({ min: 0 })
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const order = new Order({
    customer: req.body.customer,
    phone: req.body.phone,
    items: req.body.items,
    subtotal: req.body.subtotal,
    discountType: req.body.discountType || 'percentage',
    discountValue: req.body.discountValue || 0,
    total: req.body.total
  });

  try {
    const newOrder = await order.save();
    res.status(201).json(newOrder);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router; 