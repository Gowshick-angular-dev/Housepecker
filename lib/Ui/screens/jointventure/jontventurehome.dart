import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../app/routes.dart';
import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'jointventuredetail.dart';


class JointVenture extends StatefulWidget {
  const JointVenture({super.key});

  @override
  State<JointVenture> createState() => _JointVentureState();
}

class _JointVentureState extends State<JointVenture> {

  bool Loading = false;
  List venturesList = [];
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  TextEditingController searchControler = TextEditingController();
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
    getVentures('');
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
      getVentures('');
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  Future<void> getVentures(String? search) async {
    setState(() {
      Loading = true;
    });
    var response = await Api.get(url: Api.venturesList, queryParameters: {
      'search': search!,
      'city': currentMainCity,
    });
    if(!response['error']) {
      setState(() {
        venturesList = response['data'];
        Loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Joint Ventures',
              style: TextStyle(
                  fontSize: 14,color: Colors.white
              ),
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
                      // getServiceList('', currentMainCity);
                    });
                    getVentures('');
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
        backgroundColor: tertiaryColor_,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                        color: Color(0xffebebeb),
                        width: 1
                    )
                ),
                padding: EdgeInsets.fromLTRB(15, 0, 6, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Expanded(
                      child: TextFormField(
                        controller: searchControler,
                        onChanged: (val) {
                          getVentures(searchControler.text);
                        },
                        decoration: const InputDecoration(
                            hintText: 'Search Here',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.0,
                              color: Color(0xff9c9c9c),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent, // Remove the border
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ))
                        ),
                      ),
                    ),

                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color(0xff117af9),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/Home/__Search.png',
                          width: 20,
                          height: 20.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              if(Loading)
                Column(
                  children: [
                    Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            width: 1,
                            color: Color(0xffe5e5e5)
                        )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                          child: CustomShimmer(height: 150, width: double.infinity),
                        ),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 30, width: 30),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomShimmer(height: 12, width: 200),
                                      SizedBox(height: 3,),
                                      CustomShimmer(height: 10, width: 80),
                                    ],
                                  ),
                                )
                              ],),
                              SizedBox(height: 5,),
                              // CustomShimmer(height: 15, width: 150),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Image.asset("assets/Home/__location.png",width: 15,height: 15,),
                                  SizedBox(width: 5,),
                                  CustomShimmer(height: 10, width: 230),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                                  ),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: Color(0xffe5e5e5)
                          )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            child: CustomShimmer(height: 150, width: double.infinity),
                          ),
                          SizedBox(width: 10,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  ClipRRect(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: CustomShimmer(height: 30, width: 30),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomShimmer(height: 12, width: 200),
                                        SizedBox(height: 3,),
                                        CustomShimmer(height: 10, width: 80),
                                      ],
                                    ),
                                  )
                                ],),
                                SizedBox(height: 5,),
                                // CustomShimmer(height: 15, width: 150),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset("assets/Home/__location.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    CustomShimmer(height: 10, width: 230),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: Color(0xffe5e5e5)
                          )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            child: CustomShimmer(height: 150, width: double.infinity),
                          ),
                          SizedBox(width: 10,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  ClipRRect(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: CustomShimmer(height: 30, width: 30),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomShimmer(height: 12, width: 200),
                                        SizedBox(height: 3,),
                                        CustomShimmer(height: 10, width: 80),
                                      ],
                                    ),
                                  )
                                ],),
                                SizedBox(height: 5,),
                                // CustomShimmer(height: 15, width: 150),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset("assets/Home/__location.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    CustomShimmer(height: 10, width: 230),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
                if(venturesList.length != 0)
                  Column(
                    children: [
                      for(var i = 0; i < venturesList.length; i++)
                        InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  JointventureDetail(id: venturesList[i]['id'])),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 1,
                                  color: Color(0xffe5e5e5)
                              )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  // child: Image.network(venturesList[i]['image'],width: double.infinity,height: 150,fit: BoxFit.cover,)
                                  child: UiUtils.getImage(
                                    venturesList[i]['image'] ?? "",
                                    width: double.infinity,fit: BoxFit.cover,height: 150,
                                  ),
                              ),
                              SizedBox(width: 10,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          // child: Image.network(venturesList[i]['photo'],width: 30,height: 30,fit: BoxFit.cover,),
                                          child: UiUtils.getImage(
                                            venturesList[i]['photo'] ?? "",
                                            width: 30,fit: BoxFit.cover,height: 30,
                                          ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text('${venturesList[i]['title']}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),),
                                                ),
                                                // Row(
                                                //   children: [
                                                //     Image.asset("assets/Loans/_-114.png",width: 15,height: 15,),
                                                //     SizedBox(width: 5,),
                                                //     Text('${UiUtils.trimNumberToOneDecimal(venturesList[i]['reviews_avg_ratting'] ?? '0')} (${venturesList[i]['user_count']} Ratings)',
                                                //       style: TextStyle(
                                                //         fontSize: 11,
                                                //         color: Color(0xff7d7d7d)
                                                //     ),)
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                            SizedBox(height: 3,),
                                            Text('${venturesList[i]['post_date']}',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),),
                                          ],
                                        ),
                                      )
                                    ],),
                                    SizedBox(height: 5,),
                                    Text('${venturesList[i]['post_name']}: ${venturesList[i]['land_size']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Image.asset("assets/Home/__location.png",width: 15,height: 15,),
                                        SizedBox(width: 5,),
                                        Text('${venturesList[i]['location']}',style: TextStyle(
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
                    ],
                  ),
                if(venturesList.length == 0 && !Loading)
                  NoDataFound(),
            ],
          ),
        ),
      ),
    );
  }
}
