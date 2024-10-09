import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../helper/custom_exception.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  bool isAuthenticated = false;

  Authenticated(this.isAuthenticated);
}

class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure(this.errorMessage);
}

class AuthCubit extends Cubit<AuthState> {
  //late String name, email, profile, address;
  AuthCubit() : super(AuthInitial()) {
    // checkIsAuthenticated();
  }
  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {
      //setUserData();
      emit(Authenticated(true));
    } else {
      emit(Unauthenticated());
    }
  }

  Future updateFCM(BuildContext context) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      await Api.post(
        url: Api.apiUpdateProfile,
        parameter: {
          Api.userid: HiveUtils.getUserId(),
          "fcm_id": token,
        },
      );
    } catch (e) {}
  }

  Future<Map> updateUserData(BuildContext context,
      {
      String? name,
      String? email,
      String? role,
      String? residentType,
      String? mobile,
      String? address,
      File? fileUserimg,
      String? fcmToken,
      String? notification,
      String? city,
      String? state,
      String? country,
      String? aboutMe,
      String? facebookId,
      String? twiiterId,
      String? instagramId,
      String? pintrestId,
      String? rera,
      String? companyName,
      String? completedProject,
      String? currentProject,
      String? officeTiming,
      String? webLink,
      String? gstNo,
      String? experience,
      List? gallery,
      List? verifiedUpload,
      String? rentNo,
      String? saleNo,
      }) async {
    Map<String, dynamic> parameters = {
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      Api.userid: HiveUtils.getUserId(),
      Api.notification: notification,
      "city": city,
      "state": state,
      "country": country,
      'mobile': mobile,
      'role': role,
      'resident_type': residentType,
      'about_me': aboutMe,
      'facebook_id': facebookId,
      'twiiter_id': twiiterId,
      'instagram_id': instagramId,
      'pintrest_id': pintrestId,
      'rera': rera,
      'company_name': companyName,
      'completed_project': completedProject,
      'office_timing': officeTiming,
      'experience': experience,
      'gallery': gallery,
      'verified_upload': verifiedUpload,
      'rent_no': rentNo,
      'sale_no': saleNo,
      'web_link': webLink,
      'gst_no': gstNo,
      'current_project': currentProject,
    };
    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }
    var response =
        await Api.post(url: Api.apiUpdateProfile, parameter: parameters);

    if (!response[Api.error]) {
      HiveUtils.setUserData(response['data']);
      checkIsAuthenticated();
    } else {
      throw CustomException(response[Api.message]);
    }
    return response;
  }

  void getUserById(
    BuildContext context,
  ) async {
    Map<String, String> body = {Api.userid: HiveUtils.getUserId().toString()};

    var response = await HelperUtils.sendApiRequest(
        Api.apigetUserbyId, body, false, context);

    Future.delayed(
      Duration.zero,
      () async {
        response = await HelperUtils.sendApiRequest(
            Api.apiUpdateProfile, body, true, context);
      },
    );

    var getdata = json.decode(response);

    if (getdata != null) {
      if (!getdata[Api.error]) {
        // Constant.session.setUserData(getdata['data'], "");
        checkIsAuthenticated();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }
  }

  void signOut(BuildContext context) async {
    if ((state as Authenticated).isAuthenticated) {
      HiveUtils.logoutUser(context, onLogout: () {});
      emit(Unauthenticated());
    }
  }
}
