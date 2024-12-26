import 'package:flutter/material.dart';

class CreateMatchPageContent extends StatelessWidget {
  final void Function(BuildContext) openBottomSheet;

  const CreateMatchPageContent({
    Key? key,
    required this.openBottomSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FloatingActionButton(
        onPressed: () {
          openBottomSheet(context);
        },
        backgroundColor: const Color(0xFF01BF6B),
        tooltip: 'Créer un match',
        child: const Icon(Icons.add),
      ),
    );
  }
}