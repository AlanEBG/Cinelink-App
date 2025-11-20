import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const AppLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Solo muestra un snackbar, NO navega
    String section = '';
    switch (index) {
      case 0:
        section = 'Películas';
        break;
      case 1:
        section = 'Boletos';
        break;
      case 2:
        section = 'Perfil';
        break;
      case 3:
        section = 'Más';
        break;
    }

    if (index != widget.currentIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$section - En construcción'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Películas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Boletos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            activeIcon: Icon(Icons.menu_open),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}