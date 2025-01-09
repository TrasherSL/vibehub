import 'dart:async';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';

class ConnectivityService {
  final _connectionStatusController = StreamController<DataConnectionStatus>.broadcast();
  late StreamSubscription<DataConnectionStatus> _connectionSubscription;

  ConnectivityService() {
    _connectionSubscription = DataConnectionChecker().onStatusChange.listen((status) {
      _connectionStatusController.add(status);
    });
  }

  Stream<DataConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  Future<bool> get hasConnection async => await DataConnectionChecker().hasConnection;

  void dispose() {
    _connectionSubscription.cancel();
    _connectionStatusController.close();
  }
}

final connectivityService = ConnectivityService();
