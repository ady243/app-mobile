import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasNewMessages;

  const TopBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.hasNewMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(0),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Infos',
                    style: TextStyle(
                      color: currentIndex == 0 ? const Color(0xFF01BF6B) : const Color(0xFF01BF6B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (currentIndex == 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: const Color(0xFF01BF6B),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(1),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: currentIndex == 1 ? const Color(0xFF01BF6B) : const Color(0xFF01BF6B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (currentIndex == 1)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: const Color(0xFF01BF6B),
                    ),
                  ),
                if (hasNewMessages)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}