import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prj3/utils/hot_message.dart';

class NetworkController extends GetxController {
  var hasNetworkAccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    monitorNetworkChanges();
  }

  void monitorNetworkChanges() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> newConnections) {
      _handleConnectivityChange(newConnections);
    });
  }

  Future<void> _handleConnectivityChange(
      List<ConnectivityResult> result) async {
    hasNetworkAccess.value = await hasInternetAccess();
  }

  Future<bool> hasInternetAccess() async {
    try {
      final response =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
              );
      return response.statusCode == 200;
    } catch (err) {
      HotMessage.showError(Intl.message('no_internet', name: 'no_internet'));
      return false;
    }
  }
}
