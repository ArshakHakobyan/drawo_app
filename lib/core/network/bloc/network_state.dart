part of 'network_bloc.dart';

enum NetworkStatus { initial, connected, disconnected }

class NetworkState extends Equatable {
  final NetworkStatus status;

  const NetworkState({this.status = NetworkStatus.initial});

  @override
  List<Object> get props => [status];

  NetworkState copyWith({NetworkStatus? status}) {
    return NetworkState(status: status ?? this.status);
  }
}
