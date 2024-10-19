import 'dart:io';
import 'dart:ui';

import 'package:Housepecker/Ui/screens/projects/project_interested_user_details.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:excel/excel.dart' as excelTable;
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd1.dart';
import 'package:Housepecker/Ui/screens/projects/projectCategoryScreen.dart';
import 'package:Housepecker/Ui/screens/projects/projectDetailsScreen.dart';
import 'package:Housepecker/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/AdMob/bannerAdLoadWidget.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_keys.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'package:flutter/src/painting/box_border.dart' as MatBorder;

class MyProjectScreen extends StatefulWidget {
  const MyProjectScreen({super.key});

  @override
  State<MyProjectScreen> createState() => _MyProjectScreenState();
}

class _MyProjectScreenState extends State<MyProjectScreen> {
  final ScrollController _pageScrollController = ScrollController();

  List myProjectList = [];
  bool loading = false;

  @override
  void initState() {
    getMyprojects();
    super.initState();
  }

  Future<void> getMyprojects() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.getProject, queryParameters: {
      'userid': Hive.box(HiveKeys.userDetailsBox).get('id'),
    });
    if(!response['error']) {
      setState(() {
        myProjectList = response['data'];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(context, "My Projects")),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          if(loading)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (myProjectList != null && myProjectList.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                shrinkWrap: true,
                controller: _pageScrollController,
                itemCount: myProjectList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1 / 0.4,
                ),

                itemBuilder: (context, index) {
                  var item = myProjectList[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ProjectDetails(property: item, fromMyProperty: true,
                                    fromCompleteEnquiry: true, fromSlider: false, fromPropertyAddSuccess: true
                                )),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: MatBorder.Border.all(
                                  width: 1,
                                  color: Color(0xffe0e0e0)
                              )
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: Container(
                                      height: double.infinity,
                                      width: 130,
                                      child: UiUtils.getImage(
                                        item['image'] ?? "",
                                        width: double.infinity,fit: BoxFit.cover,height: 103,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,),
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item['category']?['category'] ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('${item['title']}',
                                      maxLines: 2,overflow:TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        Image.asset("assets/Home/__location.png",width:12,fit: BoxFit.cover,height: 12,),
                                        SizedBox(width: 2,),
                                        Expanded(
                                          child: Text('${item['address']}',
                                            maxLines: 2,overflow:TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xff333333),
                                              fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      item['project_details'] != null && item['project_details'].isNotEmpty
                                          ? item['project_details'][0]['project_status_name'] ?? ''
                                          : '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text('${item['total_click']} Views',
                                          maxLines: 2,overflow:TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xff333333),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(width: 5,),
                                        Text("|",     style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xff333333),
                                            fontWeight: FontWeight.w500),),
                                        SizedBox(width: 5,),
                                        Text('Posted On : ${item['post_created']}',
                                          maxLines: 2,overflow:TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xff333333),
                                              fontWeight: FontWeight.w500),
                                        ),

                                      ],
                                    ),

                                    /*      Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ProjectFormOne(data: item, isEdit: true)),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              children: [
                                                // Text('Edit',style: TextStyle(
                                                //     fontSize: 11,
                                                //     color: Colors.white,
                                                //     fontWeight: FontWeight.w500),
                                                // ),
                                                // SizedBox(width: 3,),
                                                Icon(Icons.edit,color:Colors.white,size: 15,),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                // return object of type Dialog
                                                return Dialog(
                                                  elevation: 0.0,
                                                  shape:
                                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                  child: Wrap(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(20.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Text('Are You Sure',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xff333333),
                                                                  fontWeight: FontWeight.w600
                                                              ),
                                                            ),
                                                            SizedBox(height: 15,),
                                                            Text('Do you want to delete this ?'),
                                                            SizedBox(height: 15,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.green,
                                                                      borderRadius: BorderRadius.circular(15),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Cancel',style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    var response = await Api.post(url: Api.deleteProject, parameter: {
                                                                      "id": item['id']
                                                                    });
                                                                    if(!response['error']) {
                                                                      HelperUtils.showSnackBarMessage(
                                                                          context, UiUtils.getTranslatedLabel(context, "${response['message']}"),
                                                                          type: MessageType.warning, messageDuration: 3);
                                                                      Navigator.pop(context);
                                                                      getMyprojects();
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.red,
                                                                      borderRadius: BorderRadius.circular(15),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Delete',style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              children: [
                                                // Text('Delete',style: TextStyle(
                                                //     fontSize: 11,
                                                //     color: Colors.white,
                                                //     fontWeight: FontWeight.w500),
                                                // ),
                                                // SizedBox(width: 3,),
                                                Icon(Icons.delete, color:Colors.white, size: 15,),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),

                                      ],
                                    ),*/
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProjectInterestedUsersDetails(projectId:item['id']??0, ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 25,
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Color(0xff117af9))
                                            ),child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/assets/Images/eye-icon.png",height: 15,),
                                              SizedBox(width: 5,),
                                              Text(item['total_interested_users']?.toString()??"0",style: TextStyle(fontSize: 12,color:  Color(0xff117af9)),)
                                            ],
                                          ),
                                          ),
                                        ),
                                        SizedBox(width: 15,),
                                        Container(
                                          height: 28,
                                          padding: EdgeInsets.symmetric(horizontal: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color:item['status'] == 0?Color(0xfffff1f1):Color(0xffd9efcf),
                                              border: Border.all(color:  item['status'] == 0?Colors.red:Colors.green)
                                          ),child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text( item['status'] == 0? "InActive" : "Active",style: TextStyle(fontSize: 12,color:item['status'] == 0?Colors.red: Colors.green),)
                                          ],
                                        ),
                                        ),
                                        // InkWell(
                                        //   onTap: () {
                                        //     Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(builder: (context) => ProjectFormOne(data: item, isEdit: true)),
                                        //     );
                                        //   },
                                        //   child: Container(
                                        //     padding: EdgeInsets.all(5),
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.green,
                                        //       borderRadius: BorderRadius.circular(15),
                                        //     ),
                                        //     child: Row(
                                        //       children: [
                                        //         // Text('Edit',style: TextStyle(
                                        //         //     fontSize: 11,
                                        //         //     color: Colors.white,
                                        //         //     fontWeight: FontWeight.w500),
                                        //         // ),
                                        //         // SizedBox(width: 3,),
                                        //         Icon(Icons.edit,color:Colors.white,size: 15,),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        // InkWell(
                                        //   onTap: () {
                                        //     showDialog(
                                        //       context: context,
                                        //       barrierDismissible: false,
                                        //       builder: (BuildContext context) {
                                        //         // return object of type Dialog
                                        //         return Dialog(
                                        //           elevation: 0.0,
                                        //           shape:
                                        //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                        //           child: Wrap(
                                        //             children: [
                                        //               Container(
                                        //                 padding: EdgeInsets.all(20.0),
                                        //                 child: Column(
                                        //                   mainAxisAlignment: MainAxisAlignment.center,
                                        //                   crossAxisAlignment: CrossAxisAlignment.center,
                                        //                   children: <Widget>[
                                        //                     Text('Are You Sure',
                                        //                       style: TextStyle(
                                        //                           fontSize: 15,
                                        //                           color: Color(0xff333333),
                                        //                           fontWeight: FontWeight.w600
                                        //                       ),
                                        //                     ),
                                        //                     SizedBox(height: 15,),
                                        //                     Text('Do you want to delete this ?'),
                                        //                     SizedBox(height: 15,),
                                        //                     Row(
                                        //                       mainAxisAlignment: MainAxisAlignment.end,
                                        //                       children: [
                                        //                         InkWell(
                                        //                           onTap: () {
                                        //                             Navigator.pop(context);
                                        //                           },
                                        //                           child: Container(
                                        //                             padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                        //                             decoration: BoxDecoration(
                                        //                               color: Colors.green,
                                        //                               borderRadius: BorderRadius.circular(15),
                                        //                             ),
                                        //                             child: Row(
                                        //                               children: [
                                        //                                 Text('Cancel',style: TextStyle(
                                        //                                     fontSize: 13,
                                        //                                     color: Colors.white,
                                        //                                     fontWeight: FontWeight.w500),
                                        //                                 ),
                                        //                               ],
                                        //                             ),
                                        //                           ),
                                        //                         ),
                                        //                         SizedBox(width: 10),
                                        //                         InkWell(
                                        //                           onTap: () async {
                                        //                             var response = await Api.post(url: Api.deleteProject, parameter: {
                                        //                               "id": item['id']
                                        //                             });
                                        //                             if(!response['error']) {
                                        //                               HelperUtils.showSnackBarMessage(
                                        //                                   context, UiUtils.getTranslatedLabel(context, "${response['message']}"),
                                        //                                   type: MessageType.warning, messageDuration: 3);
                                        //                               Navigator.pop(context);
                                        //                               getMyprojects();
                                        //                             }
                                        //                           },
                                        //                           child: Container(
                                        //                             padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                        //                             decoration: BoxDecoration(
                                        //                               color: Colors.red,
                                        //                               borderRadius: BorderRadius.circular(15),
                                        //                             ),
                                        //                             child: Row(
                                        //                               children: [
                                        //                                 Text('Delete',style: TextStyle(
                                        //                                     fontSize: 13,
                                        //                                     color: Colors.white,
                                        //                                     fontWeight: FontWeight.w500),
                                        //                                 ),
                                        //                               ],
                                        //                             ),
                                        //                           ),
                                        //                         ),
                                        //                       ],
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         );
                                        //       },
                                        //     );
                                        //   },
                                        //   child: Container(
                                        //     padding: EdgeInsets.all(5),
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.red,
                                        //       borderRadius: BorderRadius.circular(15),
                                        //     ),
                                        //     child: Row(
                                        //       children: [
                                        //         // Text('Delete',style: TextStyle(
                                        //         //     fontSize: 11,
                                        //         //     color: Colors.white,
                                        //         //     fontWeight: FontWeight.w500),
                                        //         // ),
                                        //         // SizedBox(width: 3,),
                                        //         Icon(Icons.delete, color:Colors.white, size: 15,),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        // SizedBox()

                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: 0,
                          right: 0,
                          child:  PopupMenuButton<int>(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 20,
                              color: Colors.black,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(
                                onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ProjectFormOne(data: item, isEdit: true)),
                                      );
                                },
                                value: 1,
                                child:  const Row(
                                  children: [
                                    Icon(Icons.edit,color:Color(0xff117af9),size: 17,),
                                    SizedBox(width: 8,),
                                    Text("Edit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),


                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                onTap: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return Dialog(
                                            elevation: 0.0,
                                            shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                            child: Wrap(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('Are You Sure',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xff333333),
                                                            fontWeight: FontWeight.w600
                                                        ),
                                                      ),
                                                      SizedBox(height: 15,),
                                                      Text('Do you want to delete this ?'),
                                                      SizedBox(height: 15,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                              decoration: BoxDecoration(
                                                                color: Colors.green,
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text('Cancel',style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.w500),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          InkWell(
                                                            onTap: () async {
                                                              var response = await Api.post(url: Api.deleteProject, parameter: {
                                                                "id": item['id']
                                                              });
                                                              if(!response['error']) {
                                                                HelperUtils.showSnackBarMessage(
                                                                  context,
                                                                  UiUtils.getTranslatedLabel(context, response['message']),
                                                                  type: MessageType.success,
                                                                  messageDuration: 3,
                                                                );
                                                                Navigator.pop(context);
                                                                getMyprojects();
                                                              }
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                              decoration: BoxDecoration(
                                                                color: Colors.red,
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text('Delete',style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.w500),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                },
                                value: 2,
                                child: const Row(
                                  children: [

                                        Icon(Icons.delete, color:Colors.red, size: 17,),
                                      SizedBox(width: 8,),
                                    Text("Delete", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),

                                  ],
                                ),
                              ),
                            ],

                            color: Color(0xFFFFFFFF),
                          )
                      )
                    ],
                  );
                },
              ),
            )else const Expanded(child: Center(child: Text("Projects not available"),)),

        ],
      ),
    );
  }
}
