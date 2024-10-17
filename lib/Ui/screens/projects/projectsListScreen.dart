import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:Housepecker/Ui/screens/projects/projectDetailsScreen.dart';
import 'package:Housepecker/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/helper_utils.dart';
import 'package:Housepecker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/api.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/hive_utils.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/all_gallary_image.dart';


class ProjectViewAllScreen extends StatefulWidget {
  final Map? filter;
  final String? city;
  ProjectViewAllScreen({
    Key? key, this.filter,this.city
  });

  void open(BuildContext context) {
    Navigator.push(context, BlurredRouter(
      builder: (context) {
        return ProjectViewAllScreen();
      },
    ));
  }

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ProjectViewAllScreen> {

  bool projectLoading = false;
  List projectList = [];
  List<bool> likeLoading = [];

  @override
  void initState() {
    getProjects();
    super.initState();
  }

  Future<void> getProjects() async {
    setState(() {
      projectLoading = true;
    });
    var response = await Api.get(url: Api.getProject, queryParameters: widget.filter != null ? {
      'current_user': HiveUtils.getUserId(),
      ...widget.filter!
    } : {
      'current_user': HiveUtils.getUserId(),
      'city':widget.city
    });
    if(!response['error']) {
      setState(() {
        projectList = response['data'];
        likeLoading = List.filled(response['data'].length, false);
        projectLoading = false;
      });
    }
  }

  String formatAmount(number) {
    String result = '';
    if(number >= 10000000) {
      result = '${(number/10000000).toStringAsFixed(2)} Cr';
    } else if(number >= 100000) {
      result = '${(number/100000).toStringAsFixed(2)} Laks';
    } else {
      result = number.toStringAsFixed(2);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: 'Projects', showBackButton: true),
      body: projectLoading ? Center(child: UiUtils.progress()) : Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: RemoveGlow(),
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                // controller: controller,
                shrinkWrap: true,
                itemCount: projectList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1 / 1.2,
                ),
            
                itemBuilder: (context, index) {
                  // var model = projectList[index];
                  // return GestureDetector(
                  //     onTap: () {
                  //       // HelperUtils.goToNextPage(
                  //       //   Routes.propertyDetails,
                  //       //   context,
                  //       //   false,
                  //       //   args: {
                  //       //     'propertyData': model,
                  //       //     'propertiesList': state.properties,
                  //       //     'fromMyProperty': false,
                  //       //   },
                  //       // );
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) =>
                  //             ProjectDetails(property: projectList![index], fromMyProperty: true,
                  //                 fromCompleteEnquiry: true, fromSlider: false, fromPropertyAddSuccess: true
                  //             )),
                  //       );
                  //     },
                  //     child: GestureDetector(
                  //       onLongPress: () {
                  //         HelperUtils.share(context, model['id'], model['slugId'] ?? "");
                  //       },
                  //       child: Container(
                  //         // height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
                  //         decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(15),
                  //             border: Border.all(
                  //                 width: 1,
                  //                 color: Color(0xffe0e0e0)
                  //             )
                  //         ),
                  //         child: Stack(
                  //           fit: StackFit.expand,
                  //           children: [
                  //             Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Column(
                  //                   children: [
                  //                     ClipRRect(
                  //                       borderRadius: BorderRadius.only(
                  //                         topRight: Radius.circular(15),
                  //                         topLeft:Radius.circular(15),
                  //                       ),
                  //                       child: Stack(
                  //                         children: [
                  //
                  //                           UiUtils.getImage(
                  //                             model['image'] ?? "",
                  //                             width: double.infinity,fit: BoxFit.cover,height: 103,
                  //                           ),
                  //                           // Text(property.promoted.toString()),
                  //                           // if (showLikeButton ?? true)
                  //                           //   Positioned(
                  //                           //     right: 8,
                  //                           //     top: 8,
                  //                           //     child: Container(
                  //                           //       width: 32,
                  //                           //       height: 32,
                  //                           //       decoration: BoxDecoration(
                  //                           //         color: context.color.secondaryColor,
                  //                           //         shape: BoxShape.circle,
                  //                           //         boxShadow: const [
                  //                           //           BoxShadow(
                  //                           //             color:
                  //                           //             Color.fromARGB(12, 0, 0, 0),
                  //                           //             offset: Offset(0, 2),
                  //                           //             blurRadius: 15,
                  //                           //             spreadRadius: 0,
                  //                           //           )
                  //                           //         ],
                  //                           //       ),
                  //                           //       child: LikeButtonWidget(
                  //                           //         property: property,
                  //                           //         onLikeChanged: onLikeChange,
                  //                           //       ),
                  //                           //     ),
                  //                           //   ),
                  //                           // if (property.promoted ?? false)
                  //                           //   const PositionedDirectional(
                  //                           //       start: 5,
                  //                           //       top: 5,
                  //                           //       child: PromotedCard(
                  //                           //           type: PromoteCardType.icon)),
                  //                           PositionedDirectional(
                  //                             bottom: 6,
                  //                             start: 6,
                  //                             child: Container(
                  //                               height: 19,
                  //                               clipBehavior: Clip.antiAlias,
                  //                               decoration: BoxDecoration(
                  //                                   color: context.color.secondaryColor
                  //                                       .withOpacity(0.7),
                  //                                   borderRadius:
                  //                                   BorderRadius.circular(4)),
                  //                               child: BackdropFilter(
                  //                                 filter: ImageFilter.blur(
                  //                                     sigmaX: 2, sigmaY: 3),
                  //                                 child: Padding(
                  //                                   padding: const EdgeInsets.symmetric(
                  //                                       horizontal: 8.0),
                  //                                   child: Center(
                  //                                     child: Text(
                  //                                       '${model['category'] != null ? model['category']['category'] : ''}',
                  //                                     )
                  //                                         .color(
                  //                                       context.color.textColorDark,
                  //                                     )
                  //                                         .bold(weight: FontWeight.w500)
                  //                                         .size(10),
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     // if (statusButton != null)
                  //                     //   Padding(
                  //                     //     padding: const EdgeInsets.symmetric(
                  //                     //         vertical: 3.0, horizontal: 3.0),
                  //                     //     child: Container(
                  //                     //       decoration: BoxDecoration(
                  //                     //           color: Colors.red,
                  //                     //           borderRadius: BorderRadius.circular(4)),
                  //                     //
                  //                     //       child: Center(
                  //                     //           child: Text('statusButton!.lable')
                  //                     //               .size(11)
                  //                     //               .bold(weight: FontWeight.w500)
                  //                     //               .color(Colors.black)),
                  //                     //     ),
                  //                     //   )
                  //                   ],
                  //                 ),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left:10,right: 10),
                  //                   child: Column(
                  //                     crossAxisAlignment: CrossAxisAlignment.start,
                  //                     mainAxisAlignment:
                  //                     MainAxisAlignment.spaceEvenly,
                  //                     children: [
                  //                       SizedBox(height: 6,),
                  //                       Text(
                  //                         model['title'],
                  //                         maxLines: 1,
                  //                         overflow: TextOverflow.ellipsis,
                  //                         style: TextStyle(
                  //                             color: Color(0xff333333),
                  //                             fontSize: 12.5,
                  //                             fontWeight: FontWeight.w500
                  //                         ),
                  //                       ),
                  //
                  //                       // UiUtils.imageType(
                  //                       //     property.category!.image ?? "",
                  //                       //     width: 18,
                  //                       //     height: 18,
                  //                       //     color: Constant.adaptThemeColorSvg
                  //                       //         ? context.color.tertiaryColor
                  //                       //         : null),
                  //                       // const SizedBox(
                  //                       //   width: 5,
                  //                       // ),
                  //                       // Text(property.category!.category!)
                  //                       //     .setMaxLines(lines: 1)
                  //                       //     .size(
                  //                       //       context.font.small
                  //                       //           .rf(context),
                  //                       //     )
                  //                       //     .bold(
                  //                       //       weight: FontWeight.w400,
                  //                       //     )
                  //                       //     .color(
                  //                       //       context.color.textLightColor,
                  //                       //     ),
                  //
                  //                       Text(
                  //                         '${model['project_details'][0]['avg_price']}'
                  //                             .toString()
                  //                             .formatAmount(
                  //                           prefix: true,
                  //                         ),
                  //                         maxLines: 1,
                  //                         overflow: TextOverflow.ellipsis,
                  //                         style: TextStyle(
                  //                             color: Color(0xff333333),
                  //                             fontSize: 12,
                  //                             fontWeight: FontWeight.w500
                  //                         ),
                  //                       ),
                  //                       SizedBox(height: 4,),
                  //                       if (model['address'] != "")
                  //                         Padding(
                  //                           padding: const EdgeInsets.only(bottom: 4),
                  //                           child: Row(
                  //                             children: [
                  //                               Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                  //                               SizedBox(width: 5,),
                  //                               Expanded(
                  //                                   child: Text(
                  //                                     model['address'] ?? "",  maxLines: 1,
                  //                                     overflow: TextOverflow.ellipsis,
                  //                                     style: TextStyle(
                  //                                         color: Color(0xffa2a2a2),
                  //                                         fontSize: 9,
                  //                                         fontWeight: FontWeight.w400
                  //                                     ),)
                  //                               )
                  //                             ],
                  //                           ),
                  //                         ),
                  //                       SizedBox(height: 4,),
                  //                       Text("Ready To Move",
                  //                         maxLines: 1,
                  //                         overflow: TextOverflow.ellipsis,
                  //                         style: TextStyle(
                  //                             color: Color(0xffa2a2a2),
                  //                             fontSize: 9,
                  //                             fontWeight: FontWeight.w400
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Positioned(
                  //               right: 8,
                  //               top: 8,
                  //               child: InkWell(
                  //                 onTap: () {
                  //                   GuestChecker.check(onNotGuest: () async {
                  //                     setState(() {
                  //                       likeLoading[index] = true;
                  //                     });
                  //                     var body = {
                  //                       "type": projectList[index]['is_favourite'] == 1 ? 0 : 1,
                  //                       "project_id": projectList[index]['id']
                  //                     };
                  //                     var response = await Api.post(
                  //                         url: Api.addFavProject, parameter: body);
                  //                     if (!response['error']) {
                  //                       projectList[index]['is_favourite'] = (projectList[index]['is_favourite'] == 1 ? 0 : 1);
                  //                       setState(() {
                  //                         likeLoading[index] = false;
                  //                       });
                  //
                  //                     }
                  //                   });
                  //                 },
                  //                 child: Container(
                  //                   width: 32,
                  //                   height: 32,
                  //                   decoration: BoxDecoration(
                  //                     color: context.color.secondaryColor,
                  //                     shape: BoxShape.circle,
                  //                     boxShadow: const [
                  //                       BoxShadow(
                  //                         color:
                  //                         Color.fromARGB(12, 0, 0, 0),
                  //                         offset: Offset(0, 2),
                  //                         blurRadius: 15,
                  //                         spreadRadius: 0,
                  //                       )
                  //                     ],
                  //                   ),
                  //                   child: Container(
                  //                     width: 32,
                  //                     height: 32,
                  //                     decoration: BoxDecoration(
                  //                       color: context.color.primaryColor,
                  //                       shape: BoxShape.circle,
                  //                       boxShadow: const [
                  //                         BoxShadow(
                  //                             color: Color.fromARGB(33, 0, 0, 0),
                  //                             offset: Offset(0, 2),
                  //                             blurRadius: 15,
                  //                             spreadRadius: 0)
                  //                       ],
                  //                     ),
                  //                     child: Center(
                  //                         child:
                  //                         (likeLoading[index])
                  //                             ? UiUtils.progress(width: 20, height: 20)
                  //                             : projectList[index]['is_favourite'] == 1
                  //                             ?
                  //                         UiUtils.getSvg(
                  //                           AppIcons.like_fill,
                  //                           color: context.color.tertiaryColor,
                  //                         )
                  //                             : UiUtils.getSvg(AppIcons.like,
                  //                             color: context.color.tertiaryColor)
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ));
                  return projectCard(index, projectList);
                },
              ),
            ),
          ),
          if(projectList.isEmpty)
            Expanded(child: NoDataFound()),
        ],
      ),
    );
  }

  Widget projectCard(index, projectList) {
    return Container(
      width: 200,
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ProjectDetails(property: projectList![index], fromMyProperty: true,
                      fromCompleteEnquiry: true, fromSlider: false, fromPropertyAddSuccess: true
                  )),
            );
          },
          child: Container(
            // height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    width: 1,
                    color: Color(0xffe0e0e0)
                )
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft:Radius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              UiUtils.getImage(
                                projectList![index]['image'] ?? "",
                                width: double.infinity,fit: BoxFit.cover,height: 103,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: InkWell(
                                  onTap: () {
                                    GuestChecker.check(onNotGuest: () async {
                                      setState(() {
                                        likeLoading![index] = true;
                                      });
                                      var body = {
                                        "type": projectList![index]['is_favourite'] == 1 ? 0 : 1,
                                        "project_id": projectList![index]['id']
                                      };
                                      var response = await Api.post(
                                          url: Api.addFavProject, parameter: body);
                                      if (!response['error']) {
                                        projectList![index]['is_favourite'] = (projectList![index]['is_favourite'] == 1 ? 0 : 1);
                                        setState(() {
                                          likeLoading![index] = false;
                                        });

                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: context.color.secondaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color:
                                          Color.fromARGB(12, 0, 0, 0),
                                          offset: Offset(0, 2),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: context.color.primaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Color.fromARGB(33, 0, 0, 0),
                                              offset: Offset(0, 2),
                                              blurRadius: 15,
                                              spreadRadius: 0)
                                        ],
                                      ),
                                      child: Center(
                                          child:
                                          (likeLoading![index])
                                              ? UiUtils.progress(width: 20, height: 20)
                                              : projectList![index]['is_favourite'] == 1
                                              ?
                                          UiUtils.getSvg(
                                            AppIcons.like_fill,
                                            color: context.color.tertiaryColor,
                                          )
                                              : UiUtils.getSvg(AppIcons.like,
                                              color: context.color.tertiaryColor)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if(projectList![index]['gallary_images'] != null)
                                Positioned(
                                  right: 48,
                                  top: 8,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          BlurredRouter(
                                            builder: (context) {
                                              return AllGallaryImages(
                                                  images: projectList![index]['gallary_images'] ?? [],
                                                  isProject: true);
                                            },
                                          ));
                                    },
                                    child: Container(
                                      width: 35,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Color(0xff000000).withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(width: 1, color: Color(0xffe0e0e0)),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromARGB(12, 0, 0, 0),
                                            offset: Offset(0, 2),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              Icons.image,
                                              color: Color(0xffe0e0e0),
                                              size: 15
                                          ),
                                          SizedBox(width: 3,),
                                          Text('${projectList![index]['gallary_images']!.length}',
                                            style: TextStyle(
                                                color: Color(0xffe0e0e0),
                                                fontSize: 10
                                            ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 6,),
                          Text(
                            projectList![index]['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 4,),
                          if(projectList![index]['min_price'] == null)
                            Row(
                              children: [
                                Text(
                                  '₹${projectList![index]['project_details'].length > 0 ? formatAmount(projectList![index]['project_details'][0]['avg_price'] ?? 0) : 0}'
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 12,
                                      fontFamily: 'Robato',
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Container(
                                    height: 12,
                                    width: 2,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '${projectList![index]['project_details'].length > 0 ? formatAmount(projectList![index]['project_details'][0]['size'] ?? 0) : 0} Sq.ft'
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xffa2a2a2),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          if(projectList![index]['min_price'] != null)
                            Row(
                              children: [
                                Text(
                                  '₹${formatAmount(projectList![index]['min_price'] ?? 0)} - ${formatAmount(projectList![index]['max_price'] ?? 0)}'
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 12,
                                      fontFamily: 'Robato',
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          if(projectList![index]['min_price'] != null)
                            Row(
                              children: [
                                Text(
                                  '${projectList![index]['min_size']} - ${projectList![index]['max_size']} Sq.ft'
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xffa2a2a2),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 4,),
                          if (projectList![index]['address'] != "")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                  SizedBox(width: 5,),
                                  Expanded(
                                      child: Text(
                                        projectList![index]['address']?.trim() ?? "",  maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color(0xffa2a2a2),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400
                                        ),)
                                  )
                                ],
                              ),
                            ),
                          SizedBox(height: 4,),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

}

