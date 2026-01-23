import 'package:drawo_app/data/models/drawing_model.dart';
import 'package:flutter/material.dart';
import 'package:drawo_app/presentation/auth/auth_screen.dart';
import 'package:drawo_app/presentation/gallery/gallery_screen.dart';
import 'package:drawo_app/presentation/painter/painter_screen.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String gallery = '/';
  static const String painter = '/painter';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case painter:
        final artwork = settings.arguments as DrawingModel?;
        return MaterialPageRoute(
          builder: (_) => PainterScreen(drawing: artwork),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
