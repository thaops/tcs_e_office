import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/news_models.dart';
import '../repository/news_repository.dart';

class NewsState {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalRecord = 0.obs;
  final RxString keyword = ''.obs;

  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  int _pageIndex = 1;
  final int _pageSize = 10;
}

class NewsController extends GetxController {
  final NewsRepository _repository = NewsRepository();
  final NewsState state = NewsState();


  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  @override
  void onClose() {
    state._searchDebounce?.cancel();
    state.searchController.dispose();
    super.onClose();
  }

  Future<void> loadNews({bool refresh = false}) async {
    if (refresh) {
      state._pageIndex = 1;
      state.hasMore.value = true;
      state.newsList.clear();
    }

    state.isInitialLoading.value = state.newsList.isEmpty;

    try {
      final response = await _repository.getListNews(
        keyword: state.keyword.value,
        pageIndex: state._pageIndex,
        pageSize: state._pageSize,
      );

      if (refresh) {
        state.newsList.assignAll(response.data);
      } else {
        state.newsList.addAll(response.data);
      }

      state.totalRecord.value = response.totalRecord;
      state.hasMore.value = state.newsList.length < response.totalRecord;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải tin tức');
    } finally {
      state.isInitialLoading.value = false;
      state.isSearching.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore.value || state.isLoadingMore.value) return;

    state.isLoadingMore.value = true;
    state._pageIndex++;

    try {
      final response = await _repository.getListNews(
        keyword: state.keyword.value,
        pageIndex: state._pageIndex,
        pageSize: state._pageSize,
      );

      state.newsList.addAll(response.data);
      state.hasMore.value = state.newsList.length < response.totalRecord;
    } catch (e) {
      state._pageIndex--;
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  Future<void> refresh() async {
    await loadNews(refresh: true);
  }

  void onSearchChanged(String query) {
    state.keyword.value = query;
    state._searchDebounce?.cancel();

    if (query.isEmpty) {
      loadNews(refresh: true);
      return;
    }

    state.isSearching.value = true;
    state._searchDebounce = Timer(const Duration(milliseconds: 500), () {
      loadNews(refresh: true);
    });
  }

  void clearSearch() {
    state._searchDebounce?.cancel();
    state.searchController.clear();
    state.keyword.value = '';
    loadNews(refresh: true);
  }
}