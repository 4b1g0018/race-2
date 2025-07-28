// App 的主入口點、主題設定、以及導覽列框架。

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import './services/database_helper.dart';
import './pages/login_page.dart';

import './pages/dashboard_home_page.dart';
import './pages/select_part_page.dart';
import './pages/workout_history_page.dart';
import './pages/settings_page.dart';
import './services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await NotificationService.instance.init();
  await initializeDateFormatting();
  await DatabaseHelper.instance.initDB();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A84FF);

    return MaterialApp(
      title: '智慧健身 App',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PingFang TC',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), 

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, 
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E),
          primary: primaryColor,
        ),

        // 【修正】換回新的 WidgetStateProperty API
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            // 【修正】換回新的 WidgetState API
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF00B900);
            }
            return Colors.grey.shade600;
          }),
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),

        // 【修正】CardTheme -> CardThemeData
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFF2C2C2E), 
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor, 
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'PingFang TC',
            )
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          floatingLabelStyle: const TextStyle(
            color: primaryColor,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1C1C1E),
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
        ),
      ),

      home: const LoginPage(),
    );
  }
}


// 【新增】我們之前建立的 MainAppShell 導覽列框架，原封不動加到這裡
class MainAppShell extends StatefulWidget {
  final String account;
  const MainAppShell({super.key, required this.account});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
  DashboardHomePage(account: widget.account),
  const SelectPartPage(),
  WorkoutHistoryPage(account: widget.account),
  SettingsPage(account: widget.account),
];

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: '首頁',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.fitness_center_outlined),
    activeIcon: Icon(Icons.fitness_center),
    label: '開始訓練',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.calendar_today_outlined),
    activeIcon: Icon(Icons.calendar_today),
    label: '日曆',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    activeIcon: Icon(Icons.settings),
    label: '設定',
  ),
],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}