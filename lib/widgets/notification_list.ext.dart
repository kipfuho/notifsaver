part of 'notification_list.dart';

class PagingListController extends GetxController {
  final String notiType;
  var pageSize = 20.obs;
  Rx<DateTime> currentDate = (DateTime.now()).obs;
  late final RxList<dynamic> itemList;
  final RxInt currentListSize = 0.obs;
  final PagingController<int, dynamic> _pagingCtl =
      PagingController(firstPageKey: 0);
  final NotificationController _notiCtl = Get.find();
  final FilterController _filterCtl = Get.find();

  PagingListController(this.notiType);

  @override
  void onInit() {
    super.onInit();

    itemList = _notiCtl.getNotificationList(notiType);
    currentListSize.value = itemList.length;

    ever(itemList, (newList) {
      if (_notiCtl.isLoading.value) {
        return;
      }
      if (newList.length > currentListSize.value &&
          (_pagingCtl.itemList?.length ?? 0) + pageSize.value >
              newList.length) {
        _fetchPage(_pagingCtl.nextPageKey ?? 0);
        return;
      }

      if (newList.length < currentListSize.value) {
        // Update PagingController's state manually
        _pagingCtl.value = PagingState<int, Map<String, dynamic>>(
          itemList: List<Map<String, dynamic>>.from(newList),
          nextPageKey: _pagingCtl.nextPageKey,
          error: null,
        );
      }
    });

    _pagingCtl.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<bool> _fetchAnotherBox() async {
    currentDate.value = DateTime(
      currentDate.value.year,
      currentDate.value.month - 1, // Move to the previous month
      currentDate.value.day,
    );
    var result = await _notiCtl.getPastNotificationList(
      notiType,
      currentDate.value,
      searchApps: _filterCtl.searchParams['searchApps'],
      searchText: _filterCtl.searchParams['searchText'],
    );
    itemList.addAll(result['list']);
    currentListSize.value = itemList.length;
    return result['shouldContinue'];
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final startIndex = _pagingCtl.itemList?.length ?? 0;
      final endIndex = startIndex + pageSize.value;

      if (startIndex >= itemList.length) {
        while (startIndex >= itemList.length) {
          // Try fetch from past box
          var shouldContinue = await _fetchAnotherBox();
          if (!shouldContinue) break;
        }
      }

      if (startIndex >= itemList.length) {
        _pagingCtl.appendLastPage([]);
        return;
      }

      final newItems = itemList.sublist(
        startIndex,
        endIndex > itemList.length ? itemList.length : endIndex,
      );

      final isLastPage = newItems.length < pageSize.value;
      if (isLastPage) {
        _pagingCtl.appendLastPage(newItems);
      } else {
        _pagingCtl.appendPage(newItems, pageKey + 1);
      }
    } catch (e) {
      _pagingCtl.error = e;
    }
  }

  void removeItem(int index) {
    final currentItems = _pagingCtl.itemList ?? [];

    if (index < currentItems.length) {
      // Create a new list without the item
      final updatedItems = List<Map<String, dynamic>>.from(currentItems)
        ..removeAt(index);

      // Update PagingController's state manually
      _pagingCtl.value = PagingState<int, Map<String, dynamic>>(
        itemList: updatedItems,
        nextPageKey: _pagingCtl.nextPageKey,
        error: null,
      );
    }
  }

  void refreshList() {
    _pagingCtl.refresh();
  }

  @override
  void dispose() {
    _pagingCtl.dispose();
    super.dispose();
  }
}
