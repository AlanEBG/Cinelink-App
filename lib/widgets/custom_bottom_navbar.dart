import 'package:flutter/material.dart';
import 'package:cinelink_app/app/theme.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.movie_outlined,
                activeIcon: Icons.movie,
                label: 'Películas',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number,
                label: 'Boletos',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Perfil',
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.menu,
                activeIcon: Icons.menu_open,
                label: 'Más',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono con animación
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? AppColors.primary : AppColors.grey500,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
