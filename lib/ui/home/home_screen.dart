import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text('Giỏ hàng')),
    const Center(child: Text('Tin nhắn')),
    const Center(child: Text('Cá nhân'))
  ]
}