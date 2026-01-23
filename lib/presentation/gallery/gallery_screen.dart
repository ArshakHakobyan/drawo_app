import 'package:drawo_app/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/painter/painter_screen.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/core/languages/app_localizations.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          service_locator.sl<GalleryBloc>()..add(LoadGallery()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.gallery),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthSignOutRequested()),
            ),
          ],
        ),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            if (state.status == GalleryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.images.isEmpty) {
              return const Center(child: Text('No images yet. Start drawing!'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final imageDoc = state.images[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to painter with this image? Or just view?
                  },
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(imageDoc.title ?? 'Untitled'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => context.read<GalleryBloc>().add(
                          DeleteImage(imageDoc),
                        ),
                      ),
                    ),
                    child: Image.network(imageDoc.url, fit: BoxFit.cover),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.painter),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
