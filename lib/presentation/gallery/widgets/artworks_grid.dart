import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/core/routes/app_router.dart';

class ArtworksGrid extends StatelessWidget {
  const ArtworksGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Defines grid layout constants
    const double cardRadius = 22.0;

    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state.status == GalleryStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Palette.primary),
          );
        }

        final artworks = state.images;

        if (artworks.isEmpty) {
          return Center(
            child: Text(
              'No artworks yet', // TODO: Add to localization
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Palette.whiter.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.0, // Square cards look professional
          ),
          itemCount: artworks.length,
          itemBuilder: (ctx, i) {
            final artwork = artworks[i];
            return ArtworkCard(
              imageUrl: artwork.url,
              radius: cardRadius,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.painter, arguments: artwork);
              },
            );
          },
        );
      },
    );
  }
}

class ArtworkCard extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final VoidCallback onTap;

  const ArtworkCard({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Palette.darkGrey, // Placeholder BG while loading
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Palette.white.withValues(alpha: 0.2),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) {
              return const Center(
                child: Icon(Icons.broken_image, color: Palette.grey),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Palette.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
