import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/expense_tracker_database.dart';
import '../utils/string_constants.dart';
import 'package:intl/intl.dart';

class ExpenseChartPage extends StatefulWidget {
  const ExpenseChartPage({super.key});

  @override
  State<ExpenseChartPage> createState() => _ExpenseChartPageState();
}

class _ExpenseChartPageState extends State<ExpenseChartPage> {
  final db = ExpenseTrackerDatabase();
  DateTime selectedMonth = DateTime.now();
  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final transactions = await db.fetchTransactions();
    Map<String, double> temp = {};

    for (var txn in transactions) {
      final txnDate = DateTime.parse(txn[DATE]);
      if (txnDate.month == selectedMonth.month &&
          txnDate.year == selectedMonth.year &&
          txn[TYPE] == 'expense') {
        final cat = txn[CATEGORY];
        final amt = txn[AMOUNT];
        temp[cat] = (temp[cat] ?? 0) + amt;
      }
    }

    setState(() {
      categoryTotals = temp;
    });
  }

  List<PieChartSectionData> getPieSections() {
    final List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    int index = 0;
    return categoryTotals.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expense Charts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Month: ${DateFormat.yMMM().format(selectedMonth)}',
                  style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    DropdownButton<int>(
                      value: selectedMonth.month,
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                              DateFormat.MMM().format(DateTime(0, index + 1))),
                        );
                      }),
                      onChanged: (month) {
                        setState(() {
                          selectedMonth = DateTime(selectedMonth.year, month!);
                        });
                        fetchData();
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: selectedMonth.year,
                      items: List.generate(10, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        );
                      }),
                      onChanged: (year) {
                        setState(() {
                          selectedMonth =
                              DateTime(year!, selectedMonth.month);
                        });
                        fetchData();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (categoryTotals.isEmpty)
              const Center(child: Text("No expense data for this month."))
            else
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Expenses by Category - ${DateFormat.yMMM().format(selectedMonth)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: getPieSections(),
                          centerSpaceRadius: 30,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: categoryTotals.entries.map((entry) {
                          return ListTile(
                            leading:
                            const Icon(Icons.label_important_outline),
                            title: Text(entry.key),
                            trailing:
                            Text('₹${entry.value.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
