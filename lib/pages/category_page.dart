import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_management/models/database.dart';
import 'package:drift/drift.dart' as drift;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDatabase database = AppDatabase();
  final TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            type: type,
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
    setState(() {});
  }

  Future update(int id, String name) async {
    await (database.update(database.categories)..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(name: drift.Value(name)));
    setState(() {});
  }

  Future delete(int id) async {
    await (database.delete(
      database.categories,
    )..where((t) => t.id.equals(id))).go();
    setState(() {});
  }

  void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    } else {
      categoryNameController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category == null
                      ? (isExpense ? "Tambah Pengeluaran" : "Tambah Pemasukan")
                      : "Edit Kategori",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: (isExpense) ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Nama Kategori",
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (category == null) {
                        await insert(
                          categoryNameController.text,
                          isExpense ? 2 : 1,
                        );
                      } else {
                        await update(category.id, categoryNameController.text);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isExpense) ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Simpan"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          type = value ? 2 : 1;
                        });
                      },
                      thumbColor: WidgetStatePropertyAll<Color>(
                        isExpense ? Colors.red : Colors.green,
                      ),
                      trackColor: WidgetStatePropertyAll<Color>(
                        isExpense
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.shade200,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(isExpense ? "Pengeluaran" : "Pemasukan"),
                  ],
                ),

                IconButton(
                  onPressed: () => openDialog(null),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: database.getAllCategory(type),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              isExpense ? Icons.upload : Icons.download,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => delete(category.id),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    openDialog(snapshot.data![index]);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("Tidak ada data kategori"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
