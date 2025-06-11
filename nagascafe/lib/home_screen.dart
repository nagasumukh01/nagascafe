import 'package:flutter/material.dart';
import 'order_history_page.dart';
import 'analytics_page.dart';
import 'services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  int itemQuantity = 1;
  List<Map<String, dynamic>> orderItems = [];

  // Discount
  String discountType = 'percentage';
  final TextEditingController discountController = TextEditingController(text: '0');

  // Dummy order history data
  final List<Map<String, dynamic>> orderHistory = [
    {
      'customer': 'shivani',
      'phone': '7899401457',
      'date': DateTime(2025, 6, 6, 4, 53, 45),
      'items': [
        {'name': 'DBC', 'quantity': 1, 'price': 79.0},
      ],
    },
    {
      'customer': 'arjun',
      'phone': '9876543210',
      'date': DateTime(2025, 6, 5, 10, 30, 0),
      'items': [
        {'name': 'Coffee', 'quantity': 2, 'price': 50.0},
        {'name': 'Sandwich', 'quantity': 1, 'price': 60.0},
      ],
    },
    {
      'customer': 'meera',
      'phone': '9123456789',
      'date': DateTime(2025, 6, 4, 9, 15, 0),
      'items': [
        {'name': 'Tea', 'quantity': 3, 'price': 20.0},
      ],
    },
    {
      'customer': 'ravi',
      'phone': '9988776655',
      'date': DateTime(2025, 6, 3, 14, 45, 0),
      'items': [
        {'name': 'Pastry', 'quantity': 1, 'price': 90.0},
        {'name': 'Juice', 'quantity': 2, 'price': 30.0},
      ],
    },
    {
      'customer': 'anita',
      'phone': '9001122334',
      'date': DateTime(2025, 6, 2, 16, 0, 0),
      'items': [
        {'name': 'Burger', 'quantity': 1, 'price': 120.0},
      ],
    },
  ];
  DateTime? selectedDate;

  void addItem() {
    final name = itemNameController.text.trim();
    final price = double.tryParse(itemPriceController.text.trim()) ?? 0.0;
    if (name.isNotEmpty && price > 0 && itemQuantity > 0) {
      setState(() {
        orderItems.add({
          'name': name,
          'price': price,
          'quantity': itemQuantity,
        });
        itemNameController.clear();
        itemPriceController.clear();
        itemQuantity = 1;
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }

  double get subtotal => orderItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  double get discountAmount {
    final discountValue = double.tryParse(discountController.text) ?? 0.0;
    if (discountType == 'percentage') {
      return subtotal * (discountValue / 100);
    } else {
      return discountValue;
    }
  }

  double get total => (subtotal - discountAmount).clamp(0, double.infinity);

  Future<void> _submitOrder() async {
    if (customerNameController.text.isEmpty || phoneController.text.isEmpty || orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final orderData = {
        'customer': customerNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'items': orderItems,
        'subtotal': subtotal,
        'discountType': discountType,
        'discountValue': double.tryParse(discountController.text) ?? 0.0,
        'total': total
      };

      await ApiService.createOrder(orderData);

      // Clear form
      customerNameController.clear();
      phoneController.clear();
      setState(() {
        orderItems.clear();
        itemQuantity = 1;
        discountController.text = '0';
        discountType = 'percentage';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating order: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Colors.black;
    final Color cardBg = Colors.white;
    final Color pageBg = const Color(0xFFF6F7FB);
    final BorderRadius cardRadius = BorderRadius.circular(18);
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/logo.jpg'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 18),
            const Text(
              'SLV Super Cafe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: cardBg,
        foregroundColor: accentColor,
        elevation: 2,
        shadowColor: accentColor.withOpacity(0.08),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
            child: Row(
              children: [
                _buildTabButton('Take Order', 0, accentColor),
                const SizedBox(width: 8),
                _buildTabButton('Order History', 1, accentColor),
                const SizedBox(width: 8),
                _buildTabButton('Analytics', 2, accentColor),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: _buildTakeOrderPage(cardBg, accentColor, cardRadius),
                ),
                const OrderHistoryPage(),
                const AnalyticsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color accentColor) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor, width: 1.2),
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isSelected ? Colors.white : accentColor,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () {
            setState(() {
              selectedTab = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
          child: Text(label),
        ),
      ),
    );
  }

  // --- Take Order Page (existing UI) ---
  Widget _buildTakeOrderPage(Color cardBg, Color accentColor, BorderRadius cardRadius) {
    // ... move all the previous take order UI code here ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Customer Details
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          color: cardBg,
          shadowColor: accentColor.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: accentColor, size: 26),
                    const SizedBox(width: 8),
                    const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name *',
                    hintText: 'Enter customer name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.account_circle_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter 10-digit phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Order Items
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          color: cardBg,
          shadowColor: accentColor.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fastfood, color: accentColor, size: 26),
                    const SizedBox(width: 8),
                    const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 2),
                            child: Text('Item Name *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                          SizedBox(
                            height: 38,
                            child: TextField(
                              controller: itemNameController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 2),
                            child: Text('Price *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                          SizedBox(
                            height: 38,
                            child: TextField(
                              controller: itemPriceController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 2),
                            child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                          SizedBox(
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      color: accentColor,
                                      padding: EdgeInsets.zero,
                                      splashRadius: 16,
                                      onPressed: () {
                                        setState(() {
                                          if (itemQuantity > 1) itemQuantity--;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Text('$itemQuantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      color: accentColor,
                                      padding: EdgeInsets.zero,
                                      splashRadius: 16,
                                      onPressed: () {
                                        setState(() {
                                          itemQuantity++;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: addItem,
                    child: const Text('Add Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (orderItems.isNotEmpty) ...[
          const SizedBox(height: 28),
          // Current Order
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: cardRadius),
            color: cardBg,
            shadowColor: accentColor.withOpacity(0.10),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: accentColor, size: 26),
                      const SizedBox(width: 8),
                      const Text('Current Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: accentColor.withOpacity(0.07)),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text(''),
                          ),
                        ],
                      ),
                      ...orderItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: idx % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.04),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            Center(child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w500))),
                            Center(child: Text('₹${item['price'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))),
                            Center(child: Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))),
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => removeItem(idx),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  // Discount Section
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('% Discount (or Amount)', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: discountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'percentage',
                            groupValue: discountType,
                            onChanged: (val) {
                              setState(() {
                                discountType = val!;
                              });
                            },
                            activeColor: accentColor,
                          ),
                          const Text('Percentage (%)', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'fixed',
                            groupValue: discountType,
                            onChanged: (val) {
                              setState(() {
                                discountType = val!;
                              });
                            },
                            activeColor: accentColor,
                          ),
                          const Text('Fixed Amount (₹)', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      Text('Total: ₹${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: accentColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: _submitOrder,
                      child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
} 