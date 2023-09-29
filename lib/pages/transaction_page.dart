import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rat_book/models/database.dart';
import 'package:rat_book/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionsWithCategory;
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDatabase database = AppDatabase();
  bool isExpense = true;
  late int type;
  List<String> list = ['Makan', 'Transportasi', 'Bensin'];
  late String dropDownValue = list.first;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future<void> insert(int amount, DateTime date, String description, int categoryId) async {
  DateTime now = DateTime.now();
  await database.into(database.transactions).insert(
    TransactionsCompanion.insert(
      description: description, 
      category_id: categoryId, 
      transaction_date: date, 
      amount: amount, 
      created_at: now, 
      updated_at: now
    ),
  );
}

  Future<List<Category>>getAllCategory(int type) async{
      return await database.getAllCategoryRepo(type);
  }

  Future update(int transactionId, int categoryId, int amount, DateTime transactionDate, String description) async {
    return await database.updateTransactionRepo(transactionId, amount, categoryId  , transactionDate, description);
  }

  @override
  void initState() {    
    if (widget.transactionsWithCategory != null) {
      updateTransactionView(widget.transactionsWithCategory!);
    }else{
      type = 2;
    }

    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory){
    amountController.text = transactionWithCategory.transaction.amount.toString();
    detailController.text = transactionWithCategory.transaction.description;
    dateController.text = DateFormat("yyyy-MM-dd").format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;

    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Transaksi")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Switch(
                  value: isExpense, 
                  onChanged: (bool value) {
                    setState(() {
                      isExpense = value;
                      type = (isExpense) ? 2 : 1;
                      selectedCategory = null;
                    });
                  }, 
                  inactiveTrackColor: Colors.green[200], 
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                  ),
                  Text(
                    isExpense ? 'Pengeluaran' : 'Pemasukan',
                    style: GoogleFonts.montserrat(fontSize: 14),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: UnderlineInputBorder(), labelText: "Amount"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Category",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ),
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context,snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }else{
                      if (snapshot.hasData) {
                        if (snapshot.data!.length > 0) {
                          selectedCategory = (selectedCategory == null) ? snapshot.data!.first : selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButton<Category>(
                              value: (selectedCategory == null) ? snapshot.data!.first : selectedCategory,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_downward),
                              items: snapshot.data!.map((Category item){
                                  return DropdownMenuItem<Category>(
                                    value: item,
                                    child: Text(item.name),
                                    );
                              }).toList(),
                              onChanged: (Category ? value) {
                                setState(() {                                  
                                  selectedCategory = value;
                                });
                              }),
                          );
                        }else{
                          return Center(
                            child: Text("Data Kosong"),
                          );
                        }
                      }else{
                        return Center(
                          child: Text("Tidak ada data"),
                        );
                      }
                    }
                }
              ),              
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Pilih Tanggal"), 
                    onTap: () async{
                      DateTime? pickedDate = await showDatePicker(
                        context: context, 
                        initialDate: DateTime.now(), 
                        firstDate: DateTime(2023), 
                        lastDate: DateTime(2099));
              
                        if (pickedDate != null) {
                          String formatedDate = 
                            DateFormat('yyyy-MM-dd').format(pickedDate);
              
                          dateController.text = formatedDate;
                        }
                    },),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(    
                  controller: detailController,              
                  decoration: InputDecoration(border: UnderlineInputBorder(), labelText: "Keterangan"),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (widget.transactionsWithCategory == null) {
                // Reset input fields
                amountController.clear();
                dateController.text = '2023-01-01';
                detailController.clear();
                // Set selected category to the first category in the list if available
                final categories = await getAllCategory(type);
                if (categories.isNotEmpty) {
                  setState(() {
                    selectedCategory = categories.first;
                  });
                }
              } else {
                // If in edit mode, reset to original values
                updateTransactionView(widget.transactionsWithCategory!);
              }
            },
            child: Text("Reset"),
            style: ElevatedButton.styleFrom(primary: Colors.red),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (widget.transactionsWithCategory == null) {
                await insert(
                  int.parse(amountController.text),
                  DateTime.parse(dateController.text),
                  detailController.text,
                  selectedCategory!.id,
                );
              } else {
                await update(
                  widget.transactionsWithCategory!.transaction.id,
                  int.parse(amountController.text),
                  selectedCategory!.id,
                  DateTime.parse(dateController.text),
                  detailController.text,
                );
              }
              setState(() {});
              Navigator.pop(context, true);
            },
            child: Text("Save"))])),
            ],
            ),
          ),
        ),
      );
  }
}