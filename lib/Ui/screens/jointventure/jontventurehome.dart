import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../app/routes.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
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

  List jointVenturTypeList = [];

  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  TextEditingController searchControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();

  final List<String> _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];


  String? _selectedItemID;


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
    getVentures();
    getjointVentureTypes();
    super.initState();
  }

  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<void> getjointVentureTypes() async {

    var response = await Api.get(url: Api.getVenturetype, );
    if(!response['error']) {
      setState(() {
        jointVenturTypeList = response['data'];
      });
    }
  }



  Future<void> getVentures({String? location, String? jointType}) async {
    setState(() {
      Loading = true;
    });


    Map<String, String> queryParameters = {};

    if (jointType != null) {
      queryParameters['type'] = jointType;
    }

    if (location != null) {
      queryParameters['city'] = location;
    }

    var response = await Api.get(url: Api.venturesList, queryParameters: queryParameters);

    if (!response['error']) {
      setState(() {
        venturesList = response['data'];
        Loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFFFAF9F6),
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Joint Ventures',
          actions: [
          ]),
 /*     appBar: AppBar(
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
      ),*/
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

             Container(
               padding: EdgeInsets.only(left: 8,top: 8,bottom: 8),
               decoration: BoxDecoration(
                 //border: Border.all(  color: Color(0xffebebeb),),
                 borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                     offset: const Offset(0, 1),
                     blurRadius: 5,
                     color: Colors.black.withOpacity(0.1),
                   ),
                 ],
               ),
               child: Column(
                 children: [
                   Container(
                     padding: EdgeInsets.only(left: 10),
                     width: double.infinity,
                     // decoration: BoxDecoration(
                     //     borderRadius: BorderRadius.circular(10.0),
                     //     border: Border.all(
                     //         color: Color(0xffebebeb),
                     //         width: 1
                     //     )
                     // ),
                     child: Row(
                       children: [
                         Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                         SizedBox(width: 10,),
                         Expanded(
                           child: GooglePlaceAutoCompleteTextField(
                             boxDecoration: BoxDecoration(
                                 border: Border.all(color: Colors.transparent)
                             ),
                             textEditingController: locationControler,
                             textStyle: TextStyle(fontSize: 14),
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
                                         Text("${prediction.description ?? ""}",style: TextStyle(fontSize: 14,color: Colors.black),))
                                   ],
                                 ),
                               );
                             },
                             seperatedBuilder: Divider(),
                             isCrossBtnShown: true,
                             placeType: PlaceType.geocode,
                           ),
                         ),
                       ],
                     ),
                   ),
                   SizedBox(height: 0,),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 15),
                     child: Divider(thickness: 1.5,),
                   ),
                   SizedBox(height: 0,),
                   Container(
                     padding: EdgeInsets.only(left: 10,right: 10),
                     width: double.infinity,
                     // decoration: BoxDecoration(
                     //     borderRadius: BorderRadius.circular(10.0),
                     //     border: Border.all(
                     //         color: Color(0xffebebeb),
                     //         width: 1
                     //     )
                     // ),
                     child: Row(
                       children: [
                         Image.asset("assets/assets/Images/advertisement.png",height: 20,width: 20,),
                         SizedBox(width: 10,),
                         Expanded(
                           child: DropdownButton<String>(
                             underline: const SizedBox(),
                             value: _selectedItemID,
                             isExpanded: true,
                             icon: _selectedItemID != null
                                 ? GestureDetector(
                               onTap: () {
                                 setState(() {
                                   _selectedItemID = null;
                                 });
                               },
                               child: Icon(Icons.close,size: 25,color: Colors.black,),
                             )
                                 : Icon(Icons.keyboard_arrow_down_outlined,color: Colors.black,),
                             hint: const Text(
                               'Joint Venture Type...',
                               style: TextStyle(
                                 fontSize: 14,
                                 fontWeight: FontWeight.w400,
                                 color: Color(0xff9c9c9c),
                               ),
                             ),
                             items: jointVenturTypeList.map<DropdownMenuItem<String>>((dynamic item) {
                                 return DropdownMenuItem<String>(
                                   value: item['id'].toString(),
                                   child: Text(item['name'] ?? '', style: TextStyle(fontSize: 14)),
                                 );
                               }).toList(),
                             onChanged: (String? newValue) {
                               setState(() {
                                 _selectedItemID = newValue;
                               });
                             },
                           ),
                         )
                       ],
                     ),
                   ),
             
                 ],
               ),
             ),
              SizedBox(height: 10,),
              InkWell(
                onTap: (){
                  getVentures(location: locationControler.text,jointType:_selectedItemID );
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xff117af9),
                    borderRadius: BorderRadius.circular(30),
                  ),child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/assets/Images/search.png",height: 30,width: 30,),
                    Text(Loading?"Loading...":"Search",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w500),)
                  ],
                ),
                ),
              ),
              SizedBox(height: 5,),


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
