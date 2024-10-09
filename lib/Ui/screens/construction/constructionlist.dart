import 'package:Housepecker/Ui/screens/filter_screen.dart';
import 'package:Housepecker/exports/main_export.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/Service/servicedetail.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'constructiondetail.dart';


class ConstructionList extends StatefulWidget {
  final int? id;
  final String? name;
  const ConstructionList({super.key, this.id, this.name});

  @override
  State<ConstructionList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ConstructionList> {

  TextEditingController searchControler = TextEditingController();
  bool Loading = false;
  List serviceList = [];
  List banners = [];
  int currentIndex = 0;
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  String dropdownvalue6 = 'Chennai';
  var items6 =  ['Chennai','Madurai'];
  String dropdownvalue5 = 'Select Locality';
  var items5 =  ['Select Locality','Tamil'];
  String dropdownvalue4 = 'Loan Type';
  var items4 =  ['Loan Type','Gold Loan'];
  final serviceIncludeList = [
    { 'image': 'assets/Loans/1.png', },
    {'image': 'assets/Loans/2.png',},
    {'image': 'assets/Loans/3.png',},
    {'image': 'assets/Loans/4.png',},
    {'image': 'assets/Loans/5.png', },
    {'image': 'assets/Loans/6.png', }
  ];

  @override
  void initState() {
    _getCurrentLocation();
    getBanners();
    getServiceList('','');
    super.initState();
  }

  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<void> _getCurrentLocation() async {
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
  }

  void getBanners() async {
    var response = await Api.post(url: Api.apiGetSystemSettings, parameter: {
      'city': currentMainCity,
    });
    if(!response['error']) {
      setState(() {
        banners = [response['data']['advertisement_first_banner'], response['data']['advertisement_second_banner']];
      });
    }
  }

  Future<void> getServiceList(String? search, String? city) async {
    setState(() {
      Loading = true;
    });
    var response = await Api.get(url: Api.constructionsList, queryParameters: {
      'property_type': widget.id,
      'city': city!,
      'search': search!
    });
    if(!response['error']) {
      setState(() {
        serviceList = response['data'];
        Loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tertiaryColor_,
        leadingWidth: 40, // Adjust the width to decrease the space between back icon and title
        titleSpacing: 15,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.name!}',
              style: TextStyle(
                  fontSize: 14,color: Colors.white
              ),
            ),
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                Map? placeMark =
                await Navigator.pushNamed(context, Routes.chooseLocaitonMap) as Map?;
                var latlng = placeMark!['latlng'];
                if(latlng != null) {
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
                    Placemark place = placemarks.first;
                    String address = '${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
                    setState(() {
                      currentAddress = address;
                      currentPlace = '${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
                      currentMainCity = '${place.locality}';
                      getServiceList('',currentMainCity);
                    });
                    HiveUtils.setCurrentAddress(address);
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
                  SizedBox(width: 5,),
                  Container(
                    width: 100,
                    child: Text('${currentPlace}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),
                    ),
                  ),
                  SizedBox(width: 5,),
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
      ),
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
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 1.9,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                items: [
                  for (var img in banners)
                    Container(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(15.0),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    )
                ],
              ),
              if(Loading)
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
              SizedBox(height: 10,),
              for(var i = 0; i < serviceList.length; i++)
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  ConstructionDetail(id: serviceList[i]['id'])),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: Color(0xffe5e5e5)
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              // child: Image.network("${serviceList[i]['photo']}",width: 90,height: 90,),
                              child: UiUtils.getImage(
                                serviceList[i]['photo'] ?? "",
                                width: 90, fit: BoxFit.cover, height: 90,
                              ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${serviceList[i]['title']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),),
                                    SizedBox(width: 2,),
                                    if(serviceList[i]!['status'] == 'Verified')
                                      Image.asset("assets/verified.png",width: 20,height: 20,),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset("assets/Loans/_-114.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text('${UiUtils.trimNumberToOneDecimal(serviceList[i]['reviews_avg_ratting'] ?? '0')} (${serviceList[i]['user_count']} Ratings)',style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),)
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('${serviceList[i]['property_type']['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                    ),
                                    // SizedBox(width: 5,),
                                    // Text('₹ ${serviceList[i]['price'] ?? '0'}/-',
                                    //   style: TextStyle(
                                    //     fontSize: 12,
                                    //     color: Colors.black,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset("assets/Home/__location.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text('${serviceList[i]['location'] ?? '--'}',style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),),
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
              if(serviceList.isEmpty)
                NoDataFound(),
            ],
          ),
        ),
      ),
    );
  }
}
