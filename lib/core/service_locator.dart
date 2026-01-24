import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drawo_app/core/storage.dart';
import 'package:drawo_app/core/languages/bloc/languages_bloc.dart';
import 'package:drawo_app/data/services/auth_service.dart';
import 'package:drawo_app/data/services/gallery_service.dart';
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/gallery/bloc/gallery_bloc.dart';
import 'package:drawo_app/presentation/drawing/bloc/drawing_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void call() {
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<LanguageBloc>(
    () => LanguageBloc(storageService: sl()),
  );

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  sl.registerLazySingleton<AuthService>(() => AuthService(auth: sl()));
  sl.registerLazySingleton<GalleryService>(
    () => GalleryService(firestore: sl(), storage: sl(), auth: sl()),
  );

  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
  sl.registerFactory<GalleryBloc>(() => GalleryBloc(imageRepository: sl()));
  sl.registerFactory<DrawingBloc>(() => DrawingBloc(imageRepository: sl()));
}
