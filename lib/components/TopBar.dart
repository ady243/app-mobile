import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const TopBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(0), // Onglet Infos
            child: Container(
              color: currentIndex == 0 ? const Color(0xFF01BF6B) : Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Infos',
                style: TextStyle(
                  color: currentIndex == 0 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(1), // Onglet Chat
            child: Container(
              color: currentIndex == 1 ? const Color(0xFF01BF6B) : Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Messages',
                style: TextStyle(
                  color: currentIndex == 1 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}