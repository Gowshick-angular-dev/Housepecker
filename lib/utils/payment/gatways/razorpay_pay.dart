import 'dart:developer';

import 'package:Housepecker/data/model/subscription_pacakage_model.dart';
import 'package:Housepecker/utils/payment/lib/payment.dart';
import 'package:Housepecker/utils/payment/lib/purchase_package.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../api.dart';
import '../../constant.dart';
import '../../helper_utils.dart';
import '../../hive_utils.dart';
import '../../ui_utils.dart';

class RazorpayPay extends Payment {
  SubscriptionPackageModel? _model;

  @override
  void onEvent(
      BuildContext context, covariant PaymentStatus currentStatus) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }

  @override
  void pay(BuildContext context) {
    log("LKEY IS ${Constant.razorpayKey}");

    ///
    final Razorpay razorpay = Razorpay();
    var options = {
      'key': Constant.razorpayKey,
      'amount': _model!.offerPrice! * 100,
      'name': _model!.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile,
        'email': HiveUtils.getUserDetails().email
      },
      "notes": {
        "package_id": _model!.id,
        "user_id": HiveUtils.getUserId(),
      },
    };

    if (Constant.razorpayKey != "") {
      razorpay.open(options);
      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (
          PaymentSuccessResponse response,
        ) async {
          emit(Success(message: "Success"));
          var updateResponse = await Api.post(url: Api.razorPay, parameter: {
            "package_id": _model!.id,
            "amount": _model!.price,
            "transaction_id": response.paymentId,
            "customer_id": HiveUtils.getUserId()
          });
          // await _purchase(context);
        },
      );
      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
          emit(Failure(message: "Success"));
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(context, "purchaseFailed"));
        },
      );
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (e) {
        log("ISSUE IS ON RAZORPAY ITSELF $e");
      });
      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (e) {},
      );
    } else {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(context, "setAPIkey"));
    }
  }

  @override
  Payment setPackage(SubscriptionPackageModel modal) {
    _model = modal;
    return this;
  }
}
