import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/expense_tracker_database.dart';
import '../utils/string_constants.dart';

class AddEditTransactionPage extends StatefulWidget {
  final Map<String, dynamic>? existingTransaction; // Pass null for add

  const AddEditTransactionPage({super.key, this.existingTransaction});

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String selectedCategory = 'Food';
  String selectedType = 'expense';
  DateTime selectedDate = DateTime.now();

  final db = ExpenseTrackerDatabase();

  final categories = ['Food', 'Shopping', 'Salary', 'Transport', 'Rent', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final txn = widget.existingTransaction!;
      amountController.text = txn[AMOUNT].toString();
      selectedCategory = txn[CATEGORY];
      selectedType = txn[TYPE];
      selectedDate = DateTime.parse(txn[DATE]);
    }
  }

  void saveTransaction() async {
    if (!formKey.currentState!.validate()) return;

    final map = {
      AMOUNT: double.parse(amountController.text),
      CATEGORY: selectedCategory,
      NOTE: '',
      DATE: DateFormat('yyyy-MM-dd').format(selectedDate),
      TYPE: selectedType,
    };

    if (widget.existingTransaction == null) {
      await db.addTransaction(map);
    } else {
      await db.updateTransaction(widget.existingTransaction![ID], map);
    }

    Navigator.pop(context, true); // Return true to refresh home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTransaction == null ? 'Add Transaction' : 'Edit Transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['income', 'expense'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => selectedType = val!),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    icon: Icon(Icons.calendar_month),
                    label: Text('Pick Date'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveTransaction,
                child: Text(widget.existingTransaction == null ? 'Add Transaction' : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
