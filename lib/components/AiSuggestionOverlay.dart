import 'package:flutter/material.dart';

class AiSuggestionOverlay extends StatelessWidget {
  final String aiResponse;
  final VoidCallback onClose;
  final Animation<Offset> offsetAnimation;

  const AiSuggestionOverlay({
    super.key,
    required this.aiResponse,
    required this.onClose,
    required this.offsetAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offsetAnimation,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggestion formation de teamUp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  aiResponse,
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}