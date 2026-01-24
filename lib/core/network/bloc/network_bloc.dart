import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkBloc() : super(const NetworkState()) {
    on<NetworkObserve>(_onObserve);
    on<NetworkNotify>(_onNotify);
  }

  void _onObserve(NetworkObserve event, Emitter<NetworkState> emit) async {
    _subscription?.cancel();

    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    final isInitialConnected = results.any(
      (result) => result != ConnectivityResult.none,
    );
    add(NetworkNotify(isConnected: isInitialConnected));

    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isConnected = results.any(
        (result) => result != ConnectivityResult.none,
      );
      add(NetworkNotify(isConnected: isConnected));
    });
  }

  void _onNotify(NetworkNotify event, Emitter<NetworkState> emit) {
    emit(
      state.copyWith(
        status: event.isConnected
            ? NetworkStatus.connected
            : NetworkStatus.disconnected,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
