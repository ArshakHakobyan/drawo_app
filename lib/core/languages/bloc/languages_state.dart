part of 'languages_bloc.dart';

class LanguagesState extends Equatable {
  final Locale locale;
  

  const LanguagesState({
    required this.locale,

  });

  LanguagesState copyWith({
   Locale? locale,

  }) {
    return LanguagesState(
        locale: locale ?? this.locale,
   );
  }

  @override
  List<Object?> get props => [
        locale,
       
      ];
}
