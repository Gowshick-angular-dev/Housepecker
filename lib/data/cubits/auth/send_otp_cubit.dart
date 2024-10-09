// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dio/dio.dart';
import 'package:Housepecker/data/Repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/api.dart';
import '../../../utils/constant.dart';

String verificationID = "";

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  final String verificationId;
  SendOtpSuccess({
    required this.verificationId,
  });
}

class SendOtpFailure extends SendOtpState {
  final String errorMessage;

  SendOtpFailure(this.errorMessage);
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();

  get dio => null;
  void sendOTP({required String phoneNumber}) async {
    try {
      emit(SendOtpInProgress());

      // var response = await Api.get(url: Api.generateOTP, queryParameters: {
      //   'mobile': phoneNumber,
      // });

     var response = await Dio().get(Constant.baseUrl + Api.generateOTP,
          queryParameters: {
            'mobile': phoneNumber,
          });
      if(response.data['error'] == false) {
        print('ggggggggggggggggggggggg');
        verificationID = 'verificationId';
        emit(SendOtpSuccess(verificationId: 'verificationId'));
      }

      // await _authRepository.sendOTP(
      //   phoneNumber: phoneNumber,
      //   onCodeSent: (verificationId) {
      //     verificationID = verificationId;
      //     emit(SendOtpSuccess(verificationId: verificationId));
      //   },
      //   onError: (e) {
      //     emit(SendOtpFailure(e.toString()));
      //   },
      // );

    } catch (e) {
      print('ttttttttttttttterr: ${e}');
      emit(SendOtpFailure(e.toString()));
    }
  }

  void setToInitial() {
    emit(SendOtpInitial());
  }
}
