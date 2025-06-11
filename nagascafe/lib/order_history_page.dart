import 'package:flutter/material.dart';
import 'services/api_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final Color accentColor = Colors.black;
  final Color cardBg = Colors.white;
  final Color pageBg = const Color(0xFFF6F7FB);
  List<Map<String, dynamic>> orderHistory = [];
  bool isLoading = true;
  String? error;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final orders = selectedDate != null
          ? await ApiService.getOrdersByDate(selectedDate!)
          : await ApiService.getOrders();

      setState(() {
        orderHistory = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

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
                      Row(
                        children: [
                          const Icon(Icons.history, size: 28, color: Colors.black87),
                          const SizedBox(width: 8),
                          const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
                        ],
                      ),
                      Row(
                        children: [
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
                                      _loadOrders();
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
                          if (selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                });
                                _loadOrders();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (orderHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No orders found'),
                ),
              )
            else
              ...orderHistory.map((order) {
                final date = DateTime.parse(order['date']);
                final total = order['total'] as double;
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
                                    const SizedBox(height: 12),
                                    ...(order['items'] as List).map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item['name'], style: const TextStyle(fontSize: 14)),
                                          Text('x${item['quantity']} - ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1, color: Colors.black12),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              }),
          ],
        ),
      ),
    );
  }
} 