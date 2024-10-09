// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dio/dio.dart';
import 'package:Housepecker/data/Repositories/auth_repository.dart';
import 'package:Housepecker/utils/errorFilter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../../utils/constant.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  // final UserCredential credential;
  // VerifyOtpSuccess({
  //   required this.credential,
  // });
  final String credential;
  VerifyOtpSuccess({
    required this.credential,
  });
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;

  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOTP(
      {required String verificationId, required String otp}) async {
    try {
      emit(VerifyOtpInProgress());
      if(otp.length == 6) {
        emit(VerifyOtpSuccess(credential: otp));
      }
      // UserCredential userCredential = await _authRepository.verifyOTP(
      //     otpVerificationId: verificationId, otp: otp);
      // emit(VerifyOtpSuccess(credential: userCredential));
      // var response = await Dio().post(Constant.baseUrl + Api.apiLogin,
      //     data: {
      //       'mobile': '91${verificationId}',
      //       'otp': otp
      //     });
      // if(response.data['error'] == false) {
      //   print('ggggggggggggggggggggggg');
      //   emit(VerifyOtpSuccess(credential: response.data['token']));
      // }
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error));
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  void setInitialState() {
    emit(VerifyOtpInitial());
  }
}
