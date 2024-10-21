import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/Personalized/personalized_property_screen.dart';
import 'package:Housepecker/Ui/screens/main_activity.dart';
import 'package:Housepecker/data/model/user_model.dart';
import 'package:Housepecker/utils/guestChecker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_theme.dart';
import '../../../app/routes.dart';
import '../../../data/cubits/Utility/like_properties.dart';
import '../../../data/cubits/system/app_theme_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../data/cubits/system/user_details.dart';
import '../../../data/model/property_model.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Network/apiCallTrigger.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../Advertisement/my_advertisment_screen.dart';
import '../Contactus/contactus.dart';
import '../Loan/loanhome.dart';
import '../Service/servicehome.dart';
import '../chat/chat_list_screen.dart';
import '../construction/constructionhome.dart';
import '../home/Widgets/property_horizontal_card.dart';
import '../jointventure/jontventurehome.dart';
import '../projects/myProjectScreen.dart';
import '../proprties/my_properties_screen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/blurred_dialoge_box.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;

import '../widgets/shimmerLoadingContainer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class UserDetailProfileScreen extends StatefulWidget {
  final int? id;
  final String? name;
  final bool? isAgent;

  const UserDetailProfileScreen({Key? key, this.id, this.name,required this.isAgent})
      : super(key: key);

  @override
  State<UserDetailProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserDetailProfileScreen> {
  ValueNotifier isDarkTheme = ValueNotifier(false);
  bool isGuest = false;
  Map? userData;
  bool loading = false;


  List<Map<String, dynamic>> dropDownList = [
    {"id": 0, "name": "Sell"},
    {"id": 1, "name": "Rent"},
  ];

  String? selectedValue;
  String? selectedStatus;
  String? selectedCategory;



  int offset = 0, total = 0;
  List<PropertyModel> propertylist = [];
  List propertyLikeLoading = [];

  bool propertyLoading = false;
  bool propertyLoadingMore = false;

  @override
  void initState() {
    getUser();
    getStatus();
    getCatgory();
    getProperties(propertyType: "");
    super.initState();
  }

  Future<void> getUser() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.getUserDetails, queryParameters: {
      'user_id': widget.id!,
    });
    if (!response['error']) {
      setState(() {
        userData = response['data'];
        loading = false;
      });
    }
  }

  List statusList = [];

  Future<void> getStatus() async {

    var response = await Api.get(url: Api.status, queryParameters: {
      'user_id': widget.id!,
    });
    if (!response['error']) {
      setState(() {
        statusList = response['data'];
      });
    }
  }
  
  List getCatgoryList = [];

  Future<void> getCatgory() async {

    var response = await Api.get(url: Api.apiGetCategories, queryParameters: {
      'user_id': widget.id!,
    });
    if (!response['error']) {
      setState(() {
        getCatgoryList = response['data'];
      });
    }
  }


  Future<void> getProperties({String? propertyType,String? status,String? categoryId}) async {
    setState(() {
      propertyLoading = true;
    });

    var queryParams = {
      'offset': offset,
      'limit': 10.toString(),
      'userid': widget.id,
    };

    if (propertyType != null) {
      queryParams['property_type'] = propertyType;
    }
    if (status != null) {
      queryParams['status'] = status;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }

    var response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: queryParams,
    );

    if (!response['error']) {
      List<PropertyModel> props = (response['data'] as List)
          .where((e) => e['is_type'] == 'property')
          .toList()
          .map((item) => PropertyModel.fromMap(item))
          .toList();
      setState(() {
        total = response['total'];
        propertylist = props;
        propertyLikeLoading = List.filled(response['total'], false);
        propertyLoading = false;
        offset += 10;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: UiUtils.buildAppBar(
        showBackButton: true,
        context,
        title: widget.isAgent == true ? 'Agent Profile':'Builder Profile',
      ),
      body: loading
          ? Center(child: UiUtils.progress(width: 40, height: 40))
          : ScrollConfiguration(
              behavior: RemoveGlow(),
              child: SingleChildScrollView(
                controller: profileScreenController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(15),
                        // height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: profileImgWidget(context),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('${userData!['name']}')
                                              .color(
                                                  context.color.textColorDark)
                                              .size(18)
                                              .bold(weight: FontWeight.w600)
                                              .setMaxLines(lines: 1),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          if (userData!['verified'] != 0)
                                            const Icon(
                                              Icons.verified,
                                              size: 15,
                                              color: Colors.black,
                                            )
                                        ],
                                      ),
                                      if (userData!['company_name'] != null)
                                        Text('${userData!['company_name']}')
                                            .color(
                                                context.color.textColorDark)
                                            .size(13)
                                            .bold(weight: FontWeight.w400)
                                            .setMaxLines(lines: 1),
                                      Text(
                                        userData!['email'].length > 4
                                            ? '${userData!['email'].substring(0, 4)}..@.....'
                                            : '${userData!['email']}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        userData!['mobile'].length > 4
                                            ? '${userData!['mobile'].substring(0, 4)}XXXXXX'
                                            : '${userData!['mobile']}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.only(top: 5,bottom: 5),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFffe6db),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('${userData!['completed_project'] ?? '--'}')
                                              .color(const Color(0xff333333))
                                              .size(context.font.larger)
                                              .setMaxLines(lines: 1),
                                          const Text(
                                            'Total Projects',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('${userData!['experience'] ?? '--'}')
                                              .color(const Color(0xff333333))
                                              .size(context.font.larger)
                                              .setMaxLines(lines: 1),
                                          const Text(
                                            'Experiance',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Address',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),    const SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Image.asset(
                              "assets/Home/__location.png",
                              width: 17,
                              height: 17,
                              color: const Color(0xff9c9c9c),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                userData!['address'] ?? "Address not available",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Text(
                      //     'Social Media',
                      //     style: TextStyle(
                      //         fontSize: 15, fontWeight: FontWeight.bold),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         children: [
                      //           if (userData!['facebook_id'] != '')
                      //             InkWell(
                      //               onTap: () async {
                      //                 await urllauncher.launchUrl(
                      //                     Uri.parse(
                      //                         '${userData!['facebook_id']}'),
                      //                     mode:
                      //                         LaunchMode.externalApplication);
                      //               },
                      //               child: Image.asset(
                      //                 'assets/facebook.png',
                      //                 height: 22,
                      //                 width: 22,
                      //               ),
                      //             ),
                      //           if (userData!['facebook_id'] != '')
                      //             SizedBox(
                      //               width: 5,
                      //             ),
                      //           if (userData!['instagram_id'] != '')
                      //             InkWell(
                      //               onTap: () async {
                      //                 await urllauncher.launchUrl(
                      //                     Uri.parse(
                      //                         '${userData!['instagram_id']}'),
                      //                     mode:
                      //                         LaunchMode.externalApplication);
                      //               },
                      //               child: Image.asset(
                      //                 'assets/instagram.png',
                      //                 height: 22,
                      //                 width: 22,
                      //               ),
                      //             ),
                      //           if (userData!['instagram_id'] != '')
                      //             SizedBox(
                      //               width: 5,
                      //             ),
                      //           if (userData!['twitter_id'] != '')
                      //             InkWell(
                      //               onTap: () async {
                      //                 await urllauncher.launchUrl(
                      //                     Uri.parse(
                      //                         '${userData!['twitter_id']}'),
                      //                     mode:
                      //                         LaunchMode.externalApplication);
                      //               },
                      //               child: Image.asset(
                      //                 'assets/pinterest.png',
                      //                 height: 22,
                      //                 width: 22,
                      //               ),
                      //             ),
                      //           if (userData!['twitter_id'] != '')
                      //             SizedBox(
                      //               width: 5,
                      //             ),
                      //           if (userData!['pintrest_id'] != '')
                      //             InkWell(
                      //               onTap: () async {
                      //                 await urllauncher.launchUrl(
                      //                     Uri.parse(
                      //                         '${userData!['pintrest_id']}'),
                      //                     mode:
                      //                         LaunchMode.externalApplication);
                      //               },
                      //               child: Image.asset(
                      //                 'assets/twitter.png',
                      //                 height: 22,
                      //                 width: 22,
                      //               ),
                      //             ),
                      //           if (userData!['pintrest_id'] != '')
                      //             SizedBox(
                      //               width: 5,
                      //             ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 12,
                      // ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photos',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      if (userData!['gallery'] != null && userData!['gallery'].isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userData!['gallery'].length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            mainAxisExtent: 130,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                UiUtils.imageGallaryView(
                                  context,
                                  images: userData!['gallery'],
                                  initalIndex: index,
                                );
                                // Navigator.push(context,
                                //     BlurredRouter(
                                //       builder: (context) {
                                //         return AllGallaryImages(
                                //             images: userData!['gallery'],
                                //             isProject: true);
                                //       },
                                //     ));
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => FullScreenGallery(
                                //       images: userData!['gallery'],
                                //       initialIndex: index,
                                //     ),
                                //   ),
                                // );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UiUtils.getImage(
                                  userData!['gallery'][index] ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Center(child: Text('No images found!')),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 15,),
                   if(widget.isAgent == true)
                   ...[
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           SizedBox(
                             width: MediaQuery.of(context).size.width/2,
                             child: const Text(
                               'Properties by Home Connect',
                               maxLines: 1,overflow: TextOverflow.ellipsis,
                               style: TextStyle(
                                   fontWeight: FontWeight.w600, fontSize: 14),
                             ),
                           ),
                           Container(
                             height: 40,
                             padding: EdgeInsets.symmetric(horizontal: 10),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(10),
                               boxShadow: [
                                 BoxShadow(
                                   offset: const Offset(0, 1),
                                   blurRadius: 5,
                                   color: Colors.black.withOpacity(0.1),
                                 ),
                               ],
                             ),
                             width: 130,
                             child: DropdownButton<String>(
                               underline: const SizedBox(),
                               isExpanded: true,
                               style: const TextStyle(fontSize: 14,color: Colors.black),
                               hint: const Text("Select an option",style: TextStyle(fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,),
                               value: selectedValue,
                               items: dropDownList.map((item) {
                                 return DropdownMenuItem<String>(
                                   value: item['id'].toString(),
                                   child: Text(item['name']),
                                 );
                               }).toList(),
                               onChanged: (value) {
                                 setState(() {
                                   selectedValue = value;
                                   getProperties(propertyType: value.toString());
                                 });
                               },
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 10,),
                     SizedBox(
                       height: 230,
                       width: size.width,
                       child: propertyLoading?
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 15),
                         child: buildPropertiesShimmer(context,),
                       )
                           :propertylist.isEmpty
                           ? const Center(
                         child: Text(
                           'No properties available',
                           style: TextStyle(fontSize: 14, color: Colors.black),
                         ),
                       )
                           : ListView.separated(
                         padding: const EdgeInsets.symmetric(horizontal: 15),
                         separatorBuilder: (context,i)=>const SizedBox(width: 10,),
                         scrollDirection: Axis.horizontal,
                         itemCount: propertylist.length,
                         itemBuilder: (context, index) {
                           PropertyModel property = propertylist[index];
                           return GestureDetector(
                             onTap: () {
                               Navigator.pushNamed(
                                 context,
                                 Routes.propertyDetails,
                                 arguments: {
                                   'propertyData': property,
                                   'propertiesList': propertylist,
                                   'fromMyProperty': false,
                                 },
                               );
                             },
                             child: PropertyVerticalCard(
                               property: property,
                             ),
                           );
                         },
                       ),
                     ),
                   ],
                      if(widget.isAgent == false)
                        ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: const Text(
                                    'Projects by AR Foundation',
                                    maxLines: 1,overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    width: 130,
                                    child: DropdownButton<String>(
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 14,color: Colors.black),
                                      hint: const Text("Select an status",style: TextStyle(fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      value: selectedStatus,
                                      items: statusList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['id'].toString(),
                                          child: Text(item['name']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    width: 130,
                                    child: DropdownButton<String>(
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 14,color: Colors.black,),
                                      hint: const Text("Select an categories",style: TextStyle(fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      value: selectedCategory,
                                      items: getCatgoryList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['id'].toString(),
                                          child: Text(item['category']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategory = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                InkWell(
                                  onTap: (){
                                    getProperties(status: selectedStatus,propertyType: selectedCategory);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff117af9),
                                      borderRadius: BorderRadius.circular(10)
                                    ),child:Center(child: Image.asset("assets/assets/Images/search.png"),),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 15,),
                          SizedBox(
                            height: 230,
                            width: size.width,
                            child: propertyLoading?
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: buildPropertiesShimmer(context,),
                            )
                                :propertylist.isEmpty
                                ? const Center(
                              child: Text(
                                'No properties available',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            )
                                : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              separatorBuilder: (context,i)=>const SizedBox(width: 10,),
                              scrollDirection: Axis.horizontal,
                              itemCount: propertylist.length,
                              itemBuilder: (context, index) {
                                PropertyModel property = propertylist[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.propertyDetails,
                                      arguments: {
                                        'propertyData': property,
                                        'propertiesList': propertylist,
                                        'fromMyProperty': false,
                                      },
                                    );
                                  },
                                  child: PropertyVerticalCard(
                                    property: property,
                                  ),
                                );
                              },
                            ),
                          ),

                        ],

                      const SizedBox(height: 30,)



                      // Column(
                      //   children: [
                      //     if (propertyLoading)
                      //       Expanded(
                      //         child: Padding(
                      //           padding: const EdgeInsets.symmetric(horizontal: 15),
                      //           child: buildPropertiesShimmer(context),
                      //         ),
                      //       ),
                      //     if (!propertyLoading)
                      //
                      //   ],
                      // ),

                      //               SizedBox(
                      // height: 200,
                      // child: GridView.builder(
                      // shrinkWrap: true,
                      // scrollDirection: Axis.horizontal,
                      // itemCount:
                      // widget.projectLoading! ? 10 : widget.projectList!.length,
                      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // crossAxisCount: 1,
                      // crossAxisSpacing: 8,
                      // mainAxisSpacing: 8,
                      // // mainAxisExtent: 200,
                      // childAspectRatio: MediaQuery.sizeOf(context).height / 950),
                      // itemBuilder: (context, index) {
                      // if (!widget.projectLoading!) {
                      // return Padding(
                      // padding: EdgeInsets.only(
                      // left: (index == 0 ? 10 : 0),
                      // right: (widget.projectLoading!
                      // ? 10
                      //     : widget.projectList!.length) ==
                      // (index + 1)
                      // ? 10
                      //     : 0),
                      // child: Container(
                      // width: 230,
                      // child: GestureDetector(
                      // onTap: () {
                      // Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      // builder: (context) => ProjectDetails(
                      // property: widget.projectList![index],
                      // fromMyProperty: true,
                      // fromCompleteEnquiry: true,
                      // fromSlider: false,
                      // fromPropertyAddSuccess: true)),
                      // );
                      // },
                      // child: Container(
                      // // height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
                      // decoration: BoxDecoration(
                      // color: Colors.white,
                      // borderRadius: BorderRadius.circular(15),
                      // border: Border.all(
                      // width: 1, color: Color(0xffe0e0e0))),
                      // child: Stack(
                      // fit: StackFit.expand,
                      // children: [
                      // Column(
                      // mainAxisSize: MainAxisSize.min,
                      // children: [
                      // Column(
                      // children: [
                      // ClipRRect(
                      // borderRadius: BorderRadius.only(
                      // topRight: Radius.circular(15),
                      // topLeft: Radius.circular(15),
                      // ),
                      // child: Stack(
                      // children: [
                      // UiUtils.getImage(
                      // widget.projectList![index]
                      // ['image'] ??
                      // "",
                      // width: double.infinity,
                      // fit: BoxFit.cover,
                      // height: 103,
                      // ),
                      // // const PositionedDirectional(
                      // //     start: 5,
                      // //     top: 5,
                      // //     child: PromotedCard(
                      // //         type: PromoteCardType.icon)),
                      // // PositionedDirectional(
                      // //   bottom: 6,
                      // //   start: 6,
                      // //   child: Container(
                      // //     height: 19,
                      // //     clipBehavior: Clip.antiAlias,
                      // //     decoration: BoxDecoration(
                      // //         color: context.color.secondaryColor
                      // //             .withOpacity(0.7),
                      // //         borderRadius:
                      // //         BorderRadius.circular(4)),
                      // //     child: BackdropFilter(
                      // //       filter: ImageFilter.blur(
                      // //           sigmaX: 2, sigmaY: 3),
                      // //       child: Padding(
                      // //         padding: const EdgeInsets.symmetric(
                      // //             horizontal: 8.0),
                      // //         child: Center(
                      // //           child: Text(widget.projectList![index]['category'] != null ?
                      // //             widget.projectList![index]['category']!['category'] : '',
                      // //           )
                      // //               .color(
                      // //             context.color.textColorDark,
                      // //           )
                      // //               .bold(weight: FontWeight.w500)
                      // //               .size(10),
                      // //         ),
                      // //       ),
                      // //     ),
                      // //   ),
                      // // ),
                      // Positioned(
                      // right: 8,
                      // top: 8,
                      // child: InkWell(
                      // onTap: () {
                      // GuestChecker.check(
                      // onNotGuest: () async {
                      // setState(() {
                      // widget.likeLoading![
                      // index] = true;
                      // });
                      // var body = {
                      // "type": widget.projectList![
                      // index][
                      // 'is_favourite'] ==
                      // 1
                      // ? 0
                      //     : 1,
                      // "project_id":
                      // widget.projectList![
                      // index]['id']
                      // };
                      // var response =
                      // await Api.post(
                      // url: Api
                      //     .addFavProject,
                      // parameter: body);
                      // if (!response['error']) {
                      // widget.projectList![
                      // index][
                      // 'is_favourite'] =
                      // (widget.projectList![
                      // index]
                      // [
                      // 'is_favourite'] ==
                      // 1
                      // ? 0
                      //     : 1);
                      // setState(() {
                      // widget.likeLoading![
                      // index] = false;
                      // });
                      // }
                      // });
                      // },
                      // child: Container(
                      // width: 32,
                      // height: 32,
                      // decoration: BoxDecoration(
                      // color: context
                      //     .color.secondaryColor,
                      // shape: BoxShape.circle,
                      // boxShadow: const [
                      // BoxShadow(
                      // color: Color.fromARGB(
                      // 12, 0, 0, 0),
                      // offset: Offset(0, 2),
                      // blurRadius: 15,
                      // spreadRadius: 0,
                      // )
                      // ],
                      // ),
                      // child: Container(
                      // width: 32,
                      // height: 32,
                      // decoration: BoxDecoration(
                      // color: context
                      //     .color.primaryColor,
                      // shape: BoxShape.circle,
                      // boxShadow: const [
                      // BoxShadow(
                      // color: Color
                      //     .fromARGB(33,
                      // 0, 0, 0),
                      // offset:
                      // Offset(0, 2),
                      // blurRadius: 15,
                      // spreadRadius: 0)
                      // ],
                      // ),
                      // child: Center(
                      // child: (widget
                      //     .likeLoading![
                      // index])
                      // ? UiUtils
                      //     .progress(
                      // width: 20,
                      // height:
                      // 20)
                      //     : widget.projectList![
                      // index]
                      // [
                      // 'is_favourite'] ==
                      // 1
                      // ? UiUtils
                      //     .getSvg(
                      // AppIcons
                      //     .like_fill,
                      // color: context
                      //     .color
                      //     .tertiaryColor,
                      // )
                      //     : UiUtils.getSvg(
                      // AppIcons
                      //     .like,
                      // color: context
                      //     .color
                      //     .tertiaryColor)),
                      // ),
                      // ),
                      // ),
                      // ),
                      // ],
                      // ),
                      // ),
                      // ],
                      // ),
                      // Padding(
                      // padding: const EdgeInsets.only(
                      // left: 10, right: 10),
                      // child: Column(
                      // crossAxisAlignment:
                      // CrossAxisAlignment.start,
                      // mainAxisAlignment:
                      // MainAxisAlignment.spaceEvenly,
                      // children: [
                      // SizedBox(
                      // height: 6,
                      // ),
                      // Text(
                      // widget.projectList![index]['title'],
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      // style: TextStyle(
                      // color: Color(0xff333333),
                      // fontSize: 12.5,
                      // fontWeight: FontWeight.w500),
                      // ),
                      // SizedBox(
                      // height: 4,
                      // ),
                      // if (widget.projectList![index]
                      // ['address'] !=
                      // "")
                      // Padding(
                      // padding: const EdgeInsets.only(
                      // bottom: 4),
                      // child: Row(
                      // children: [
                      // Image.asset(
                      // "assets/Home/__location.png",
                      // width: 15,
                      // fit: BoxFit.cover,
                      // height: 15,
                      // ),
                      // SizedBox(
                      // width: 5,
                      // ),
                      // Expanded(
                      // child: Text(
                      // widget.projectList![index]
                      // ['address']
                      //     ?.trim() ??
                      // "",
                      // maxLines: 1,
                      // overflow:
                      // TextOverflow.ellipsis,
                      // style: TextStyle(
                      // color:
                      // Color(0xffa2a2a2),
                      // fontSize: 9,
                      // fontWeight:
                      // FontWeight.w400),
                      // ))
                      // ],
                      // ),
                      // ),
                      // SizedBox(
                      // height: 4,
                      // ),
                      // Row(
                      // children: [
                      // Text(
                      // '${widget.projectList![index]['project_details'].length > 0 ? formatAmount(widget.projectList![index]['project_details'][0]['avg_price'] ?? 0) : 0}'
                      //     .toString()
                      //     .formatAmount(
                      // prefix: true,
                      // ),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      // style: TextStyle(
                      // color: Color(0xff333333),
                      // fontSize: 9,
                      // fontWeight:
                      // FontWeight.w500),
                      // ),
                      // Padding(
                      // padding:
                      // const EdgeInsets.symmetric(
                      // horizontal: 8.0),
                      // child: Container(
                      // height: 12,
                      // width: 2,
                      // color: Colors.black54,
                      // ),
                      // ),
                      // Text(
                      // '${widget.projectList![index]['project_details'].length > 0 ? formatAmount(widget.projectList![index]['project_details'][0]['size'] ?? 0) : 0} Sq.ft'
                      //     .toString(),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      // style: TextStyle(
                      // color: Color(0xff333333),
                      // fontSize: 9,
                      // fontWeight:
                      // FontWeight.w500),
                      // ),
                      // ],
                      // ),
                      // SizedBox(
                      // height: 4,
                      // ),
                      // Row(
                      // mainAxisAlignment:
                      // MainAxisAlignment.end,
                      // children: [
                      // // Text("Posted By ${premiumPropertiesList[i]['role'] == 1 ? 'Owner' : premiumPropertiesList[i]['role'] == 2 ? 'Agent' : premiumPropertiesList[i]['role'] == 3 ? 'Builder' : 'Housepecker'}",
                      // //   maxLines: 1,
                      // //   overflow: TextOverflow.ellipsis,
                      // //   style: TextStyle(
                      // //       color: Color(0xffa2a2a2),
                      // //       fontSize: 8,
                      // //       fontWeight: FontWeight.w400
                      // //   ),
                      // // ),
                      // ],
                      // ),
                      // ],
                      // ),
                      // ),
                      // ],
                      // ),
                      // ],
                      // ),
                      // )),
                      // ),
                      // );
                      // } else {
                      // return ClipRRect(
                      // clipBehavior: Clip.antiAliasWithSaveLayer,
                      // borderRadius: BorderRadius.all(Radius.circular(15)),
                      // child: CustomShimmer(height: 90, width: 90),
                      // );
                      // }
                      // },
                      // ),
                      // ),
                    ]),
              ),
            ),
    );
  }

  Padding dividerWithSpacing() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: UiUtils.getDivider(),
    );
  }

  Widget updateTile(BuildContext context,
      {required String title,
      required String newVersion,
      required bool isUpdateAvailable,
      required String svgImagePath,
      Function(dynamic value)? onTapSwitch,
      dynamic switchValue,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: () {
          if (isUpdateAvailable) {
            onTap.call();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor
                    .withOpacity(0.10000000149011612),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                  fit: BoxFit.none,
                  child: isUpdateAvailable == false
                      ? const Icon(Icons.done)
                      : UiUtils.getSvg(svgImagePath,
                          color: context.color.tertiaryColor)),
            ),
            SizedBox(
              width: 25.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isUpdateAvailable == false
                        ? "uptoDate".translate(context)
                        : title)
                    .bold(weight: FontWeight.w700)
                    .color(context.color.textColorDark),
                if (isUpdateAvailable)
                  Text("v$newVersion")
                      .bold(weight: FontWeight.w300)
                      .color(context.color.textColorDark)
                      .size(context.font.small)
                      .italic()
              ],
            ),
            if (isUpdateAvailable) ...[
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: context.color.borderColor, width: 1.5),
                  color: context.color.secondaryColor
                      .withOpacity(0.10000000149011612),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: SizedBox(
                    width: 8,
                    height: 15,
                    child: UiUtils.getSvg(
                      AppIcons.arrowRight,
                      color: context.color.textColorDark,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

//eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3Ricm9rZXJodWIud3J0ZWFtLmluL2FwaS91c2VyX3NpZ251cCIsImlhdCI6MTY5Njg1MDQyNCwibmJmIjoxNjk2ODUwNDI0LCJqdGkiOiJxVTNpY1FsRFN3MVJ1T3M5Iiwic3ViIjoiMzg4IiwicHJ2IjoiMWQwYTAyMGFjZjVjNGI2YzQ5Nzk4OWRmMWFiZjBmYmQ0ZThjOGQ2MyIsImN1c3RvbWVyX2lkIjozODh9.Y8sQhZtz6xGROEMvrTwA6gSSfPK-YwuhwDDc7Yahfg4
//   Widget customTile(BuildContext context,
//       {required String title,
//       required String svgImagePath,
//       bool? isSwitchBox,
//       Function(dynamic value)? onTapSwitch,
//       dynamic switchValue,
//       required VoidCallback onTap}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: GestureDetector(
//         onTap: onTap,
//         child: AbsorbPointer(
//           absorbing: !(isSwitchBox ?? false),
//           child: Row(
//             children: [
//               Container(
//                 // width: 40,
//                 // height: 40,
//                 // decoration: BoxDecoration(
//                 //   color: context.color.tertiaryColor
//                 //       .withOpacity(0.10000000149011612),
//                 //   borderRadius: BorderRadius.circular(10),
//                 // ),
//                 child: FittedBox(
//                     fit: BoxFit.none,
//                     child: UiUtils.getSvg(svgImagePath,
//                         height: 24,
//                         width: 24,
//                         color: context.color.tertiaryColor)),
//               ),
//               SizedBox(
//                 width: 25.rw(context),
//               ),
//               Expanded(
//                 flex: 3,
//                 child: Text(title,style: TextStyle(
//                   fontSize: 13,
//                   color: Color(0xff333333),
//                   fontWeight: FontWeight.w500
//                 ),),
//               ),
//               const Spacer(),
//               if (isSwitchBox != true)
//                 Container(
//                   // width: 32,
//                   // height: 32,
//                   // decoration: BoxDecoration(
//                   //   border: Border.all(
//                   //       color: context.color.borderColor, width: 1.5),
//                   //   color: context.color.secondaryColor
//                   //       .withOpacity(0.10000000149011612),
//                   //   borderRadius: BorderRadius.circular(10),
//                   // ),
//                   child: FittedBox(
//                     fit: BoxFit.none,
//                     child: SizedBox(
//                       width: 8,
//                       height: 13,
//                       child: UiUtils.getSvg(
//                         AppIcons.arrowRight,
//                         color: context.color.textColorDark,
//                       ),
//                     ),
//                   ),
//                 ),
//               if (isSwitchBox ?? false)
//                 // CupertinoSwitch(value: value, onChanged: onChanged)
//                 SizedBox(
//                   height: 40,
//                   width: 30,
//                   child: CupertinoSwitch(
//                     activeColor: context.color.tertiaryColor,
//                     value: switchValue ?? false,
//                     onChanged: (value) {
//                       onTapSwitch?.call(value);
//                     },
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

  Widget customTile(BuildContext context,
      {required String title,
      required String pngImagePath, // Change svgImagePath to pngImagePath
      bool? isSwitchBox,
      Function(dynamic value)? onTapSwitch,
      dynamic switchValue,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          absorbing: !(isSwitchBox ?? false),
          child: Row(
            children: [
              Container(
                child: Image.asset(
                  // Use Image.asset instead of UiUtils.getSvg
                  pngImagePath, // Use pngImagePath here
                  height: 22,
                  width: 22,
                ),
              ),
              SizedBox(
                width: 15.rw(context),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title.firstUpperCase(),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              if (isSwitchBox != true)
                Container(
                  child: Image.asset(
                    // Use Image.asset instead of UiUtils.getSvg
                    "assets/profile/_-79.png",
                    width: 15,
                    height: 15,
                  ),
                ),
              if (isSwitchBox ?? false)
                SizedBox(
                  height: 40,
                  width: 30,
                  child: CupertinoSwitch(
                    activeColor: context.color.tertiaryColor,
                    value: switchValue ?? false,
                    onChanged: (value) {
                      onTapSwitch?.call(value);
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  deleteConfirmWidget(String title, String desc, bool callDel) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: title,
        content: Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xff6d6d6d), fontSize: 12),
        ),
        acceptButtonName: "deleteBtnLbl".translate(context),
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.deleteIcon,
        isAcceptContainesPush: true,
        onAccept: () async {
          Navigator.of(context).pop();
          if (callDel) {
            Future.delayed(
              const Duration(microseconds: 100),
              () {
                Navigator.pushNamed(context, Routes.login,
                    arguments: {"isDeleteAccount": true});
              },
            );
          } else {
            HiveUtils.logoutUser(
              context,
              onLogout: () {},
            );
          }
        },
      ),
    );
  }

  Widget profileImgWidget(BuildContext context) {
    final userProfile =
        userData?['profile'] ?? ""; // Handle potential null value
    return GestureDetector(
      onTap: () {
        if (userProfile.isNotEmpty) {
          UiUtils.showFullScreenImage(
            context,
            provider: NetworkImage(userProfile),
          );
        }
      },
      child: Image.network(
        userProfile, // Display the user profile from the API
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          // Show default SVG or fallback widget if image loading fails
          return buildDefaultPersonSVG(context);
        },
        loadingBuilder: (BuildContext context, Widget? child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child!;
          // Show loading or fallback widget while the image is loading
          return buildDefaultPersonSVG(context);
        },
      ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: context.color.tertiaryColor.withOpacity(0.1),
      child: FittedBox(
        fit: BoxFit.none,
        child: UiUtils.getSvg(AppIcons.defaultPersonLogo,
            color: context.color.tertiaryColor, width: 30, height: 30),
      ),
    );
  }

  Widget buildPropertiesShimmer(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.2,
      ),
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 1, color: const Color(0xffe0e0e0))),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                  child: CustomShimmer(
                    width: double.infinity,
                    height: 110,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                LayoutBuilder(builder: (context, c) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomShimmer(
                          height: 14,
                          width: c.maxWidth - 50,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const CustomShimmer(
                          height: 13,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomShimmer(
                          height: 12,
                          width: c.maxWidth / 1.2,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: CustomShimmer(
                            width: c.maxWidth / 4,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ]),
        );
      },
    );
  }
}



class FullScreenGallery extends StatelessWidget {
  final List<dynamic> images; // Assuming images are in the form of a list (URLs, file paths, etc.)
  final int initialIndex;

  FullScreenGallery({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]), // Use AssetImage if images are local files
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
          );
        },
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
