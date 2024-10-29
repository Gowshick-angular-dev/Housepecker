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
import 'package:hive/hive.dart';
import 'package:launch_review/launch_review.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_theme.dart';
import '../../../app/routes.dart';
import '../../../data/cubits/Utility/like_properties.dart';
import '../../../data/cubits/system/app_theme_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../data/cubits/system/user_details.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Network/apiCallTrigger.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_keys.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../Advertisement/my_advertisment_screen.dart';
import '../Contactus/contactus.dart';
import '../Loan/loanhome.dart';
import '../Service/servicehome.dart';
import '../calculator/EMICalculator.dart';
import '../chat/chat_list_screen.dart';
import '../construction/constructionhome.dart';
import '../jointventure/jontventurehome.dart';
import '../projects/myProjectScreen.dart';
import '../proprties/my_properties_screen.dart';
import '../widgets/blurred_dialoge_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  ValueNotifier isDarkTheme = ValueNotifier(false);
  // with SingleTickerProviderStateMixin {
  bool isGuest = false;
  Map? systemSetting;
  @override
  void initState() {
    getSystemSetting();
    var settings = context.read<FetchSystemSettingsCubit>();
    print('yyyyyyyyyyyyyyyyyyyyyyyyy: ${settings}');
    isGuest = GuestChecker.value;
    GuestChecker.listen().addListener(() {
      isGuest = GuestChecker.value;
      if (mounted) setState(() {});
    });
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn = settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    super.initState();
  }

  int propertyCount = 0;
  int projectCount = 0;
  int advertisementCount = 0;

  int propertyLimit = 0;
  int projectLimit = 0;
  int advertisementLimit = 0;


  Future<void> getSystemSetting() async {
    String city = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city) ?? 'Unknown City';

    var response = await Api.post(url: Api.apiGetSystemSettings, parameter: {
      'user_id': HiveUtils.getUserId(),
     // 'city':city,

    });
    if(!response['error']) {
      setState(() {
        systemSetting = response['data'];
        var data = response['data']['free_package'] ?? {};

       // print("dddddddddddddddd${data}");

        propertyLimit = data['property_limit']??0;
        projectLimit = data['project_limit']??0;
        advertisementLimit = data['advertisement_limit']??0;


        propertyCount = data['used_property_limit']??0;
        projectCount = data['used_project_limit']??0;
        advertisementCount = data['used_advertisement_limit']??0;

      });
    }
  }




  @override
  void didChangeDependencies() {
    isDarkTheme.value = context.read<AppThemeCubit>().isDarkMode();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isDarkTheme.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
  int? a;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // log(a!.toString());
    var settings = context.watch<FetchSystemSettingsCubit>();

    if (!const bool.fromEnvironment("force-disable-demo-mode", defaultValue: false)) {
      Constant.isDemoModeOn = settings.getSetting(SystemSetting.demoMode) ?? false;
    }

    var username = "Anonymous";
    var email = "Not logged in";
    if (!isGuest) {
      UserModel? user = context.watch<UserDetailsCubit>().state.user;
      username = user?.name!.firstUpperCase() ?? "Anonymous";
      email = (user?.email) ?? "Login first";
    }
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          // systemNavigationBarColor: Theme.of(context).colorScheme.secondaryColor,
          systemNavigationBarIconBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                  ? Brightness.light
                  : Brightness.dark,
          //
          statusBarColor: Theme.of(context).colorScheme.secondaryColor,
          statusBarBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                  ? Brightness.dark
                  : Brightness.light,
          statusBarIconBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                  ? Brightness.light
                  : Brightness.dark),
      child: Scaffold(
        backgroundColor: Color(0xfff9f9f9),
        appBar: UiUtils.buildAppBar(
          context,
          title: '${UiUtils.getTranslatedLabel(context, "myProfile")} (${HiveUtils
              .getUserDetails().role == "1" ? 'Owner' : HiveUtils.getUserDetails().role == "2" ? 'Agent' : HiveUtils.getUserDetails().role == "3"  ? 'Builder' : 'Owner'})',
        ),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: SingleChildScrollView(

            controller: profileScreenController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: 170,
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: profileImgWidget(),
                          ),
                          SizedBox(height: 8,),
                          Text(username)
                              .color(context.color.textColorDark)
                              .size(18)
                              .bold(weight: FontWeight.w600)
                              .setMaxLines(lines: 1),
                          SizedBox(height: 5,),
                          Text(email)
                              .color(Color(0xff333333))
                              .size(context.font.small)
                              .setMaxLines(lines: 1),

                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Column(
                        children: [
                          GuestChecker.updateUI(
                            onChangeStatus: (bool? isGuest) {
                              if (isGuest == true) {
                                return MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.login,
                                      arguments: {"popToCurrent": true},
                                    );
                                  },
                                  child: const Text("Login"),
                                );
                              }

                              return InkWell(
                                onTap: () {
                                  HelperUtils.goToNextPage(
                                      Routes.completeProfile, context, false,
                                      args: {"from": "profile"});
                                },
                                child: Container(
                                  width: 33.rw(context),
                                  height: 33.rh(context),
                                  decoration: BoxDecoration(
                                    color: Color(0xffffa920),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Center(child: Image.asset("assets/profile/_-97.png",width: 17,height: 17,fit: BoxFit.cover,))
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(0xecbee1da),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.asset("assets/profile/_-80.png",width: 30,height: 30,fit: BoxFit.cover,color: Color(0xff86beb4),),
                              ),
                              SizedBox(width: 8,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Ads',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Row(
                                    children: [
                                      // Icon(Icons.ads_click_sharp),
                                      Text('${systemSetting != null ? systemSetting!['my_advert'] : 0}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                    ),
                    SizedBox(width: 7,),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xffb0d3fd),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Image.asset("assets/profile/total-properties.png",width: 30,height: 30,fit: BoxFit.cover,color: Color(0xff5a97e0),),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Properties',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    // Icon(Icons.ads_click_sharp),
                                    Text('${systemSetting != null ? systemSetting!['my_property_count'] : 0}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7,),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xecafb9fe),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Image.asset("assets/profile/total-views.png",width: 30,height: 30,fit: BoxFit.cover,color: Color(0xff5e64d0),),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Views',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    // Icon(Icons.ads_click_sharp),
                                    Text('${systemSetting != null ? (int.parse(systemSetting!['property_view']) + int.parse(systemSetting!['project_view'])) : 0}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 7,),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xfffff2c8),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Image.asset("assets/profile/building.png",width: 30,height: 30,fit: BoxFit.cover,color: Color(0xffb49a45),),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Projects',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    // Icon(Icons.ads_click_sharp),
                                    Text('${systemSetting != null ? systemSetting!['my_project_count'] : 0}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    color: Colors.white
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Color(0xffebedfe),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft:  Radius.circular(10),
                          )
                        ),child: const Text("Free Package",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15),),

                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                    color: Color(0xfff9f9f9),
                                    borderRadius: BorderRadius.circular(10)
                                ),child:     Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("Property",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 35.0,
                                    lineWidth: 8.0,
                                    animation: true,
                                    percent: propertyLimit > 0 ? propertyCount / propertyLimit : 0,
                                    center: Text(
                                      "$propertyCount/$propertyLimit",
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: const Color(0xffeaeaea),
                                    progressColor: const Color(0xff117af9),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                    color: Color(0xfff9f9f9),
                                    borderRadius: BorderRadius.circular(10)
                                ),child:Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("Project",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 35.0,
                                    lineWidth: 8.0,
                                    animation: true,
                                    percent: projectLimit > 0 ? projectCount / projectLimit : 0,
                                    center: Text(
                                      "$projectCount/$projectLimit",
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: const Color(0xffeaeaea),
                                    progressColor: const Color(0xff117af9),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                    color: Color(0xfff9f9f9),
                                    borderRadius: BorderRadius.circular(10)
                                ),child:     Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("Advertisement",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 35.0,
                                    lineWidth: 8.0,
                                    animation: true,
                                    percent: advertisementLimit > 0 ? advertisementCount / advertisementLimit : 0,
                                    center: Text(
                                      "$advertisementCount/$advertisementLimit",
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: const Color(0xffeaeaea),
                                    progressColor: const Color(0xff117af9),
                                  ),
                                ],
                              ),
                              ),
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
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      // customTile(
                      //   context,
                      //   title: "ONLY FOR DEVELOPMENT",
                      //   svgImagePath: AppIcons.enquiry,
                      //   onTap: () async {
                      //     var s = await FirebaseMessaging.instance.getToken();
                      //     Navigator.push(context, MaterialPageRoute(
                      //       builder: (context) {
                      //         return Scaffold(
                      //           body: Padding(
                      //             padding: const EdgeInsets.all(20.0),
                      //             child: Center(
                      //               child: SelectableText(s.toString()),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ));
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "myEnquiry"),
                      //   svgImagePath: AppIcons.enquiry,
                      //   onTap: () {
                      //     Navigator.pushNamed(context, Routes.myEnquiry);
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      //THIS IS EXPERIMENTAL
                      if (false) ...[
                        customTile(
                          context,
                          title:
                              UiUtils.getTranslatedLabel(context, "Dashboard"),
                          pngImagePath: "assets/images/promoted.png",
                          onTap: () {
                            Navigator.pushNamed(context, Routes.dashboard);
                          },
                        ),
                        dividerWithSpacing(),
                      ],

                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "myAds"),
                        pngImagePath: "assets/profile/_-80.png",
                        onTap: () async {
                          // APICallTrigger.trigger();
                          GuestChecker.check(
                            onNotGuest: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyAdvertismentScreen()),
                              );
                            },
                          );
                        },
                      ),

                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "My Properties"),
                        pngImagePath: "assets/profile/_-81.png",
                        onTap: () async {
                          APICallTrigger.trigger();
                          GuestChecker.check(
                            onNotGuest: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PropertiesScreen()),
                              );
                              // Navigator.pushNamed(
                              //     context, Routes.myAdvertisment);
                            },
                          );
                        },
                      ),
                      if(HiveUtils.getUserDetails().role != null && HiveUtils.getUserDetails().role == '3'||HiveUtils.getUserDetails().role == '2')
                        dividerWithSpacing(),
                      if(HiveUtils.getUserDetails().role != null && HiveUtils.getUserDetails().role == '3'||HiveUtils.getUserDetails().role == '2')
                        customTile(
                          context,
                          title: UiUtils.getTranslatedLabel(context, "My Projects"),
                          pngImagePath: "assets/profile/_-81.png",
                          onTap: () async {
                            GuestChecker.check(
                              onNotGuest: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyProjectScreen()),
                                );
                                // Navigator.pushNamed(
                                //     context, Routes.myAdvertisment);
                              },
                            );
                          },
                        ),


                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "Loans"),
                      //   pngImagePath: "assets/profile/_-81.png",
                      //   onTap: () async {
                      //     // APICallTrigger.trigger();
                      //     GuestChecker.check(
                      //       onNotGuest: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(builder: (context) =>  LoanHome()),
                      //         );
                      //         // Navigator.pushNamed(
                      //         //     context, Routes.myAdvertisment);
                      //       },
                      //     );
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "Service"),
                      //   pngImagePath: "assets/profile/_-81.png",
                      //   onTap: () async {
                      //     // APICallTrigger.trigger();
                      //     GuestChecker.check(
                      //       onNotGuest: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(builder: (context) =>  ServiceHome()),
                      //         );
                      //         // Navigator.pushNamed(
                      //         //     context, Routes.myAdvertisment);
                      //       },
                      //     );
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "JointVenture"),
                      //   pngImagePath: "assets/profile/_-81.png",
                      //   onTap: () async {
                      //     // APICallTrigger.trigger();
                      //     GuestChecker.check(
                      //       onNotGuest: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(builder: (context) =>  JointVenture()),
                      //         );
                      //         // Navigator.pushNamed(
                      //         //     context, Routes.myAdvertisment);
                      //       },
                      //     );
                      //   },
                      // ),
                      //
                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "Construction"),
                      //   pngImagePath: "assets/profile/_-81.png",
                      //   onTap: () async {
                      //     // APICallTrigger.trigger();
                      //     GuestChecker.check(
                      //       onNotGuest: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(builder: (context) =>  ConstructionHome()),
                      //         );
                      //         // Navigator.pushNamed(
                      //         //     context, Routes.myAdvertisment);
                      //       },
                      //     );
                      //   },
                      // ),


                      dividerWithSpacing(),
                      customTile(
                        context,
                        title:
                            UiUtils.getTranslatedLabel(context, "subscription"),
                        pngImagePath: "assets/profile/_-82.png",
                        onTap: () async {
                          GuestChecker.check(onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.subscriptionPackageListRoute);
                          });
                        },
                      ),
                      dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(
                      //       context, "Message"),
                      //   pngImagePath: "assets/profile/_-83.png",
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) =>  ChatListScreen()),
                      //     );
                      //
                      //     // GuestChecker.check(onNotGuest: () {
                      //     //   Navigator.pushNamed(
                      //     //       context, Routes.transactionHistory);
                      //     // });
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(
                            context, "transactionHistory"),
                        pngImagePath: "assets/profile/_-84.png",
                        onTap: () {
                          GuestChecker.check(onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.transactionHistory);
                          });
                        },
                      ),
                //      dividerWithSpacing(),

                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(
                      //     context,
                      //     "personalized",
                      //   ),
                      //   pngImagePath: "assets/profile/_-85.png",
                      //   onTap: () {
                      //     GuestChecker.check(onNotGuest: () {
                      //       Navigator.pushNamed(
                      //           context, Routes.personalizedPropertyScreen,
                      //           arguments: {
                      //             "type": PersonalizedVisitType.Normal
                      //           });
                      //     });
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      //
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "language"),
                      //   pngImagePath: "assets/profile/_-80.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //         context, Routes.languageListScreenRoute);
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      // ValueListenableBuilder(
                      //     valueListenable: isDarkTheme,
                      //     builder: (context, v, c) {
                      //       return customTile(
                      //         context,
                      //         title: UiUtils.getTranslatedLabel(
                      //             context, "darkTheme"),
                      //         pngImagePath: "assets/profile/_-80.png",
                      //         isSwitchBox: true,
                      //         onTapSwitch: (value) {
                      //           context.read<AppThemeCubit>().changeTheme(
                      //               value == true
                      //                   ? AppTheme.dark
                      //                   : AppTheme.light);
                      //           setState(() {
                      //             isDarkTheme.value = value;
                      //           });
                      //         },
                      //         switchValue: v,
                      //         onTap: () {},
                      //       );
                      //     }),



                      const SizedBox(
                        height: 20,
                      ),

                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(top: 15,bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    children: [
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(
                            context, "notifications"),
                        pngImagePath: "assets/profile/_-86.png",
                        onTap: () {
                          GuestChecker.check(onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.notificationPage);
                          });
                        },
                      ),
                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "articles"),
                        pngImagePath: "assets/profile/_-87.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.articlesScreenRoute,
                          );
                        },
                      ),
                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "Shortlist"),
                        pngImagePath: "assets/profile/_-88.png",
                        onTap: () {
                          GuestChecker.check(onNotGuest: () {
                            Navigator.pushNamed(
                                context, Routes.favoritesScreen);
                          });
                        },
                      ),
                      dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(
                      //       context, "areaConvertor"),
                      //   pngImagePath: "assets/profile/_-89.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //         context, Routes.areaConvertorScreen);
                      //   },
                      // ),
                      // dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(
                            context, "EMI Calculator"),
                        pngImagePath: "assets/profile/_-89.png",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                EmiCalculator()),
                          );
                        },
                      ),
                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "shareApp"),
                        pngImagePath: "assets/profile/_-90.png",
                        onTap: shareApp,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)
                    ),
                  child: Column(
                    children: [
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "rateUs"),
                        pngImagePath: "assets/profile/_-91.png",
                        onTap: rateUs,
                      ),
                      // dividerWithSpacing(),
                      // customTile(
                      //   context,
                      //   title: UiUtils.getTranslatedLabel(context, "contactUs"),
                      //   pngImagePath: "assets/profile/_-80.png",
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       Routes.contactUs,
                      //     );
                      //     // Navigator.pushNamed(context, Routes.ab);
                      //   },
                      // ),

                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "aboutUs"),
                        pngImagePath: "assets/profile/_-92.png",
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.profileSettings, arguments: {
                            'title':
                            UiUtils.getTranslatedLabel(context, "aboutUs"),
                            'param': Api.aboutApp
                          });
                          // Navigator.pushNamed(context, Routes.ab);
                        },
                      ),

                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(context, "Contact Us"),
                        pngImagePath: "assets/profile/_-87.png",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ContactUs()),
                          );
                        },
                      ),
                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(
                          context,
                          "termsConditions",
                        ),
                        pngImagePath: "assets/profile/_-93.png",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.profileSettings,
                              arguments: {
                                'title': UiUtils.getTranslatedLabel(
                                    context, "termsConditions"),
                                'param': Api.termsAndConditions
                              });
                        },
                      ),
                      dividerWithSpacing(),
                      customTile(
                        context,
                        title: UiUtils.getTranslatedLabel(
                            context, "privacyPolicy"),
                        pngImagePath: "assets/profile/_-94.png",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.profileSettings,
                            arguments: {
                              'title': UiUtils.getTranslatedLabel(
                                  context, "privacyPolicy"),
                              'param': Api.privacyPolicy
                            },
                          );
                        },
                      ),
                      if (Constant.isUpdateAvailable == true) ...[
                        dividerWithSpacing(),
                        updateTile(
                          context,
                          isUpdateAvailable: Constant.isUpdateAvailable,
                          title: UiUtils.getTranslatedLabel(context, "update"),
                          newVersion: Constant.newVersionNumber,
                          svgImagePath: AppIcons.update,
                          onTap: () async {
                            if (Platform.isIOS) {
                              await launchUrl(
                                  Uri.parse(Constant.appstoreURLios));
                            } else if (Platform.isAndroid) {
                              await launchUrl(
                                  Uri.parse(Constant.playstoreURLAndroid));
                            }
                          },
                        ),
                      ],

                      // if (isGuest == false) ...[
                      //   dividerWithSpacing(),
                      //   customTile(
                      //     context,
                      //     title: UiUtils.getTranslatedLabel(
                      //         context, "deleteAccount"),
                      //     pngImagePath: "assets/profile/_-95.png",
                      //     onTap: () {
                      //       if (Constant.isDemoModeOn) {
                      //         HelperUtils.showSnackBarMessage(
                      //             context,
                      //             UiUtils.getTranslatedLabel(
                      //                 context, "thisActionNotValidDemo"));
                      //         return;
                      //       }
                      //
                      //       deleteConfirmWidget(
                      //           UiUtils.getTranslatedLabel(
                      //               context, "deleteProfileMessageTitle"),
                      //           UiUtils.getTranslatedLabel(
                      //               context, "deleteProfileMessageContent"),
                      //           true);
                      //     },
                      //   ),
                      // ],

                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),
                if (isGuest == false) ...[
                  InkWell(
                    onTap: () {
                      logOutConfirmWidget();
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: [
                          Container(
                            child: Image.asset(
                              "assets/profile/_-96.png",
                              height: 24,
                              width: 24,
                            ),
                          ),
                          SizedBox(
                            width: 20.rw(context),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                             "Logout",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Spacer(),

                            Container(
                              child: Image.asset( // Use Image.asset instead of UiUtils.getSvg
                                "assets/profile/_-79.png",
                                width: 15,
                                height: 15,
                              ),
                            ),

                        ],
                      ),
                    ),
                  ),
                  // UiUtils.buildButton(context, onPressed: () {
                  //   logOutConfirmWidget();
                  // },
                  //     height: 52.rh(context),
                  //     prefixWidget: Padding(
                  //       padding: const EdgeInsetsDirectional.only(end: 16.0),
                  //       child: Image.asset("assets/profile/_-96.png",width: 24,height: 24,fit: BoxFit.cover,),
                  //     ),
                  //     buttonTitle:
                  //         UiUtils.getTranslatedLabel(context, "logout"))

                ],
                // profileInfo(),
                // Expanded(
                //   child: profileMenus(),
                // )
              ]),
            ),
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
                child: Image.asset( // Use Image.asset instead of UiUtils.getSvg
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
                  child: Image.asset( // Use Image.asset instead of UiUtils.getSvg
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
        content: Text(desc,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xff6d6d6d),
              fontSize: 12
          ),),
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

  Widget profileImgWidget() {
    return GestureDetector(
      onTap: () {
        if (HiveUtils.getUserDetails().profile != "" &&
            HiveUtils.getUserDetails().profile != null) {
          UiUtils.showFullScreenImage(
            context,
            provider: NetworkImage(
                context.read<UserDetailsCubit>().state.user?.profile ?? ""),
          );
        }
      },
      child: (context.watch<UserDetailsCubit>().state.user?.profile ?? "")
              .trim()
              .isEmpty
          ? buildDefaultPersonSVG(context)
          : Image.network(
              context.watch<UserDetailsCubit>().state.user?.profile ?? "",
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return buildDefaultPersonSVG(context);
              },
              loadingBuilder: (BuildContext context, Widget? child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child!;
                return buildDefaultPersonSVG(context);
              },
            ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: context.color.tertiaryColor.withOpacity(0.1),
      child: FittedBox(
        fit: BoxFit.none,
        child: UiUtils.getSvg(AppIcons.defaultPersonLogo,
            color: context.color.tertiaryColor, width: 30, height: 30),
      ),
    );
  }

  void shareApp() {
    try {
      if (Platform.isAndroid) {
        Share.share(
            '${Constant.appName}\n${Constant.playstoreURLAndroid}\n${Constant.shareappText}',
            subject: Constant.appName);
      } else {
        Share.share(
            '${Constant.appName}\n${Constant.appstoreURLios}\n${Constant.shareappText}',
            subject: Constant.appName);
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  Future<void> rateUs() async {
    LaunchReview.launch(
      androidAppId: Constant.androidPackageName,
      iOSAppId: Constant.iOSAppId,
    );
  }

  void logOutConfirmWidget() {
    UiUtils.showBlurredDialoge(context,
        dialoge: BlurredDialogBox(
            title: UiUtils.getTranslatedLabel(context, "confirmLogoutTitle"),
            onAccept: () async {
              Future.delayed(
                Duration.zero,
                () {
                  HiveUtils.clear();
                  Constant.favoritePropertyList.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().state.liked.clear();

                  context.read<LikedPropertiesCubit>().clear();
                  HiveUtils.logoutUser(
                    context,
                    onLogout: () {},
                  );
                },
              );
            },
            cancelTextColor: context.color.textColorDark,
            svgImagePath: AppIcons.logoutIcon,
            content:
                Text(UiUtils.getTranslatedLabel(context, "confirmLogOutMsg"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  color: Color(0xff6d6d6d),
                  fontSize: 12
                ),)));
  }
}
