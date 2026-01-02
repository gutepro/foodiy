import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({
    super.key,
    required this.label,
    required this.logTag,
  });

  final String label;
  final String logTag;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('[$logTag] rendering placeholder');
    }
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
    );
  }
}
