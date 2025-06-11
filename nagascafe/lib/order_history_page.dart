import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final Color accentColor = Colors.black;
  final Color cardBg = Colors.white;
  final Color pageBg = const Color(0xFFF6F7FB);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Positioned(
                  left: -8,
                  top: -8,
                  child: Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.black.withOpacity(0.07),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0, top: 0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
                      SizedBox(
                        width: 170,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: selectedDate == null
                                ? ''
                                : '${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}',
                          ),
                          decoration: InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20, color: Colors.black),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.black12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            ...orderHistory.where((order) => selectedDate == null || (order['date'] as DateTime).year == selectedDate!.year && (order['date'] as DateTime).month == selectedDate!.month && (order['date'] as DateTime).day == selectedDate!.day).map((order) {
              final date = order['date'] as DateTime;
              final total = (order['items'] as List).fold<double>(0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 140,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(22),
                                bottomLeft: Radius.circular(22),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 20, color: Colors.black87),
                                          const SizedBox(width: 6),
                                          Text(order['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} am', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(order['phone'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(3),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(2),
                                      },
                                      border: TableBorder(
                                        horizontalInside: BorderSide(color: Colors.black12, width: 1),
                                      ),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.13)),
                                          children: const [
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...List<TableRow>.from((order['items'] as List).map((item) => TableRow(
                                          decoration: const BoxDecoration(),
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                              ),
                                            ),
                                            Center(child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                                            Center(child: Text('₹${item['price'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                                            Center(child: Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                                          ],
                                        ))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('Order Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(width: 18),
                                      Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 