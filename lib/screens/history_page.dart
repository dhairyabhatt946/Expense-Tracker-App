import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/expense_tracker_database.dart';
import '../utils/string_constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  final db = ExpenseTrackerDatabase();
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await db.fetchTransactions();
    setState(() {
      transactions = data;
    });
  }

  Map<String, List<Map<String, dynamic>>> groupByFormat(String format) {
    Map<String, List<Map<String, dynamic>>> map = {};
    for (var txn in transactions) {
      String key = DateFormat(format).format(DateTime.parse(txn[DATE]));
      map.putIfAbsent(key, () => []);
      map[key]!.add(txn);
    }
    return map;
  }

  double getTotal(List<Map<String, dynamic>> txns, String type) {
    return txns
        .where((txn) => txn[TYPE] == type)
        .fold(0.0, (sum, txn) => sum + (txn[AMOUNT] as num).toDouble());
  }

  Widget buildTransactionCard(Map<String, dynamic> txn) {
    bool isIncome = txn[TYPE] == 'income';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green : Colors.red,
        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
      ),
      title: Text(txn[CATEGORY]),
      subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(txn[DATE]))),
      trailing: Text(
        '₹${txn[AMOUNT]}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildTabContent(String format) {
    final grouped = groupByFormat(format);
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final txns = grouped[key]!;

        final income = getTotal(txns, 'income');
        final expense = getTotal(txns, 'expense');
        final balance = income - expense;

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Income', income, Colors.green),
                    _buildSummaryCard('Expense', expense, Colors.red),
                    _buildSummaryCard('Balance', balance, Colors.indigo),
                  ],
                ),
                Divider(),
                ...txns.map(buildTransactionCard).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('History'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildTabContent('yyyy-MM-dd'),
            buildTabContent('yyyy-MM'),
            buildTabContent('yyyy'),
          ],
        ),
      ),
    );
  }
}
