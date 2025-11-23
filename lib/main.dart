import 'package:flutter/material.dart';
import 'package:utspam_c3_if5a_0018/screens/register_screen.dart';
import 'package:utspam_c3_if5a_0018/screens/rental_form_screen.dart';
import 'package:utspam_c3_if5a_0018/theme/app_theme.dart';
import 'package:utspam_c3_if5a_0018/screens/login_screen.dart';
import 'package:utspam_c3_if5a_0018/screens/home_screen.dart'; 
import 'package:utspam_c3_if5a_0018/screens/car_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'utspam_c3_if5a_0018',
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/car-list': (context) => CarListScreen(),
        '/rental-form': (context) => RentalFormScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}