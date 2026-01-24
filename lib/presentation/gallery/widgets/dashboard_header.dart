import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/routes/app_router.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:drawo_app/presentation/common/components/common_header.dart';
import 'package:drawo_app/presentation/common/components/header_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        final hasImages = state.images.isNotEmpty;

        return CommonHeader(
          title: l10n.gallery,
          leading: HeaderIconButton(
            asset: MediaAssets.exitIcon,
            color: Palette.red,
            onTap: () async {
              final confirm = await _showExitConfirmation(context);
              if (confirm && context.mounted) {
                context.read<AuthBloc>().add(AuthSignOutRequested());
              }
            },
          ),
          actions: [
            if (hasImages)
              HeaderIconButton(
                asset: MediaAssets.addIcon,
                color: Palette.whiter,
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.painter);
                },
              )
            else
              const SizedBox(width: 44),
          ],
        );
      },
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              l10n.areyousureexit,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Palette.whiter,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  l10n.yes,
                  style: const TextStyle(color: Palette.red, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: Palette.whiter, fontSize: 16),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
