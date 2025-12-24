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
  final List<Widget> _children = [HomePage(), CategoryPage()];
  int currentIndex = 0;

  void onTapTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... kode lainnya tetap sama
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.purple,
              backButton: false,
              locale: 'id',
              onDateChanged: (value) => print(value),
              firstDate: DateTime.now().subtract(const Duration(days: 140)),
              lastDate: DateTime.now(),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(
                60,
              ), // Ukuran standar AppBar yang pas
              child: Container(
                color: Colors.purple, // Memberikan background ungu penuh
                alignment:
                    Alignment.bottomLeft, // Mengatur posisi teks di kiri bawah
                padding: const EdgeInsets.only(
                  left: 20,
                  bottom: 15,
                ), // Jarak teks dari pinggir
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

      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(builder: (context) => TransactionPage()),
                )
                .then((value) {
                  setState(() {});
                });
          },
          backgroundColor: Colors.purple,
          child: const Icon(Icons.add),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                onTapTapped(0);
              },
              icon: const Icon(Icons.home),
            ),
            SizedBox(width: 20),
            IconButton(
              onPressed: () {
                onTapTapped(1);
              },
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
