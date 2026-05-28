import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.clipBehavior = Clip.none,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return liquid.GlassCard(
      padding: padding,
      shape: liquid.LiquidRoundedSuperellipse(borderRadius: radius),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
