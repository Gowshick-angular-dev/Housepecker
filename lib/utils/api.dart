import 'dart:io';

import 'package:dio/dio.dart';
import 'package:Housepecker/utils/Network/Interseptors/network_request_interseptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'constant.dart';
import 'errorFilter.dart';
import 'guestChecker.dart';
import 'hive_keys.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  static Map<String, dynamic> headers() {
    if (GuestChecker.value == true) {
      return {};
    } else {
      String jwtToken = Hive.box(HiveKeys.userDetailsBox).get(
        HiveKeys.jwtToken,
      );
      print("JWT : $jwtToken");
      if (kDebugMode) {
        return {
          "Authorization": "Bearer $jwtToken",
        };
      }
      return {
        "Authorization": "Bearer $jwtToken",
      };
    }
  }

  //Place API
  static const String _placeApiBaseUrl =
      "https://maps.googleapis.com/maps/api/place/";
  static const String _areaApiBaseUrl =
      "https://maps.googleapis.com/maps/api/";
  static String placeApiKey = "key";
  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${_placeApiBaseUrl}autocomplete/json";
  static String placeApiDetails = "${_placeApiBaseUrl}details/json";
  static String locality = "${_placeApiBaseUrl}nearbysearch/json";
  static String areasearch = "${_areaApiBaseUrl}geocode/json";
//

  static String stripeIntentAPI = "https://api.stripe.com/v1/payment_intents";
  //api fun
  static String apiLogin = "user_signup";
  static String apiUpdateProfile = "update_profile";
  static String apiGetSlider = "get_slider";
  static String apiGetCategories = "get_categories";
  static String apiGetUnit = "get_unit";
  static String apiGetProprty = "get_property";
  static String apiGetReportPropertyReson = "get_report_reasons";
  static String apiViewContact = "view_contact";
  static String apiPostProperty = "post_property";
  static String apiUpdateProperty = "update_post_property";
  static String apiGetHouseType = "get_house_type";
  static String apiGetNotificationList = "get_notification_list";
  static String setPropertyView = "set_property_total_click";
  static String apiDeleteUser = "delete_user";
  static String paypal = "paypal";
  static String getArticles = "get_articles";
  static String getCountByCitiesCategory = "get_count_by_cities_categoris";
  static String getNearByProperties = "get_nearby_properties";
  static String addFavourite = "add_favourite";
  static String removeFavorite = "delete_favourite";
  static String getPackage = "get_package";
  static String userPurchasePackage = "user_purchase_package";
  static String deleteInquiry = "delete_inquiry";
  static String getLanguagae = "get_languages";
  static String getPaymentApiKeys = "get_payment_settings";
  static String apiGetSystemSettings = "get_system_settings";
  static String apiSetPropertyEnquiry = "set_property_inquiry";
  static String apiGetPropertyEnquiry = "get_property_inquiry";
  static String apiGetNotifications = "get_notification_list";
  static String apiRemovePostImages = "remove_post_images";
  static String apigetUserbyId = "get_user_by_id";
  static String getFavoriteProperty = "get_favourite_property";
  static String interestedUsers = "interested_users";
  static String interestedProjects = "interested_project";
  static String storeAdvertisement = "store_advertisement";
  static String getLimitsOfPackage = "get_limits";
  static String getPaymentDetails = "get_payment_details";
  static String deleteAdvertisement = "delete_advertisement";
  static String updatePropertyStatus = "update_property_status";
  static String deleteChatMessage = "delete_chat_message";
  static String getOutdoorFacilites = "get_facilities";
  static String getReportReasons = "get_report_reasons";
  static String addReports = "add_reports";
  static String addEditUserInterest = "add_edit_user_interest";
  static String getUserRecommendation = "get_user_recommendation";
  static String assignFreePackage = "assign_free_package";
  static String getAppSettings = "get_app_settings";
  static String getAmenities = "get_amenities";
  static String getUserDetails = "get_users";
  static String reportReason = "add_reports";
  static String getVenturetype = "get_post_type";
  static String propertyAddOn = "addon";

  ///
  static String createPaymentIntent = "createPaymentIntent";

  //Chat module apis
  static String getChatList = "get_chats";
  static String sendMessage = "send_message";
  static String getMessages = "get_messages";

  //params
  static String id = "id";
  static String mobile = "mobile";
  static String type = "type";
  static String region = "region";
  static String components = "components";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String error = "error";
  static String message = "message";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String userid = "userid";
  static String categoryId = "category_id";
  static String title = "title";
  static String description = "description";
  static String price = "price";
  static String titleImage = "title_image";
  static String postCreated = "post_created";
  static String galleryImages = "gallery_images";
  static String typeId = "type_id";
  static String propertyType = "property_type";
  static String Saletype = "Sale_type";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String getProjectPlaced = "get_project_placed";
  static String getSuitable = "get_suitable_for";
  static String totalView = "total_view";
  static String addedBy = "added_by";
  static String languageCode = "language_code";
  static String aboutApp = "about_app";
  static String termsAndConditions = "terms_conditions";
  static String privacyPolicy = "privacy_policy";
  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String actionType = "action_type";
  static String propertyId = "property_id";
  static String customerId = "customer_id";
  static String propertysId = "propertys_id";
  static String customersId = "customers_id";
  static String enqStatus = "status";
  static String search = "search";
  static String createdAt = "created_at";
  static String created = "created";
  static String compName = "company_name";
  static String compWebsite = "company_website";
  static String compEmail = "company_email";
  static String compAdrs = "company_address";
  static String tele1 = "company_tel1";
  static String tele2 = "company_tel2";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String property = "property";
  static String offset = "offset";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String limit = "limit";
  static String city = "city";
  static String packageId = "package_id";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";
  static String blogs = "get_articles";
  static String loanTypes = "get_loan";
  static String banksList = "bank_filter";
  static String agentsList = "loan_list";
  static String agentsDetails = "Loan_detail";
  static String services = "get_service";
  static String serviceList = "service_list";
  static String venturesList = "joint_venture_list";
  static String ventureDetails = "joint_venture_detail";
  static String serviceDetails = "service_detail";
  static String constructionTypes = "get_property_type";
  static String constructionsList = "constructor_list";
  static String constructionDetails = "constructor_detail";
  static String advertisementPost = "advertisement_post";
  static String advertisementCategory = "advertisement_category";
  static String roles = "get_roles";
  static String ventureCategories = "get_post_type";
  static String myAdvertisements = "my_advertisement";
  static String advertisementDelete = "advertisement_delete";
  static String advertisementGetById = "advertisement_get";
  static String advertisementUpdate = "advertisement_update";
  static String homeLoanOffers = "get_bank";
  static String postProject = "post_project";
  static String getProject = "get_projects";
  static String razorPay = "razor_pay";
  static String generateInvoice = "generate_invoice";
  static String deleteProject = "delete_project";
  static String projectImageUpload = "project_image_upload";
  static String addFavProject = "project_favourite";
  static String getUserData = "get-user-data";
  static String getBannerData = "banner";
  static String addRatting = "add_ratting";
  static String favProjects = "get_favourite_project";
  static String getParameters = "get_parameter";
  static String generateOTP = "generate_otp";
  static String gettop_agent = "top_agents";
  static String gettop_builder = "top_builders";
  static String getInterstedList = "get_interested_users";
  static String postInterstedStatus = "interested_property_status";
  static String getInterestedUserProjects = "interested_user_projects";
  static String postProjectInterstedStatus = "interested_project_status";


  //not in use yet
  // static String offset = "offset";
  // static String limit = "limit";
  static final Dio dio = Dio();
  static int apiRequestCount = 0;
  static int apiErrorCount = 0;

  static List<String> currentlyCallingAPI = [];

  static void initInterceptors() {
    // dio.interceptors.add(ThrottleInterceptor(minInterval: 1000));

    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    //     apiRequestCount++;
    //     print("REQUEST COUNT: $apiRequestCount ${options.uri.toString()}");
    //
    //     // if (!currentlyCallingAPI.contains(options.uri.toString())) {
    //     //   currentlyCallingAPI.add(options.uri.toString());
    //     return handler.next(options);
    //     // } else {}
    //   },
    //   onResponse: (Response e, ResponseInterceptorHandler handler) {
    //     currentlyCallingAPI.remove(e.realUri.toString());
    //     return handler.next(e);
    //   },
    //   onError: (DioError e, ErrorInterceptorHandler handler) {
    //     apiErrorCount++;
    //     currentlyCallingAPI.remove(e.requestOptions.uri.toString());
    //     return handler.next(e);
    //   },
    // ));

    dio.interceptors.add(NetworkRequestInterseptor());
  }

  static Future<Map<String, dynamic>> post(
      {required String url,
      required Map<String, dynamic> parameter,
      Options? options,
      bool? useAuthToken,
      bool? useBaseUrl}) async {
    try {
      final FormData formData = FormData.fromMap(
        parameter,
        ListFormat.multiCompatible,
      );

      final response =
          await dio.post(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              data: formData,
              options: (useAuthToken ?? true)
                  ? Options(
                      contentType: "multipart/form-data",
                      headers: headers(),
                    )
                  : Options(
                      contentType: "multipart/form-data",
                    ));
      // dynamic resp = response.data.toString().trim();
      var resp = response.data;

      // resp = JsonEncoder(resp);
      // if (resp['error'] ?? false) {
      //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   //   content: Text(resp['message']),
      //   // ));
      //   throw ApiException(resp['message'].toString());
      // }

      return Map.from(resp);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw "auth-expired";
      }

      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(
        e.error is SocketException
            ? "no-internet"
            : "Something went wrong with error ${e.response?.statusCode}",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
      {required String url,
      bool? useAuthToken,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      //

      final response = await dio.get(
          ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
          queryParameters: queryParameters,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);
      //log("API is ${url.toString()}");
      //log("parameters are $queryParameters");
      //log("response is ${response.data}");
      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }
      return Map.from(response.data);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw "auth-expired";
      }
      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(e.error is SocketException
          ? ('no-internet')
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }
}
