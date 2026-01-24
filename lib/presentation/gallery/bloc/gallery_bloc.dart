import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:drawo_app/data/models/drawing_model.dart';
import 'package:drawo_app/data/services/gallery_service.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryService _imageRepository;
  StreamSubscription? _imagesSubscription;

  GalleryBloc({required GalleryService imageRepository})
    : _imageRepository = imageRepository,
      super(const GalleryState()) {
    on<LoadGallery>(_onLoadGallery);
    on<GalleryUpdated>(_onGalleryUpdated);
    on<DeleteImage>(_onDeleteImage);
  }

  // Subscribe to images from Firestore
  void _onLoadGallery(LoadGallery event, Emitter<GalleryState> emit) {
    emit(state.copyWith(status: GalleryStatus.loading));
    _imagesSubscription?.cancel();
    _imagesSubscription = _imageRepository.imagesStream().listen(
      (images) => add(GalleryUpdated(images)),
      onError: (e) => emit(
        state.copyWith(status: GalleryStatus.error, errorMessage: e.toString()),
      ),
    );
  }

  // Update state when images change
  void _onGalleryUpdated(GalleryUpdated event, Emitter<GalleryState> emit) {
    emit(state.copyWith(status: GalleryStatus.loaded, images: event.images));
  }

  // Delete drawing from DB and storage
  Future<void> _onDeleteImage(
    DeleteImage event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      await _imageRepository.deleteImage(
        event.image.id,
        event.image.storagePath,
      );
    } catch (e) {
      emit(
        state.copyWith(status: GalleryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _imagesSubscription?.cancel();
    return super.close();
  }
}
