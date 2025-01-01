import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:prj3/utils/hot_message.dart';

class ListController extends GetxController {
  var list = <Map<String, String>>[];

  @override
  void onInit() {
    super.onInit();
    // Populate the list with dummy data
    for (int i = 0; i < 1000; i++) {
      list.add({'name': 'Item $i'});
    }
  }

  void removeAt(index) {
    list.removeAt(index);
  }
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  PagingController<int, Map<String, String>>? _pagingController; // Nullable
  final ListController _listController = Get.put(ListController());
  final int pageSize = 20;

  @override
  void initState() {
    super.initState();

    // Safely initialize the PagingController
    _pagingController =
        PagingController<int, Map<String, String>>(firstPageKey: 0);
    _pagingController!.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final startIndex = _pagingController?.itemList?.length ?? 0;
      final endIndex = startIndex + pageSize;

      if (startIndex >= _listController.list.length) {
        _pagingController?.appendLastPage([]);
        return;
      }

      final newItems = _listController.list.sublist(
        startIndex,
        endIndex > _listController.list.length
            ? _listController.list.length
            : endIndex,
      );

      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        _pagingController?.appendLastPage(newItems);
      } else {
        _pagingController?.appendPage(newItems, pageKey + 1);
      }
    } catch (e) {
      HotMessage.showError(e.toString());
      _pagingController?.error = e;
    }
  }

  void removeItem(int index) {
    final currentItems = _pagingController?.itemList ?? [];

    if (index < currentItems.length) {
      // Create a new list without the item
      final updatedItems = List<Map<String, String>>.from(currentItems)
        ..removeAt(index);

      _listController.removeAt(index);

      // Update PagingController's state manually
      _pagingController?.value = PagingState<int, Map<String, String>>(
        itemList: updatedItems,
        nextPageKey: _pagingController?.nextPageKey,
        error: null,
      );
    }
  }

  @override
  void dispose() {
    _pagingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pagingController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paged List Example'),
      ),
      body: PagedListView<int, Map<String, String>>(
        pagingController: _pagingController!,
        builderDelegate: PagedChildBuilderDelegate<Map<String, String>>(
          itemBuilder: (context, item, index) {
            return ListTile(
              leading: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(item['name'] ?? ''),
              trailing: ElevatedButton(
                onPressed: () {
                  // Add your action here
                  removeItem(index);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'Click Me',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
