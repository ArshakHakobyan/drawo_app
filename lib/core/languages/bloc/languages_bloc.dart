import 'dart:ui';
import 'package:drawo_app/core/storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'languages_event.dart';
part 'languages_state.dart';

class LanguageBloc extends Bloc<LanguagesEvent, LanguagesState> {
  LanguageBloc({required StorageService storageService})
    : super(const LanguagesState(locale: Locale('ru'))) {
    _loadLocale(storageService);

    // Save and apply new language
    on<ChangeLanguage>((event, emit) async {
      await storageService.saveLocale(locale: event.locale.languageCode);
      emit(state.copyWith(locale: event.locale));
    });
  }

  // Initial load of saved language
  Future<void> _loadLocale(StorageService storageService) async {
    String? localeString = await storageService.getLocale();
    if (localeString != null) {
      add(ChangeLanguage(locale: Locale(localeString)));
    } else {
      // Use Russian as default
      add(const ChangeLanguage(locale: Locale('ru')));
    }
  }
}
