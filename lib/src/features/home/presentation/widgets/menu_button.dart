import 'package:flutter/material.dart';

/// A reusable menu button for the [HomePage].
///
/// When [isEnabled] is false the button is rendered in a disabled
/// state and [onPressed] will never be invoked, signalling to the
/// user that the feature is not yet available.
class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: FilledButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: Theme.of(context).textTheme.titleMedium,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
