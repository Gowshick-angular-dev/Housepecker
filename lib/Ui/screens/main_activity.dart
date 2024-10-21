// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd1.dart';
import 'package:Housepecker/Ui/screens/projects/projectCategoryScreen.dart';
import 'package:Housepecker/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:Housepecker/data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rive/components.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/component.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/analytics_routes.dart';
import '../../app/routes.dart';
import '../../data/Repositories/property_repository.dart';
import '../../data/cubits/company_cubit.dart';
import '../../data/cubits/property/search_property_cubit.dart';
import '../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../data/model/property_model.dart';
import '../../data/model/system_settings_model.dart';
import '../../settings.dart';
import '../../utils/AppIcon.dart';
import '../../utils/Extensions/extensions.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/errorFilter.dart';
import '../../utils/guestChecker.dart';
import '../../utils/helper_utils.dart';
import '../../utils/hive_utils.dart';
import '../../utils/responsiveSize.dart';
import '../../utils/ui_utils.dart';
import 'Advertisement/selectAdType.dart';
import 'chat/chat_list_screen.dart';
import 'favorites_screen.dart';
import 'home/home_screen.dart';
import 'home/search_screen.dart';
import 'proprties/my_properties_screen.dart';
import 'userprofile/profile_screen.dart';
import 'widgets/blurred_dialoge_box.dart';

List<PropertyModel> myPropertylist = [];
Map<String, dynamic> searchbody = {};
String selectedcategoryId = "0";
String selectedcategoryName = "";
String selectedtype = "0";
String selectedtypeName = "";
dynamic selectedCategory;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = "";
dynamic currentVisitingCategory = "";

List<int> navigationStack = [0];

ScrollController homeScreenController = ScrollController();
ScrollController chatScreenController = ScrollController();
ScrollController sellScreenController = ScrollController();
ScrollController rentScreenController = ScrollController();
ScrollController profileScreenController = ScrollController();

List<ScrollController> controllerList = [
  homeScreenController,
  chatScreenController,
  if (propertyScreenCurrentPage == 0) ...[
    sellScreenController
  ] else ...[
    rentScreenController
  ],
  profileScreenController
];

//
class MainActivity extends StatefulWidget {
  final String from;
  const MainActivity({Key? key, required this.from}) : super(key: key);

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
        builder: (_) => MainActivity(from: arguments['from'] as String));
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  int currtab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List _pageHistory = [];
  late PageController pageController;
  DateTime? currentBackPressTime;

  Artboard? artboard;
  SMIBool? isReverse;
  StateMachineController? _controller;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;
  bool showSellRentButton = false;
  List? adList = [];

  ///Animation for sell and rent button
  late final AnimationController _forSellAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 400,
    ),
    reverseDuration: const Duration(
      milliseconds: 400,
    ),
  );
  late final AnimationController _forPropAnimationController =
  AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
    reverseDuration: const Duration(
      milliseconds: 500,
    ),
  );
  late final AnimationController _forRentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );

  ///END: Animation for sell and rent button
  late final Animation<double> _sellTween = Tween<double>(begin: -50, end: 80)
      .animate(CurvedAnimation(
          parent: _forSellAnimationController, curve: Curves.easeIn));
  late final Animation<double> _propTween = Tween<double>(begin: -50, end: 130)
      .animate(CurvedAnimation(
      parent: _forPropAnimationController, curve: Curves.easeIn));
  late final Animation<double> _rentTween = Tween<double>(begin: -50, end: 30)
      .animate(
          CurvedAnimation(parent: _forRentController, curve: Curves.easeIn));

  Map<String, dynamic> riveConfig = AppSettings.riveAnimationConfigurations;
  late var addButtonConfig = riveConfig['add_button'];
  late var artboardName = addButtonConfig['artboard_name'];
  late var stateMachine = addButtonConfig['state_machine'];
  late var booleanName = addButtonConfig['boolean_name'];
  late var booleanInitialValue = addButtonConfig['boolean_initial_value'];
  late var addButtonShapeName = addButtonConfig['add_button_shape_name'];

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    getAdTypes();
    GuestChecker.setContext(context);
    GuestChecker.set(isGuest: HiveUtils.isGuest());
    FetchSystemSettingsCubit settings =
        context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    var numberWithSuffix = settings.getSetting(SystemSetting.numberWithSuffix);
    Constant.isNumberWithSuffix = numberWithSuffix == "1" ? true : false;

    if (Constant.isDemoModeOn) {
      HiveUtils.setLocation(
        city: "Bhuj",
        state: "Gujrat",
        country: "India",
        placeId: "ChIJF28LAAniUDkRpnQHr1jzd3A",
      );
    }

    ///this will check if your profile is complete or not if it is incomplete it will redirect you to the edit profile page
    // completeProfileCheck();

    ///This will check for update
    versionCheck(settings);

    ///This will check if location is set or not , If it is not set it will show popup dialoge so you can set for better result
    // if (GuestChecker.value == false) {
    //   locationSetCheck(context);
    // }

//Initializing rive animations
    initRiveAddButtonAnimation();

//This will init page controller
    initPageController();
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    context.read<CompanyCubit>().fetchCompany(
          context,
        ); //getCompanyData @ Start [specially for contact number]
  }

  Future<void> getAdTypes() async {
    var response = await Api.get(url: Api.advertisementCategory);
    if(!response['error']) {
      setState(() {
        adList = response['data'];
      });
    }
  }

  void addHistory(int index) {
    List<int> stack = navigationStack;
    // if (stack.length > 5) {
    //   stack.removeAt(0);
    // } else {
    if (stack.last != index) {
      stack.add(index);
      navigationStack = stack;
    }

    setState(() {});
  }

  void initPageController() {
    pageController = PageController(initialPage: 0)
      ..addListener(() {
        _pageHistory.insert(0, pageController.page);
      });
  }

  void initRiveAddButtonAnimation() {
    ///Open file
    rootBundle
        .load("assets/riveAnimations/${Constant.riveAnimation}")
        .then((value) {
      ///Import that data to this method below
      RiveFile riveFile = RiveFile.import(value);

      ///Artboard by name you can check https://rive.app and learn it for more information
      /// Here Add is artboard name from that workspace
      artboard = riveFile.artboardByName(artboardName);
      artboard?.forEachComponent((child) {
        if (child.name == "plus") {
          for (Component element in (child as Node).children) {
            if (element.name == "Path_49") {
              if (element is Shape) {
                final Shape shape = element;

                shape.fills.first.paint.color = Colors.white;
              }
            }
          }
        }
        if (child is Shape && child.name == addButtonShapeName) {
          final Shape shape = child;
          shape.fills.first.paint.color = context.color.tertiaryColor;
        }
      });

      ///in rive there is state machine to control states of animation, like. walking,running, and more
      ///click is state machine name
      _controller =
          StateMachineController.fromArtboard(artboard!, stateMachine);
      // _controller.
      if (_controller != null) {
        artboard?.addController(_controller!);

        //this SMI means State machine input, we can create conditions in rive , so isReverse is boolean value name from there
        isReverse = _controller?.findSMI(booleanName);

        ///this is optional it depends on your conditions you can change this whole conditions and values,
        ///for this animation isReverse =true means it will play its idle animation
        isReverse?.value = booleanInitialValue;

        ///here we can change color of any shape, here 'shape' is name in rive.app file
      }
      setState(() {});
    });
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(context, Routes.completeProfile,
              arguments: {"from": "login"});
        },
      );
    }
  }

  void versionCheck(settings) async {
    var remoteVersion = settings.getSetting(Platform.isIOS
        ? SystemSetting.iosVersion
        : SystemSetting.androidVersion);
    var remote = remoteVersion;

    var forceUpdate = settings.getSetting(SystemSetting.forceUpdate);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var current = packageInfo.version;

    int currentVersion = HelperUtils.comparableVersion(packageInfo.version);
    if (remoteVersion == null) {
      return;
    }
    remoteVersion = HelperUtils.comparableVersion(
      remoteVersion,
    );

    if (remoteVersion > currentVersion) {
      Constant.isUpdateAvailable = true;
      Constant.newVersionNumber = settings.getSetting(
        Platform.isIOS
            ? SystemSetting.iosVersion
            : SystemSetting.androidVersion,
      );

      Future.delayed(
        Duration.zero,
        () {
          if (forceUpdate == "1") {
            ///This is force update
            UiUtils.showBlurredDialoge(context,
                dialoge: BlurredDialogBox(
                    onAccept: () async {
                      if (Platform.isAndroid) {
                        await launchUrl(
                            Uri.parse(
                              Constant.playstoreURLAndroid,
                            ),
                            mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(
                            Uri.parse(
                              Constant.appstoreURLios,
                            ),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    backAllowedButton: false,
                    svgImagePath: AppIcons.update,
                    isAcceptContainesPush: true,
                    svgImageColor: context.color.tertiaryColor,
                    showCancleButton: false,
                    title: "updateAvailable".translate(context),
                    acceptTextColor: context.color.buttonColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$current>$remote"),
                        Text("newVersionAvailableForce".translate(context),
                            textAlign: TextAlign.center),
                      ],
                    )));
          } else {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                onAccept: () async {
                  if (Platform.isAndroid) {
                    await launchUrl(
                        Uri.parse(
                          Constant.playstoreURLAndroid,
                        ),
                        mode: LaunchMode.externalApplication);
                  } else {
                    await launchUrl(
                        Uri.parse(
                          Constant.appstoreURLios,
                        ),
                        mode: LaunchMode.externalApplication);
                  }
                },
                svgImagePath: AppIcons.update,
                svgImageColor: context.color.tertiaryColor,
                showCancleButton: true,
                title: "updateAvailable".translate(context),
                content: Text(
                  "newVersionAvailable".translate(context),
                ),
              ),
            );
          }
        },
      );
    }
  }

  void locationSetCheck(context) {
    if (HiveUtils.isShowChooseLocationDialoge() &&
        !HiveUtils.isLocationFilled()) {
      Future.delayed(
        Duration.zero,
        () {
          UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: UiUtils.getTranslatedLabel(context, "setLocation",),

              content: StatefulBuilder(builder: (context, update) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      textAlign : TextAlign.center,
                      UiUtils.getTranslatedLabel(
                        context,
                        "setLocationforBetter",
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width :20,
                          height:20,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            side: MaterialStateBorderSide.resolveWith(
                                  (states) => BorderSide(width: 1.0, color: Color(0xff117af9)),
                            ),
                            fillColor: MaterialStateProperty.resolveWith(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return context.color.tertiaryColor;
                                } else {
                                  return context.color.primaryColor;
                                }
                              },
                              // context.color.primaryColor,
                            ),
                            value: isChecked,
                            onChanged: (value) {
                              isChecked = value ?? false;
                              update(() {});
                            },
                          ),
                        ),
                        const SizedBox( width: 8,),
                        Text(UiUtils.getTranslatedLabel( context, "dontshowagain"),style: TextStyle(fontSize: 11,fontWeight: FontWeight.w500,color: Color(0xff117af9)),)
                      ],
                    ),
                  ],
                );
              }),
              isAcceptContainesPush: true,
              onCancel: () {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
              },
              onAccept: () async {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
                Navigator.pop(context);

                Navigator.pushNamed(context, Routes.completeProfile,
                    arguments: {
                      "from": "chooseLocation",
                      "navigateToHome": true
                    });
              },
            ),
          );
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    ErrorFilter.setContext(context);

    artboard?.forEachComponent((child) {
      if (child.name == "plus") {
        for (Component element in (child as Node).children) {
          if (element.name == "Path_49") {
            if (element is Shape) {
              final Shape shape = element;

              shape.fills.first.paint.color = Colors.white;
            }
          }
        }
      }
      if (child is Shape && child.name == addButtonShapeName) {
        final Shape shape = child;

        shape.fills.first.paint.color = context.color.tertiaryColor;
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> checkForMaintenanceMode() async {
    Map<String, String> body = {
      Api.type: Api.maintenanceMode,
    };

    var response = await HelperUtils.sendApiRequest(
      Api.apiGetSystemSettings,
      body,
      true,
      context,
    );
    var getdata = json.decode(response);
    print("Setiing : $getdata");
    if (getdata != null) {
      if (!getdata[Api.error]) {
        Constant.maintenanceMode = getdata['data'].toString();
        if (Constant.maintenanceMode == "1") {
          setState(() {});
        }
      }
    }
  }

  void _openDrawer() {
    print('working...');
    if (isReverse?.value == true) {
      isReverse?.value = false;
      showSellRentButton = true;
      _forRentController.forward();
      _forSellAnimationController.forward();
      _forPropAnimationController.forward();
    } else {
      showSellRentButton = false;
      isReverse?.value = true;
      _forRentController.reverse();
      _forSellAnimationController.reverse();
      _forPropAnimationController.reverse();
    }
  }

  late List<Widget> pages = [
    HomeScreen(from: widget.from, /*openDrawer: isReverse!.value*/),
    const PropertiesScreen(),
    const Text(""),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: WillPopScope(
        onWillPop: () async {
          ///Navigation history
          int length = navigationStack.length;
          if (length == 1 && navigationStack[0] == 0) {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              Fluttertoast.showToast(
                msg: "pressAgainToExit".translate(context),
              );
              return Future.value(false);
            }
          } else {
            //This will put our page on previous page.
            int secondLast = navigationStack[length - 2];
            navigationStack.removeLast();
            pageController.jumpToPage(secondLast);
            setState(() {});
            return false;
          }

          return Future.value(true);
        },
        child: Scaffold(
         backgroundColor: Colors.white,
          bottomNavigationBar:
              Constant.maintenanceMode == "1" ? null : bottomBar(),
          body: Stack(
            children: <Widget>[
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: onItemSwipe,
                children: pages,
              ),
              if (Constant.maintenanceMode == "1")
                Container(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight,
                child: Stack(
                  children: [
                    if(HiveUtils.getUserDetails().role != null && HiveUtils.getUserDetails().role == '3')
                      AnimatedBuilder(
                        animation: _forRentController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _rentTween.value,
                            left: 100,
                            right: 100,
                            child: GestureDetector(
                              onTap: () {
                                GuestChecker.check(onNotGuest: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        ProjectFormOne()),
                                  );
                                });
                              },
                              child: Container(
                                width: 128,
                                height: 44,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: context.color.tertiaryColor
                                    //         .withOpacity(0.4),
                                    //     offset: const Offset(0, 3),
                                    //     blurRadius: 10,
                                    //     spreadRadius: 0,
                                    //   )
                                    // ],
                                    color: context.color.tertiaryColor,
                                    borderRadius: BorderRadius.circular(22)),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // UiUtils.getSvg(AppIcons.forSale),
                                    // SizedBox(
                                    //   width: 7.rw(context),
                                    // ),
                                    Text(UiUtils.getTranslatedLabel(
                                        context, "Post Your Projects")).size(12)
                                        .color(context.color.buttonColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _forPropAnimationController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _propTween.value,
                            left: 100,
                            right: 100,
                            child: GestureDetector(
                              onTap: () {
                                // GuestChecker.check(onNotGuest: () {
                                //   Constant.addProperty.addAll(
                                //       {"propertyType": PropertyType.rent});
                                //   Navigator.pushNamed(
                                //     context,
                                //     Routes.selectPropertyTypeScreen,
                                //   );
                                // });
                                GuestChecker.check(onNotGuest: ()
                                {
                                  if (adList!.length > 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          SelectAdType(cat: adList)),
                                    );
                                  }
                                });
                              },
                              child: Container(
                                  width: 181,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: context.color.borderColor,
                                        width: 1.5,
                                      ),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: context.color.tertiaryColor
                                      //         .withOpacity(0.4),
                                      //     offset: const Offset(0, 3),
                                      //     blurRadius: 10,
                                      //     spreadRadius: 0,
                                      //   )
                                      // ],
                                      color: context.color.tertiaryColor,
                                      borderRadius: BorderRadius.circular(22)),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /*UiUtils.getSvg(AppIcons.forRent),
                                      SizedBox(
                                        width: 7.rw(context),
                                      ),*/
                                      Text(UiUtils.getTranslatedLabel(
                                              context, "Post Your Advertisment")).size(12)
                                          .color(context.color.buttonColor),
                                    ],
                                  )),
                            ),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _forSellAnimationController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _sellTween.value,
                            left: 100,
                            right: 100,
                            child: GestureDetector(
                              onTap: () {
                                GuestChecker.check(onNotGuest: () {
                                  Constant.addProperty.addAll(
                                    {
                                      "propertyType": PropertyType.sell,
                                    },
                                  );

                                  Navigator.pushNamed(
                                    context,
                                    Routes.selectPropertyTypeScreen,
                                  );
                                });
                              },
                              child: Container(
                                width: 128,
                                height: 44,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: context.color.tertiaryColor
                                    //         .withOpacity(0.4),
                                    //     offset: const Offset(0, 3),
                                    //     blurRadius: 10,
                                    //     spreadRadius: 0,
                                    //   )
                                    // ],
                                    color: context.color.tertiaryColor,
                                    borderRadius: BorderRadius.circular(22)),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // UiUtils.getSvg(AppIcons.forSale),
                                    // SizedBox(
                                    //   width: 7.rw(context),
                                    // ),
                                    Text(UiUtils.getTranslatedLabel(
                                            context, "Post Your Property")).size(12)
                                        .color(context.color.buttonColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              )

              //
            ],
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    addHistory(index);

    if (index == currtab) {
      var xIndex = index;

      if (xIndex == 3) {
        xIndex = 2;
      } else if (xIndex == 4) {
        xIndex = 3;
      }
      if (controllerList[xIndex].hasClients) {
        controllerList[xIndex].animateTo(0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut);
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
    isReverse?.value = true;
    _forSellAnimationController.reverse();
    _forRentController.reverse();
    _forPropAnimationController.reverse();

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = "";
      }
    }
    searchbody = {};
    if (index == 1 || index == 3) {
      GuestChecker.check(
        onNotGuest: () {
          currtab = index;
          pageController.jumpToPage(currtab);
          setState(
            () {},
          );
        },
      );
    } else {
      currtab = index;
      pageController.jumpToPage(currtab);

      setState(() {});
    }
  }

  void onItemSwipe(int index) {
    addHistory(index);

    if (index == 0) {
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: AnalyticsRoutes.home);
    } else if (index == 1) {
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: AnalyticsRoutes.chatList);
    } else if (index == 3) {
      FirebaseAnalytics.instance
          .setCurrentScreen(screenName: AnalyticsRoutes.properties);
    } else if (index == 4) {}
    FocusManager.instance.primaryFocus?.unfocus();
    isReverse?.value = true;
    _forSellAnimationController.reverse();
    _forRentController.reverse();
    _forPropAnimationController.reverse();

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = "";
      }
    }
    searchbody = {};
    setState(() {
      currtab = index;
    });
    pageController.jumpToPage(currtab);
  }

  BottomAppBar bottomBar() {
    return BottomAppBar(
      // notchMargin: 10.0,
      elevation: 0,
      color: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      child: Container(
        padding: EdgeInsets.only(left: 5,right: 5,bottom: 8,top: 8),
        margin: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xffeaeaea), // Shadow color
              offset: Offset(
                  0, 2), // Offset from the widget's position
              blurRadius: 2.0, // Spread of the shadow
              spreadRadius: 2.0, // Expands the shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buildBottomNavigationbarItem(
                    0,
                    "assets/Home/__Home.png",
                    UiUtils.getTranslatedLabel(context, "Home"),
                    currtab == 0,
                  ),
                  buildBottomNavigationbarItem(
                    1,
                    "assets/Home/__Explore.png",
                    UiUtils.getTranslatedLabel(context, "My Post"),
                    currtab == 1,
                  ),
                  // const SizedBox(
                  //   width: 100,
                  //   height: 100,
                  //   child: RiveAnimation.asset(
                  //     "",
                  //     artboard: "Add",
                  //   ),
                  // ),

                  // Transform(
                  //   transform: Matrix4.identity()..translate(0.toDouble(), -40),
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () async {
                  //           if (isReverse?.value == true) {
                  //             isReverse?.value = false;
                  //             showSellRentButton = true;
                  //             _forRentController.forward();
                  //             _forSellAnimationController.forward();
                  //             _forPropAnimationController.forward();
                  //           } else {
                  //             showSellRentButton = false;
                  //             isReverse?.value = true;
                  //             _forRentController.reverse();
                  //             _forSellAnimationController.reverse();
                  //             _forPropAnimationController.reverse();
                  //           }
                  //           // setState(() {});
                  //         },
                  //         child: SizedBox(
                  //             width: 55,
                  //             height: 55,
                  //             child: artboard == null
                  //                 ? Container()
                  //                 : Container(
                  //               width: 55,
                  //                height: 55,
                  //                decoration: BoxDecoration(
                  //                  border: Border.all(
                  //                    width: 3,
                  //                    color: Colors.white
                  //                  ),
                  //                  color: Color(0xff117af9),
                  //                  borderRadius: BorderRadius.circular(50),
                  //                  boxShadow: [
                  //                    BoxShadow(
                  //                      color: Color(0xffe1e1e1), // Shadow color
                  //                      offset: Offset(
                  //                          0, 2), // Offset from the widget's position
                  //                      blurRadius: 2.0, // Spread of the shadow
                  //                      spreadRadius: 2.0, // Expands the shadow
                  //                    ),
                  //                  ],
                  //                ),
                  //               child: InkWell(
                  //                   onTap: () async {
                  //                     if (isReverse?.value == true) {
                  //                       isReverse?.value = false;
                  //                       showSellRentButton = true;
                  //                       _forRentController.forward();
                  //                       _forSellAnimationController.forward();
                  //                       _forPropAnimationController.forward();
                  //                     } else {
                  //                       showSellRentButton = false;
                  //                       isReverse?.value = true;
                  //                       _forRentController.reverse();
                  //                       _forSellAnimationController.reverse();
                  //                       _forPropAnimationController.reverse();
                  //                     }
                  //                     // setState(() {});
                  //                   },
                  //                   child: Center(child: Image.asset("assets/Home/__Add .png",width: 22,height: 22,fit: BoxFit.cover,))),
                  //             ),
                  //         )
                  //                 // : Rive(artboard: artboard!)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  buildBottomNavigationbarItem(
                    3,
                    "assets/Home/__Shortlist.png",
                    UiUtils.getTranslatedLabel(context, "Shortlist"),
                    currtab == 3,
                  ),
                  buildBottomNavigationbarItem(
                    4,
                    "assets/Home/__Profile.png",
                    UiUtils.getTranslatedLabel(context, "Profile"),
                    currtab == 4,
                  ),
                ]),
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //
            //     children: [
            //       SizedBox(height: 8,),
            //       InkWell(
            //         onTap: () async {
            //           if (isReverse?.value == true) {
            //             isReverse?.value = false;
            //             showSellRentButton = true;
            //             _forRentController.forward();
            //             _forSellAnimationController.forward();
            //             _forPropAnimationController.forward();
            //           } else {
            //             showSellRentButton = false;
            //             isReverse?.value = true;
            //             _forRentController.reverse();
            //             _forSellAnimationController.reverse();
            //             _forPropAnimationController.reverse();
            //           }
            //           // setState(() {});
            //         },
            //         child: Text(
            //           "Post Ad",
            //           style: TextStyle(
            //               fontSize: 10,fontWeight: FontWeight.w500,color: Color(0xff747474)
            //           ),
            //           textAlign: TextAlign.center,
            //         ),
            //       ),
            //       SizedBox(height: 3,),
            //       InkWell(
            //         onTap: () async {
            //           if (isReverse?.value == true) {
            //             isReverse?.value = false;
            //             showSellRentButton = true;
            //             _forRentController.forward();
            //             _forSellAnimationController.forward();
            //             _forPropAnimationController.forward();
            //           } else {
            //             showSellRentButton = false;
            //             isReverse?.value = true;
            //             _forRentController.reverse();
            //             _forSellAnimationController.reverse();
            //             _forPropAnimationController.reverse();
            //           }
            //           // setState(() {});
            //         },
            //         child: Container(
            //           padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
            //           decoration: BoxDecoration(
            //             color: Color(0xffffa920),
            //             borderRadius: BorderRadius.circular(15.0),
            //
            //           ),
            //           child: Text(
            //             "FREE",
            //             style: TextStyle(
            //                 fontSize: 7,fontWeight: FontWeight.w600,color: Colors.white
            //             ),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 5,),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
      int index,
      String imagePath,
      String title,
      bool isSelected,
  ) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                imagePath,
                width: 23,
                height: 23,
                fit: BoxFit.cover,
                color: isSelected ? context.color.tertiaryColor : Color(0xff6b6b6b),
              ),
              // if (currtab == index) ...{
              //   UiUtils.getSvg(svgImage, color: context.color.tertiaryColor),
              // } else ...{
              //   UiUtils.getSvg(svgImage, color: context.color.textLightColor),
              // },
              SizedBox(height: 5,),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ).color(currtab == index
                  ? Color(0xff117af9)
                  : Color(0xff6b6b6b)),
            ],
          ),
        ),
      ),
    );
  }
}
