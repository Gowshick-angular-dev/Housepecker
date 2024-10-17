import 'dart:io';

import 'package:Housepecker/Ui/screens/projects/projectAdd5.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd2.dart';

import '../../../app/routes.dart';
import '../../../data/Repositories/system_repository.dart';
import '../../../data/helper/designs.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ProjectFormsixth extends StatefulWidget {
  final Map? data;
  final Map? body;
  final bool? isEdit;
  const ProjectFormsixth({super.key, this.isEdit, this.data, this.body});

  @override
  State<ProjectFormsixth> createState() => _ProjectFormSecondState();
}

class _ProjectFormSecondState extends State<ProjectFormsixth> {
  int? selectedPackage = 0;
  TextEditingController locationControler = TextEditingController();
  FocusNode placesFocusNode = FocusNode();
  TextEditingController cityControler = TextEditingController();
  TextEditingController StateController = TextEditingController();
  TextEditingController ContryControler = TextEditingController();
  TextEditingController AdresssController = TextEditingController();
  List packages = [];
  String projectType = 'Sell';
  String selectedRole = 'Free Listing';
  String brokerage = '';
  int remainFreeProPost = 0;
  List<ValueItem> brokerageWidget = [];
  String propertyType = '';
  List<ValueItem> propertyTypeWidget = [];
  String status = '';
  List<ValueItem> statusWidget = [];
  String category = '';
  List<ValueItem> categoryWidget = [];
  String lat = '';
  String lng = '';

  List categoryList = [];
  List statusList = [];

  bool loading = false;

  // GooglePlaces places = GooglePlaces(apiKey: yourGooglePlacesApiKey);

  @override
  void initState() {
    getMasters();
    getPackages();
    super.initState();
  }

  Future<void> getPackages() async {
    try {
      // Start loading
      setState(() {
        loading = true;
      });

      final SystemRepository _systemRepository = SystemRepository();
      Map settings =
          await _systemRepository.fetchSystemSettings(isAnonymouse: false);

      print('hhhhhhhhhhhhhhhhhhhhhhhhhhh: ${settings['data']}');

      List allPacks = settings['data']['package']['user_purchased_package'];
      Map freepackage = settings['data']['free_package'];

      if (freepackage != null) {
        setState(() {
          remainFreeProPost =
              freepackage['project_limit'] - freepackage['used_project_limit'];
        });
      }

      List temp = [];
      if (settings['data']['package'] != null && allPacks != null) {
        for (int i = 0; i < allPacks.length; i++) {
          print(
              'hhhhhhhhhhhhhhhhhhhhhhhhhhh2: ${allPacks[i]['used_limit_for_project']}, ${allPacks[i]['package']['project_limit']}');

          if (((allPacks[i]['package']['project_limit'] ?? 0) -
                  (allPacks[i]['used_limit_for_project'] ?? 0)) >
              0) {
            temp.add(allPacks[i]);
          }
        }
      }
      setState(() {
        packages = temp;
        print('fjbsdjfbdn${packages}');
      });
      // Update state with the filtered packages
      // setState(() {
      //   packages = temp;
      // });
    } catch (e, stacktrace) {
      // Handle any error that occurs in the try block
      print('An error occurred: $e');
      print('Stacktrace: $stacktrace');

      // Optionally, you can show an error message to the user using a Snackbar or AlertDialog
    } finally {
      // Stop loading, whether an error occurred or not
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getUpdateProject() async {
    locationControler.text = widget.data!['address'];
    cityControler.text = widget.data!['city'];
    projectType = widget.data!['project_type']!.toString();
    brokerage = widget.data!['project_details'][0]['brokerage'] ?? '';
    propertyType = widget.data!['project_details'][0]['property_type'] ?? '';
    status = widget.data!['project_details'][0]['project_status'].toString();
    lat = widget.data!['latitude'];
    lng = widget.data!['longitude'];

    statusWidget = statusList
        .where((element) =>
            element['id'].toString() ==
            widget.data!['project_details'][0]['project_status'].toString())
        .toList()
        .map((item) {
      return ValueItem(label: item['name'], value: item['id'].toString());
    }).toList();

    if (widget.data!['project_details'][0]['brokerage'] == 'yes') {
      brokerageWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      brokerageWidget = [ValueItem(label: 'No', value: 'no')];
    }

    propertyTypeWidget = [
      ValueItem(
          label: widget.data!['project_details'][0]['property_type'],
          value: widget.data!['project_details'][0]['property_type'])
    ];

    setState(() {
      loading = false;
    });
  }

  Future<void> getMasters() async {
    setState(() {
      loading = true;
    });
    var staResponse = await Api.get(url: Api.status);
    if (!staResponse['error']) {
      setState(() {
        statusList = staResponse['data'];
      });
    }
    if (widget.isEdit!) {
      getUpdateProject();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  String getAddress(Placemark place) {
    try {
      String address = "";
      if (place.street == null && place.subLocality != null) {
        address = place.subLocality!;
      } else if (place.street == null && place.subLocality == null) {
        address = "";
      } else {
        address = "${place.street ?? ""},${place.subLocality ?? ""}";
      }

      return address;
    } catch (e, st) {
      throw Exception("$st");
    }
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      // Extract and format the address
      Placemark place = placemarks.first;
      String address =
          '${place.street} ${place.thoroughfare}, ${place.subLocality} ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
      cityControler.text = place.locality ?? '';
      StateController.text = place.administrativeArea ?? '';
      ContryControler.text = place.country ?? '';
      setState(() { });
      return address;
    } catch (e) {
      print("Error fetching address: $e");
      return ""; // Or return a default error message
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: UiUtils.getTranslatedLabel(
            context,
            "Add Project",
          ),
          actions: const [
            Text("1/5", style: TextStyle(color: Colors.white)),
            SizedBox(
              width: 14,
            ),
          ],
          showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Location Details',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Map? placeMark = await Navigator.pushNamed(
                                context, Routes.chooseLocaitonMap) as Map?;
                            var latlng = placeMark!['latlng'];
                            if (latlng != null) {
                              var address = await getAddressFromLatLng(
                                  latlng.latitude, latlng.longitude);
                              setState(() {
                                locationControler.text = address as String;
                                lat = '${latlng.latitude}';
                                lng = '${latlng.longitude}';
                              });
                              // try {
                              //   List<Placemark> placemarks = await Geolocator.placemarkFromCoordinates(latitude, longitude);
                              //   if (placemarks.isNotEmpty) {
                              //     Placemark place = placemarks.first;
                              //
                              //     String city = place.locality ?? "";
                              //     String state = place.administrativeArea ?? "";
                              //     String country = place.country ?? "";
                              //
                              //     print("City: $city");
                              //     print("State: $state");
                              //     print("Country: $country");
                              //   } else {
                              //     print("No placemark found for the given latitude and longitude.");
                              //   }
                            }
                          },
                          child: Container(
                            child: Text(
                              'Choose on map',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: locationControler,
                      focusNode: placesFocusNode,
                      inputDecoration: const InputDecoration(
                        hintText: 'Enter location..',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          color: Color(0xff9c9c9c),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )
                        )
                      ),
                      googleAPIKey: "AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8",
                      debounceTime: 800,
                      countries: ["in"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        print("placeDetails" + prediction.lng.toString());
                        lat = prediction.lat.toString();
                        lng = prediction.lng.toString();
                        setState(() { });
                      },
                      itemClick: (Prediction prediction) {
                        locationControler.text = prediction.description!;
                        locationControler.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: prediction.description!.length));
                        print('yyyyyyyyyyyyyyyyyyyyyyyyyy: ${prediction.lat}, ${prediction.lng}');
                        List address = prediction.description!.split(',').reversed.toList();
                        if(address.length >= 3) {
                          cityControler.text = address[2];
                          StateController.text = address[1];
                          ContryControler.text = address[0];
                          setState(() { });
                        } else if(address.length == 2) {
                          cityControler.text = address[1];
                          StateController.text = address[1];
                          ContryControler.text = address[0];
                          setState(() { });
                        } else if(address.length == 1) {
                          cityControler.text = address[0];
                          StateController.text = address[0];
                          ContryControler.text = address[0];
                          setState(() { });
                        }
                        // cityControler.text = place.locality ?? '';
                        // StateController.text = place.administrativeArea ?? '';
                        // ContryControler.text = place.country ?? '';
                        // setState(() { });
                        // getAddressFromLatLng(prediction.placeId);
                      },
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                  child:
                                      Text("${prediction.description ?? ""}"))
                            ],
                          ),
                        );
                      },
                      seperatedBuilder: Divider(),
                      isCrossBtnShown: true,
                      containerHorizontalPadding: 10,
                      placeType: PlaceType.geocode,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "City",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: cityControler,
                                    readOnly: true,
                                    onTap: () {
                                      placesFocusNode.requestFocus();
                                    },
                                    decoration: const InputDecoration(
                                        // hintText: 'Enter City..',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: Color(0xff9c9c9c),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "State",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: StateController,
                                    readOnly: true,
                                    onTap: () {
                                      placesFocusNode.requestFocus();
                                    },
                                    decoration: const InputDecoration(
                                        // hintText: 'Enter State..',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: Color(0xff9c9c9c),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Country",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: ContryControler,
                                    readOnly: true,
                                    onTap: () {
                                      placesFocusNode.requestFocus();
                                    },
                                    decoration: const InputDecoration(
                                        // hintText: 'Enter Country..',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: Color(0xff9c9c9c),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     RichText(
                    //       text: TextSpan(
                    //         children: [
                    //           TextSpan(
                    //             text: "Address",
                    //             style: TextStyle(
                    //                 color: Colors.black,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w600),
                    //           ),
                    //           TextSpan(
                    //             text: " *",
                    //             style: TextStyle(
                    //                 color:
                    //                 Colors.red), // Customize asterisk color
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       height: 10,
                    //     ),
                    //     Row(
                    //       children: [
                    //         Expanded(
                    //           child: Container(
                    //             decoration: BoxDecoration(
                    //               border: Border.all(
                    //                   width: 1, color: Color(0xffe1e1e1)),
                    //               color: Color(0xfff5f5f5),
                    //               borderRadius: BorderRadius.circular(
                    //                   10.0), // Optional: Add border radius
                    //             ),
                    //             child: Padding(
                    //               padding: const EdgeInsets.only(
                    //                   left: 8.0, right: 5),
                    //               child: TextFormField(
                    //                 controller: AdresssController,
                    //                 decoration: const InputDecoration(
                    //                     hintText: 'Enter Address..',
                    //                     hintStyle: TextStyle(
                    //                       fontFamily: 'Poppins',
                    //                       fontSize: 14.0,
                    //                       color: Color(0xff9c9c9c),
                    //                       fontWeight: FontWeight.w500,
                    //                       decoration: TextDecoration.none,
                    //                     ),
                    //                     enabledBorder: UnderlineInputBorder(
                    //                       borderSide: BorderSide(
                    //                         color: Colors.transparent,
                    //                       ),
                    //                     ),
                    //                     focusedBorder: UnderlineInputBorder(
                    //                         borderSide: BorderSide(
                    //                           color: Colors.transparent,
                    //                         ))),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     SizedBox(
                    //       height: 25,
                    //     ),
                    //   ],
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Address",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: " *",
                                    style: TextStyle(
                                        color: Colors
                                            .red), // Customize asterisk color
                                  ),
                                ],
                              ),
                            ),
                            // InkWell(
                            //   onTap: () async {
                            //     FocusManager.instance.primaryFocus?.unfocus();
                            //     Map? placeMark = await Navigator.pushNamed(
                            //         context, Routes.chooseLocaitonMap) as Map?;
                            //     var latlng = placeMark!['latlng'];
                            //     if (latlng != null) {
                            //       var address = await getAddressFromLatLng(
                            //           latlng.latitude, latlng.longitude);
                            //       setState(() {
                            //         locationControler.text = address as String;
                            //         lat = '${latlng.latitude}';
                            //         lng = '${latlng.longitude}';
                            //       });
                            //     }
                            //   },
                            //   child: Text(
                            //     'Choose on map',
                            //     style: TextStyle(
                            //         color: Colors.blue,
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w600),
                            //   ),
                            // )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    maxLines: 4,
                                    controller: locationControler,
                                    readOnly: true,
                                    // onTap: () async {
                                    //   FocusManager.instance.primaryFocus
                                    //       ?.unfocus();
                                    //   Map? placeMark =
                                    //       await Navigator.pushNamed(context,
                                    //           Routes.chooseLocaitonMap) as Map?;
                                    //   var latlng = placeMark!['latlng'];
                                    //   if (latlng != null) {
                                    //     var address =
                                    //         await getAddressFromLatLng(
                                    //             latlng.latitude,
                                    //             latlng.longitude);
                                    //     setState(() {
                                    //       locationControler.text =
                                    //           address as String;
                                    //       lat = '${latlng.latitude}';
                                    //       lng = '${latlng.longitude}';
                                    //     });
                                    //   }
                                    // },
                                    onTap: () {
                                      placesFocusNode.requestFocus();
                                    },
                                    decoration: const InputDecoration(
                                        // hintText: 'location..',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: Color(0xff9c9c9c),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ))),
                                    onChanged: (String? val) async {
                                      final results =
                                          await locationFromAddress(val!);
                                      setState(() {
                                        lat = '${results[0]}';
                                        lng = '${results[1]}';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff117af9),
              ),
              child: Text(
                'Please wait...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          if (!loading)
            InkWell(
              onTap: () {
                var body = {
                  'city': cityControler.text,
                  'state' : StateController.text,
                  'country' : ContryControler.text,
                  'address': locationControler.text,
                  'latitude': lat,
                  'longitude': lng,
                  ...widget.body!
                };
                print('uuuuuuuuuuuuuuuuuuuuuuuu: ${body}');
                if (cityControler.text != '' &&
                    StateController.text != '' &&
                    ContryControler.text != '' &&
                    locationControler.text != '' &&
                    lat != '' && lng != '') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProjectFormFive(
                            body: body,
                            isEdit: widget.isEdit,
                            data: widget.data)),
                  );
                } else {
                  HelperUtils.showSnackBarMessage(
                      context,
                      UiUtils.getTranslatedLabel(
                          context, "Please fill all the (*) marked fields!"),
                      type: MessageType.warning,
                      messageDuration: 5);
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                width: double.infinity,
                height: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff117af9),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
