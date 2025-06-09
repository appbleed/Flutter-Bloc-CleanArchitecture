import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

class CommonPagingController<T> implements Disposable {
  CommonPagingController({
    this.invisibleItemsThreshold =
        PagingConstants.defaultInvisibleItemsThreshold,
    this.firstPageKey = PagingConstants.initialPage,
  });

  late final PagingController<int, T> pagingController;

  final int? invisibleItemsThreshold;
  final int firstPageKey;

  // call when error
  set error(AppException? appException) {
    // In the new API, we need to handle errors through the state
    final currentState = pagingController.value;
    final newState = currentState.copyWith(
      error: appException,
      isLoading: false,
    );
    pagingController.value = newState;
  }

  // call when initState to listen to trigger load more
  void listen({
    required VoidCallback onLoadMore,
  }) {
    // Initialize the PagingController with the actual onLoadMore callback
    pagingController = PagingController<int, T>(
      getNextPageKey: (state) => (state.keys?.last ?? firstPageKey - 1) + 1,
      fetchPage: (pageKey) async {
        if (pageKey > firstPageKey) {
          onLoadMore();
        }
        // Return empty list as actual data will be provided through appendLoadMoreOutput
        return [];
      },
    );
  }

  // call append data when load first page / more page success
  void appendLoadMoreOutput(LoadMoreOutput<T> loadMoreOutput) {
    // In the new API, we need to convert LoadMoreOutput to PagingState
    final currentState = pagingController.value;

    final newKeys = loadMoreOutput.isRefreshSuccess
        ? [firstPageKey]
        : [...?currentState.keys, loadMoreOutput.page];

    final newState = currentState.copyWith(
      pages: loadMoreOutput.isRefreshSuccess
          ? [loadMoreOutput.data]
          : [...?currentState.pages, loadMoreOutput.data],
      keys: newKeys,
      hasNextPage: !loadMoreOutput.isLastPage,
      isLoading: false,
      error: null,
    );

    pagingController.value = newState;
  }

  void insertItemAt(int index, T item) {
    final currentState = pagingController.value;
    final allItems = currentState.pages?.expand((page) => page).toList() ?? [];
    if (index < allItems.length) {
      allItems.insert(index, item);
      // Rebuild pages from allItems - this is a simplified approach
      final newState = currentState.copyWith(
        pages: [allItems],
        keys: [firstPageKey],
      );
      pagingController.value = newState;
    }
  }

  void insertAllItemsAt(int index, Iterable<T> items) {
    final currentState = pagingController.value;
    final allItems = currentState.pages?.expand((page) => page).toList() ?? [];
    if (index <= allItems.length) {
      allItems.insertAll(index, items);
      // Rebuild pages from allItems - this is a simplified approach
      final newState = currentState.copyWith(
        pages: [allItems],
        keys: [firstPageKey],
      );
      pagingController.value = newState;
    }
  }

  void updateItemAt(int index, T newItem) {
    final currentState = pagingController.value;
    final allItems = currentState.pages?.expand((page) => page).toList() ?? [];
    if (index < allItems.length) {
      allItems[index] = newItem;
      // Rebuild pages from allItems - this is a simplified approach
      final newState = currentState.copyWith(
        pages: [allItems],
        keys: [firstPageKey],
      );
      pagingController.value = newState;
    }
  }

  void removeItemAt(int index) {
    final currentState = pagingController.value;
    final allItems = currentState.pages?.expand((page) => page).toList() ?? [];
    if (index < allItems.length) {
      allItems.removeAt(index);
      // Rebuild pages from allItems - this is a simplified approach
      final newState = currentState.copyWith(
        pages: [allItems],
        keys: [firstPageKey],
      );
      pagingController.value = newState;
    }
  }

  void removeRange(int start, int end) {
    final currentState = pagingController.value;
    final allItems = currentState.pages?.expand((page) => page).toList() ?? [];
    if (start < allItems.length && end <= allItems.length) {
      allItems.removeRange(start, end);
      // Rebuild pages from allItems - this is a simplified approach
      final newState = currentState.copyWith(
        pages: [allItems],
        keys: [firstPageKey],
      );
      pagingController.value = newState;
    }
  }

  void clear(int start, int end) {
    final newState = pagingController.value.copyWith(
      pages: [],
      keys: [],
      hasNextPage: true,
      isLoading: false,
      error: null,
    );
    pagingController.value = newState;
  }

  @override
  void dispose() {
    pagingController.dispose();
  }
}
