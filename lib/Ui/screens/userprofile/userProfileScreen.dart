import 'dart:io';

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
import '../widgets/blurred_dialoge_box.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;

import '../widgets/shimmerLoadingContainer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class UserDetailProfileScreen extends StatefulWidget {
  final int? id;
  final String? name;

  const UserDetailProfileScreen({Key? key, this.id, this.name})
      : super(key: key);

  @override
  State<UserDetailProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserDetailProfileScreen> {
  ValueNotifier isDarkTheme = ValueNotifier(false);
  bool isGuest = false;
  Map? userData;
  bool loading = false;
  String selectedValue = '0';
  int offset = 0, total = 0;
  List<PropertyModel> propertylist = [];
  List propertyLikeLoading = [];

  bool propertyLoading = false;
  bool propertyLoadingMore = false;

  @override
  void initState() {
    getUser();
    getProperties();
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

  Future<void> getProperties() async {
    setState(() {
      propertyLoading = true;
    });
    var response = await Api.get(
        url: Api.apiGetProprty,
        queryParameters: {'offset': offset, 'limit': 10, 'userid': widget.id});
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
      backgroundColor: Color(0xfff9f9f9),
      appBar: UiUtils.buildAppBar(
        context,
        title: 'Agent Profile',
      ),
      body: loading
          ? Center(child: UiUtils.progress(width: 40, height: 40))
          : ScrollConfiguration(
              behavior: RemoveGlow(),
              child: SingleChildScrollView(
                controller: profileScreenController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          // height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
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
                                            SizedBox(
                                              width: 5,
                                            ),
                                            if (userData!['verified'] != 0)
                                              Icon(
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
                                          '${userData!['email']}',
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          '${userData!['mobile']}',
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFffe6db),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text('${userData!['completed_project'] ?? '--'}')
                                                .color(Color(0xff333333))
                                                .size(context.font.larger)
                                                .setMaxLines(lines: 1),
                                            Text(
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
                                                .color(Color(0xff333333))
                                                .size(context.font.larger)
                                                .setMaxLines(lines: 1),
                                            Text(
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
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          child: Text(
                            'Address',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          child: Text(
                            '${userData!['address'] ?? ''}',
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Social Media',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (userData!['facebook_id'] != '')
                                    InkWell(
                                      onTap: () async {
                                        await urllauncher.launchUrl(
                                            Uri.parse(
                                                '${userData!['facebook_id']}'),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Image.asset(
                                        'assets/facebook.png',
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  if (userData!['facebook_id'] != '')
                                    SizedBox(
                                      width: 5,
                                    ),
                                  if (userData!['instagram_id'] != '')
                                    InkWell(
                                      onTap: () async {
                                        await urllauncher.launchUrl(
                                            Uri.parse(
                                                '${userData!['instagram_id']}'),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Image.asset(
                                        'assets/instagram.png',
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  if (userData!['instagram_id'] != '')
                                    SizedBox(
                                      width: 5,
                                    ),
                                  if (userData!['twitter_id'] != '')
                                    InkWell(
                                      onTap: () async {
                                        await urllauncher.launchUrl(
                                            Uri.parse(
                                                '${userData!['twitter_id']}'),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Image.asset(
                                        'assets/pinterest.png',
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  if (userData!['twitter_id'] != '')
                                    SizedBox(
                                      width: 5,
                                    ),
                                  if (userData!['pintrest_id'] != '')
                                    InkWell(
                                      onTap: () async {
                                        await urllauncher.launchUrl(
                                            Uri.parse(
                                                '${userData!['pintrest_id']}'),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Image.asset(
                                        'assets/twitter.png',
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  if (userData!['pintrest_id'] != '')
                                    SizedBox(
                                      width: 5,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        if (userData!['gallery'] != null && userData!['gallery'].isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Disable scrolling inside GridView
                            itemCount: userData!['gallery'].length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: 130,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenGallery(
                                        images: userData!['gallery'],
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: UiUtils.getImage(
                                  userData!['gallery'][index] ?? "",
                                  fit: BoxFit.cover,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Properties by Agent',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            DropdownButton<String>(
                              value: selectedValue,
                              items: [
                                DropdownMenuItem(
                                  child: Text('Sell'),
                                  value: '0', // Value for 'Sell'
                                ),
                                DropdownMenuItem(
                                  child: Text('Rent'),
                                  value: '1', // Value for 'Rent'
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 250,
                          width: size.width,
                          child: propertylist == null || propertylist.isEmpty
                              ? Center(
                            child: Text(
                              'No properties available', // Message for empty list
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                              : ListView.builder(
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
                        )



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
                  style: TextStyle(
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
          style: TextStyle(color: Color(0xff6d6d6d), fontSize: 12),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
              border: Border.all(width: 1, color: Color(0xffe0e0e0))),
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
                SizedBox(
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
                        SizedBox(
                          height: 5,
                        ),
                        const CustomShimmer(
                          height: 13,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomShimmer(
                          height: 12,
                          width: c.maxWidth / 1.2,
                        ),
                        SizedBox(
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
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
