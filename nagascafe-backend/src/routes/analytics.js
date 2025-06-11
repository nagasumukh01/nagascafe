const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const moment = require('moment');

// Get analytics for a specific period
router.get('/:period', async (req, res) => {
  try {
    const { period } = req.params;
    let startDate, endDate;

    // Set date range based on period
    switch (period) {
      case 'today':
        startDate = moment().startOf('day').toDate();
        endDate = moment().endOf('day').toDate();
        break;
      case 'week':
        startDate = moment().startOf('week').toDate();
        endDate = moment().endOf('week').toDate();
        break;
      case 'month':
        startDate = moment().startOf('month').toDate();
        endDate = moment().endOf('month').toDate();
        break;
      case 'year':
        startDate = moment().startOf('year').toDate();
        endDate = moment().endOf('year').toDate();
        break;
      default:
        return res.status(400).json({ message: 'Invalid period' });
    }

    // Get orders within date range
    const orders = await Order.find({
      date: {
        $gte: startDate,
        $lte: endDate
      }
    });

    // Calculate analytics
    const totalAmount = orders.reduce((sum, order) => sum + order.total, 0);
    const totalOrders = orders.length;
    const averageOrder = totalOrders > 0 ? totalAmount / totalOrders : 0;

    // Calculate top items
    const itemCounts = {};
    orders.forEach(order => {
      order.items.forEach(item => {
        if (itemCounts[item.name]) {
          itemCounts[item.name] += item.quantity;
        } else {
          itemCounts[item.name] = item.quantity;
        }
      });
    });

    const topItems = Object.entries(itemCounts)
      .map(([name, qty]) => ({ name, qty }))
      .sort((a, b) => b.qty - a.qty)
      .slice(0, 3);

    res.json({
      label: period.charAt(0).toUpperCase() + period.slice(1),
      amount: totalAmount,
      orders: totalOrders,
      avg: averageOrder,
      topItems
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router; 