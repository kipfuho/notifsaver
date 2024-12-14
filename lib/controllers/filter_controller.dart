import 'package:get/get.dart';

class FilterController extends GetxController {
  var searchParams = {}.obs; // Reactive variable to hold the user state
  var isSearching = false.obs;

  String getSearchText() {
    var searchText = searchParams['searchText'];
    if (searchText != null) {
      return searchText;
    }
    return '';
  }

  List<String> getSearchApps() {
    var appPackageNames = searchParams['searchApps'];
    if (appPackageNames != null) {
      return appPackageNames;
    }
    return [];
  }

  void setSearchText(String searchText) {
    searchParams['searchText'] = searchText.toLowerCase();
    isSearching.value = true;
  }

  void setSearchApps(List<String> appPackageNames) {
    searchParams['searchApps'] = appPackageNames;
    isSearching.value = true;
  }

  void clearSearch() {
    searchParams.clear();
    isSearching.value = false;
  }
}
