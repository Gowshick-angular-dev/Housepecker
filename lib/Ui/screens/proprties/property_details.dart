// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/chat/chat_screen.dart';
import 'package:Housepecker/Ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:Housepecker/Ui/screens/proprties/widgets/report_property_widget.dart';
import 'package:Housepecker/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:Housepecker/Ui/screens/widgets/like_button_widget.dart';
import 'package:Housepecker/Ui/screens/widgets/panaroma_image_view.dart';
import 'package:Housepecker/Ui/screens/widgets/read_more_text.dart';
import 'package:Housepecker/app/routes.dart';
import 'package:Housepecker/data/cubits/Report/property_report_cubit.dart';
import 'package:Housepecker/data/cubits/chatCubits/delete_message_cubit.dart';
import 'package:Housepecker/data/cubits/chatCubits/load_chat_messages.dart';
import 'package:Housepecker/data/cubits/enquiry/store_enqury_id.dart';
import 'package:Housepecker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:Housepecker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/delete_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:Housepecker/data/cubits/property/set_property_view_cubit.dart';
import 'package:Housepecker/data/cubits/property/update_property_status.dart';
import 'package:Housepecker/data/model/property_model.dart';
import 'package:Housepecker/utils/AppIcon.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/api.dart';
import 'package:Housepecker/utils/constant.dart';
import 'package:Housepecker/utils/hive_utils.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:Housepecker/utils/string_extenstion.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/cubits/chatCubits/send_message.dart';
import '../../../data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
import '../../../data/helper/widgets.dart';
import '../../../data/model/category.dart';
import '../../../settings.dart';
import '../../../utils/AdMob/interstitialAdManager.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';
import '../analytics/analytics_screen.dart';
import '../userprofile/userProfileScreen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/video_view_screen.dart';

Map<String, String> rentDurationMap = {
  "Quarterly": "Quarter",
  "Monthly": "Month",
  "Yearly": "Year"
};

class PropertyDetails extends StatefulWidget {
  final PropertyModel? property;
  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool fromSlider;
  final bool? fromPropertyAddSuccess;
  const PropertyDetails(
      {Key? key,
      this.fromPropertyAddSuccess,
      required this.property,
      this.fromSlider = false,
      this.fromMyProperty,
      this.fromCompleteEnquiry})
      : super(key: key);

  @override
  PropertyDetailsState createState() => PropertyDetailsState();

  static Route route(RouteSettings routeSettings) {
    try {
      Map? arguments = routeSettings.arguments as Map?;
      return BlurredRouter(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChangeInterestInPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => UpdatePropertyStatusCubit(),
            ),
            BlocProvider(
              create: (context) => DeletePropertyCubit(),
            ),
            BlocProvider(
              create: (context) => PropertyReportCubit(),
            ),
          ],
          child: PropertyDetails(
            property: arguments?['propertyData'],
            fromMyProperty: arguments?['fromMyProperty'] ?? false,
            fromSlider: arguments?['fromSlider'] ?? false,
            fromCompleteEnquiry: arguments?['fromCompleteEnquiry'] ?? false,
            fromPropertyAddSuccess: arguments?['fromSuccess'] ?? false,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FlickManager? flickManager;
  // late Property propertyData;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List promotedProeprtiesIds = [];
  List similarPropertiesList = [];
  List agentPropertiesList = [];
  bool toggleEnqButton = false;
  PropertyModel? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;
  bool showContact = false;
  List<dynamic> propertyData = [];
  BannerAd? _bannerAd;
  @override
  bool get wantKeepAlive => true;


  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Gallery>? gallary;
  String youtubeVideoThumbnail = "";
  bool? _isLoaded;

  InterstitialAdManager interstitialAdManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    loadAd();
    getSimilarProperties();
    getAgentProperties();
    interstitialAdManager.load();
    // customListenerForConstant();
    //add title image along with gallary images1
    context.read<FetchOutdoorFacilityListCubit>().fetch();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gallary = List.from(widget.property!.gallery!);
      if (widget.property?.video != "") {
        injectVideoInGallary();
        setState(() {});
      }
    });

    if (widget.fromSlider) {
      getProperty();
    } else {
      property = widget.property;
      setData();
    }

    setViewdProperty();
    if (widget.property?.video != "" &&
        widget.property?.video != null &&
        !HelperUtils.isYoutubeVideo(widget.property?.video ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
          property!.video!,
        ),
      );
      flickManager?.onVideoEnd = () {};
    }

    if (widget.property?.video != "" &&
        widget.property?.video != null &&
        HelperUtils.isYoutubeVideo(widget.property?.video ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(property!.video!);
      String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
    }
  }

  Future<void> getSimilarProperties() async {
    var response = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'category_id': widget.property!.category!.id,
      'get_simiilar': 1,
      'id': widget.property!.id
    });
    if(!response['error']) {
      setState(() {
        similarPropertiesList = response['data'].where((e) => e['is_type'] == 'property').toList();
      });
    }
  }

  Future<void> getAgentProperties() async {
    var response = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'userid': widget.property!.addedBy,
    });
    if(!response['error']) {
      setState(() {
        agentPropertiesList = response['data'].where((e) => e['is_type'] == 'property').toList();
      });
    }
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: Constant.admobBannerAndroid,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> getProperty() async {
    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty,
        {
          Api.id: widget.property!.id,
        },
        true,
        context,
        passUserid: false);
    if (response != null) {
      var getdata = json.decode(response);
      if (!getdata[Api.error]) {
        getdata['data'];
        propertyData = getdata['data'];
        setData();
        setState(() {});
      }
    }
  }

  void setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  void setViewdProperty() {
    if (property!.addedBy.toString() != HiveUtils.getUserId()) {
      context.read<SetPropertyViewCubit>().set(property!.id!.toString());
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        (property?.latitude ?? "0.0"),
      ),
      double.parse(
        (property?.longitude ?? "0.0"),
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    flickManager?.dispose();

    super.dispose();
  }

  void injectVideoInGallary() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (widget.property?.video != null) {
        gallary?.add(Gallery(
            id: 99999999999,
            image: property!.video ?? "",
            imageUrl: "",
            isVideo: true));
      }
    } else {
      gallary?.insert(
          0,
          Gallery(
              id: 99999999999,
              image: property!.video!,
              imageUrl: "",
              isVideo: true));
    }

    setState(() {});
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

  String? _statusFilter(String value) {
    if (value == "Sell") {
      return "sold".translate(context);
    }
    if (value == "Rent") {
      return "Rented".translate(context);
    }

    return null;
  }

  int? _getStatus(type) {
    int? value;
    if (type == "Sell") {
      value = 2;
    } else if (type == "Rent") {
      value = 3;
    } else if (type == "Rented") {
      value = 1;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String rentPrice = (formatAmount(int.parse(property!.price!))
        // .priceFormate(
        //   disabled: Constant.isNumberWithSuffix == false,
        // )
        .toString()
        .formatAmount(prefix: true));

    if (property?.rentduration != "" && property?.rentduration != null) {
      rentPrice =
          ("${rentPrice} / ") + (rentDurationMap[property!.rentduration] ?? "");
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          await interstitialAdManager.show();
          if (widget.fromPropertyAddSuccess ?? false) {
            Navigator.popUntil(context, (route) => route.isFirst);
            return false;
          }

          showGoogleMap = false;
          setState(() {});

          return true;
        },
        child: AnnotatedRegion(
          value: UiUtils.getSystemUiOverlayStyle(
            context: context,
          ),
          child: SafeArea(
              child: Scaffold(

                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: tertiaryColor_,
                  title: Text(property!.title!,style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),),
                    actions: [
                      if (!HiveUtils.isGuest()) ...[
                        if (int.parse(HiveUtils.getUserId() ?? "0") ==
                            property?.addedBy)
                          IconButton(
                              onPressed: () {
                                Navigator.push(context, BlurredRouter(
                                  builder: (context) {
                                    return AnalyticsScreen(
                                      interestUserCount: widget
                                          .property!.totalInterestedUsers
                                          .toString(),
                                    );
                                  },
                                ));
                              },
                              icon: Icon(
                                Icons.analytics,
                                color: context.color.tertiaryColor,
                              )),
                      ],
                      if (property?.addedBy.toString() == HiveUtils.getUserId() &&
                          property!.properyType != "Sold" &&
                          property?.status == 1)
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            var action = await UiUtils.showBlurredDialoge(
                              context,
                              dialoge: BlurredDialogBuilderBox(
                                  title: "changePropertyStatus".translate(context),
                                  acceptButtonName: "change".translate(context),
                                  contentBuilder: (context, s) {
                                    return FittedBox(
                                      fit: BoxFit.none,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: context.color.tertiaryColor,
                                                borderRadius:
                                                BorderRadius.circular(10)),
                                            width: s.maxWidth / 4,
                                            height: 50,
                                            child: Center(
                                                child: Text(property!.properyType!
                                                    .translate(context))
                                                    .color(
                                                    context.color.buttonColor)),
                                          ),
                                          Text(
                                            "toArrow".translate(context),
                                          ),
                                          Container(
                                            width: s.maxWidth / 4,
                                            decoration: BoxDecoration(
                                                color: context.color.tertiaryColor
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                BorderRadius.circular(10)),
                                            height: 50,
                                            child: Center(
                                                child: Text(_statusFilter(property!
                                                    .properyType!) ??
                                                    "")
                                                    .color(
                                                    context.color.buttonColor)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            );
                            if (action == true) {
                              Future.delayed(Duration.zero, () {
                                context.read<UpdatePropertyStatusCubit>().update(
                                  propertyId: property!.id,
                                  status: _getStatus(property!.properyType),
                                );
                              });
                            }
                          },
                          color: context.color.secondaryColor,
                          itemBuilder: (BuildContext context) {
                            return {
                              'changeStatus'.translate(context),
                            }.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                textStyle:
                                TextStyle(color: context.color.textColorDark),
                                child: Text(choice),
                              );
                            }).toList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      )
                    ]
                ),
            // appBar: UiUtils.buildAppBar(context,
            //     hideTopBorder: true,
            //     showBackButton: true,
            //     title: Text(property!.title!),
            //     actions: [
            //       if (!HiveUtils.isGuest()) ...[
            //         if (int.parse(HiveUtils.getUserId() ?? "0") ==
            //             property?.addedBy)
            //           IconButton(
            //               onPressed: () {
            //                 Navigator.push(context, BlurredRouter(
            //                   builder: (context) {
            //                     return AnalyticsScreen(
            //                       interestUserCount: widget
            //                           .property!.totalInterestedUsers
            //                           .toString(),
            //                     );
            //                   },
            //                 ));
            //               },
            //               icon: Icon(
            //                 Icons.analytics,
            //                 color: context.color.tertiaryColor,
            //               )),
            //       ],
            //       IconButton(
            //         onPressed: () {
            //           HelperUtils.share(
            //               context, property!.id!, property?.slugId ?? "");
            //         },
            //         icon: Icon(
            //           Icons.share,
            //           color: context.color.tertiaryColor,
            //         ),
            //       ),
            //       if (property?.addedBy.toString() == HiveUtils.getUserId() &&
            //           property!.properyType != "Sold" &&
            //           property?.status == 1)
            //         PopupMenuButton<String>(
            //           onSelected: (value) async {
            //             var action = await UiUtils.showBlurredDialoge(
            //               context,
            //               dialoge: BlurredDialogBuilderBox(
            //                   title: "changePropertyStatus".translate(context),
            //                   acceptButtonName: "change".translate(context),
            //                   contentBuilder: (context, s) {
            //                     return FittedBox(
            //                       fit: BoxFit.none,
            //                       child: Row(
            //                         mainAxisAlignment: MainAxisAlignment.start,
            //                         children: [
            //                           Container(
            //                             decoration: BoxDecoration(
            //                                 color: context.color.tertiaryColor,
            //                                 borderRadius:
            //                                     BorderRadius.circular(10)),
            //                             width: s.maxWidth / 4,
            //                             height: 50,
            //                             child: Center(
            //                                 child: Text(property!.properyType!
            //                                         .translate(context))
            //                                     .color(
            //                                         context.color.buttonColor)),
            //                           ),
            //                           Text(
            //                             "toArrow".translate(context),
            //                           ),
            //                           Container(
            //                             width: s.maxWidth / 4,
            //                             decoration: BoxDecoration(
            //                                 color: context.color.tertiaryColor
            //                                     .withOpacity(0.4),
            //                                 borderRadius:
            //                                     BorderRadius.circular(10)),
            //                             height: 50,
            //                             child: Center(
            //                                 child: Text(_statusFilter(property!
            //                                             .properyType!) ??
            //                                         "")
            //                                     .color(
            //                                         context.color.buttonColor)),
            //                           ),
            //                         ],
            //                       ),
            //                     );
            //                   }),
            //             );
            //             if (action == true) {
            //               Future.delayed(Duration.zero, () {
            //                 context.read<UpdatePropertyStatusCubit>().update(
            //                       propertyId: property!.id,
            //                       status: _getStatus(property!.properyType),
            //                     );
            //               });
            //             }
            //           },
            //           color: context.color.secondaryColor,
            //           itemBuilder: (BuildContext context) {
            //             return {
            //               'changeStatus'.translate(context),
            //             }.map((String choice) {
            //               return PopupMenuItem<String>(
            //                 value: choice,
            //                 textStyle:
            //                     TextStyle(color: context.color.textColorDark),
            //                 child: Text(choice),
            //               );
            //             }).toList();
            //           },
            //           child: Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 4.0),
            //             child: Icon(
            //               Icons.more_vert_rounded,
            //               color: context.color.tertiaryColor,
            //             ),
            //           ),
            //         ),
            //       const SizedBox(
            //         width: 10,
            //       )
            //     ]),
            backgroundColor: Colors.white,
            floatingActionButton: (property == null ||
                    property!.addedBy.toString() == HiveUtils.getUserId())
                ? const SizedBox.shrink()
                : Container(),
                bottomNavigationBar: isPlayingYoutubeVideo == false
                ? BottomAppBar(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: context.color.secondaryColor,
                    child: bottomNavBar())
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: BlocListener<DeletePropertyCubit, DeletePropertyState>(
              listener: (context, state) {
                if (state is DeletePropertyInProgress) {
                  Widgets.showLoader(context);
                }

                if (state is DeletePropertySuccess) {
                  Widgets.hideLoder(context);
                  Future.delayed(
                    const Duration(milliseconds: 1000),
                    () {
                      Navigator.pop(context, true);
                    },
                  );
                }
                if (state is DeletePropertyFailure) {
                  Widgets.showLoader(context);
                }
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocListener<UpdatePropertyStatusCubit,
                      UpdatePropertyStatusState>(
                    listener: (context, state) {
                      if (state is UpdatePropertyStatusInProgress) {
                        Widgets.showLoader(context);
                      }

                      if (state is UpdatePropertyStatusSuccess) {
                        Widgets.hideLoder(context);
                        Fluttertoast.showToast(
                            msg: "statusUpdated".translate(context),
                            backgroundColor: successMessageColor,
                            gravity: ToastGravity.TOP,
                            toastLength: Toast.LENGTH_LONG);

                        (cubitReference as FetchMyPropertiesCubit).updateStatus(
                            property!.id!, property!.properyType!);
                        setState(() {});
                      }
                      if (state is UpdatePropertyStatusFail) {
                        Widgets.hideLoder(context);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        if (!isPlayingYoutubeVideo)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    height: 227.rh(context),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // google map doesn't allow blur so we hide it:)
                                            showGoogleMap = false;
                                            setState(() {});
                                            UiUtils.showFullScreenImage(
                                              context,
                                              provider: NetworkImage(
                                                property!.titleImage!,
                                              ),
                                              then: () {
                                                showGoogleMap = true;
                                                setState(() {});
                                              },
                                            );
                                          },
                                          child: UiUtils.getImage(
                                            property!.titleImage!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 227.rh(context),
                                            showFullScreenImage: true,
                                          ),
                                        ),
                                        PositionedDirectional(
                                          top: 20,
                                          end: 20,
                                          child: LikeButtonWidget(
                                            onStateChange:
                                                (AddToFavoriteCubitState
                                                    state) {
                                              if (state
                                                  is AddToFavoriteCubitInProgress) {
                                                favoriteInProgress = true;
                                                setState(
                                                  () {},
                                                );
                                              } else {
                                                favoriteInProgress = false;
                                                setState(
                                                  () {},
                                                );
                                              }
                                            },
                                            property: property!,
                                          ),
                                        ),
                                        PositionedDirectional(
                                          top: 60,
                                          end: 20,
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
                                            child: InkWell(
                                              onTap: () {
                                                HelperUtils.share(
                                                    context, property!.id!, property?.slugId ?? "");
                                              },
                                              child: Icon(
                                                Icons.share,
                                                color: context.color.tertiaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PositionedDirectional(
                                          bottom: 5,
                                          end: 18,
                                          child: Visibility(
                                            visible:
                                                property?.threeDImage != "",
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  BlurredRouter(
                                                    builder: (context) =>
                                                        PanaromaImageScreen(
                                                      imageUrl: property!
                                                          .threeDImage!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .color.secondaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                height: 40.rh(context),
                                                width: 40.rw(context),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: UiUtils.getSvg(
                                                      AppIcons.v360Degree,
                                                      color: context
                                                          .color.tertiaryColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // advertismentLable()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15,),
                                child: Row(children: [
                                  // UiUtils.imageType(
                                  //     property?.category!.image ?? "",
                                  //     width: 18,
                                  //     height: 18,
                                  //     color: Constant.adaptThemeColorSvg
                                  //         ? context.color.tertiaryColor
                                  //         : null),

                                  Container(
                                    padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xfffff2c8),
                                        borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(property!.category != null ? property!.category!.category! : '',style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500
                                    ),)
                                        .setMaxLines(lines: 1),
                                  ),
                                  SizedBox(width: 5,),
                                  Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(7),
                                        color: context.color.tertiaryColor),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Center(
                                          child: Text(
                                        property!.properyType
                                            .toString()
                                            .toLowerCase()
                                            .translate(context),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11
                                            ),
                                      )),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Container(
                                    // width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: Color(0xff6c5555)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                                      child: Center(
                                        child: Text(
                                          property!.brokerage == 'yes' ? 'Brokerage' : 'No Brokerage'
                                              .toString()
                                              .toLowerCase()
                                              .translate(context),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11
                                          ),
                                        ),
                                      ),
                                    ),
                                  ), SizedBox(width: 5,),
                                  Container(
                                    // width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: Color(0xffcff4fc)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                                      child: Center(
                                        child: Text(

                                          property!.code.toString()
                                              .toLowerCase()
                                              .translate(context),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Text(
                                  '${property!.title!.firstUpperCase()}',style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff333333)
                                ),),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric( horizontal: 15,),
                                    child: Row(
                                      children: [
                                        if (property!.properyType
                                            .toString()
                                            .toLowerCase() ==
                                            "rent") ...[
                                          Text((rentPrice))
                                              .color(context.color.tertiaryColor)
                                              .size(13)
                                              .bold(weight: FontWeight.w500),
                                        ] else ...[
                                          Text(formatAmount(int.parse(property!.price!))
                                          // .priceFormate(
                                          //     disabled: Constant
                                          //             .isNumberWithSuffix ==
                                          //         false)
                                              .formatAmount(prefix: true))
                                              .color(context.color.tertiaryColor)
                                              .size(13)
                                              .bold(weight: FontWeight.w500),
                                        ],
                                        if (Constant.isNumberWithSuffix) ...[
                                          if (property!.properyType
                                              .toString()
                                              .toLowerCase() !=
                                              "rent") ...[
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text("(${formatAmount(int.parse(property!.price!))})")
                                                .color(context.color.tertiaryColor)
                                                .size(13).bold(weight: FontWeight.w500),
                                          ]
                                        ]
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric( horizontal: 15,),
                                    child: Text(property?.sqft != null ? '${property?.sqft} Sq.Ft.' : '',
                                      style: TextStyle(
                                          color: Color(0xffa2a2a2),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.sizeOf(context).width - 120,
                                      child: Row(
                                        children: [
                                          Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                          SizedBox(width: 5,),
                                          Expanded(
                                            child: Text(property!.address!.firstUpperCase(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(0xffa2a2a2),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(property?.postCreated ?? "",
                                      style: TextStyle(
                                        color: Color(0xffa2a2a2),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400
                                      ),
                                    )
                                  ],
                                ),
                              ),
                    
                              const SizedBox(
                                height: 20,
                              ),
                              CusomterProfileWidget1(
                                widget: widget,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if(property?.parameters != null)
                               Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 5,
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Property Overview".translate(context),style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600
                                      ),),
                                      SizedBox(height :10),
                                      Wrap(
                                        direction: Axis.horizontal,
                                        crossAxisAlignment: WrapCrossAlignment.start,
                                        runAlignment: WrapAlignment.start,
                                        alignment: WrapAlignment.start,
                                        children: List.generate(
                                            property?.parameters?.length ?? 0,
                                            (index) {
                                              Parameter? parameter = property?.parameters![index];
                                          //     bool isParameterValueEmpty =
                                          //     (parameter?.value == "" ||
                                          //         parameter?.value == "0" ||
                                          //         parameter?.value == null ||
                                          //         parameter?.value == "null");
                                          //     print('kkkkkkkkkkkkkk: ${parameter}');
                                          //
                                          // ///If it has no value
                                          // if (isParameterValueEmpty) {
                                          //   return const SizedBox.shrink();
                                          // }

                                          return ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minWidth:(context.screenWidth / 2) - 40),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                  0, 8, 8, 8),
                                              child: SizedBox(
                                                // height: 37,
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 36.rw(context),
                                                        height: 36.rh(context),
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: context
                                                                .color.tertiaryColor
                                                                .withOpacity(0.2),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10)),
                                                        child: SizedBox(
                                                          height: 20.rh(context),
                                                          width: 20.rw(context),
                                                          child: FittedBox(
                                                            child: UiUtils.imageType(
                                                              parameter?.image ?? "",
                                                              fit: BoxFit.cover,
                                                              color: Constant
                                                                      .adaptThemeColorSvg
                                                                  ? context.color
                                                                      .tertiaryColor
                                                                  : null,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10.rw(context),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(parameter?.name ?? "")
                                                              .size(10)
                                                              .color(Color(0xff5d5d5d)),
                                                          if (parameter
                                                                  ?.typeOfParameter ==
                                                              "file") ...{
                                                            InkWell(
                                                              onTap: () async {
                                                                await urllauncher.launchUrl(
                                                                    Uri.parse(
                                                                        parameter!
                                                                            .value),
                                                                    mode: LaunchMode
                                                                        .externalApplication);
                                                              },
                                                              child: Text(
                                                                UiUtils
                                                                    .getTranslatedLabel(
                                                                        context,
                                                                        "viewFile"),
                                                              ).underline().color(
                                                                  context.color
                                                                      .tertiaryColor),
                                                            ),
                                                          } else if (parameter?.value
                                                              is List) ...{
                                                            Text((parameter?.value
                                                                    as List)
                                                                .join(","))
                                                          } else ...[
                                                            if (parameter
                                                                    ?.typeOfParameter ==
                                                                "textarea") ...[
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.7,
                                                                child: Text(
                                                                        "${parameter?.value}")
                                                                    .size(12)
                                                                    .bold(
                                                                      weight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                              )
                                                            ] else ...[
                                                              Text("${parameter?.value}")
                                                                  .size(12)
                                                                  .bold(
                                                                    weight: FontWeight
                                                                        .w500,
                                                                  )
                                                            ]
                                                          ]
                                                        ],
                                                      )
                                                    ]),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              // Padding(
                              //   padding: EdgeInsets.symmetric( horizontal: 15,),
                              //   child: Container(
                              //     padding: EdgeInsets.all(10),
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(15.0),
                              //       color: Colors.white,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           offset: Offset(0, 1),
                              //           blurRadius: 5,
                              //           color: Colors.black.withOpacity(0.1),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //        Text("Property Details".translate(context),style: TextStyle(
                              //            fontSize: 14,
                              //            color: Color(0xff333333),
                              //            fontWeight: FontWeight.w600
                              //        ),),
                              //        SizedBox(height :15),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Age of the property:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("4 years")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Launch Date:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("Feb 2024")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Size:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("1029 Sq.Ft-2650 Sq.Ft")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Rera No:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("Sdsd/213232/Fsf/6")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Time To Call:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("12Pm-06 PM")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Possession Starts:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("Sdsd/213232/Fsf/6")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Configurations :")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("2,3,4 BHK Apart")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Avg Price:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("12.5 K/Sq.Ft")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Total Floors:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("34")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Padding(
                              //          padding: const EdgeInsets.only(bottom: 10),
                              //          child: Row(
                              //            children: [
                              //              Expanded(
                              //                child: Text("Approved By:")
                              //                    .size(11)
                              //                    .color(Color(0xff5d5d5d)),
                              //              ),
                              //              SizedBox(width: 10,),
                              //              Expanded(
                              //                child: Text("CMDA")
                              //                    .size(11)
                              //                    .bold( weight: FontWeight.w500,),
                              //              )
                              //            ],
                              //          ),
                              //        ),
                              //        Text("Read More",style: TextStyle(
                              //          fontSize: 13,
                              //          fontWeight: FontWeight.w600,
                              //          color: Color(0xff117af9),
                              //        ),),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 14,
                              // ),
                              if(property!.highlight != null)
                                Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Container(
                                  padding: EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                      color: Color(0xfffffaf4),
                                      borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Property Highlights".translate(context),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w600
                                      ),),
                                      SizedBox(height: 13, ),
                                      for(int i = 0; i < property!.highlight!.split(',').length; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                          children: [
                                            Image.asset("assets/NewPropertydetailscreen/_-55.png",width: 13,height: 13,fit: BoxFit.cover,),
                                            SizedBox(width: 10,),
                                            Expanded(
                                              child: Text("${property!.highlight!.split(',')[i]}")
                                                  .size(11)
                                                  .color(Color(0xff5d5d5d)),
                                            ),
                                          ],                                                                                ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),

                              if (widget.property?.assignedOutdoorFacility
                                  ?.isNotEmpty ??
                                  false) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric( horizontal: 15,),
                                  child: Text("Near by Places",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600
                                    ),),
                                ),
                                const SizedBox(height: 10),
                              ],

                              

                              Padding(
                                padding: EdgeInsets.only( left: 15,),
                                child: OutdoorFacilityListWidget(
                                    outdoorFacilityList: widget.property
                                        ?.assignedOutdoorFacility ??
                                        []),
                              ),
                           
                              const SizedBox(
                                height: 15,
                              ),



                              Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 5,
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(UiUtils.getTranslatedLabel(
                                          context, "aboutThisPropLbl"),style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w600
                                      ),),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      ReadMoreText(
                                          text: property?.description ?? "",
                                          style: TextStyle(
                                            fontSize: 11,
                                              color: Color(0xff707070)),
                                          readMoreButtonStyle: TextStyle(
                                              color: context.color.tertiaryColor)),
                                    ],
                                  ),
                                ),
                              ),

                              //TODO:
                              if (_bannerAd != null &&
                                  Constant.isAdmobAdsEnabled)
                                Padding(
                                  padding: EdgeInsets.only( left: 15,right:15,bottom: 20),
                                  child: SizedBox(
                                      width: _bannerAd?.size.width.toDouble(),
                                      height: _bannerAd?.size.height.toDouble(),
                                      child: AdWidget(ad: _bannerAd!)),
                                ),
                    
                              // const SizedBox(
                              //   height: 20,
                              // ),


                              const SizedBox( height: 15,),
                              if (gallary?.isNotEmpty ?? false) ...[
                                Padding(
                                  padding: EdgeInsets.only( left: 15,right: 15),
                                  child: Text(UiUtils.getTranslatedLabel(
                                          context, "Videos & Photos",),  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                              ],
                              if (gallary?.isNotEmpty ?? false) ...[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: EdgeInsets.only( left: 15,bottom: 15),
                                    child: Row(
                                        children: List.generate(
                                      (gallary?.length.clamp(0, 4)) ?? 0,
                                      (index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 13),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            child: Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (gallary?[index].isVideo ==
                                                        true) return;

                                                    //google map doesn't allow blur so we hide it:)
                                                    showGoogleMap = false;
                                                    setState(() {});

                                                    var images = gallary
                                                        ?.map((e) => e.imageUrl)
                                                        .toList();

                                                    UiUtils.imageGallaryView(
                                                      context,
                                                      images: images!,
                                                      initalIndex: index,
                                                      then: () {
                                                        showGoogleMap = true;
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    width: 240.rw(context),
                                                    height: 150.rh(context),
                                                    child: gallary?[index]
                                                                .isVideo ==
                                                            true
                                                        ? Container(
                                                            child: UiUtils.getImage(
                                                                youtubeVideoThumbnail,
                                                                fit:
                                                                    BoxFit.cover),
                                                          )
                                                        : UiUtils.getImage(
                                                            gallary?[index]
                                                                    .imageUrl ??
                                                                "",
                                                            fit: BoxFit.cover),
                                                  ),
                                                ),
                                                if (gallary?[index].isVideo ==
                                                    true)
                                                  Positioned.fill(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          return VideoViewScreen(
                                                            videoUrl:
                                                                gallary?[index]
                                                                        .image ??
                                                                    "",
                                                            flickManager:
                                                                flickManager,
                                                          );
                                                        },
                                                      ));
                                                    },
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      child: FittedBox(
                                                        fit: BoxFit.none,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              color: context.color
                                                                  .tertiaryColor
                                                                  .withOpacity(
                                                                      0.8)),
                                                          width: 30,
                                                          height: 30,
                                                          child: Icon(
                                                            Icons.play_arrow,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                if (index == 3)
                                                  Positioned.fill(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          BlurredRouter(
                                                        builder: (context) {
                                                          return AllGallaryImages(
                                                              youtubeThumbnail:
                                                                  youtubeVideoThumbnail,
                                                              images: property
                                                                      ?.gallery ??
                                                                  []);
                                                        },
                                                      ));
                                                    },
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      child: Text(
                                                              "+${(property?.gallery?.length ?? 0) - 3}")
                                                          .color(
                                                            Colors.white,
                                                          )
                                                          .size(
                                                              context.font.large)
                                                          .bold(),
                                                    ),
                                                  ))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                  ),
                                )
                              ],

                              // Padding(
                              //   padding: EdgeInsets.only( left: 15,right: 15),
                              //   child: Text(UiUtils.getTranslatedLabel(
                              //       context, "Agent Profile"),
                              //     style: TextStyle(
                              //         fontSize: 14,
                              //         color: Color(0xff333333),
                              //         fontWeight: FontWeight.w600
                              //     ),),
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),

                              // Padding(
                              //   padding: EdgeInsets.only( left: 15,right: 15),
                              //   child: GestureDetector(
                              //     onTap: () {},
                              //     child: CusomterProfileWidget(
                              //       widget: widget,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 15,
                              // ),
                              Padding(
                                padding: EdgeInsets.only( left: 15,right: 15),
                                child: Text(UiUtils.getTranslatedLabel(
                                    context, "Amenities"),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                  ),),
                              ),


                              GridView.builder(
                                padding: const EdgeInsets.all(15),
                                shrinkWrap: true,
                                itemCount: property?.amenity!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1 / 0.7,
                                ),

                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> griddata = property?.amenity![index];
                                  return GestureDetector(
                                    onTap: () {
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                      decoration: BoxDecoration(
                                          color: Color(0xffebf4ff),
                                          borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(left: 10,right: 10,top: 6,bottom: 6),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              ),
                                            ),
                                             child: Container(
                                               width: 23, height: 23,
                                               child: UiUtils.networkSvg(griddata["image"], fit: BoxFit.cover, color: Color(0xff2e8af9)),
                                             ),
                                          ),
                                          Text(
                                              griddata["name"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                              .size(11)
                                              .color(Color(0xff5d5d5d))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: EdgeInsets.only( left: 15,right: 15),
                                child: Text(UiUtils.getTranslatedLabel(
                                        context, "Property Location"))
                                    .color(context.color.textColorDark)
                                    .size(context.font.large)
                                    .bold(weight: FontWeight.w600),
                              ),

                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.only( left: 15,right: 15),
                                child: SizedBox(
                                  height: 150,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                    child: GoogleMapScreen(
                                        property: property,
                                        kInitialPlace:_kInitialPlace,
                                        controller:_controller
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: EdgeInsets.only( left: 15,right: 15),
                              //   child: SizedBox(
                              //     height: 175,
                              //     child: ClipRRect(
                              //       borderRadius: BorderRadius.circular(10),
                              //       child: Stack(
                              //         fit: StackFit.expand,
                              //         children: [
                              //           Image.asset(
                              //             "assets/map.png",
                              //             fit: BoxFit.cover,
                              //           ),
                              //           BackdropFilter(
                              //             filter: ImageFilter.blur(
                              //               sigmaX: 1,
                              //               sigmaY: 1,
                              //             ),
                              //             // filter: ImageFilter.blur(
                              //             //   sigmaX: 4.0,
                              //             //   sigmaY: 4.0,
                              //             // ),
                              //             child: Center(
                              //               child: MaterialButton(
                              //                 onPressed: () {
                              //                   Navigator.push(context,
                              //                       BlurredRouter(
                              //                     builder: (context) {
                              //                       return Scaffold(
                              //                         extendBodyBehindAppBar:
                              //                             true,
                              //                         appBar: AppBar(
                              //                           elevation: 0,
                              //                           iconTheme: IconThemeData(
                              //                               color: context.color
                              //                                   .tertiaryColor),
                              //                           backgroundColor:
                              //                               Colors.transparent,
                              //                         ),
                              //                         body: GoogleMapScreen(
                              //                             property: property,
                              //                             kInitialPlace:
                              //                                 _kInitialPlace,
                              //                             controller:
                              //                                 _controller),
                              //                       );
                              //                     },
                              //                   ));
                              //                 },
                              //                 shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(5)),
                              //                 color:
                              //                     context.color.tertiaryColor,
                              //                 elevation: 0,
                              //                 child: Text("viewMap"
                              //                         .translate(context))
                              //                     .color(
                              //                   context.color.buttonColor,
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.only( left: 15,right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text("${UiUtils.getTranslatedLabel(context, "addressLbl")} :")
                                    //     .size(context.font.normal)
                                    //     .color(context.color.textColorDark),
                                    // // .bold(weight: FontWeight.w600),
                                    // SizedBox(
                                    //   height: 5.rh(context),
                                    // ),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // UiUtils.getSvg(AppIcons.location,
                                        //     color: context.color.tertiaryColor),
                                        // SizedBox(
                                        //   width: 5.rw(context),
                                        // ),
                                        Expanded(
                                          child: Text("${property?.address!}"),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(
                              //   height: 18,
                              // ),
                              // if (!HiveUtils.isGuest()) ...[
                              //   if (int.parse(HiveUtils.getUserId() ?? "0") !=
                              //       property?.addedBy)
                              //     Padding(
                              //       padding: EdgeInsets.only( left: 15,right: 15),
                              //       child: Row(
                              //         children: [
                              //           // sendEnquiryButtonWithState(),
                              //           setInterest(),
                              //         ],
                              //       ),
                              //     ),
                              // ],
                              const SizedBox(
                                height: 15,
                              ),

                              // Padding(
                              //   padding: EdgeInsets.symmetric( horizontal: 15,),
                              //   child: Container(
                              //     padding: EdgeInsets.all(10),
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(15.0),
                              //       color: Colors.white,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           offset: Offset(0, 1),
                              //           blurRadius: 5,
                              //           color: Colors.black.withOpacity(0.1),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         Text("Specifications".translate(context),style: TextStyle(
                              //             fontSize: 14,
                              //             color: Color(0xff333333),
                              //             fontWeight: FontWeight.w600
                              //         ),),
                              //         SizedBox(height :15),
                              //         Text("Step into the epitome of urban living with this inviting 2 BHK flat in the heart of KK Nagar, Chennai. This residence seamlessly blends modern comfort...")
                              //             .size(11)
                              //             .color(Color(0xff707070)),
                              //         Text("Read More",style: TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w500,
                              //           color: Color(0xff117af9),
                              //         ),),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                              if (Constant.showExperimentals &&
                                  !reportedProperties
                                      .contains(widget.property!.id) &&
                                  widget.property!.addedBy.toString() !=
                                      HiveUtils.getUserId())
                                 Padding(
                                  padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                                  child: ReportPropertyButton(
                                    propertyId: property!.id!,
                                    onSuccess: () {
                                      setState(
                                        () {},
                                      );
                                    },
                                  ),
                                )
                            ],
                          ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    var response = await Api.post(url: Api.interestedUsers, parameter: {
                                      'property_id': property!.id!,
                                      'type': 1,
                                    });
                                    if(!response['error']) {
                                      HelperUtils.showSnackBarMessage(
                                          context, UiUtils.getTranslatedLabel(context, response['message']),
                                          type: MessageType.success, messageDuration: 3);
                                      HelperUtils.showSnackBarMessage(
                                          context, UiUtils.getTranslatedLabel(context, 'Our Executive will reach you shortly!'),
                                          type: MessageType.success, messageDuration: 5);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            width: 1,
                                            color: Color(0xff2e8af9)
                                        )
                                    ),
                                    child: Center(
                                      child: Text("Request a Callback",style: TextStyle(
                                          color: Color(0xff2e8af9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                      ),),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 15,right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Similar Properties",
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                                      
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: SingleChildScrollView(
                              scrollDirection : Axis.horizontal,
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for(int i = 0; i < similarPropertiesList.length; i++)
                                    InkWell(
                                      onTap: () {
                                        HelperUtils.goToNextPage(
                                            Routes.propertyDetails, context, false, args: {
                                          'propertyData': PropertyModel.fromMap(similarPropertiesList[i]),
                                          'propertiesList': []
                                        });
                                      },
                                      child: Container(
                                      width: 230,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xffe0e0e0)
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(15),
                                                    topLeft:Radius.circular(15),
                                                  ),
                                                  // child: Image.asset("assets/propertylist/1.png",width: double.infinity,fit: BoxFit.cover,height: 150,),
                                                  child: UiUtils.getImage(
                                                    similarPropertiesList[i]['title_image'] ?? "",
                                                    width: double.infinity,fit: BoxFit.cover,height: 150,
                                                  ),
                                              ),

                                              Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: LikeButtonWidget(
                                                    onStateChange:
                                                        (AddToFavoriteCubitState state) {
                                                      if (state is AddToFavoriteCubitInProgress) {
                                                        favoriteInProgress = true;
                                                        setState(
                                                              () {},
                                                        );
                                                      } else {
                                                        favoriteInProgress = false;
                                                        setState(
                                                              () {},
                                                        );
                                                      }
                                                    },
                                                    property: PropertyModel.fromMap(similarPropertiesList[i]!),
                                                  ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left:10,right: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 8,),
                                                Text("${similarPropertiesList[i]['title']}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0xff333333),
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                ),
                                                SizedBox(height: 6,),
                                                Row(
                                                  children: [
                                                    Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                                    SizedBox(width: 5,),
                                                    Expanded(
                                                      child: Text("${similarPropertiesList[i]['address']}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Color(0xffa2a2a2),
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.w400
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 6,),
                                                Row(
                                                  children: [
                                                    Text("Rs. ${similarPropertiesList[i]['price']}",
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Color(0xff333333),
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500
                                                      ),
                                                    ),
                                                    SizedBox(width: 15,),
                                                    // Container(width: 1,height: 10,color: Color(0xff7d7d7d),),
                                                    // SizedBox(width: 5,),
                                                    // Text("952 sqft",
                                                    //   maxLines: 1,
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   style: TextStyle(
                                                    //       color: Color(0xff767676),
                                                    //       fontSize: 11,
                                                    //       fontWeight: FontWeight.w400
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                SizedBox(height: 6,),
                                                Text("${similarPropertiesList[i]['category']['category']}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0xffa2a2a2),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                                SizedBox(height: 8,),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                                                        ),
                                    ),
                                ],
                              )
                          ),
                        ),
                    
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 15,right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Other Project By Agent",
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                    
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: SingleChildScrollView(
                              scrollDirection : Axis.horizontal,
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for(int i = 0; i < agentPropertiesList.length; i++)
                                    InkWell(
                                      onTap: () {
                                          HelperUtils.goToNextPage(
                                              Routes.propertyDetails, context, false, args: {
                                            'propertyData': PropertyModel.fromMap(agentPropertiesList[i]),
                                            'propertiesList': []
                                          });
                                      },
                                      child: Container(
                                        width: 230,
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 1,
                                                color: Color(0xffe0e0e0)
                                            )
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(15),
                                                    topLeft:Radius.circular(15),
                                                  ),
                                                  // child: Image.asset("assets/propertylist/1.png",width: double.infinity,fit: BoxFit.cover,height: 150,),
                                                  child: UiUtils.getImage(
                                                    agentPropertiesList[i]['title_image'] ?? "",
                                                    width: double.infinity,fit: BoxFit.cover,height: 150,
                                                  ),
                                                ),

                                                Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: LikeButtonWidget(
                                                      onStateChange:
                                                          (AddToFavoriteCubitState state) {
                                                        if (state is AddToFavoriteCubitInProgress) {
                                                          favoriteInProgress = true;
                                                          setState(
                                                                () {},
                                                          );
                                                        } else {
                                                          favoriteInProgress = false;
                                                          setState(
                                                                () {},
                                                          );
                                                        }
                                                      },
                                                      property: PropertyModel.fromMap(agentPropertiesList[i]!),
                                                    ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:10,right: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 8,),
                                                  Text("${agentPropertiesList[i]['title']}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Color(0xff333333),
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Row(
                                                    children: [
                                                      Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                                      SizedBox(width: 5,),
                                                      Expanded(
                                                        child: Text("${agentPropertiesList[i]['address']}",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: Color(0xffa2a2a2),
                                                              fontSize: 10.5,
                                                              fontWeight: FontWeight.w400
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Row(
                                                    children: [
                                                      Text("Rs. ${agentPropertiesList[i]['price']}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Color(0xff333333),
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w500
                                                        ),
                                                      ),
                                                      SizedBox(width: 15,),
                                                      // Container(width: 1,height: 10,color: Color(0xff7d7d7d),),
                                                      // SizedBox(width: 5,),
                                                      // Text("952 sqft",
                                                      //   maxLines: 1,
                                                      //   overflow: TextOverflow.ellipsis,
                                                      //   style: TextStyle(
                                                      //       color: Color(0xff767676),
                                                      //       fontSize: 11,
                                                      //       fontWeight: FontWeight.w400
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Text("${agentPropertiesList[i]['category'] != null ? agentPropertiesList[i]['category']['category'] : ''}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Color(0xffa2a2a2),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w400
                                                    ),
                                                  ),
                                                  SizedBox(height: 8,),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                          ),
                        ),
                        SizedBox(height: 20,),
                    
                        //here
                        SizedBox(
                          height: 20.rh(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }




  Widget advertismentLable() {
    if (property?.promoted == false || property?.promoted == null) {
      return const SizedBox.shrink();
    }

    return PositionedDirectional(
        start: 20,
        top: 20,
        child: Container(
          width: 83,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: context.color.tertiaryColor,
              borderRadius: BorderRadius.circular(4)),
          child: Text(UiUtils.getTranslatedLabel(context, 'featured'))
              .color(context.color.buttonColor)
              .size(context.font.small),
        ));
  }

  // Future<void> _delayedPop(BuildContext context) async {
  //   unawaited(
  //     Navigator.of(context, rootNavigator: true).push(
  //       PageRouteBuilder(
  //         pageBuilder: (_, __, ___) => WillPopScope(
  //           onWillPop: () async => false,
  //           child: Scaffold(
  //             backgroundColor: Colors.transparent,
  //             body: Center(
  //               child: UiUtils.progress(),
  //             ),
  //           ),
  //         ),
  //         transitionDuration: Duration.zero,
  //         barrierDismissible: false,
  //         barrierColor: Colors.black45,
  //         opaque: false,
  //       ),
  //     ),
  //   );
  //   await Future.delayed(const Duration(seconds: 1));

  //   Future.delayed(
  //     Duration.zero,
  //     () {},
  //   );

  //   Future.delayed(
  //     Duration.zero,
  //     () {
  //       Navigator.of(context).pop();
  //       Navigator.of(context).pop();
  //     },
  //   );
  // }

  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (!HiveUtils.isGuest()) {
      if (int.parse(HiveUtils.getUserId() ?? "0") == property?.addedBy) {
        return SizedBox(
          height: 65.rh(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
              builder: (context, state) {
                PropertyModel? model;

                if (state is FetchMyPropertiesSuccess) {
                  model = state.myProperty
                      .where((element) => element.id == property?.id)
                      .first;
                }

                model ??= widget.property;

                var isPromoted = (model?.promoted);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!HiveUtils.isGuest()) ...[
                      if (isPromoted == false &&
                          (property?.status.toString() != "0")) ...[
                        Expanded(
                            child: UiUtils.buildButton(
                          context,
                          disabled: (property?.status.toString() == "0"),
                          // padding: const EdgeInsets.symmetric(horizontal: 1),
                          outerPadding: const EdgeInsets.all(
                            1,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.createAdvertismentScreenRoute,
                              arguments: {
                                "model": property,
                              },
                            ).then(
                              (value) {
                                setState(() {});
                              },
                            );
                          },
                          prefixWidget: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SvgPicture.asset(
                              AppIcons.promoted,
                              width: 14,
                              height: 14,
                            ),
                          ),

                          fontSize: context.font.normal,
                          width: context.screenWidth / 3,
                          buttonTitle:
                              UiUtils.getTranslatedLabel(context, "feature"),
                        )),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ],
                    Expanded(
                      child: UiUtils.buildButton(context,
                          // padding: const EdgeInsets.symmetric(horizontal: 1),
                          outerPadding: const EdgeInsets.all(1), onPressed: () {
                        Constant.addProperty.addAll({
                          "category": Category(
                            category: property?.category!.category,
                            id: property?.category?.id!.toString(),
                            image: property?.category?.image,
                            parameterTypes: {
                              "parameters": property?.parameters
                                  ?.map((e) => e.toMap())
                                  .toList()
                            },
                          )
                        });
                        Navigator.pushNamed(
                            context, Routes.addPropertyDetailsScreen,
                            arguments: {
                              "details": {
                                "id": property?.id,
                                "catId": property?.category?.id,
                                "propType": property?.properyType,
                                "name": property?.title,
                                "desc": property?.description,
                                "city": property?.city,
                                "state": property?.state,
                                "country": property?.country,
                                "latitude": property?.latitude,
                                "longitude": property?.longitude,
                                "address": property?.address,
                                "client": property?.clientAddress,
                                "price": property?.price,
                                'parms': property?.parameters,
                                'rera': property?.rera,
                                'highlight': property?.highlight,
                                'brokerage': property?.brokerage,
                                'customerRole': property?.customerRole,
                                'amenity': property?.amenity,
                                'sqft': property?.sqft,
                                "images": property?.gallery
                                    ?.map((e) => e.imageUrl)
                                    .toList(),
                                "gallary_with_id": property?.gallery,
                                "rentduration": property?.rentduration,
                                "assign_facilities":
                                    property?.assignedOutdoorFacility,
                                "titleImage": property?.titleImage
                              }
                            });
                      },
                          fontSize: context.font.normal,
                          width: context.screenWidth / 3,
                          prefixWidget: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: SvgPicture.asset(AppIcons.edit),
                          ),
                          buttonTitle:
                              UiUtils.getTranslatedLabel(context, "edit")),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: UiUtils.buildButton(context,
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          outerPadding: const EdgeInsets.all(1),
                          buttonColor: Colors.redAccent,
                          prefixWidget: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: SvgPicture.asset(
                              AppIcons.delete,
                              color: context.color.buttonColor,
                              width: 14,
                              height: 14,
                            ),
                          ), onPressed: () async {
                        // //THIS IS FOR DEMO MODE
                        bool isPropertyActive =
                            property?.status.toString() == "1";

                        bool isDemoNumber = HiveUtils.getUserDetails().mobile ==
                            "${Constant.demoCountryCode}${Constant.demoMobileNumber}";

                        if (Constant.isDemoModeOn &&
                            isPropertyActive &&
                            isDemoNumber) {
                          HelperUtils.showSnackBarMessage(context,
                              "Active property cannot be deleted in demo app.");

                          return;
                        }

                        var delete = await UiUtils.showBlurredDialoge(
                          context,
                          dialoge: BlurredDialogBox(
                            title: UiUtils.getTranslatedLabel(
                              context,
                              "deleteBtnLbl",
                            ),
                            content: Text(
                              UiUtils.getTranslatedLabel(
                                  context, "deletepropertywarning"),
                            ),
                          ),
                        );
                        if (delete == true) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              // if (Constant.isDemoModeOn) {
                              //   HelperUtils.showSnackBarMessage(
                              //       context,
                              //       UiUtils.getTranslatedLabel(
                              //           context, "thisActionNotValidDemo"));
                              // } else {
                              context
                                  .read<DeletePropertyCubit>()
                                  .delete(property!.id!);
                              // }
                            },
                          );
                        }
                      },
                          fontSize: context.font.normal,
                          width: context.screenWidth / 3.2,
                          buttonTitle: UiUtils.getTranslatedLabel(
                              context, "deleteBtnLbl")),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 65.rh(context), // Custom height for the widget (ensure rh function works as expected)
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: widget.property?.viewContact == 1 || showContact ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between buttons
          children: <Widget>[
            // Call Button
            callButton(),

            // Email Button
            Expanded(child: email()),

            // Message Button Expanded to take remaining space
            Expanded( // This takes up more space in the row
              child: messageButton(),
            ),
          ],
        ) : InkWell(
          onTap:() async {
            var response = await Api.post(url: Api.apiViewContact, parameter: {
              'property_id': widget.property!.id,
              'project_id': ''
            });
            if(!response['error'] && response['message'] == 'Update Successfully') {
              setState(() {
                showContact = true;
              });
            } else {
              print('................................................');
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //   content: Text(response['message']),
              // ));
              HelperUtils.showSnackBarMessage(
                  context, UiUtils.getTranslatedLabel(context, response['message']),
                  type: MessageType.success, messageDuration: 3);
            }
          },
          child: Center(child: Text('View Contact').size(context.font.large)
              .bold().color(Color(0xff117af9)),)),
      ),
    );

  }

  String statusText(String text) {
    if (text == "1") {
      return UiUtils.getTranslatedLabel(context, "active");
    } else if (text == "0") {
      return UiUtils.getTranslatedLabel(context, "deactive");
    }
    return "";
  }

  Widget setInterest() {
    // check if list has this id or not
    bool interestedProperty =
        Constant.interestedPropertyIds.contains(widget.property?.id);

    /// default icon
    dynamic icon = AppIcons.interested;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.property?.isInterested == 1) {
      /// If list has id or our property is interested so we are gonna show icon of No Interest
      icon = Icons.not_interested_outlined;
    }

    return BlocConsumer<ChangeInterestInPropertyCubit,
        ChangeInterestInPropertyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChangeInterestInPropertySuccess) {
          if (state.interest == PropertyInterest.interested) {
            //If interested show no interested icon
            icon = Icons.not_interested_outlined;
          } else {
            icon = AppIcons.interested;
          }
        }

        return Expanded(
          flex: 1,
          child: UiUtils.buildButton(
            context,
            height: 48,
            outerPadding: const EdgeInsets.all(1),
            isInProgress: state is ChangeInterestInPropertyInProgress,
            onPressed: () {
              PropertyInterest interest;

              bool contains =
                  Constant.interestedPropertyIds.contains(widget.property!.id!);

              if (contains == true || widget.property!.isInterested == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                  propertyId: widget.property!.id!.toString(),
                  interest: interest);
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.getTranslatedLabel(context, "interested")
                : UiUtils.getTranslatedLabel(context, "interest")),
            fontSize: context.font.large,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: (icon is String) ? SvgPicture.asset(icon, width: 22, height: 22,)
                : Icon(icon, color: Theme.of(context).colorScheme.buttonColor, size: 22,),
            ),
          ),
        );
      },
    );
  }

  bool isDisabledEnquireButton(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool showIcon(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  String setLable(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return UiUtils.getTranslatedLabel(
          context,
          "sent",
        );
      } else {
        return UiUtils.getTranslatedLabel(
          context,
          "sendEnqBtnLbl",
        );
      }
    }
    return "";
  }

  Widget callButton() {
    return UiUtils.buildButton(context,
        fontSize: 12,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "call"),
        width: 35,
        onPressed: _onTapCall,
        prefixWidget: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: SizedBox(
              width: 16,
              height: 16,
              child: UiUtils.getSvg(AppIcons.call, color: Colors.white,)),
        ));
  }
  Widget email() {
    return UiUtils.buildButton(context,
        fontSize: 13,
        buttonColor: Color(0xffff5f7a),
        outerPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "Email"),
        onPressed: _onTapEmail,
        prefixWidget: SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Image.asset("assets/Sale_RentPropertydetailscreen/gmail.png",),
          ),
        ));
  }
  Widget messageButton() {
    return UiUtils.buildButton(context,
        fontSize: 13,
        buttonColor: Color(0xff25d366),
        outerPadding: const EdgeInsets.symmetric(horizontal: 0,vertical: 1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "WhatsApp"),
        onPressed: _onTapMessage,
        prefixWidget: SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Image.asset("assets/Sale_RentPropertydetailscreen/__whatsapp.png"),
          ),
        ));
  }



  Widget chatButton() {
    return UiUtils.buildButton(context,
        fontSize: 12,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "chat"),
        width: 40,
        onPressed: _onTapChat,
        prefixWidget: SizedBox(
          width: 18,
          height: 18,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child:
                UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
          ),
        ));
  }

  _onTapCall() async {
    var contactNumber = widget.property?.customerNumber;

    var url = Uri.parse("tel: $contactNumber"); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onTapMessage() async {
    var contactNumber = widget.property?.customerNumber;

    var url = Uri.parse("sms:$contactNumber"); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _onTapEmail() async {
    var email = widget.property?.customerEmail; // Correctly use customerEmail

    if (email != null && email.isNotEmpty) {
      var url = Uri.parse("mailto:$email"); // Use mailto: for emails
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Handle the case where email is null or empty
      throw 'Invalid email address';
    }
  }

  _onTapChat() {
    GuestChecker.check(onNotGuest: () {
      //entering chat
      Navigator.push(context, BlurredRouter(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SendMessageCubit(),
              ),
              BlocProvider(
                create: (context) => LoadChatMessagesCubit(),
              ),
              BlocProvider(
                create: (context) => DeleteMessageCubit(),
              ),
            ],
            child: ChatScreen(
              profilePicture: property?.customerProfile ?? "",
              userName: property?.customerName ?? "",
              propertyImage: property?.titleImage ?? "",
              proeprtyTitle: property?.title ?? "",
              userId: (property?.addedBy).toString(),
              from: "property",
              propertyId: (property?.id).toString(),
            ),
          );
        },
      ));
    });
  }
}

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({
    super.key,
    required this.property,
    required CameraPosition kInitialPlace,
    required Completer<GoogleMapController> controller,
  })  : _kInitialPlace = kInitialPlace,
        _controller = controller;

  final PropertyModel? property;
  final CameraPosition _kInitialPlace;
  final Completer<GoogleMapController> _controller;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isGoogleMapVisible = false;

  @override
  void initState() {
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        isGoogleMapVisible = true;
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        isGoogleMapVisible = false;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
        Future.delayed(
          Duration.zero,
          () {
            Navigator.pop(context);
          },
        );
        return false;
      },
      child: Builder(builder: (context) {
        if (!isGoogleMapVisible) {
          return Center(child: UiUtils.progress());
        }
        return GoogleMap(
          key: const Key("AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8"),
          myLocationButtonEnabled: false,
          gestureRecognizers: <f.Factory<OneSequenceGestureRecognizer>>{
            f.Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          markers: {
            Marker(
                markerId: const MarkerId("1"),
                position: LatLng(
                    double.parse((widget.property?.latitude ?? "0")),
                    double.parse((widget.property?.longitude ?? "0"))))
          },
          mapType: AppSettings.googleMapType,
          initialCameraPosition: widget._kInitialPlace,
          onMapCreated: (GoogleMapController controller) {
            if (!widget._controller.isCompleted) {
              widget._controller.complete(controller);
            }
          },
        );
      }),
    );
  }
}

class CusomterProfileWidget extends StatelessWidget {
  const CusomterProfileWidget({
    super.key,
    required this.widget,
  });

  final PropertyDetails widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
      decoration: BoxDecoration(
          color: Color(0xfff9f9f9),
          borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              UiUtils.showFullScreenImage(context,
                  provider:
                      NetworkImage(widget?.property?.customerProfile ?? ""));
            },

            child: Container(
                width: 55,
                height: 55,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                      width: 1,
                      color: Color(0xffdfdfdf)
                    ),
                    borderRadius: BorderRadius.circular(50)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                  child: UiUtils.getImage(widget.property?.customerProfile ?? "",
                      fit: BoxFit.cover),
                )

                //  CachedNetworkImage(
                //   imageUrl: widget.propertyData?.customerProfile ?? "",
                //   fit: BoxFit.cover,
                // ),


                ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.property?.customerName ?? "")
                    .size(context.font.large)
                    .bold(),
                Text(widget.property?.customerEmail ?? ""),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CusomterProfileWidget1 extends StatelessWidget {
  const CusomterProfileWidget1({
    super.key,
    required this.widget,
  });

  final PropertyDetails widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15,right: 15,),
      child: Row(
        children: [

          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    UiUtils.showFullScreenImage(context,
                        provider:
                            NetworkImage(widget?.property?.customerProfile ?? ""));
                  },
            
                  child: Container(
                      width: 43,
                      height: 43,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            width: 1,
                            color: Color(0xffdfdfdf)
                          ),
                          borderRadius: BorderRadius.circular(50)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                        child: UiUtils.getImage(widget.property?.customerProfile ?? "",
                            fit: BoxFit.cover),
                      )
            
                      //  CachedNetworkImage(
                      //   imageUrl: widget.propertyData?.customerProfile ?? "",
                      //   fit: BoxFit.cover,
                      // ),
            
                      ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.property?.customerName ?? "")
                          .size(13)
                      .color(Color(0xff4c4c4c))
                          .bold(),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Text("${widget.property?.customerRole == 1 ? 'Owner' : widget.property?.customerRole == 2 ? 'Agent' : 'Builder'}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff7d7d7d)
                            ),
                          ),
                          SizedBox(width: 5,),
                          Container(
                            padding: EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                            decoration: BoxDecoration(
                                color: Color(0xffd6fffa),
                                borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              children: [
                                Image.asset("assets/NewPropertydetailscreen/__rara.png",width: 13,height: 13,fit: BoxFit.cover,),
                                SizedBox(width: 2,),
                                Text("RERA",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff009681)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          if(widget.property?.customerRole != 1)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      UserDetailProfileScreen(id: widget.property?.addedBy)),
                );
              },
              child: Container(
              padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      width: 1,
                      color: Color(0xff2e8af9)
                  )

              ),
              child: Text("Profile",style: TextStyle(
                color: Color(0xff2e8af9),
                fontSize: 12,
                fontWeight: FontWeight.w500
              ),),
                        ),
            )
        ],
      ),
    );
  }
}

class OutdoorFacilityListWidget extends StatelessWidget {
  final List<AssignedOutdoorFacility> outdoorFacilityList;
  const OutdoorFacilityListWidget({Key? key, required this.outdoorFacilityList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CrossAxisAlignment getCrossAxisAlignment(int columnIndex) {
      if (columnIndex == 1) {
        return CrossAxisAlignment.center;
      } else if (columnIndex == 2) {
        return CrossAxisAlignment.end;
      } else {
        return CrossAxisAlignment.start;
      }
    }

    // return GridView.builder(
    //   physics: const NeverScrollableScrollPhysics(),
    //   shrinkWrap: true,
    //   gridDelegate:
    //       const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    //   itemCount: outdoorFacilityList.length,
    //   itemBuilder: (context, index) {
    //     AssignedOutdoorFacility facility = outdoorFacilityList[index];
    //
    //     return Container(
    //       padding: EdgeInsets.all(6),
    //       decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(10),
    //           border: Border.all(
    //               width: 1,
    //               color: Color(0xffe9e9e9)
    //           )
    //
    //       ),
    //       child: Column(
    //         //crossAxisAlignment: getCrossAxisAlignment(columnIndex),
    //         children: [
    //           Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Container(
    //                 width: 46,
    //                 height: 46,
    //                 decoration: BoxDecoration(
    //                     // shape: BoxShape.circle,
    //                     borderRadius: BorderRadius.circular(10),
    //                     color: Color(0xfffff1db)),
    //                 child: Center(
    //                   child: UiUtils.imageType(
    //                     facility.image ?? "",
    //                     color: Constant.adaptThemeColorSvg
    //                         ? context.color.tertiaryColor
    //                         : null,
    //                     // fit: BoxFit.cover,
    //                     width: 20,
    //                     height: 20,
    //                   ),
    //                 ),
    //               ),
    //               const SizedBox(width: 8),
    //               Expanded(
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(facility.name ?? "")
    //                         .centerAlign()
    //                         .size(11)
    //                         .color(Color(0xff585858))
    //                         .setMaxLines(lines: 1),
    //                     const SizedBox(height: 4),
    //                     Text("${facility.distance} KM",style: TextStyle(
    //                       color: Color(0xff333333),
    //                       fontSize: 12,
    //                       fontWeight: FontWeight.w500
    //                     ),)
    //                         .centerAlign()
    //                         .setMaxLines(lines: 1),
    //                   ],
    //                 ),
    //               )
    //             ],
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );

    return SizedBox(
      height: 60,
      child: GridView.builder(
        // physics: const NeverScrollableScrollPhysics(),
        // shrinkWrap: true,
        scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing :10,
          mainAxisExtent: 140,
        ),
        itemCount: outdoorFacilityList.length,
        itemBuilder: (context, index) {
          AssignedOutdoorFacility facility = outdoorFacilityList[index];

          return Row(
            children: [
              Container(
                width: 140,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: Color(0xffe9e9e9),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xfffff1db),
                        ),
                        child: Center(
                          child: UiUtils.imageType(
                            facility.image ?? "",
                            color: Constant.adaptThemeColorSvg
                                ? context.color.tertiaryColor
                                : null,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility.name ?? "",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xff585858),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${facility.distance} KM",
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
          );
        },
      ),
    );


  }
}
