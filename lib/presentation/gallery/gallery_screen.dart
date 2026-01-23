import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/routes/app_router.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:drawo_app/presentation/gallery/widgets/main_background.dart';
import 'package:drawo_app/presentation/gallery/widgets/artworks_grid.dart';
import 'package:drawo_app/presentation/gallery/widgets/dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/core/languages/app_localizations.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          service_locator.sl<GalleryBloc>()..add(LoadGallery()),
      child: const _GalleryDashboardLayout(),
    );
  }
}

class _GalleryDashboardLayout extends StatelessWidget {
  const _GalleryDashboardLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            top: false,
            child: Column(
              children: [
                const DashboardHeader(),
                const Expanded(child: ArtworksGrid()),

                // Prominent Create Action for Empty State
                BlocBuilder<GalleryBloc, GalleryState>(
                  builder: (context, state) {
                    final shouldShowBigCta =
                        state.status != GalleryStatus.loading &&
                        state.images.isEmpty;

                    if (shouldShowBigCta) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Palette.primary, Palette.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.painter);
                            },
                            icon: Image.asset(
                              MediaAssets.addIcon,
                              width: 20,
                              height: 20,
                              color: Palette.white,
                            ),
                            label: Text(
                              l10n.create,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Palette.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
