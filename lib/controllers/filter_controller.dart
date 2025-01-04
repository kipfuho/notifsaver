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

  DateTime? getStartDate() {
    var startDate = searchParams['startDate'];
    return startDate;
  }

  DateTime? getEndDate() {
    var endDate = searchParams['endDate'];
    return endDate;
  }

  void setSearchParams(
      {String? searchText,
      List<String>? selectedApps,
      DateTime? startDate,
      DateTime? endDate}) {
    if (searchText!.isNotEmpty) {
      searchParams['searchText'] = searchText.toLowerCase();
    }
    if (selectedApps!.isNotEmpty) {
      searchParams['searchApps'] = selectedApps;
    }
    if (startDate != null) {
      searchParams['startDate'] = startDate;
    }
    if (endDate != null) {
      searchParams['endDate'] = endDate;
    }
    isSearching.value = true;
  }

  void clearSearch() {
    searchParams.clear();
    isSearching.value = false;
  }
}
