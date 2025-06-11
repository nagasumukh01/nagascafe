# Naga's Cafe Backend

This is the backend server for the Naga's Cafe Management System. It provides APIs for order management and analytics.

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory with the following variables:
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/nagascafe
```

3. Start MongoDB service on your machine

4. Start the development server:
```bash
npm run dev
```

## API Endpoints

### Orders

- `GET /api/orders` - Get all orders
- `GET /api/orders/date/:date` - Get orders for a specific date
- `POST /api/orders` - Create a new order

### Analytics

- `GET /api/analytics/:period` - Get analytics for a specific period
  - Available periods: today, week, month, year

## Data Models

### Order

```javascript
{
  customer: String,
  phone: String,
  items: [{
    name: String,
    quantity: Number,
    price: Number
  }],
  subtotal: Number,
  discountType: String,
  discountValue: Number,
  total: Number,
  date: Date
}
``` 