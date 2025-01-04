import 'package:get/get.dart';

class FilterController extends GetxController {
  final searchParams = {}.obs; // Reactive finaliable to hold the user state
  final isSearching = false.obs;

  String getSearchText() {
    final searchText = searchParams['searchText'];
    if (searchText != null) {
      return searchText;
    }
    return '';
  }

  List<String> getSearchApps() {
    final appPackageNames = searchParams['searchApps'];
    if (appPackageNames != null) {
      return appPackageNames;
    }
    return [];
  }

  DateTime? getStartDate() {
    final startDate = searchParams['startDate'];
    return startDate;
  }

  DateTime? getEndDate() {
    final endDate = searchParams['endDate'];
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
