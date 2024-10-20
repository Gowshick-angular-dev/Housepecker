// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Housepecker/Ui/screens/home/Widgets/category_card.dart';
import 'package:Housepecker/Ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:Housepecker/Ui/screens/home/Widgets/property_horizontal_card.dart';
import 'package:Housepecker/Ui/screens/proprties/viewAll.dart';
import 'package:Housepecker/app/default_app_setting.dart';
import 'package:Housepecker/data/cubits/Personalized/fetch_personalized_properties.dart';
import 'package:Housepecker/data/cubits/Utility/proeprty_edit_global.dart';
import 'package:Housepecker/data/cubits/category/fetch_cities_category.dart';
import 'package:Housepecker/data/cubits/property/fetch_city_property_list.dart';
import 'package:Housepecker/data/cubits/property/fetch_nearby_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_recent_properties.dart';
import 'package:Housepecker/utils/AdMob/bannerAdLoadWidget.dart';
import 'package:Housepecker/utils/guestChecker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/components.dart';
import 'package:rive/rive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_links/uni_links.dart';

import '../../../app/app.dart';
import '../../../app/routes.dart';
import '../../../data/Repositories/favourites_repository.dart';
import '../../../data/Repositories/property_repository.dart';
import '../../../data/cubits/Utility/like_properties.dart';
import '../../../data/cubits/category/fetch_category_cubit.dart';
import '../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../data/cubits/favorite/fetch_favorites_cubit.dart';
import '../../../data/cubits/property/fetch_home_properties_cubit.dart';
import '../../../data/cubits/property/fetch_most_liked_properties.dart';
import '../../../data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import '../../../data/cubits/property/fetch_promoted_properties_cubit.dart';
import '../../../data/cubits/slider_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../data/cubits/system/get_api_keys_cubit.dart';
import '../../../data/helper/design_configs.dart';
import '../../../data/model/article_model.dart';
import '../../../data/model/category.dart';
import '../../../data/model/data_output.dart';
import '../../../data/model/property_model.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../settings.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/DeepLink/nativeDeepLinkManager.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/deeplinkManager.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Advertisement/selectAdType.dart';
import '../Loan/loanhome.dart';
import '../See all page/Agent.dart';
import '../See all page/Builder.dart';
import '../Service/servicehome.dart';
import '../construction/constructionhome.dart';
import '../jointventure/jontventurehome.dart';
import '../main_activity.dart';
import '../projects/projectAdd1.dart';
import '../projects/projectCategoryScreen.dart';
import '../projects/projectDetailsScreen.dart';
import '../projects/projectsListScreen.dart';
import '../proprties/widgets/propertyListWidget.dart';
import '../userprofile/userProfileScreen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/no_internet.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/like_button_widget.dart';
import '../widgets/promoted_widget.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'Widgets/city_heading_card.dart';
import 'Widgets/header_card.dart';
import 'Widgets/homeListener.dart';
import 'Widgets/home_profile_image_card.dart';
import 'Widgets/home_search.dart';
import 'Widgets/home_shimmers.dart';
import 'Widgets/location_widget.dart';
import 'Widgets/property_card_big.dart';
import 'slider_widget.dart';
import 'package:rive/src/rive_core/component.dart';

const double sidePadding = 3;

class HomeScreen extends StatefulWidget {
  final String? from;
  final bool openDrawer;
  final Function(FavoriteType type)? onLikeChange;
  const HomeScreen({Key? key, this.from, this.onLikeChange, this.openDrawer = false}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  List<PropertyModel> propertyLocalList = [];
  List blogsList = [];
  List adList = [];
  bool adListLoading = false;
  String currentAddress = '';
  String currentPlace = '';
  String currentCity = '';
  String currentMainCity = '';
  bool isCategoryEmpty = false;
  bool blogLoading = false;
  HomePageStateListener homeStateListener = HomePageStateListener();
  SMIBool? isReverse;
  Artboard? artboard;
  bool showSellRentButton = false;
  StateMachineController? _controller;
  bool favoriteInProgress = false;

  int _totalPropertyCount = 0;

  Map<String, dynamic> riveConfig = AppSettings.riveAnimationConfigurations;
  late var addButtonConfig = riveConfig['add_button'];
  late var artboardName = addButtonConfig['artboard_name'];
  late var stateMachine = addButtonConfig['state_machine'];
  late var booleanName = addButtonConfig['boolean_name'];
  late var booleanInitialValue = addButtonConfig['boolean_initial_value'];
  late var addButtonShapeName = addButtonConfig['add_button_shape_name'];

  late final AnimationController _forRentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 400),
  );

  late final AnimationController _forAdsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500),
  );

  late final AnimationController _forSellAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _sellTween = Tween<double>(begin: -50, end: 80)
      .animate(CurvedAnimation(
      parent: _forSellAnimationController, curve: Curves.easeIn));
  late final Animation<double> _adsTween = Tween<double>(begin: -50, end: 130)
      .animate(CurvedAnimation(
      parent: _forAdsController, curve: Curves.easeIn));
  late final Animation<double> _rentTween = Tween<double>(begin: -50, end: 30)
      .animate(
      CurvedAnimation(parent: _forRentController, curve: Curves.easeIn));

  @override
  void initState() {
    DeepLinkManager.initDeepLinks(context);
    _getCurrentLocation();
    getInitialLink().then((value) {
      if (value == null) return;

      Navigator.push(
        Constant.navigatorKey.currentContext!,
        NativeLinkWidget.render(
          RouteSettings(name: value),
        ),
      );
    });
    linkStream.listen((event) {
      Navigator.push(
        Constant.navigatorKey.currentContext!,
        NativeLinkWidget.render(
          RouteSettings(name: event),
        ),
      );
    });
    super.initState();
  }

  String formatAmount(int number) {
    String result = '';
    if(number >= 10000000) {
      result = '${(number/10000000).toStringAsFixed(2)} Cr';
    } else if(number >= 100000) {
      result = '${(number/100000).toStringAsFixed(2)} Laks';
    } else {
      result = '$number';
    }
    return result;
  }

  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await _requestLocationPermission();
    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
      return Future.error('Location permission denied');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      String address = '${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
      setState(() {
        currentAddress = address;
        currentPlace = '${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
        currentCity = '${place.subLocality}';
        currentMainCity = '${place.locality}';
      });

      // HiveUtils.setLocation(
      //   city: place.locality ?? '',
      //   state: place.administrativeArea ?? '',
      //   country: place.country ?? '',
      //   placeId: place.postalCode??'',
      // );

      getBanners(address);
      getProjects();
      getProperties();
      getAdTypes();
      getSystemSetting();
      initializeSettings();
      addPageScrollListener();
      notificationPermissionChecker();
      fetchApiKeys();
      loadInitialData(context);
      initializeHomeStateListener();
      getBlogs();
      initRiveAddButtonAnimation();
      HiveUtils.setCurrentAddress(address);
    } catch (e) {
      print("Error fetching address: $e");
    }
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

  List projectList = [];
  List premiumPropertiesList = [];
  List recentPropertiesList = [];
  List propertyDealList = [];
  List banners = [];
  List<bool> likeLoading = [];
  List<bool> premiumPropertyLikeLoading = [];
  List<bool> recentPropertyLikeLoading = [];
  List<bool> propertyDealLikeLoading = [];
  bool projectLoading = false;

  Map? systemSetting;

  bool premiumLoading = false;
  bool  recentLoading = false;
  bool dealLoading = false;



  Future<void> getProjects() async {
    setState(() {
      projectLoading = true;
    });
    var response = await Api.get(url: Api.getProject, queryParameters: {
      'offset': 0,
      'limit': 10,
      'city': currentMainCity,
      'current_user': HiveUtils.getUserId(),
      'new_launch' : 1
    });
    if(!response['error']) {
      setState(() {
        projectList = response['data'];
        likeLoading = List.filled(response['data'].length, false);
        projectLoading = false;
      });
    }
  }



  Future<void> getProperties() async {
    setState(() {
      premiumLoading = true;
      recentLoading = true;
      dealLoading = true;
    });
    var response = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'offset': 0,
      'limit': 10,
      'premium': 1,
      'city': currentMainCity,
      'current_user': HiveUtils.getUserId()
    });
    if(!response['error']) {
      setState(() {
        premiumPropertiesList = response['data'].where((e) => e['is_type'] == 'property').toList();
        premiumPropertyLikeLoading = List.filled(response['data'].length, false);
        premiumLoading = false;
      });
    }
    var recentResponse = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'offset': 0,
      'limit': 10,
      'recently_added': 1,
      'city': currentMainCity,
      'current_user': HiveUtils.getUserId()
    });
    if(!response['error']) {
      setState(() {
        recentPropertiesList = recentResponse['data'].where((e) => e['is_type'] == 'property').toList();
        recentPropertyLikeLoading = List.filled(recentResponse['data'].length, false);
        recentLoading = false;
      });
    }
    var dealResponse = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'offset': 0,
      'limit': 4,
      'city': currentMainCity,
      'deal_of_month': 1,
      'current_user': HiveUtils.getUserId()
    });
    if(!dealResponse['error']) {
      setState(() {
        propertyDealList = dealResponse['data'].where((e) => e['is_type'] == 'property').toList();
        propertyDealLikeLoading = List.filled(dealResponse['data'].length, false);
        dealLoading = false;

      });
    }
  }

  bool isBannerLoading = false;

  Future<void> getBanners(String address) async {

    setState(() {
      isBannerLoading = true;
    });

    var response = await Api.get(url: Api.getBannerData, queryParameters: {
      'address': address
    });
    if(!response['error']) {
      setState(() {
        banners = response['data'];
        isBannerLoading = false;
      });
    }
  }

  List<Map<String,dynamic>> allPropertyData = [];

  Future<void> getSystemSetting() async {
    var response = await Api.post(url: Api.apiGetSystemSettings, parameter: {
      'city': currentMainCity,
    });
    if (response != null && !response['error']) {
      setState(() {
        systemSetting = response['data'] ?? {};
        print("ssssssss: ${response}");

        var data = response['data'] ?? {};

        allPropertyData = [
          {
            "image": "assets/assets/Images/protal_2.png",
            "count": data['all_post_count'] ?? 0,
            "name": "All Properties & Project"
          },
          {
            "image": "assets/assets/Images/protal_3.png",
            "count": data['all_property'] ?? 0,
            "name": "Properties"
          },
          {
            "image": "assets/assets/Images/protal_4.png",
            "count":  data['project_count'] ?? 0,
            "name": "Project"
          }
        ];

      });
    }
  }


  Future<void> getAdTypes() async {
    setState(() {
      adListLoading = true;
    });
    var response = await Api.get(url: Api.advertisementCategory);
    if(!response['error']) {
      setState(() {
        adList = response['data'];
        adListLoading = false;
      });
    }
  }

  Future<void> getLiked() async {
    final FavoriteRepository _favoritesRepository = FavoriteRepository();
    DataOutput<PropertyModel> result =
      await _favoritesRepository.fechFavorites(offset: 0);

    Set likedItems = {};
    for(int i = 0; i < result.modelList.length; i++) {
      likedItems.add(result.modelList[i].id);
    }
    context.read<LikedPropertiesCubit>().emit(LikedPropertiesState(
        liked: likedItems, removedLikes: {}));
  }

  Future<void> getBlogs() async {
    setState(() {
      blogLoading = true;
    });
    var response = await Api.get(url: Api.blogs, queryParameters: {
      'limit': 5,
      'city': currentMainCity,
      'offset': 0
    });
    if(!response['error']) {
      setState(() {
        blogsList = response['data'];
        blogLoading = false;
      });
    }
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    homeScreenController.addListener(pageScrollListener);
  }

  bool _isLoaded = false;

  void initializeHomeStateListener() {
    homeStateListener.init(
      setState,
      onNetAvailable: () {
        loadInitialData(context);
      },
    );
  }

  void fetchApiKeys() {
    context.read<GetApiKeysCubit>().fetch();
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (homeScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchHomePropertiesCubit>().hasMoreData()) {
          context.read<FetchHomePropertiesCubit>().fetchMoreProperty();
        }
      }
    }
  }

  void _onTapPromotedSeeAll() {
    // Navigator.pushNamed(context, Routes.promotedPropertiesScreen);
    StateMap stateMap = StateMap<
        FetchPromotedPropertiesInitial,
        FetchPromotedPropertiesInProgress,
        FetchPromotedPropertiesSuccess,
        FetchPromotedPropertiesFailure>();

    ViewAllScreen<FetchPromotedPropertiesCubit, FetchPromotedPropertiesState>(
      title: "promotedProperties".translate(
        context,
      ),
      map: stateMap,
    ).open(context);
  }

  void _onTapNearByPropertiesAll() {
    StateMap stateMap = StateMap<
        FetchNearbyPropertiesInitial,
        FetchNearbyPropertiesInProgress,
        FetchNearbyPropertiesSuccess,
        FetchNearbyPropertiesFailure>();

    ViewAllScreen<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      title: "nearByProperties".translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onTapMostLikedAll() {
    ///Navigator.pushNamed(context, Routes.mostLikedPropertiesScreen);
    StateMap stateMap = StateMap<
        FetchMostLikedPropertiesInitial,
        FetchMostLikedPropertiesInProgress,
        FetchMostLikedPropertiesSuccess,
        FetchMostLikedPropertiesFailure>();

    ViewAllScreen<FetchMostLikedPropertiesCubit, FetchMostLikedPropertiesState>(
      title: "mostLikedProperties".translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onTapMostViewedSeelAll() {
    StateMap stateMap = StateMap<
        FetchMostViewedPropertiesInitial,
        FetchMostViewedPropertiesInProgress,
        FetchMostViewedPropertiesSuccess,
        FetchMostViewedPropertiesFailure>();

    ViewAllScreen<FetchMostViewedPropertiesCubit,
        FetchMostViewedPropertiesState>(
      title: "mostViewed".translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onRefresh() {
    getProjects();
    getProperties();
    getBlogs();
    getAdTypes();
    context.read<FetchMostViewedPropertiesCubit>().fetch(forceRefresh: true);
    context.read<SliderCubit>().fetchSlider(context, forceRefresh: true);
    context.read<FetchCategoryCubit>().fetchCategories(forceRefresh: true,locationName: currentMainCity);
    context.read<FetchRecentPropertiesCubit>().fetch(forceRefresh: true);
    context.read<FetchMostLikedPropertiesCubit>().fetch(forceRefresh: true);
    context.read<FetchNearbyPropertiesCubit>().fetch(forceRefresh: true);
    context.read<FetchPromotedPropertiesCubit>().fetch(forceRefresh: true);
    context
        .read<FetchCityCategoryCubit>()
        .fetchCityCategory(forceRefresh: true);
    context.read<FetchPersonalizedPropertyList>().fetch(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    HomeScreenDataBinding homeScreenState = homeStateListener.listen(context);

    // FirebaseMessaging.instance
    //     .getToken()
    //     .then((value) => log(value!, name: "FCM"));
    //
    // HiveUtils.getJWT()?.log("JWT");
    // HiveUtils.getUserId()?.log("USER ID");

    return Stack(
      children: [
        SafeArea(
          child: RefreshIndicator(
            color: context.color.tertiaryColor,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () async {
              _onRefresh();
            },
            child: Scaffold(
              backgroundColor: const Color(0xff000000).withOpacity(0.04),
              appBar: AppBar(
                elevation: 0,
                leadingWidth: HiveUtils.getCityName() != null ? 200.rw(context) : 130,
                leading: Container(),
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/Splash/Logo.png",
                            width: 140,
                            height: 20,
                            fit: BoxFit.contain,
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
                                  });
                                  getBanners(address);
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
                                const SizedBox(width: 5,),
                                Container(
                                  width: 80,
                                  child: Text('${currentMainCity}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5,),
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
                      Row(
                        children: [
                          if(!showSellRentButton)
                            InkWell(
                              // onTap: () async {
                              //   GuestChecker.check(onNotGuest: ()
                              //     {
                              //       if (adList!.length > 0) {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(builder: (context) =>
                              //               SelectAdType(cat: adList)),
                              //         );
                              //       }
                              //     });
                              // },
                              // onTap: () => widget.openDrawer,
                              onTap: () {
                                Timer? _timer;
                                if (isReverse?.value == true) {
                                  isReverse?.value = false;
                                  showSellRentButton = true;
                                  _forRentController.forward();
                                  _forAdsController.forward();
                                  _forSellAnimationController.forward();
                                  setState(() {});
                                  _timer = Timer(const Duration(seconds: 3), () {
                                    showSellRentButton = false;
                                    isReverse?.value = true;
                                    _forRentController.reverse();
                                    _forAdsController.reverse();
                                    _forSellAnimationController.reverse();
                                    setState(() {});
                                  });
                                } else {
                                  showSellRentButton = false;
                                  isReverse?.value = true;
                                  _forRentController.reverse();
                                  _forAdsController.reverse();
                                  _forSellAnimationController.reverse();
                                  setState(() {});
                                  if (_timer != null && _timer.isActive) {
                                    _timer.cancel();
                                  }
                                }
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 8,top: 5,bottom: 5),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/Home/__Add post.png',
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 5,),
                                      const Text(
                                        'Post Ads',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Container(
                                        padding: const EdgeInsets.only(right: 8.0,left: 8,top: 5,bottom: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffffa920),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Text(
                                          'FREE',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 10,),
                          InkWell(
                            onTap: () {
                              GuestChecker.check(onNotGuest: () {
                                Navigator.pushNamed(
                                    context, Routes.notificationPage);
                              });
                            },
                            child: Container(
                              child: Stack(
                                children: [
                                  Icon(Icons.notifications_on_outlined,
                                    color: context.color.secondaryColor,),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                      height: 8,
                                      width: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                backgroundColor: const Color(0xff117af9),
                // actions: [
                //   GuestChecker.updateUI(
                //     onChangeStatus: (bool? isGuest) {
                //       Widget buildDefaultPersonSVG(BuildContext context) {
                //         return Container(
                //           width: 90,
                //           height: 90,
                //           decoration: BoxDecoration(
                //               color: context.color.tertiaryColor.withOpacity(0.1),
                //               shape: BoxShape.circle),
                //           child: Center(
                //             child: UiUtils.getSvg(
                //               AppIcons.defaultPersonLogo,
                //               color: context.color.tertiaryColor,
                //               // fit: BoxFit.none,
                //               width: 30,
                //               height: 30,
                //             ),
                //           ),
                //         );
                //       }
                //
                //       if (isGuest == null) {
                //         return buildDefaultPersonSVG(context);
                //       } else if (isGuest == true) {
                //         return buildDefaultPersonSVG(context);
                //       } else {
                //         return const CircularProfileImageWidget();
                //       }
                //     },
                //   )
                // ],
              ),
              body: Builder(builder: (context) {
                // if (homeScreenState.state == HomeScreenDataState.fail) {
                //   return const SomethingWentWrong();
                // }

                return BlocConsumer<FetchSystemSettingsCubit,
                    FetchSystemSettingsState>(
                  listener: (context, state) {
                    if (state is FetchCategoryInProgress) {
                      homeStateListener.setNetworkState(setState, true);
                      setState(() {});
                    }
                    if (state is FetchSystemSettingsSuccess) {
                      homeStateListener.setNetworkState(setState, true);

                      setState(() {});
                      var setting = context
                          .read<FetchSystemSettingsCubit>()
                          .getSetting(SystemSetting.subscription);
                      if (setting.length != 0) {
                        String packageId = setting[0]['package_id'].toString();
                        Constant.subscriptionPackageId = packageId;
                      }
                    }
                  },
                  builder: (context, state) {
                    if (homeScreenState.state == HomeScreenDataState.success) {
                    } else if (homeScreenState.state ==
                        HomeScreenDataState.nointernet) {
                      return NoInternet(
                        onRetry: () {
                          context.read<SliderCubit>().fetchSlider(context);
                          context.read<FetchCategoryCubit>().fetchCategories();
                          context.read<FetchMostViewedPropertiesCubit>().fetch();
                          context.read<FetchPromotedPropertiesCubit>().fetch();
                          context.read<FetchHomePropertiesCubit>().fetchProperty();
                        },
                      );
                    }

                    if (homeScreenState.state == HomeScreenDataState.nodata) {
                      return Center(
                        child: NoDataFound(
                          onTap: () {
                            context.read<SliderCubit>().fetchSlider(context);
                            context.read<FetchCategoryCubit>().fetchCategories();

                            context.read<FetchMostViewedPropertiesCubit>().fetch();
                            context.read<FetchPromotedPropertiesCubit>().fetch();
                            context
                                .read<FetchHomePropertiesCubit>()
                                .fetchProperty();
                          },
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      controller: homeScreenController,
                      // physics: const BouncingScrollPhysics(),
                      // padding: EdgeInsets.symmetric(
                      //   vertical: MediaQuery.of(context).padding.top,
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ///Looping through sections so arrange it
                          ...List.generate(
                            AppSettings.sections.length,
                            (index) {
                              HomeScreenSections section = AppSettings.sections[index];

                              if (section == HomeScreenSections.Search) {
                                return HomeSearchField(banner: systemSetting != null ? systemSetting : null);
                              }

                              // else if (section == HomeScreenSections.Slider) {
                              //   return sliderWidget();
                              // }

                              else if (section == HomeScreenSections.Category) {
                                return categoryWidget();
                              }

                              else if (section == HomeScreenSections.banner) {
                                return isBannerLoading?const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: SliderShimmer(),
                                ):bannerWidget();
                              }

                              // else if (section == HomeScreenSections.RecentlyAdded) {
                              //   return  const RecentPropertiesSectionWidget();
                              // }

                              else if (section == HomeScreenSections.Premiumpropertiesforsale) {
                                return PremiumpropertiesforsaleWidget();
                              }

                              else if (section == HomeScreenSections.NearbyProperties) {
                                return buildNearByProperties();
                              }

                              // else if (section == HomeScreenSections.FeaturedProperties) {
                              //   return  featuredProperties(homeScreenState, context);
                              // }

                              // else if (section == HomeScreenSections.PersonalizedFeed) {
                              //   return const PersonalizedPropertyWidget();
                              // }



                              // else if (section == HomeScreenSections.MostLikedProperties) {
                              //   return mostLikedProperties(
                              //       homeScreenState, context);
                              // }
                              //
                              // else if (section == HomeScreenSections.MostViewed) {
                              //   return mostViewedProperties( homeScreenState, context);
                              // }
                              //
                              // else if (section == HomeScreenSections.PopularCities) {
                              //   return Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //       vertical: 10,
                              //     ),
                              //     child: Column(
                              //       children: [
                              //         const BannerAdWidget(),
                              //         const SizedBox(
                              //           height: 10,
                              //         ),
                              //         popularCityProperties(),
                              //       ],
                              //     ),
                              //   );
                              // }

                              else {
                                return const SizedBox.shrink();
                              }

                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
        if(widget.openDrawer)
          SizedBox(
          width: double.infinity,
          height: context.screenHeight,
          child: Stack(
            children: [
              AnimatedBuilder(
                  animation: _forAdsController,
                  builder: (context, c) {
                    return Positioned(
                      bottom: _adsTween.value,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: context.color.tertiaryColor
                                        .withOpacity(0.4),
                                    offset: const Offset(0, 3),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  )
                                ],
                                color: context.color.tertiaryColor,
                                borderRadius: BorderRadius.circular(22)),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // UiUtils.getSvg(AppIcons.forRent),
                                // SizedBox(
                                //   width: 7.rw(context),
                                // ),
                                Text(UiUtils.getTranslatedLabel(
                                    context, "Post Your Advertisment")).size(12)
                                    .color(context.color.buttonColor),
                              ],
                            )),
                      ),
                    );
                  }),
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
                                  const ProjectFormOne()),
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
                              boxShadow: [
                                BoxShadow(
                                  color: context.color.tertiaryColor
                                      .withOpacity(0.4),
                                  offset: const Offset(0, 3),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                )
                              ],
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
                              boxShadow: [
                                BoxShadow(
                                  color: context.color.tertiaryColor
                                      .withOpacity(0.4),
                                  offset: const Offset(0, 3),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                )
                              ],
                              color: context.color.tertiaryColor,
                              borderRadius: BorderRadius.circular(22)),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*UiUtils.getSvg(AppIcons.forSale),
                              SizedBox(
                                width: 7.rw(context),
                              ),*/
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
      ],
    );
  }

  bool cityEmpty() {
    if (context.watch<FetchCityCategoryCubit>().state
        is FetchCityCategorySuccess) {
      return (context.watch<FetchCityCategoryCubit>().state
              as FetchCityCategorySuccess)
          .cities
          .isEmpty;
    }
    return true;
  }

  Widget popularCityProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!cityEmpty()) const CityHeadingCard(),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
            builder: (context, FetchCityCategoryState state) {
              if (state is FetchCityCategorySuccess) {
                return StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    ...List.generate(state.cities.length, (index) {
                      if ((index % 4 == 0 || index % 5 == 0)) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 2,
                          child: buildCityCard(state, index),
                        );
                      } else {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: buildCityCard(state, index),
                        );
                      }
                    }),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget mostViewedProperties(
      HomeScreenDataBinding homeScreenState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!homeScreenState.dataAvailability.isMostViewdPropertyEmpty)
          TitleHeader(
              onSeeAll: _onTapMostViewedSeelAll,
              title: UiUtils.getTranslatedLabel(context, "mostViewed")),
        if (!homeScreenState.dataAvailability.isMostViewdPropertyEmpty)
          buildMostViewedProperties(),
      ],
    );
  }

  Widget mostLikedProperties(
      HomeScreenDataBinding homeScreenState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!homeScreenState.dataAvailability.isMostLikedPropertiesEmpty) ...[
          TitleHeader(
            onSeeAll: _onTapMostLikedAll,
            title: UiUtils.getTranslatedLabel(
              context,
              "mostLikedProperties",
            ),
          ),
          buildMostLikedProperties(),
          const SizedBox(
            height: 15,
          ),
        ],
      ],
    );
  }

  Widget featuredProperties(
      HomeScreenDataBinding homeScreenState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!homeScreenState.dataAvailability.isPromotedPropertyEmpty)
          TitleHeader(
            onSeeAll: _onTapPromotedSeeAll,
            title: UiUtils.getTranslatedLabel(
              context,
              "promotedProperties",
            ),
          ),
        if (!homeScreenState.dataAvailability.isPromotedPropertyEmpty)
          buildPromotedProperites(),
      ],
    );
  }

  Widget sliderWidget() {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderFetchSuccess) {
          homeStateListener.setNetworkState(setState, true);
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is SliderFetchInProgress) {
          return const SliderShimmer();
        }
        if (state is SliderFetchFailure) {
          return Container();
        }
        if (state is SliderFetchSuccess) {
          if (state.sliderlist.isNotEmpty) {
            return const SliderWidget();
          }
        }
        return Container();
      },
    );
  }

  Widget buildCityCard(FetchCityCategorySuccess state, int index) {
    return GestureDetector(
      onTap: () {
        context.read<FetchCityPropertyList>().fetch(
              cityName: state.cities[index].name.toString(),
              forceRefresh: true,
            );

        var stateMap = StateMap<
            FetchCityPropertyInitial,
            FetchCityPropertyInProgress,
            FetchCityPropertySuccess,
            FetchCityPropertyFail>();

        ViewAllScreen<FetchCityPropertyList, FetchCityPropertyListState>(
          title: state.cities[index].name.firstUpperCase(),
          map: stateMap,
        ).open(context);
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: state.cities[index].image,
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.bottomCenter,
                //     end: Alignment.topCenter,
                //     colors: [
                //       Colors.black.withOpacity(0.76),
                //       Colors.black.withOpacity(0.68),
                //       Colors.black.withOpacity(0)
                //     ],
                //   ),
                // ),
              ),
              PositionedDirectional(
                bottom: 8,
                start: 8,
                child: Text(
                        "${state.cities[index].name.toString().firstUpperCase()} (${state.cities[index].count})")
                    .color(context.color.buttonColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPromotedProperites() {
    return BlocBuilder<FetchPromotedPropertiesCubit, FetchPromotedPropertiesState>(
      builder: (context, state) {
        if (state is FetchPromotedPropertiesInProgress) {
          return const PromotedPropertiesShimmer();
        }
        if (state is FetchPromotedPropertiesFailure) {
          return Text(state.error);
        }

        if (state is FetchPromotedPropertiesSuccess) {
          return SizedBox(
            height: 240,
            child: ListView.builder(
              itemCount: state.properties.length.clamp(0, 6),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: sidePadding,
              ),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                GlobalKey thisITemkye = GlobalKey();

                ///Model
                PropertyModel propertymodel = state.properties[index];
                propertymodel =
                    context.watch<PropertyEditCubit>().get(propertymodel);
                return GestureDetector(
                    onTap: () {
                      FirebaseAnalytics.instance
                          .logEvent(name: "preview_property", parameters: {
                        "user_ids": HiveUtils.getUserId(),
                        "from_section": "featured",
                        "property_id": propertymodel.id,
                        "category_id": propertymodel.category!.id
                      });

                      HelperUtils.goToNextPage(
                        Routes.propertyDetails,
                        context,
                        false,
                        args: {
                          'propertyData': propertymodel,
                          'propertiesList': state.properties,
                          'fromMyProperty': false,
                        },
                      );
                    },
                    child: BlocProvider(
                      create: (context) {
                        return AddToFavoriteCubitCubit();
                      },
                      child: PropertyCardBig(
                        key: thisITemkye,
                        isFirst: index == 0,
                        property: propertymodel,
                        onLikeChange: (type) {
                          if (type == FavoriteType.add) {
                            context
                                .read<FetchFavoritesCubit>()
                                .add(propertymodel);
                          } else {
                            context
                                .read<FetchFavoritesCubit>()
                                .remove(state.properties[index].id);
                          }
                        },
                      ),
                    ));
              },
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget buildMostLikedProperties() {
    return BlocConsumer<FetchMostLikedPropertiesCubit,
        FetchMostLikedPropertiesState>(
      listener: (context, state) {
        if (state is FetchMostLikedPropertiesFailure) {
          if (state.error is ApiException) {
            homeStateListener.setNetworkState(
                setState, !(state.error.errorMessage == "no-internet"));
          }
          setState(() {});
        }
        if (state is FetchMostLikedPropertiesSuccess) {
          homeStateListener.setNetworkState(setState, true);
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is FetchMostLikedPropertiesInProgress) {
          return const MostLikedPropertiesShimmer();
        }

        if (state is FetchMostLikedPropertiesFailure) {
          return Text(state.error.error.toString());
        }
        if (state is FetchMostLikedPropertiesSuccess) {
          return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 240),
            itemCount: state.properties.length.clamp(0, 4),
            itemBuilder: (context, index) {
              PropertyModel property = state.properties[index];

              property = context.watch<PropertyEditCubit>().get(property);

              return GestureDetector(
                onTap: () {
                  HelperUtils.goToNextPage(
                      Routes.propertyDetails, context, false,
                      args: {
                        'propertyData': property,
                        'propertiesList': state.properties,
                        'fromMyProperty': false,
                      });
                },
                child: BlocProvider(
                  create: (context) => AddToFavoriteCubitCubit(),
                  child: PropertyCardBig(
                    showEndPadding: false,
                    isFirst: index == 0,
                    onLikeChange: (type) {
                      if (type == FavoriteType.add) {
                        context.read<FetchFavoritesCubit>().add(property);
                      } else {
                        context.read<FetchFavoritesCubit>().remove(property.id);
                      }
                    },
                    property: property,
                  ),
                ),
              );
            },
          );
        }

        return Container();
      },
    );
  }

  Widget buildNearByProperties() {
    return BlocConsumer<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      listener: (context, state) {
        if (state is FetchNearbyPropertiesFailure) {
          if (state.error is ApiException) {
            homeStateListener.setNetworkState(
              setState,
              !(state.error.error == "no-internet"),
            );
          } else if (state.error is String) {
            homeStateListener.setNetworkState(setState, false);
          }
          setState(() {});
        }
        if (state is FetchNearbyPropertiesSuccess) {
          setState(() {});
        }
      },

      builder: (context, state) {
        if (state is FetchNearbyPropertiesInProgress) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                TitleHeader(
                  onSeeAll: _onTapNearByPropertiesAll,
                  title: "${UiUtils.getTranslatedLabel(
                    context,
                    "nearByProperties",
                  )} (${currentCity})",
                ),
                const NearbyPropertiesShimmer(),
              ],
            ),
          );
        }
        if (state is FetchNearbyPropertiesFailure) {
          final errorMessage = state.error is String
              ? state.error
              : state.error.error;
          return Center();
        }
        // if (state is FetchNearbyPropertiesFailure) {
        //   final errorMessage = state.error is String
        //       ? state.error
        //       : state.error.error;
        //   return Center(child: Text(errorMessage));
        // }
        if (state is FetchNearbyPropertiesSuccess) {
          if (state.properties.isEmpty) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TitleHeader(
                  onSeeAll: _onTapNearByPropertiesAll,
                  title: "${UiUtils.getTranslatedLabel(
                    context,
                    "nearByProperties",
                  )} (${currentCity})",
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  separatorBuilder: (context,i)=>SizedBox(width: 10,),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.properties.length.clamp(0, 10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      PropertyModel model = state.properties[index];
                      model = context.watch<PropertyEditCubit>().get(model);
                      return PropertyGradiendCard(
                        model: model,
                        isFirst: index == 0,
                        showEndPadding: false,
                      );
                    }),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget buildMostViewedProperties() {
    return BlocConsumer<FetchMostViewedPropertiesCubit,
        FetchMostViewedPropertiesState>(
      listener: (context, state) {
        if (state is FetchMostViewedPropertiesFailure) {
          if (state.error is ApiException) {
            homeStateListener.setNetworkState(
                setState, !(state.error.error == "no-internet"));
          }
          setState(() {});
        }
        if (state is FetchMostViewedPropertiesSuccess) {
          homeStateListener.setNetworkState(setState, true);
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is FetchMostViewedPropertiesInProgress) {
          return const MostViewdPropertiesShimmer();
        }

        if (state is FetchMostViewedPropertiesFailure) {
          return Text(state.error.error.toString());
        }
        if (state is FetchMostViewedPropertiesSuccess) {
          return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 240),
            itemCount: state.properties.length.clamp(0, 4),
            itemBuilder: (context, index) {
              PropertyModel property = state.properties[index];
              property = context.watch<PropertyEditCubit>().get(property);
              return GestureDetector(
                onTap: () {
                  HelperUtils.goToNextPage(
                      Routes.propertyDetails, context, false,
                      args: {
                        'propertyData': property,
                        'propertiesList': state.properties,
                        'fromMyProperty': false,
                      });
                },
                child: BlocProvider(
                  create: (context) => AddToFavoriteCubitCubit(),
                  child: PropertyCardBig(
                    showEndPadding: false,
                    isFirst: index == 0,
                    onLikeChange: (type) {
                      if (type == FavoriteType.add) {
                        context.read<FetchFavoritesCubit>().add(property);
                      } else {
                        context.read<FetchFavoritesCubit>().remove(property.id);
                      }
                    },
                    property: property,
                  ),
                ),
              );
            },
          );
        }

        return Container();
      },
    );
  }

  Widget categoryWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SizedBox(
            height: 85,
            child: BlocConsumer<FetchCategoryCubit, FetchCategoryState>(
              listener: (context, state) {
                if (state is FetchCategoryFailure) {
                  if (state.errorMessage == "auth-expired") {
                    HelperUtils.showSnackBarMessage(context,
                        UiUtils.getTranslatedLabel(context, "authExpired"));

                    HiveUtils.logoutUser(
                      context,
                      onLogout: () {},
                    );
                  }
                }

                if (state is FetchCategorySuccess) {
                  isCategoryEmpty = state.categories.isEmpty;
                  setState(() {});
                }
              },
              builder: (context, state) {
                if (state is FetchCategoryInProgress) {
                  return const CategoryShimmer();
                }
                if (state is FetchCategoryFailure) {
                  return Center(
                    child: Text(state.errorMessage.toString()),
                  );
                }
                if (state is FetchCategorySuccess) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: sidePadding,
                    ),
                    scrollDirection: Axis.horizontal,
                    // shrinkWrap: false,
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisCount: 4, // Number of items in one line
                    //   crossAxisSpacing: 10.0,
                    //   mainAxisSpacing: 10.0,
                    //   childAspectRatio :1.0,
                    // ),
                    itemCount: state.categories.length + 3,
                    // itemCount: state.categories.length
                    //     .clamp(0, Constant.maxCategoryLength),
                    itemBuilder: (context, index) {
                      // if (index == (Constant.maxCategoryLength - 1)) {
                      //   return Padding(
                      //     padding: const EdgeInsetsDirectional.only(start: 10,),
                      //     child: GestureDetector(
                      //       onTap: () {
                      //         Navigator.pushNamed(context, Routes.categories);
                      //       },
                      //       child: Container(
                      //         constraints: BoxConstraints(
                      //           minWidth: 100.rw(context),
                      //         ),
                      //         height: 44.rh(context),
                      //         alignment: Alignment.center,
                      //         decoration: DesignConfig.boxDecorationBorder(
                      //           color: context.color.secondaryColor,
                      //           radius: 10,
                      //           borderWidth: 1.5,
                      //           borderColor: context.color.borderColor,
                      //         ),
                      //         child: Padding(
                      //           padding:
                      //           const EdgeInsets.symmetric(horizontal: 10),
                      //           child: Text(
                      //               UiUtils.getTranslatedLabel(context, "more")),
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }
                      if(index > 2) {
                        Category category = state.categories[index - 3];
                        Constant.propertyFilter = null;
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: buildCategoryCard(context, category, index != 0),
                        );
                      } else {
                        return Container();
                      }
                    }, separatorBuilder: (BuildContext context, int index) {
                      if(index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              // onTapCategory.call(category);
                              Navigator.of(context).pushNamed(Routes.propertiesListType,
                                  arguments: {'type': 'buy', 'typeName': 'buy'});
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width/4.9,
                              decoration: BoxDecoration(
                                color: const Color(0xff117af9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color(0xfff0f0f0),
                                    offset: Offset(0, 2),
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        // borderRadius: BorderRadius.circular(10),
                                        child: Image.asset("assets/Home/__Buy.png", width: 25, height: 25,),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const SizedBox(
                                        child: Text('Buy',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff333333)
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if(index == 1) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              // onTapCategory.call(category);
                              Navigator.of(context).pushNamed(Routes.propertiesListType,
                                  arguments: {'type': 'rent', 'typeName': 'rent'});
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width/4.9,
                              decoration: BoxDecoration(
                                color: const Color(0xff117af9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color(0xfff0f0f0),
                                    offset: Offset(0, 2),
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        // borderRadius: BorderRadius.circular(10),
                                        child: Image.asset("assets/Home/__Rent.png", width: 25, height: 25,),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const SizedBox(
                                        child: Text('Rent/Lease',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff333333)
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if(index == 2) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    ProjectViewAllScreen()),
                              );
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width/4.9,
                              decoration: BoxDecoration(
                                color: const Color(0xff117af9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color(0xfff0f0f0),
                                    offset: Offset(0, 2),
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        // borderRadius: BorderRadius.circular(10),
                                        child: Image.asset("assets/Home/__PG.png", width: 25, height: 25,),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const SizedBox(
                                        child: Text('New Projects',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff333333)
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                  },
                  );
                }
                return Container();
              },
            ),
          ),
        ),
        if(adListLoading)
          const Padding(
            padding: EdgeInsets.all(13),
            child: CategoryShimmer(),
          ),
        if(adList.length > 0 && !adListLoading)
          Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    GuestChecker.check(
                      onNotGuest: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const JointVenture()),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 75,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff117af9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xfff0f0f0),
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UiUtils.imageType(adList[0]['image'],
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    color: Constant.adaptThemeColorSvg
                                        ? context.color.tertiaryColor
                                        : null),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                child: Text(adList[0]['name'],
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    GuestChecker.check(
                      onNotGuest: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const ConstructionHome()),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 75,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff117af9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xfff0f0f0),
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UiUtils.imageType(adList[1]['image'],
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    color: Constant.adaptThemeColorSvg
                                        ? context.color.tertiaryColor
                                        : null),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                child: Text(adList[1]['name'],
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    GuestChecker.check(
                      onNotGuest: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const ServiceHome()),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 75,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff117af9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xfff0f0f0),
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UiUtils.imageType(adList[2]['image'],
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    color: Constant.adaptThemeColorSvg
                                        ? context.color.tertiaryColor
                                        : null),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                child: Text(adList[2]['name'],
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    GuestChecker.check(
                      onNotGuest: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const LoanHome()),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 75,
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff117af9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xfff0f0f0),
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: UiUtils.imageType(adList[3]['image'],
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    color: Constant.adaptThemeColorSvg
                                        ? context.color.tertiaryColor
                                        : null),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                child: Text(adList[3]['name'],
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget bannerWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 2.5,
              autoPlay: true,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {},
            ),
            items: banners.map((banner) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: '${banner['banner']}',
                  width: MediaQuery.sizeOf(context).width - 30,
                  fit: BoxFit.cover,
                  height: 150,
                  placeholder: (context, url) =>
                      Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget PremiumpropertiesforsaleWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Premium Properties For Sale",
                style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        const PropertiesListWidget(typeName: "Premium Properties For Sale"),
                    ),
                  );
                },
                child: const Text("See All",
                  style: TextStyle(
                      color: Color(0xff117af9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        if(premiumLoading )
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: buildPropertiesShimmer(context, 2),
          ),
        if(!premiumLoading)
          Container(
            height: 230,
            child:premiumPropertiesList.isNotEmpty? ListView.builder(
              itemCount: premiumPropertiesList.length,
              scrollDirection: Axis.horizontal,
              // shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    HelperUtils.goToNextPage(
                        Routes.propertyDetails, context, false, args: {
                      'propertyData': PropertyModel.fromMap(
                          premiumPropertiesList[index]),
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 10),
                    child: PropertyVerticalCard(property: PropertyModel.fromMap(premiumPropertiesList[index])),
                  ),
                );
              }
            ): const Center(child: Text("No data available for this city",style: TextStyle(fontSize: 14),),),
          ),
        const SizedBox(height: 20,),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/Home/bg.png"),fit: BoxFit.cover)
          ),
          child: Column(
            children: [
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Deal Of The Month",
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              const PropertiesListWidget(typeName: "Deal Of The Month"),
                          ),
                        );
                      },
                      child: const Text("See All",
                        style: TextStyle(
                            color: Color(0xff117af9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              if(dealLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: buildPropertiesShimmer(context, 4),
                ),
              if(!dealLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: propertyDealList.isNotEmpty? GridView.builder(
                    shrinkWrap: true,
                    itemCount: propertyDealList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final PropertyModel data = PropertyModel.fromMap(propertyDealList[index]);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            HelperUtils.goToNextPage(
                                Routes.propertyDetails, context, false, args: {
                              'propertyData': data,
                            });
                          },
                          child: PropertyHorizontalCard(property: data),
                        ),
                      );
                    },
                  ):Container(height: 200,child: Center(child: Text("No data available for this city",),),),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        buildExpolerPropertiesType(),
        // if(systemSetting != null)
        //   Padding( padding: const EdgeInsets.only(right: 15,left: 15),
        //       child: ClipRRect( borderRadius : BorderRadius.circular(20),
        //           child: Image.network("${systemSetting!['second_banner']}",
        //             width: double.infinity,fit: BoxFit.cover,))),
        // if(HiveUtils.getUserDetails().role != null && HiveUtils.getUserDetails().role == '3')

        RecentPropertiesSectionWidget(projectLoading: projectLoading, likeLoading: likeLoading, projectList: projectList),
        const SizedBox(height: 20,),
        buildAllPropertyNeeds(),
        const SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recently Added",
                style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        const PropertiesListWidget(typeName: "Recently Added Properties"),
                    ),
                  );
                },
                child: const Text("See All",
                  style: TextStyle(
                      color: Color(0xff117af9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        if(recentLoading )
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: buildPropertiesShimmer(context, 2),
          ),
        if(!recentLoading)
          Container(
            height: 230,
            child:recentPropertiesList.isNotEmpty? ListView.builder(
                itemCount: recentPropertiesList.length,
                scrollDirection: Axis.horizontal,
                // shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      HelperUtils.goToNextPage(
                          Routes.propertyDetails, context, false, args: {
                        'propertyData': PropertyModel.fromMap(
                            recentPropertiesList[index]),
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 10),
                      child: PropertyVerticalCard(property: PropertyModel.fromMap(recentPropertiesList[index])),
                    ),
                  );
                }
            ):const Center(child: Text( "No data available for this city",)),
          ),
        TopAgents(city: currentMainCity),
        TopBuilders(city: currentMainCity),

        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: TitleHeader(
            enableShowAll: true,
            title: "Most Popular Blogs",
            subTitle: "Get some Inspirations",
            onSeeAll: () {
              Navigator.pushNamed(
                context,
                Routes.articlesScreenRoute,
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15,right: 15),
          padding: const EdgeInsets.only(left: 10,right: 15,top: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 1,
                  color: const Color(0xffDBDBDB)
              )

          ),
          child: blogLoading ? ListView.builder(
            physics:  const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: CustomShimmer(height: 90, width: 90),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          CustomShimmer(
                            height: 10,
                            width: MediaQuery.sizeOf(context).width - 100,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomShimmer(
                            height: 10,),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomShimmer(
                            height: 10,
                            width: MediaQuery.sizeOf(context).width / 1.2,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomShimmer(
                            height: 10,
                            width: MediaQuery.sizeOf(context).width / 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            shrinkWrap: true,
            itemCount: 5,
          ) : Column(
            children: [
              for(var i = 0; i < blogsList.length; i++)
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.articleDetailsScreenRoute,
                      arguments: {
                        "model": ArticleModel.fromJson(blogsList[i]),
                        "title": blogsList[i]['title']
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10,top: 5),
                    child: Row(
                      children: [
                        ClipRRect(
                            borderRadius : BorderRadius.circular(10),
                            child: Image.network(blogsList[i]['meta_image'],width: 80,fit: BoxFit.cover,height: 80,)),
                        const SizedBox(width: 15,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8,),
                              Text(blogsList[i]['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(height: 6,),
                              Text(blogsList[i]['created_at'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xffa2a2a2),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              const SizedBox(height: 8,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildAllPropertyNeeds(){
    return Container(
      color: const Color(0xffebf4ff),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: TitleHeader(
              enableShowAll: false,
              title: "All Property Needs - One Portal".translate(context),
              subTitle: "Find Better Places to Live, Work and Wonder...",
              onSeeAll: () {

              },
            ),
          ),
          Container(
            height: 220,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context,i)=>const SizedBox(width: 15,),
              padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: allPropertyData.length,
                itemBuilder: (context,index){
                final data = allPropertyData[index];
              return GestureDetector(
                onTap: (){
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PropertiesListWidget(
                          typeName: "Properties",
                        ),
                      ),
                    );
                  }
                  if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          ProjectViewAllScreen(city: currentMainCity,)),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width/1.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                      border: Border.all(
                          width: 1,
                          color: const Color(0xffe0e0e0)
                      ),
                    borderRadius: BorderRadius.circular(10),
                  ),child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image:AssetImage(data['image']!,),fit: BoxFit.cover)

                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      color: Colors.white,
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Text(data["count"].toString(),style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                    child: Text(data["name"],style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                              ),
                              const Row(
                                children: [
                                  Text("Explore Now",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w600),),
                                  SizedBox(width: 3,),
                                  Icon(Icons.arrow_forward,size: 15,)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildExpolerPropertiesType(){
    return Container(
      color: const Color(0xffebf4ff),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: TitleHeader(
              enableShowAll: false,
              title: "Explore Properties Types".translate(context),
              subTitle: "Get some Inspirations from $_totalPropertyCount skills",
              onSeeAll: () {

              },
            ),
          ),
          BlocConsumer<FetchCategoryCubit, FetchCategoryState>(
            listener: (context, state) {
              if (state is FetchCategoryFailure) {
                if (state.errorMessage == "auth-expired") {
                  HelperUtils.showSnackBarMessage(context,
                      UiUtils.getTranslatedLabel(context, "authExpired"));

                  HiveUtils.logoutUser(
                    context,
                    onLogout: () {},
                  );
                }
              }

              if (state is FetchCategorySuccess) {
                isCategoryEmpty = state.categories.isEmpty;
                _totalPropertyCount = state.categories.fold(0, (sum, category) => sum + (category.propertyCount ?? 0));
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is FetchCategoryInProgress) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 20,left: 15,right: 15),
                  child: CategoryShimmer(),
                );
              }
              if (state is FetchCategoryFailure) {
                return Center(
                  child: Text(state.errorMessage.toString()),
                );
              }
              if (state is FetchCategorySuccess) {
                return Container(
                  padding: const EdgeInsets.only(bottom: 15,top: 0,),
                  height: 190,
                  color: const Color(0xffebf4ff),
                  child: ListView.separated(
                      separatorBuilder: (context,i)=>const SizedBox(width: 0,),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categories.length,
                      itemBuilder: (context,index){
                        final category = state.categories[index];
                        return InkWell(
                          onTap: (){
                            Navigator.of(context).pushNamed(Routes.propertiesList,
                                arguments: {'catID': category.id, 'catName': category.category});
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.all(10),
                            width: 140,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffebf4ff),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: UiUtils.imageType(category.image!,
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.cover,
                                        color: Constant.adaptThemeColorSvg
                                            ? context.color.tertiaryColor
                                            : null),
                                  )
                                ],
                              ),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(category.category??'',style: const TextStyle(fontWeight: FontWeight.w500),),
                                 Text("${category.propertyCount?.toString()??'0'} Properties",style: const TextStyle(fontSize: 12),)
                               ],
                             )
                            ],
                          ),
                          ),
                        );
                      }),
                );
              }
              return Container();
            },
          )

        ],
      ),
    );
  }

  Widget buildPropertiesShimmer(BuildContext context, int count) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: MediaQuery.sizeOf(context).height / 950,
      ),

      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 1,
                  color: const Color(0xffe0e0e0)
              )
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft:Radius.circular(15),
                  ),
                  child: CustomShimmer(width: double.infinity,height: 110,),
                ),
                const SizedBox(height: 8,),
                LayoutBuilder(builder: (context, c) {
                  return Padding(
                    padding: const EdgeInsets.only(left:10,right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        CustomShimmer(
                          height: 14,
                          width: c.maxWidth - 50,
                        ),
                        const SizedBox(height: 5,),
                        const CustomShimmer(
                          height: 13,
                        ),
                        const SizedBox(height: 5,),
                        CustomShimmer(
                          height: 12,
                          width: c.maxWidth / 1.2,
                        ),
                        const SizedBox(height: 8,),
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

  Widget buildCategoryCard(
      BuildContext context, Category category, bool? frontSpacing) {
    return CategoryCard(
        frontSpacing: frontSpacing,
        onTapCategory: (category) {
          currentVisitingCategoryId = category.id;
          currentVisitingCategory = category;

          Navigator.of(context).pushNamed(Routes.propertiesList,
              arguments: {'catID': category.id, 'catName': category.category});
          
        },
        category: category);
  }
}



class RecentPropertiesSectionWidget extends StatefulWidget {
  final List? projectList;
  final List<bool>? likeLoading;
  final bool? projectLoading;
  const RecentPropertiesSectionWidget({Key? key, this.projectList, this.likeLoading, this.projectLoading}) : super(key: key);

  @override
  State<RecentPropertiesSectionWidget> createState() =>
      _RecentPropertiesSectionWidgetState();
}

class _RecentPropertiesSectionWidgetState
    extends State<RecentPropertiesSectionWidget> {
  void _onRecentlyAddedSeeAll() {
    // dynamic statemap = StateMap<
    //     FetchRecentProepertiesInitial,
    //     FetchRecentPropertiesInProgress,
    //     FetchRecentPropertiesSuccess,
    //     FetchRecentPropertiesFailur>();
    // ViewAllScreen<FetchRecentPropertiesCubit, FetchRecentPropertiesState>(
    //   title: "Newly Launched Projects".translate(context),
    //   map: statemap,
    // ).open(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ProjectViewAllScreen()),
    );
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
    bool isRecentEmpty() {
      if (context.watch<FetchRecentPropertiesCubit>().state
          is FetchRecentPropertiesSuccess) {
        return (context.watch<FetchRecentPropertiesCubit>().state
                as FetchRecentPropertiesSuccess)
            .properties
            .isEmpty;
      }

      return true;
    }

    return Column(
      children: [
        // if (!isRecentEmpty())
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: TitleHeader(
            enableShowAll: true,
            title: "Newly Launched Projects".translate(context),
            subTitle: "Limited Launch Offers Available",
            onSeeAll: () {
              _onRecentlyAddedSeeAll();
            },
          ),
        ),
        LayoutBuilder(builder: (context, c) {
          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth = screenWidth * 0.45;
          return SizedBox(
            height: 210,
            child:  widget.projectList!.isNotEmpty?ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 15),
              separatorBuilder: (context,index)=>SizedBox(width: 10,),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.projectLoading! ? 10 : widget.projectList!.length,
              itemBuilder: (context, index) {
                if (!widget.projectLoading!) {
                  return Container(
                    width: cardWidth,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetails(
                              property: widget.projectList![index],
                              fromMyProperty: true,
                              fromCompleteEnquiry: true,
                              fromSlider: false,
                              fromPropertyAddSuccess: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xffe0e0e0),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                  ),
                                  child: Stack(
                                    children: [
                                      UiUtils.getImage(
                                        widget.projectList![index]['image'] ?? "",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        height: 103,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Row(
                                          children: [
                                            if (widget.projectList![index]['gallary_images'] != null)
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    BlurredRouter(
                                                      builder: (context) {
                                                        return AllGallaryImages(
                                                          images: widget.projectList![index]['gallary_images'] ?? [],
                                                          isProject: true,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 35,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xff000000).withOpacity(0.35),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(width: 1, color: const Color(0xffe0e0e0)),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromARGB(12, 0, 0, 0),
                                                        offset: Offset(0, 2),
                                                        blurRadius: 15,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.image, color: Color(0xffe0e0e0), size: 15),
                                                      const SizedBox(width: 3),
                                                      Text('${widget.projectList![index]['gallary_images']!.length}',
                                                        style: const TextStyle(color: Color(0xffe0e0e0), fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () {
                                                GuestChecker.check(onNotGuest: () async {
                                                  setState(() {
                                                    widget.likeLoading![index] = true;
                                                  });
                                                  var body = {
                                                    "type": widget.projectList![index]['is_favourite'] == 1 ? 0 : 1,
                                                    "project_id": widget.projectList![index]['id'],
                                                  };
                                                  var response = await Api.post(
                                                    url: Api.addFavProject,
                                                    parameter: body,
                                                  );
                                                  if (!response['error']) {
                                                    widget.projectList![index]['is_favourite'] =
                                                    (widget.projectList![index]['is_favourite'] == 1 ? 0 : 1);
                                                    setState(() {
                                                      widget.likeLoading![index] = false;
                                                    });
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 32,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: context.color.secondaryColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromARGB(12, 0, 0, 0),
                                                      offset: Offset(0, 2),
                                                      blurRadius: 15,
                                                      spreadRadius: 0,
                                                    ),
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
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: (widget.likeLoading![index])
                                                        ? UiUtils.progress(width: 20, height: 20)
                                                        : widget.projectList![index]['is_favourite'] == 1
                                                        ? UiUtils.getSvg(AppIcons.like_fill, color: context.color.tertiaryColor)
                                                        : UiUtils.getSvg(AppIcons.like, color: context.color.tertiaryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          widget.projectList![index]['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xff333333),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        if (widget.projectList![index]['min_price'] == null)
                                          Row(
                                            children: [
                                              Text(
                                                '₹${widget.projectList![index]['project_details'].isNotEmpty
                                                    ? formatAmount(widget.projectList![index]['project_details'][0]['avg_price'] ?? 0)
                                                    : 0}',
                                                style: const TextStyle(
                                                  color: Color(0xff333333),
                                                  fontSize: 12,
                                                  fontFamily: 'Robato',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Container(height: 12, width: 2, color: Colors.black54),
                                              ),
                                              Text(
                                                '${widget.projectList![index]['project_details'].isNotEmpty
                                                    ? formatAmount(widget.projectList![index]['project_details'][0]['size'] ?? 0)
                                                    : 0} Sq.ft',
                                                style: const TextStyle(
                                                  color: Color(0xffa2a2a2),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (widget.projectList![index]['min_price'] != null)
                                          Row(
                                            children: [
                                              Text(
                                                '₹${formatAmount(widget.projectList![index]['min_price'] ?? 0)} - ${formatAmount(widget.projectList![index]['max_price'] ?? 0)}',
                                                style: const TextStyle(
                                                  color: Color(0xff333333),
                                                  fontSize: 12,
                                                  fontFamily: 'Robato',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (widget.projectList![index]['min_price'] != null)

                                        if (widget.projectList![index]['min_price'] != null)
                                          Row(
                                            children: [
                                              Text(
                                                '${widget.projectList![index]['min_size']} - ${widget.projectList![index]['max_size']} Sq.ft',
                                                style: const TextStyle(
                                                  color: Color(0xffa2a2a2),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),

                                        if (widget.projectList![index]['address'] != "")
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Image.asset("assets/Home/__location.png", width: 15, height: 15),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    widget.projectList![index]['address']?.trim() ?? "",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xffa2a2a2),
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                    ),
                  );
                } else {
                  return const ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CustomShimmer(height: 190, width: 170),
                  );
                }
              },
            ):Center(child: Text(  "No data available for this city"),),
          );
        })

      ],
    );
  }
}

class PersonalizedPropertyWidget extends StatelessWidget {
  const PersonalizedPropertyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPersonalizedPropertyList,
        FetchPersonalizedPropertyListState>(
      builder: (context, state) {
        if (state is FetchPersonalizedPropertyInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {},
                title: "personalizedFeed".translate(context),
              ),
              const PromotedPropertiesShimmer(),
            ],
          );
        }

        if (state is FetchPersonalizedPropertySuccess) {
          if (state.properties.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {
                  StateMap stateMap = StateMap<
                      FetchPersonalizedPropertyInitial,
                      FetchPersonalizedPropertyInProgress,
                      FetchPersonalizedPropertySuccess,
                      FetchPersonalizedPropertyFail>();

                  ViewAllScreen<FetchPersonalizedPropertyList,
                      FetchPersonalizedPropertyListState>(
                    title: "personalizedFeed".translate(context),
                    map: stateMap,
                  ).open(context);
                },
                title: "personalizedFeed".translate(context),
              ),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: state.properties.length.clamp(0, 6),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    GlobalKey thisITemkye = GlobalKey();

                    PropertyModel propertymodel = state.properties[index];
                    propertymodel =
                        context.watch<PropertyEditCubit>().get(propertymodel);
                    return GestureDetector(
                        onTap: () {
                          FirebaseAnalytics.instance
                              .logEvent(name: "preview_property", parameters: {
                            "user_ids": HiveUtils.getUserId(),
                            "from_section": "featured",
                            "property_id": propertymodel.id,
                            "category_id": propertymodel.category!.id
                          });

                          HelperUtils.goToNextPage(
                            Routes.propertyDetails,
                            context,
                            false,
                            args: {
                              'propertyData': propertymodel,
                              'propertiesList': state.properties,
                              'fromMyProperty': false,
                            },
                          );
                        },
                        child: BlocProvider(
                          create: (context) {
                            return AddToFavoriteCubitCubit();
                          },
                          child: PropertyCardBig(
                            key: thisITemkye,
                            isFirst: index == 0,
                            property: propertymodel,
                            onLikeChange: (type) {
                              if (type == FavoriteType.add) {
                                context
                                    .read<FetchFavoritesCubit>()
                                    .add(propertymodel);
                              } else {
                                context
                                    .read<FetchFavoritesCubit>()
                                    .remove(state.properties[index].id);
                              }
                            },
                          ),
                        ));
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}

extension mMap on Map {
  Map get(String key) {
    var m = this[key];
    if (m is Map) {
      return m;
    } else {
      throw "Child is not map";
    }
  }

  Map where(String query) {
    final parts = query.split('=');
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].replaceAll(RegExp(r"^\s*'|\s*'$"), '').trim();

      return Map.fromEntries(entries.where((entry) {
        final entryKey = entry.key.toString();
        final entryValue = entry.value.toString();

        return entryKey == key && entryValue == value;
      }));
    } else {
      throw "Invalid query format";
    }
  }
}

class TopAgents extends StatefulWidget {
  final String? city;
  const TopAgents({super.key, this.city});

  @override
  State<TopAgents> createState() => _TopAgentsState();
}

class _TopAgentsState extends State<TopAgents> {
  bool AgentLOading = false;
  List Top_agenylist = [];
  Future<void> gettop_Agents () async {
    setState(() {
      AgentLOading = true;
    });
    var response = await Api.get(url: Api.gettop_agent, queryParameters: {
      'offset': 0,
      'limit': 10,
      'city': widget.city,
      // 'current_user': HiveUtils.getUserId()
    });
    if(!response['error']) {
      setState(() {
        Top_agenylist  = response['data'];
        AgentLOading = false;
      });
    }
  }

  @override
  void initState() {
    gettop_Agents();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TitleHeader(
            enableShowAll: true,
            title: "Meet Our Top Agents!".translate(context),
            subTitle: "Get some Inspirations",
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const seeallAgent(), // Assuming SeeAllAgent is a widget.
                ),
              );

            },
          ),
        ),
        // SizedBox(height: 10),
        SizedBox(
          height: size.height * 0.26,
          child: AgentLOading
              ? buildShimmerList(size)
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Top_agenylist.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 10),
                child: buildAgentCard(size, Top_agenylist[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // Build agent card widget dynamically from data
  Widget buildAgentCard(Size size, dynamic agent) {
    return Container(
      width: size.width * 0.75,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9ea1a7).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffffffff),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: size.height * 0.07,
                  width: size.width * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF9ea1a7).withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(15),
                    // color: Color(0xffffffff),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: UiUtils.imageType(agent['profile'],
                        height: size.height * 0.07,
                        width: size.width * 0.15,
                        fit: BoxFit.cover,
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent['name'],  // Display agent's name
                      style: const TextStyle(
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
                          const SizedBox(width: 2),
                          Text(
                            'RERA ID : ${agent['rera'] ?? 'N/A'}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,// Display RERA ID
                            style: const TextStyle(
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
            const SizedBox(height: 10),
            Container(
              height: size.height * 0.11,
              decoration: BoxDecoration(
                color: const Color(0xFFfff5f1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPropertyColumn(agent['sell_property']?.toString() ?? '0', "Properties for\nsale"),  // Default to '0'
                  const VerticalDivider(color: Colors.grey, thickness: 2),
                  buildPropertyColumn(agent['rent_property']?.toString() ?? '0', "Properties for\nrent"),  // Default to '0'
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          UserDetailProfileScreen(id: agent['id'] )),
                    );
                  },
                  child: Row(
                    children: [
                      const Text(
                        'View All Properties',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF9ea1a7),fontSize: 14),
                      ),
                      Image.asset("assets/assets/Images/blue_arr.png",height: 25,color: Colors.black,)
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          UserDetailProfileScreen(id: agent['id'] )),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                    // height: 30,
                    // width: 90,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white, fontSize: 10,fontWeight: FontWeight.bold),
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
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            count,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF9ea1a7)),
        ),
      ],
    );
  }


  // Build property count column


  // Build shimmer effect for loading
  Widget buildShimmerList(Size size) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,  // Arbitrary number of shimmer items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 2),
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



class TopBuilders extends StatefulWidget {
  final String? city;
  const TopBuilders({super.key, this.city});

  @override
  State<TopBuilders> createState() => _TopBuildersState();
}

class _TopBuildersState extends State<TopBuilders> {
  bool builderLoading = false;
  List topBuilderList = [];

  Future<void> getTopBuilder() async {
    setState(() {
      builderLoading = true;
    });

    try {
      var response = await Api.get(url: Api.gettop_builder, queryParameters: {
        'offset': 0,
        'limit': 10,
        'city': widget.city,
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
    getTopBuilder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TitleHeader(
            enableShowAll: true,
            title: "Meet Our Top Builders!".translate(context),
            subTitle: "Get some Inspirations",
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const see_allBuilders(), // Assuming SeeAllAgent is a widget.
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: size.width/2,
          child: builderLoading
              ? _buildShimmerList(size) // Show shimmer when loading
              : topBuilderList.isEmpty
              ? const Center(child: Text('No Builders Found')) // Show message if list is empty
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topBuilderList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                              UserDetailProfileScreen(id: topBuilderList[index]['id'] )),
                        );
                      },
                      child: buildBuilderCard(size, topBuilderList[index])),
                  );
                },
          ),
        ),
      ],
    );
  }

  // Build shimmer effect for loading state
  Widget _buildShimmerList(Size size) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 10, // Placeholder for 5 shimmer cards
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 2),
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
  Widget buildBuilderCard(Size size, dynamic agent) {
    return Container(
      width: size.width * 0.7,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9ea1a7).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffffffff),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Row(
              children: [
                Container(
                  height: size.height * 0.07,
                  width: size.width * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF9ea1a7).withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: UiUtils.imageType(agent['profile'],
                        height: size.height * 0.07,
                        width: size.width * 0.15,
                        fit: BoxFit.cover,
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null),
                  ),
                ),
                const SizedBox(width: 10), // Space between image and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent['name'] ?? 'Unknown', // Fallback if null
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Image.asset('assets/rera_tic.png', height: 14, width:14),
                          const SizedBox(width: 2),
                          Text(
                            'RERA ID : ${agent['rera'] ?? 'N/A'}', // Fallback if null
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF9ea1a7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: size.height * 0.11,
              decoration: BoxDecoration(
                color: const Color(0xFFf5f9ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildPropertyColumn(agent['project_count']?.toString() ?? '0',
                            "Total \nProjects"),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: VerticalDivider(color: Colors.grey, thickness: 2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        buildPropertyColumn(agent['city_count']?.toString() ?? '0', "City"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Build a column for property stats
  Widget buildPropertyColumn(String count, String label) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.start,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF9ea1a7)),
        ),
      ],
    );
  }
}

