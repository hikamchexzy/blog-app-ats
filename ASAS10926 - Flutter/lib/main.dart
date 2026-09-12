import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PostListScreen(),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 420,
            child: child!,
          ),
        );
      },
    );
  }
}