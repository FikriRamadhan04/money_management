import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_management/pages/home_page.dart';
import 'package:money_management/pages/category_page.dart';
import 'package:money_management/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      currentIndex = index;
      if (date != null) {
        selectedDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      HomePage(selectedDate: selectedDate),
      const CategoryPage(),
    ];

    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.purple,
              backButton: false,
              locale: 'id',
              onDateChanged: (value) {
                updateView(0, value);
              },
              firstDate: DateTime.now().subtract(const Duration(days: 140)),
              lastDate: DateTime.now(),
              selectedDate: selectedDate,
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.purple,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20, bottom: 15),
                child: SafeArea(
                  child: Text(
                    'Kategori',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
      body: children[currentIndex],
      floatingActionButton: Visibility(
        visible: (currentIndex == 0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionPage(),
                  ),
                )
                .then((value) {
                  setState(() {});
                });
          },
          backgroundColor: Colors.purple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                updateView(0, selectedDate);
              },
              icon: const Icon(Icons.home),
              color: currentIndex == 0 ? Colors.purple : Colors.grey,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {
                updateView(1, null);
              },
              icon: const Icon(Icons.list),
              color: currentIndex == 1 ? Colors.purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
