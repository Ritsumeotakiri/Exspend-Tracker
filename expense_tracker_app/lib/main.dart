import 'package:expense_tracker_app/test/testScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_app/provider/exspense_provider.dart';
import 'package:expense_tracker_app/screens/login_screen.dart';
import 'package:expense_tracker_app/screens/signUp_screen.dart';
import 'package:expense_tracker_app/screens/home_screen.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ExpenseProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B2956),
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/testing': (_) => const TestScreen(),
        },
      ),
    );
  }
}
