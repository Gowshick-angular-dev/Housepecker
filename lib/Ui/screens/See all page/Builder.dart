import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/routes.dart';
import '../../../utils/api.dart';
import '../../../utils/hive_utils.dart';
import '../../Theme/theme.dart';
import '../filter_screen.dart';


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

  Future<void> getTopBuilder(String? city) async {
    setState(() {
      builderLoading = true;
    });

    try {
      var response = await Api.get(url: Api.gettop_builder, queryParameters: {
        'limit': 25,
        'city': city!,
        // 'current_user': HiveUtils.getUserId()
      });

      if (!response['error']) {
        setState(() {
          topBuilderList = response['data'] ?? [];
          builderLoading = false;
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

  @override
  void initState() {
    if ( city == null){
      getTopBuilder('');
    }else{
      getTopBuilder(city!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar:  AppBar(

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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10), // Add space between title and list
            SizedBox(
              height: size.height * 0.85, // Fixed height for the list
              child: builderLoading
                  ? _buildShimmerList(size) // Show shimmer when loading
                  : topBuilderList.isEmpty
                  ? Center(
                  child: Text(
                      'No Builders Found')) // Show message if list is empty
                  : ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: topBuilderList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10,bottom: 5),
                    child: buildAgentCard(size, topBuilderList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build shimmer effect for loading state
  Widget _buildShimmerList(Size size) {
    return ListView.builder(
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
    );
  }

  // Build the agent card as a reusable widget
  Widget buildAgentCard(Size size, dynamic agent) {
    return Container(
      height: size.height * 0.23,
      width: size.width * 0.7,
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
                    image: agent['profile'] != null
                        ? DecorationImage(
                      image: NetworkImage(agent['profile']),
                      fit: BoxFit.contain,
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
                    Text(
                      agent['name'] ?? 'Unknown Agent', // Fallback if null
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis),
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
              height: size.height * 0.12,
              decoration: BoxDecoration(
                color: Color(0xFFf5f9ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  buildPropertyColumn(agent['project_count']?.toString() ?? '0',
                      "Total\nProjects"),
                  // Fallback to '0'
                  // Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 10),
                  //   child: VerticalDivider(color: Colors.grey, thickness: 2),
                  // ),
                  // Spacer(),
                  // buildPropertyColumn(agent['city'] ?? 'Unknown', "City"), // Fallback to 'Unknown'
                  // SizedBox(width: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a column for property stats
  Widget buildPropertyColumn(String count, String label) {
    return Column(
      children: [
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            count,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9ea1a7)),
        ),
      ],
    );
  }
}