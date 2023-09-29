import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rat_book/models/database.dart';
import 'package:rat_book/models/transaction_with_category.dart';
import 'package:rat_book/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final transactions = snapshot.data ?? [];
                    final income = transactions
                        .where((transaction) => transaction.category.type == 1)
                        .fold<int>(
                            0, (previousValue, transaction) => previousValue + transaction.transaction.amount);
                    final expense = transactions
                        .where((transaction) => transaction.category.type == 2)
                        .fold<int>(
                            0, (previousValue, transaction) => previousValue + transaction.transaction.amount);
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  child: Icon(Icons.download, color: Colors.green),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Income",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Rp. ${NumberFormat('#,###').format(income)}",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  child: Icon(Icons.upload, color: Colors.red),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Expense",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Rp. ${NumberFormat('#,###').format(expense)}",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(16)),
                    );
                  }
                },
              ),
            ),            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final transactionWithCategory = snapshot.data![index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await database.deleteTransactionRepo(
                                              snapshot
                                                  .data![index]
                                                  .transaction
                                                  .id);
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage(
                                                        transactionsWithCategory:
                                                            snapshot
                                                                    .data![
                                                                index])));
                                      },
                                    )
                                  ],
                                ),
                                title: Text("Rp. " +
                                    transactionWithCategory.transaction.amount
                                        .toString()),
                                subtitle: Text(
                                    transactionWithCategory.category.name +
                                        "(" +
                                        transactionWithCategory
                                            .transaction.description +
                                        ")"),
                                leading: Container(
                                  child: (snapshot.data![index].category.type ==
                                          2)
                                      ? Icon(Icons.upload, color: Colors.red)
                                      : Icon(Icons.download,
                                          color: Colors.green),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text("Data Pembukuan masih kosong"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("Tidak Ada Data"),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}