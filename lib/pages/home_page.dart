import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_management/models/database.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TransactionWithCategory>>(
        stream: database.getTransactionByDate(widget.selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Inisialisasi saldo
          int totalIncome = 100000000;
          int totalExpense = 20000000;

          if (snapshot.hasData) {
            final listTransaction = snapshot.data!;

            for (var item in listTransaction) {
              if (item.category.type == 1) {
                totalIncome += item.transaction.amount;
              } else {
                totalExpense += item.transaction.amount;
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.download_for_offline,
                              color: Colors.green,
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pemasukan",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Rp $totalIncome",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white24, thickness: 1),
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.upload_file_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pengeluaran",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Rp $totalExpense",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- DAFTAR TRANSAKSI ---
                Expanded(
                  child: listTransaction.isEmpty
                      ? Center(
                          child: Text(
                            "Belum ada data di database",
                            style: GoogleFonts.montserrat(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: listTransaction.length,
                          itemBuilder: (context, index) {
                            final item = listTransaction[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Card(
                                child: ListTile(
                                  leading: Icon(
                                    item.category.type == 2
                                        ? Icons.upload_rounded
                                        : Icons.download_rounded,
                                    color: item.category.type == 2
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  title: Text(
                                    "Rp ${item.transaction.amount}",
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${item.category.name} (${item.transaction.name})",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("Error memuat data"));
          }
        },
      ),
    );
  }
}
