import 'package:flutter/material.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String rol;

  const CurvedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      const _NavItem(
        index: 0,
        icon: Icons.home_rounded,
        label: 'Inicio',
      ),
      const _NavItem(
        index: 1,
        icon: Icons.calendar_month_rounded,
        label: 'Agenda',
      ),
      _NavItem(
        index: 2,
        icon: rol == 'entrenador' ? Icons.place_rounded : Icons.add_rounded,
        label: rol == 'entrenador' ? 'Espacios' : 'Inscribir',
      ),
      const _NavItem(
        index: 3,
        icon: Icons.notifications_rounded,
        label: 'Alertas',
      ),
      const _NavItem(
        index: 4,
        icon: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2340), Color(0xFF141C34)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: const Color(0xFF2C3C63), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: items
                .map((item) => Expanded(child: _buildNavItem(item)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item) {
    final isSelected = currentIndex == item.index;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => onTap(item.index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 4 : 0,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0x332F80ED), Color(0x224CC9A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 240),
                scale: isSelected ? 1.04 : 1,
                curve: Curves.easeOutBack,
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? const Color(0xFF69A8FF)
                      : const Color(0xFF7F8FB3),
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF67789E),
                  fontSize: isSelected ? 9.5 : 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final int index;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
  });
}
