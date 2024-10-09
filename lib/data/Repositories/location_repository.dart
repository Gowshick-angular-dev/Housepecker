// ignore_for_file: file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:Housepecker/utils/constant.dart';

import '../../utils/api.dart';
import '../model/google_place_model.dart';

class GooglePlaceRepository {
  //This will search places from google place api
  //We use this to search location while adding new property
  Future<List<GooglePlaceModel>> serchCities(
    String text,
  ) async {
    try {
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: "(cities)",
        Api.components: 'country:in',
        // Api.region: "in",
      };

      ///************************ */

      Map<String, dynamic> apiResponse = await Api.get(
        url: Api.placeAPI,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );

      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  Future<List<GooglePlaceModel>> serchOnlyCities(
      String text, Map? loc
      ) async {
    try {
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        // Api.type: "(cities)",
        Api.components: 'country:in',
        Api.region: "IN",
        'location': '${loc!['lat']},${loc!['lng']}',
        'radius': '20000'
      };

      ///************************ */

      Map<String, dynamic> apiResponse = await Api.get(
        url: Api.placeAPI,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );

      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  Future<List<GooglePlaceModel>> serchOnlyArea(
      String text,
      ) async {
    try {
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: "(locality)",
        Api.components: 'country:in',
        // Api.region: "in",
      };

      ///************************ */

      Map<String, dynamic> apiResponse = await Api.get(
        url: Api.areasearch,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );

      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  Future<List<GooglePlaceModel>> serchNearbyArea(
      String text,
      ) async {
    try {
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: "(cities)",
        Api.components: 'country:in',
        // Api.region: "in",
      };

      ///************************ */

      Map<String, dynamic> apiResponse = await Api.get(
        url: Api.placeApiDetails,
        useAuthToken: false,
        useBaseUrl: false,
        queryParameters: queryParameters,
      );

      return _buildPlaceModelList(apiResponse);
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  ///this will convert normal response to List of models so we can use it easily in code
  List<GooglePlaceModel> _buildPlaceModelList(
      Map<String, dynamic> apiResponse) {
    ///loop throuh predictions list,
    ///this will create List of GooglePlaceModel
    try {
      var filterdResult = (apiResponse["predictions"] as List).map((details) {
        String name = details['description'];
        String placeId = details['place_id'];
        ///////
        ////
        var plsceArr = name.split(',').reversed.toList();
        print('jjjjjjjjjjjjjjjjj: ${plsceArr}');

        // String city = getLocationComponent(details, "locality");
        // String country = getLocationComponent(details, "geocode");
        // String state = getLocationComponent(details, "political");

        // var dfgf = addressFromPlace(placeId);
        // print('ffffffffffffffffff: ${dfgf}');
        String city = '';
        String country = '';
        String state = '';
        String locality = '';

        if(plsceArr.length > 3) {
          city = plsceArr[2];
          country = plsceArr[0];
          state = plsceArr[1];
          locality = plsceArr[3];
        } else if(plsceArr.length > 2) {
          city = plsceArr[2];
          country = plsceArr[0];
          state = plsceArr[1];
          locality = '';
        } else if(plsceArr.length > 1) {
          city = '';
          country = plsceArr[0];
          state = plsceArr[1];
          locality = '';
        } else if(plsceArr.length == 1) {
          city = '';
          country = plsceArr[0];
          state = '';
          locality = '';
        } else {
          city = '';
          country = '';
          state = '';
          locality = '';
        }


        ///
        ///
        GooglePlaceModel placeModel = GooglePlaceModel(
          city: city,
          locality: locality,
          description: name,
          placeId: placeId,
          state: state,
          country: country,
          latitude: '',
          longitude: '',
        );
        return placeModel;
      }).toList();

      return filterdResult;
    } catch (e) {

      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final apiKey = Constant.googlePlaceAPIkey; // Replace with your actual API key
    // final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey');

    final response = await Dio().get('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey');

    if (response.statusCode == 200) {
    final data = response.data;
    return data;

    } else {
    throw Exception('Failed to load place details');
    }
  }

  Future<Map<String, dynamic>> addressFromPlace(String placeId) async { // Replace with the actual place ID
    final placeDetails = await getPlaceDetails(placeId);

    // Extract state, city, and locality from the address components
    String state = '', city = '', locality = '';
    for (final component in placeDetails.values) {
      final types = component['types'] as List<String>;
      if (types.contains('administrative_area_level_1')) {
        state = component['long_name'];
      } else if (types.contains('locality')) {
        city = component['long_name'];
      } else if (types.contains('sublocality_level_1')) {
        locality = component['long_name'];
      }
    }

    print('State: $state');
    print('City: $city');
    print('Locality: $locality');
    return {
      'state': state,
      'city': city,
      'locality': locality,
    };
  }

  String getLocationComponent(Map details, String component) {
    int index = (details['types'] as List)
        .indexWhere((element) => element == component);
    print('errrrrrrrrrrr ${component}: ${index}');
    if ((details['terms'] as List).length > index && index > -1) {
      return (details['terms'] as List).elementAt(index)['value'];
    } else {
      return "";
    }
  }

  ///Google Place Autocomplete api will give us Place Id.
  ///We will use this place id to get Place Details
  Future<dynamic> getPlaceDetailsFromPlaceId(String placeId) async {
    Map<String, dynamic> queryParameters = {
      Api.placeApiKey: Constant.googlePlaceAPIkey,
      Api.placeid: placeId
    };
    Map<String, dynamic> response = await Api.get(
      url: Api.placeApiDetails,
      queryParameters: queryParameters,
      useBaseUrl: false,
      useAuthToken: false,
    );

    return response['result']['geometry']['location'];
  }
}
