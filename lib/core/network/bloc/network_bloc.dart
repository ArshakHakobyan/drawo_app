import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:equatable/equatable.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final InternetConnection _internetConnection = InternetConnection();
  StreamSubscription? _subscription;

  NetworkBloc() : super(const NetworkState()) {
    on<NetworkObserve>(_onObserve);
    on<NetworkNotify>(_onNotify);
  }

  // Monitor network changes and check initial connectivity status
  void _onObserve(NetworkObserve event, Emitter<NetworkState> emit) async {
    _subscription?.cancel();

    // Check initial connectivity
    final isInitialConnected = await _internetConnection.hasInternetAccess;
    add(NetworkNotify(isConnected: isInitialConnected));

    _subscription = _internetConnection.onStatusChange.listen((status) {
      final isConnected = status == InternetStatus.connected;
      add(NetworkNotify(isConnected: isConnected));
    });
  }

  // Update state with the results of network monitoring
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
