import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: ExpenseTablePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ExpenseTablePage extends StatefulWidget {
  @override
  _ExpenseTablePageState createState() => _ExpenseTablePageState();
}

class _ExpenseTablePageState extends State<ExpenseTablePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<Map<String, dynamic>> _expenses = [];

  double get totalExpenses =>
      _expenses.fold(0, (sum, item) => sum + (item['amount'] ?? 0));

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = _dateFormat.format(picked);
    }
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _expenses.add({
          'item': _itemController.text,
          'amount': double.tryParse(_amountController.text) ?? 0,
          'date': _dateController.text,
        });
        _itemController.clear();
        _amountController.clear();
        _dateController.clear();
      });
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _editExpense(int index) {
    final expense = _expenses[index];
    _itemController.text = expense['item'];
    _amountController.text = expense['amount'].toString();
    _dateController.text = expense['date'];

    setState(() {
      _expenses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Table")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemController,
                      decoration: InputDecoration(labelText: "Item"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter item" : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: "Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter amount" : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: "Date"),
                      readOnly: true,
                      onTap: _pickDate,
                      validator: (value) =>
                          value!.isEmpty ? "Pick a date" : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addExpense,
                    child: Text("Add"),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Item")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: _expenses
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(cells: [
                          DataCell(Text(entry.value['item'])),
                          DataCell(Text(entry.value['amount'].toString())),
                          DataCell(Text(entry.value['date'])),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editExpense(entry.key),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(entry.key),
                              ),
                            ],
                          )),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Total Expenses: ₱${totalExpenses.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
