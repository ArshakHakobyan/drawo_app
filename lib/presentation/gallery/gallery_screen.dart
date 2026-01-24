import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/routes/app_router.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:drawo_app/presentation/gallery/widgets/main_background.dart';
import 'package:drawo_app/presentation/gallery/widgets/artworks_grid.dart';
import 'package:drawo_app/presentation/gallery/widgets/dashboard_header.dart';
import 'package:drawo_app/presentation/common/components/accent_button.dart';
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
                        padding: const EdgeInsets.only(bottom: 40),
                        child: AccentButton(
                          label: l10n.create,
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.painter);
                          },
                          radius: 8,
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
