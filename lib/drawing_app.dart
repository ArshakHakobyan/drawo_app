import 'package:drawo_app/core/routes/app_router.dart';
import 'package:drawo_app/core/style/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/core/languages/bloc/languages_bloc.dart';
import 'package:drawo_app/core/network/bloc/network_bloc.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/auth/login_screen.dart';
import 'package:drawo_app/presentation/gallery/gallery_screen.dart';

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => service_locator.sl<LanguageBloc>()),
        BlocProvider(
          create: (context) =>
              service_locator.sl<NetworkBloc>()..add(NetworkObserve()),
        ),
        BlocProvider(
          create: (context) =>
              service_locator.sl<AuthBloc>()..add(AuthStarted()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguagesState>(
        builder: (context, langState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Drawing App',
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,
            supportedLocales: AppLocalizations.supportedLanguages,
            locale: langState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  BlocBuilder<NetworkBloc, NetworkState>(
                    builder: (context, state) {
                      if (state.status == NetworkStatus.disconnected) {
                        return Positioned(
                          top: MediaQuery.of(context).padding.top,
                          left: 0,
                          right: 0,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              color: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wifi_off, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'No Internet Connection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState.status == AuthStatus.authenticated) {
                  return const GalleryScreen();
                } else if (authState.status == AuthStatus.initial) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
