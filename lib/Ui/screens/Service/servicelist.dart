import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/Service/servicedetail.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../app/routes.dart';
import '../../../utils/api.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ServiceList extends StatefulWidget {
  final int? id;
  final String? name;

  const ServiceList({super.key, this.id, this.name});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  TextEditingController searchControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();
  String? locationValue='';
  bool Loading = false;
  List serviceList = [];
  List banners = [];
  int currentIndex = 0;
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  String dropdownvalue6 = 'Chennai';
  var items6 = ['Chennai', 'Madurai'];
  String dropdownvalue5 = 'Select Locality';
  var items5 = ['Select Locality', 'Tamil'];
  String dropdownvalue4 = 'Loan Type';
  var items4 = ['Loan Type', 'Gold Loan'];

  final serviceIncludeList =  [
    {
      'image': 'assets/Loans/1.png',
    },
    {
      'image': 'assets/Loans/2.png',
    },
    {
      'image': 'assets/Loans/3.png',
    },
    {
      'image': 'assets/Loans/4.png',
    },
    {
      'image': 'assets/Loans/5.png',
    },
  ];

  @override
  void initState() {
   // _getCurrentLocation();
    getServiceList('', '');
    getBanners();
    super.initState();
  }

  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

/*  Future<void> _getCurrentLocation() async {
    setState(() {
      Loading = true;
    });
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await _requestLocationPermission();
    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      return Future.error('Location permission denied');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      String address = '${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
      setState(() {
        currentAddress = address;
        currentPlace = '${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
        currentCity = '${place.subLocality}';
        currentMainCity = '${place.locality}';
      });
      getServiceList('', place.locality);
      getBanners();
    } catch (e) {
      print("Error fetching address: $e");
    }
  }*/

  Future<void> getServiceList(String? search, String? city) async {
    setState(() {
      Loading = true;
    });
    var response = await Api.get(url: Api.serviceList, queryParameters: {
      'service_type': widget.id,
      'city': city!,
      'search': search!
    });
    if (!response['error']) {
      setState(() {
        serviceList = response['data'];
        Loading = false;
      });
    }
  }

  void getBanners() async {
    var response = await Api.post(url: Api.apiGetSystemSettings, parameter: {
      'city': currentMainCity,
    });
    if (!response['error']) {
      setState(() {
        banners = [
          response['data']['advertisement_first_banner'],
          response['data']['advertisement_second_banner']
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'${widget.name!}',
          actions: [
          ]),
   /*   appBar: AppBar(
        backgroundColor: tertiaryColor_,
        leadingWidth: 40,
        titleSpacing: 15,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.name!}',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                Map? placeMark =
                    await Navigator.pushNamed(context, Routes.chooseLocaitonMap)
                        as Map?;
                var latlng = placeMark!['latlng'];
                if (latlng != null) {
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                        latlng.latitude, latlng.longitude);
                    Placemark place = placemarks.first;
                    String address =
                        '${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
                    setState(() {
                      currentAddress = address;
                      currentPlace =
                          '${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
                      currentMainCity = '${place.locality}';
                      getServiceList('', currentMainCity);
                    });
                    // HiveUtils.setCurrentAddress(address);
                  } catch (e) {
                    print("Error fetching address: $e");
                  }
                }
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/AddPostforms/__White location.png',
                    width: 10,
                    height: 10,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 100,
                    child: Text(
                      '${currentPlace}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    'assets/AddPostforms/__Down white.png',
                    width: 10,
                    height: 10,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),*/
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(30.0),
              //       border: Border.all(
              //           color: Color(0xffebebeb),
              //           width: 1
              //       )
              //   ),
              //   padding: EdgeInsets.fromLTRB(15, 0, 6, 0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //
              //       Expanded(
              //         child: TextFormField(
              //           controller: searchControler,
              //           onChanged: (val) {
              //             getServiceList(val);
              //           },
              //           decoration: const InputDecoration(
              //               hintText: 'Search Here',
              //               hintStyle: TextStyle(
              //                 fontFamily: 'Poppins',
              //                 fontSize: 14.0,
              //                 color: Color(0xff9c9c9c),
              //                 fontWeight: FontWeight.w500,
              //                 decoration: TextDecoration.none,
              //               ),
              //               enabledBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(
              //                   color: Colors.transparent, // Remove the border
              //                 ),
              //               ),
              //               focusedBorder: UnderlineInputBorder(
              //                   borderSide: BorderSide(
              //                     color: Colors.transparent,
              //                   ))
              //           ),
              //         ),
              //       ),
              //
              //       Container(
              //         width: 35,
              //         height: 35,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(50),
              //           color: Color(0xff117af9),
              //         ),
              //         child: Center(
              //           child: Image.asset(
              //             'assets/Home/__Search.png',
              //             width: 20,
              //             height: 20.0,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: const Color(0xffebebeb),
                        width: 1
                    )
                ),
                child: Row(
                  children: [
                    Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: GooglePlaceAutoCompleteTextField(
                        boxDecoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent)
                        ),
                        textEditingController: locationControler,
                        textStyle: const TextStyle(fontSize: 14),
                        inputDecoration:   const InputDecoration(
                          hintText: 'Enter City,Locality...',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff9c9c9c),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),

                        googleAPIKey: "AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8",
                        debounceTime: 800,
                        countries: ["in"],
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          print("placeDetails" + prediction.lng.toString());
                          // lat = prediction.lat.toString();
                          // lng = prediction.lng.toString();
                          setState(() { });
                        },
                        itemClick: (Prediction prediction) {
                          locationControler.text = prediction.description!;
                          locationControler.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                          List address = prediction.description!.split(',').reversed.toList();
                          if(address.length >= 3) {
                            locationValue = address[2];

                            setState(() { });
                          } else if(address.length == 2) {
                            locationValue = address[1];

                            setState(() { });
                          } else if(address.length == 1) {
                            locationValue = address[0];

                            setState(() { });
                          }
                          getServiceList("",locationValue);
                        },
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                                const SizedBox(width: 7,),
                                Expanded(
                                    child:
                                    Text("${prediction.description ?? ""}",style: const TextStyle(fontSize: 14,color: Colors.black),))
                              ],
                            ),
                          );
                        },
                        seperatedBuilder: const Divider(),
                        isCrossBtnShown: true,
                        placeType: PlaceType.geocode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              // CarouselSlider(
              //   options: CarouselOptions(
              //     aspectRatio: 1.9,
              //     viewportFraction: 1.0,
              //     autoPlay: true,
              //     onPageChanged: (index, reason) {
              //       setState(() {
              //         currentIndex = index;
              //       });
              //     },
              //   ),
              //   items: [
              //     for (var img in banners)
              //       Container(
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(15.0),
              //           child: CachedNetworkImage(
              //             imageUrl: img,
              //             fit: BoxFit.cover,
              //             width: double.infinity,
              //             placeholder: (context, url) => Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
              //             errorWidget: (context, url, error) =>  Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
              //           ),
              //         ),
              //       )
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              if (Loading)
                ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            child: CustomShimmer(height: 90, width: 90),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomShimmer(
                                  height: 10,
                                  width: MediaQuery.sizeOf(context).width - 100,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const CustomShimmer(
                                  height: 10,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomShimmer(
                                  height: 10,
                                  width: MediaQuery.sizeOf(context).width / 1.2,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomShimmer(
                                  height: 10,
                                  width: MediaQuery.sizeOf(context).width / 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  shrinkWrap: true,
                  itemCount: 8,
                ),
              SizedBox(
                height: 10,
              ),
              for (var i = 0; i < serviceList.length; i++)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ServiceDetail(id: serviceList[i]['id'])),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(width: 1, color: Color(0xffe5e5e5))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            // child: Image.network("${serviceList[i]['photo']}",width: 90,height: 90,),
                            child: UiUtils.getImage(
                              serviceList[i]['photo'] ?? "",
                              width: 90,
                              fit: BoxFit.cover,
                              height: 90,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${serviceList[i]['title']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    if (serviceList[i]['status'] == 'Verified')
                                      Image.asset(
                                        "assets/verified.png",
                                        width: 20,
                                        height: 20,
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/Loans/_-114.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '${UiUtils.trimNumberToOneDecimal(serviceList[i]['reviews_avg_ratting'] ?? '0')} (${serviceList[i]['user_count']} Ratings)',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d)),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${serviceList[i]['service_type']['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '₹ ${serviceList[i]['price'] ?? '0'}/-',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/Home/__location.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '${serviceList[i]['location'] ?? '--'}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              if (serviceList.isEmpty) NoDataFound(),
            ],
          ),
        ),
      ),
    );
  }
}
