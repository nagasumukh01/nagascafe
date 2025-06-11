import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final Color cardBg = Colors.white;
  List<Map<String, dynamic>> analytics = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final periods = ['today', 'week', 'month', 'year'];
      final results = await Future.wait(
        periods.map((period) => ApiService.getAnalytics(period))
      );

      setState(() {
        analytics = results;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, size: 26, color: Colors.black87),
              const SizedBox(width: 8),
              const Text('Sales Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAnalytics,
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
          const SizedBox(height: 18),
          if (!isLoading && error == null)
            ...analytics.map((data) => Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: cardBg,
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const Icon(Icons.calendar_today, size: 20, color: Colors.black),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('₹${(data['amount'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                      const SizedBox(height: 2),
                      Text('${data['orders']} orders', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text('Avg: ₹${(data['avg'] as num).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      if (data['topItems'] != null && (data['topItems'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.black12),
                        const SizedBox(height: 8),
                        const Text('Top Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 6),
                        ...List.generate((data['topItems'] as List).length, (i) {
                          final item = (data['topItems'] as List)[i] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['name'] as String, style: const TextStyle(fontSize: 14)),
                                Text('x${item['qty']}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }
} 