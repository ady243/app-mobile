import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastComponent {
  static void showToast(
      BuildContext context, String message, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(type == ToastificationType.success
          ? "Reussi"
          : "Erreur lors de la connexion"),
      description: RichText(text: TextSpan(text: message)),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 200),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon:
          Icon(type == ToastificationType.success ? Icons.check : Icons.error),
      showIcon: true,
      backgroundColor:
          type == ToastificationType.success ? Colors.green : Colors.red,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Toast ${toastItem.id} tapped',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onCloseButtonTap: (toastItem) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Toast ${toastItem.id} closed by tapping the close button'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onAutoCompleteCompleted: (toastItem) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Auto complete completed',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onDismissed: (toastItem) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Toast ${toastItem.id} dismissed',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
