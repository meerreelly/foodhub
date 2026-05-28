import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../meals/domain/meal.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({required this.meal, super.key});

  final MealSummary meal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(18);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: .78),
        ),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.recipe(meal.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'meal-${meal.id}',
                child: CachedNetworkImage(
                  imageUrl: meal.thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const ColoredBox(color: Colors.black12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
