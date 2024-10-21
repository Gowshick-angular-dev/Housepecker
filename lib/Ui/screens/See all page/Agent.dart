import 'package:Housepecker/Ui/screens/filter_screen.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
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
import '../home/Widgets/header_card.dart';
import '../userprofile/userProfileScreen.dart';



class seeallAgent extends StatefulWidget {
  const seeallAgent({super.key});

  @override
  State<seeallAgent> createState() => _seeallAgentState();
}

class _seeallAgentState extends State<seeallAgent> {
  // Dummy data for agents
  final List<String> agents = [
    "Agent Tobi Jr",
    "Agent Jane Doe",
    "Agent John Smith",
    "Agent Max Lee",
    "Agent Emma White",
  ];
  bool AgentLOading = false;
  List Top_agenylist = [];
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  String? locationValue='';
  TextEditingController locationControler = TextEditingController();

  Future<void> gettop_Agents(String? city) async {
    setState(() {
      AgentLOading = true;
    });
    var response = await Api.get(url: Api.gettop_agent, queryParameters: {

      'city': city!,
      'limit': 25,
      // 'current_user': HiveUtils.getUserId()
    });
    if (!response['error']) {
      setState(() {
        Top_agenylist = response['data'];
        AgentLOading = false;
      });
    }
  }

  @override
  void initState() {
    gettop_Agents('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'Top Agents (${Top_agenylist?.length ?? 0})',
        actions: [],
      ),
      /* appBar: AppBar(
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
                      gettop_Agents(currentMainCity);
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
                        gettop_Agents(locationValue);
                        setState(() { });
                      } else if(address.length == 2) {
                        locationValue = address[1];
                        gettop_Agents(locationValue);
                        setState(() { });
                      } else if(address.length == 1) {
                        locationValue = address[0];
                        gettop_Agents(locationValue);
                        setState(() { });
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
          AgentLOading
              ?  Expanded(
            child: Center(child: Center(
              child: UiUtils.progress(
                normalProgressColor:  const Color(0xff117af9),
              ),
            ),),
          )
              : Top_agenylist.isEmpty
                  ? Expanded(
                child: Center(
                    child: Text(
                        'No Agents Found')),
                  )
              : Expanded(
                child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: Top_agenylist.length,
                              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10,bottom: 5),
                  child: buildAgentCard(size, Top_agenylist[index]),
                );
                              },
                            ),
              ),
        ],
      ),
    );
  }

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
                    image: DecorationImage(
                      image: NetworkImage(agent['profile']),
                      // Load agent image dynamically
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent['name'], // Display agent's name
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
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
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1, // Display RERA ID
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9ea1a7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: size.height * 0.10,
              decoration: BoxDecoration(
                color: Color(0xFFfff5f1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPropertyColumn(agent['sell_property']?.toString() ?? '0',
                      "Properties for\nsale"), // Default to '0'
                  VerticalDivider(color: Colors.grey, thickness: 2),
                  buildPropertyColumn(agent['rent_property']?.toString() ?? '0',
                      "Properties for\nrent"), // Default to '0'
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View All Properties',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF9ea1a7)),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserDetailProfileScreen(id: agent['id'], isAgent: true,)),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'View Profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
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
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            count,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 5),
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


  Widget buildShimmerList(Size size) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 5, // Arbitrary number of shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,bottom: 5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: size.height * 0.3,
                width: size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}