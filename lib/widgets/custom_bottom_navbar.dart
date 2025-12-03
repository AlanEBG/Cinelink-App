import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
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
    );
  }
}