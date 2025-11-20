import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

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
    return BubbleBottomBar(
      opacity: 0.2,
      currentIndex: currentIndex,
      onTap: (index) => onTap(index ?? 0),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      hasNotch: false,
      hasInk: true,
      inkColor: Colors.black12,
      items: [
        BubbleBottomBarItem(
          backgroundColor: Colors.purple,
          icon: const Icon(
            Icons.movie_outlined,
            color: Colors.black,
          ),
          activeIcon: const Icon(
            Icons.movie,
            color: Colors.purple,
          ),
          title: const Text('Películas'),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.orange,
          icon: const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.black,
          ),
          activeIcon: const Icon(
            Icons.confirmation_number,
            color: Colors.orange,
          ),
          title: const Text('Boletos'),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.blue,
          icon: const Icon(
            Icons.person_outline,
            color: Colors.black,
          ),
          activeIcon: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
          title: const Text('Perfil'),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.green,
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          activeIcon: const Icon(
            Icons.menu_open,
            color: Colors.green,
          ),
          title: const Text('Más'),
        ),
      ],
    );
  }
}