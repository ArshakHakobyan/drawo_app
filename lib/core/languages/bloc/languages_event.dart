part of 'languages_bloc.dart';

abstract class LanguagesEvent extends Equatable {
  const LanguagesEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguagesEvent {
  final Locale locale;
  const ChangeLanguage({required this.locale});
}
