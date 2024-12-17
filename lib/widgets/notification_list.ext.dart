part of 'notification_list.dart';

class PagingListController extends GetxController {
  final String notiType;
  var pageSize = 20.obs;
  late final RxList<dynamic> itemList;
  final PagingController<int, dynamic> _pagingCtl =
      PagingController(firstPageKey: 0);
  final NotificationController _notiCtl = Get.find();

  PagingListController(this.notiType);

  @override
  void onInit() {
    super.onInit();

    itemList = _notiCtl.getNotificationList(notiType);

    // When new notification is added to the list, show it in the screen
    ever(itemList, (_) {
      _fetchPage(_pagingCtl.nextPageKey ?? 0);
    });

    _pagingCtl.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      print('fetch');
      final startIndex = _pagingCtl.itemList?.length ?? 0;
      final endIndex = startIndex + pageSize.value;

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

  @override
  void dispose() {
    _pagingCtl.dispose();
    super.dispose();
  }
}
