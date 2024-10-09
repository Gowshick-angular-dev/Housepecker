import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/property_repository.dart';
import '../../model/data_output.dart';
import '../../model/property_model.dart';

abstract class FetchPropertyFromTypeState {}

class FetchPropertyFromTypeInitial extends FetchPropertyFromTypeState {}

class FetchPropertyFromTypeInProgress
    extends FetchPropertyFromTypeState {}

class FetchPropertyFromTypeSuccess extends FetchPropertyFromTypeState {
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<PropertyModel> propertymodel;
  final int offset;
  final int total;
  final String? type;
  FetchPropertyFromTypeSuccess(
      {required this.isLoadingMore,
        required this.loadingMoreError,
        required this.propertymodel,
        required this.offset,
        required this.total,
        this.type});

  FetchPropertyFromTypeSuccess copyWith(
      {bool? isLoadingMore,
        bool? loadingMoreError,
        List<PropertyModel>? propertymodel,
        int? offset,
        int? total,
        String? type}) {
    return FetchPropertyFromTypeSuccess(
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadingMoreError: loadingMoreError ?? this.loadingMoreError,
        propertymodel: propertymodel ?? this.propertymodel,
        offset: offset ?? this.offset,
        total: total ?? this.total,
        type: type ?? this.type);
  }
}

class FetchPropertyFromTypeFailure extends FetchPropertyFromTypeState {
  final dynamic errorMessage;
  FetchPropertyFromTypeFailure(this.errorMessage);
}

class FetchPropertyFromTypeCubit
    extends Cubit<FetchPropertyFromTypeState> {
  FetchPropertyFromTypeCubit() : super(FetchPropertyFromTypeInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> fetchPropertyFromType(String type,
      {bool? showPropertyType}) async {
    try {
      emit(FetchPropertyFromTypeInProgress());

      DataOutput<PropertyModel> result =
      await _propertyRepository.fetchProperyFromType(
        type: type,
        offset: 0,
        showPropertyType: showPropertyType,
      );
      emit(
        FetchPropertyFromTypeSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          propertymodel: result.modelList,
          offset: 0,
          total: result.total,
          type: type,
        ),
      );
    } catch (e) {
      emit(
        FetchPropertyFromTypeFailure(
          e,
        ),
      );
    }
  }

  Future<void> fetchPropertyFromTypeMore({bool? showPropertyType}) async {
    try {
      if (state is FetchPropertyFromTypeSuccess) {
        if ((state as FetchPropertyFromTypeSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchPropertyFromTypeSuccess)
            .copyWith(isLoadingMore: true));

        DataOutput<PropertyModel> result =
        await _propertyRepository.fetchProperyFromType(
            type: (state as FetchPropertyFromTypeSuccess).type!,
            showPropertyType: showPropertyType,
            offset: (state as FetchPropertyFromTypeSuccess)
                .propertymodel
                .length);

        FetchPropertyFromTypeSuccess property =
        (state as FetchPropertyFromTypeSuccess);

        property.propertymodel.addAll(result.modelList);

        emit(
          FetchPropertyFromTypeSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            propertymodel: property.propertymodel,
            offset: (state as FetchPropertyFromTypeSuccess)
                .propertymodel
                .length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchPropertyFromTypeSuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchPropertyFromTypeSuccess) {
      return (state as FetchPropertyFromTypeSuccess).propertymodel.length <
          (state as FetchPropertyFromTypeSuccess).total;
    }
    return false;
  }
}
