// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Housepecker/data/Repositories/property_repository.dart';
import 'package:Housepecker/data/model/data_output.dart';
import 'package:Housepecker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchPropertyState {}

class SearchPropertyInitial extends SearchPropertyState {}

class SearchPropertyFetchProgress extends SearchPropertyState {}

class SearchPropertyProgress extends SearchPropertyState {}

class SearchPropertySuccess extends SearchPropertyState {
  final int total;
  final int offset;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> searchedroperties;
  final List? searchedProjects;

  SearchPropertySuccess({
    required this.searchQuery,
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.searchedroperties,
    this.searchedProjects,
  });

  SearchPropertySuccess copyWith({
    int? total,
    int? offset,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasError,
    List<PropertyModel>? searchedroperties,
    List? searchedProjects,
  }) {
    return SearchPropertySuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      searchedroperties: searchedroperties ?? this.searchedroperties,
      searchedProjects: searchedProjects ?? this.searchedProjects,
    );
  }
}

class SearchPropertyFailure extends SearchPropertyState {
  final dynamic errorMessage;
  SearchPropertyFailure(this.errorMessage);
}

class SearchPropertyCubit extends Cubit<SearchPropertyState> {
  SearchPropertyCubit() : super(SearchPropertyInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> searchProperty(String query,
      {required int offset, bool? useOffset}) async {
    try {
      emit(SearchPropertyFetchProgress());
      DataOutput<PropertyModel> result =
          await _propertyRepository.searchProperty(query, offset: 0);

      emit(SearchPropertySuccess(
          searchQuery: query,
          total: result.total,
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          searchedroperties: result.modelList,
          searchedProjects: result.modelList2,
      ));
      print('yyyyyyyyyyyyyyyyyyy${result.modelList2}');
    } catch (e) {
      emit(SearchPropertyFailure(e));
    }
  }

  void clearSearch() {
    if (state is SearchPropertySuccess) {
      emit(SearchPropertyInitial());
    }
  }

  Future<void> fetchMoreSearchData() async {
    try {
      if (state is SearchPropertySuccess) {
        if ((state as SearchPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as SearchPropertySuccess).copyWith(isLoadingMore: true));

        DataOutput<PropertyModel> result =
            await _propertyRepository.searchProperty(
          (state as SearchPropertySuccess).searchQuery,
          offset: (state as SearchPropertySuccess).searchedroperties.length,
        );

        SearchPropertySuccess bookingsState = (state as SearchPropertySuccess);
        bookingsState.searchedroperties.addAll(result.modelList);
        bookingsState.searchedProjects!.addAll(result.modelList2!);
        emit(
          SearchPropertySuccess(
            searchQuery: (state as SearchPropertySuccess).searchQuery,
            isLoadingMore: false,
            hasError: false,
            searchedroperties: bookingsState.searchedroperties,
            searchedProjects: bookingsState.searchedProjects!,
            offset: (state as SearchPropertySuccess).searchedroperties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as SearchPropertySuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is SearchPropertySuccess) {
      return (state as SearchPropertySuccess).searchedroperties.length <
          (state as SearchPropertySuccess).total;
    }
    return false;
  }
}
