import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/routes.dart';
import '../../../utils/api.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../filter_screen.dart';
import '../userprofile/userProfileScreen.dart';


class see_allBuilders extends StatefulWidget {
  const see_allBuilders({super.key});

  @override
  State<see_allBuilders> createState() => _TopBuildersState();
}

class _TopBuildersState extends State<see_allBuilders> {
  bool builderLoading = false;
  List topBuilderList = [];
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  int offset = 0;
  late ScrollController controller;
  bool AgentLoadingMore = false;
  int totalcount = 0;

  String? locationValue='';
  TextEditingController locationControler = TextEditingController();

  Future<void> getTopBuilder(String? city) async {
    setState(() {
      builderLoading = true;
    });

    try {
      var response = await Api.get(url: Api.gettop_builder, queryParameters: {
        'limit': 10,
        'offset': offset,
        'city': city!,
      });

      if (!response['error']) {
        setState(() {
          topBuilderList = response['data'] ?? [];
          totalcount = response['total'];
          builderLoading = false;
          offset += 10;
        });
      }
    } catch (e) {
      // Handle API fetch error
      setState(() {
        builderLoading = false;
        topBuilderList = [];
      });
      print('Error fetching agents: $e');
    }
  }


  Future<void> getAgentMore() async {
    setState(() {
      AgentLoadingMore = true;
    });
    var response = await Api.get(url: Api.gettop_builder, queryParameters: {
      'offset': offset,
      'limit': 10,
      'city': locationValue ?? '',
    });
    if(!response['error']) {
      setState(() {
        topBuilderList.addAll((response['data'] as List).toList());
        AgentLoadingMore = false;
        offset += 10;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    super.dispose();
  }


  void _loadMore() async {
    if (controller.isEndReached()) {
      if (totalcount > topBuilderList.length && !builderLoading && !AgentLoadingMore) {
        getAgentMore();
      }
    }
  }


  @override
  void initState() {
    getTopBuilder('');
    controller = ScrollController()..addListener(_loadMore);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Top Builders (${totalcount ?? 0})',
          actions: [
          ]),
     /* appBar:  AppBar(

        backgroundColor: tertiaryColor_,
        leadingWidth: 40, // Adjust the width to decrease the space between back icon and title
        titleSpacing: 15,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Agents',
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
                      getTopBuilder(currentMainCity);
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
      ),*/
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
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
                      List address = prediction.description!.split(',').reversed.toList();
                      if(address.length >= 3) {
                        locationValue = address[2];
                        offset=0;
                        setState(() { });
                        getTopBuilder(locationValue);
                      } else if(address.length == 2) {
                        locationValue = address[1];
                        offset=0;
                        setState(() { });
                        getTopBuilder(locationValue);
                      } else if(address.length == 1) {
                        locationValue = address[0];
                        offset=0;
                        setState(() { });
                        getTopBuilder(locationValue);
                      }

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
          SizedBox(height: 10),
          builderLoading
              ?  Expanded(
                child: Center(child: Center(
                            child: UiUtils.progress(
                normalProgressColor:  const Color(0xff117af9),
                            ),
                ),),
              )
              : topBuilderList.isEmpty
              ? const Expanded(
                child: Center(
                child: Text(
                    'No Builders Found')),
              )
              : Expanded(
                child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                           controller: controller,
                            itemCount: topBuilderList.length,
                            itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          UserDetailProfileScreen(id: topBuilderList[index]['id'], isAgent: false, )),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10,bottom: 5),
                    child: buildAgentCard(size, topBuilderList[index]),
                  ),
                );
                            },
                          ),
              ),
          if (AgentLoadingMore) UiUtils.progress()
        ],
      ),
    );
  }

  // Build shimmer effect for loading state
  Widget _buildShimmerList(Size size) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 10, // Placeholder for 5 shimmer cards
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,bottom: 5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: size.height * 0.23,
                width: size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build the agent card as a reusable widget
  Widget buildAgentCard(Size size, dynamic agent) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF9ea1a7)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF9ea1a7)),
                    borderRadius: BorderRadius.circular(15),
                    image: agent['profile'] != null
                        ? DecorationImage(
                      image: NetworkImage(agent['profile']),
                      fit: BoxFit.cover,
                    )
                        : DecorationImage(
                      image: AssetImage('assets/FilterSceen/2.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 10), // Space between image and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.7,
                      child: Text(
                        agent['name'] ?? 'Unknown Agent', // Fallback if null
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Image.asset('assets/rera_tic.png', height: 14, width:14),
                          SizedBox(width: 2),
                          Text(
                            'RERA ID : ${agent['rera'] ?? 'N/A'}',
                            // Fallback if null
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9ea1a7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10), // Space between agent details and properties
            Container(
              height: size.height * 0.10,
              decoration: BoxDecoration(
                color: Color(0xFFf5f9ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              Column(
              children: [
                  buildPropertyColumn(agent['project_count']?.toString() ?? '0',
                "Total \nProjects"),
                    ],
                  ),
                            const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: VerticalDivider(color: Colors.grey, thickness: 2),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildPropertyColumn(agent['city_count']?.toString() ?? '0', "City"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPropertyColumn(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            count,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),

        Text(
          label,
          textAlign: TextAlign.justify,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9ea1a7)),
        ),
      ],
    );
  }
}