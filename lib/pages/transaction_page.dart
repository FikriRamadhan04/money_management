import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_management/models/database.dart';
import 'package:drift/drift.dart' as drift;

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // Menggunakan instance Singleton dari AppDatabase
  final AppDatabase database = AppDatabase();
  bool isExpense = true;

  Category? selectedCategory;

  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  Future insert(
    int amount,
    DateTime date,
    String nameDetail,
    int categoryID,
  ) async {
    DateTime now = DateTime.now();
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            name: nameDetail,
            categoryId: categoryID,
            amount: amount,
            date: date,
            createdAt: drift.Value(now),
          ),
        );
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategory(type);
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Tambahkan Transaksi",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Switch Toggle (Income/Expense)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpense
                              ? Icons.upload_rounded
                              : Icons.download_rounded,
                          color: isExpense ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isExpense ? 'Pengeluaran' : 'Pendapatan',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          selectedCategory = null;
                        });
                      },
                      activeColor: Colors.red,
                      inactiveThumbColor: Colors.green,
                    ),
                  ],
                ),
              ),

              // 2. Input Nominal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    labelText: "Nominal",
                    prefixText: "Rp ",
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 3. Dropdown Kategori
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kategori',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FutureBuilder<List<Category>>(
                future: getAllCategory(isExpense ? 2 : 1),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      selectedCategory ??= snapshot.data!.first;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<Category>(
                          value: (snapshot.data!.contains(selectedCategory))
                              ? selectedCategory
                              : snapshot.data!.first,
                          isExpanded: true,
                          items: snapshot.data!.map((Category item) {
                            return DropdownMenuItem<Category>(
                              value: item,
                              child: Text(item.name),
                            );
                          }).toList(),
                          onChanged: (Category? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Kategori belum dibuat. Buat di menu Kategori.",
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 25),

              // 4. Input Tanggal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: dateController,
                  readOnly: true,
                  style: GoogleFonts.montserrat(),
                  decoration: const InputDecoration(
                    labelText: "Tanggal",
                    hintText: "Pilih Tanggal",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2099),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                      setState(() {
                        dateController.text = formattedDate;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 25),

              // 5. Deskripsi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: detailController,
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.montserrat(),
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    hintText: "Contoh: Beli nasi goreng",
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 6. Tombol Simpan
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validasi input sebelum simpan
                      if (amountController.text.isEmpty ||
                          dateController.text.isEmpty ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Harap isi nominal, tanggal, dan kategori!",
                            ),
                          ),
                        );
                        return;
                      }

                      // Memanggil fungsi insert
                      await insert(
                        int.parse(amountController.text),
                        DateTime.parse(dateController.text),
                        detailController.text,
                        selectedCategory!.id,
                      );

                      // Kembali ke halaman utama
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
