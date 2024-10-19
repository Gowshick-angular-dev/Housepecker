import 'package:Housepecker/Ui/screens/filter_screen.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
  if ( city == null){
    gettop_Agents('');
  }else{
    gettop_Agents(city!);
  }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Top Agents',
          actions: [
          ]),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            SizedBox(
              height: size.height * 0.85,
              child: AgentLOading
                  ? buildShimmerList(size) // Show shimmer effect if loading
                  : ListView.builder(
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
      ),
    );
  }

  // Build agent card widget dynamically from data
  Widget buildAgentCard(Size size, dynamic agent) {
    return Container(
      height: size.height * 0.28,
      width: size.width * 0.75,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF9ea1a7)),
        borderRadius: BorderRadius.circular(12),
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
                      fit: BoxFit.contain,
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
                          ImageIcon(
                            AssetImage('assets/FilterSceen/2.png'),
                            size: 14,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'RERA ID : ${agent['rera']}',
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
              height: size.height * 0.11,
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
                      fontWeight: FontWeight.bold, color: Color(0xFF9ea1a7)),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserDetailProfileScreen(id: agent['id'])),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
    return ListView.builder(
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
    );
  }
}