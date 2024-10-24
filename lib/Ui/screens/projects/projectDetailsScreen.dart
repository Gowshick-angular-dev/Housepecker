// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/chat/chat_screen.dart';
import 'package:Housepecker/Ui/screens/projects/reportProject.dart';
import 'package:Housepecker/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:Housepecker/Ui/screens/widgets/panaroma_image_view.dart';
import 'package:Housepecker/Ui/screens/widgets/read_more_text.dart';
import 'package:Housepecker/app/routes.dart';
import 'package:Housepecker/data/cubits/chatCubits/delete_message_cubit.dart';
import 'package:Housepecker/data/cubits/chatCubits/load_chat_messages.dart';
import 'package:Housepecker/data/cubits/enquiry/store_enqury_id.dart';
import 'package:Housepecker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/delete_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:Housepecker/data/cubits/property/set_property_view_cubit.dart';
import 'package:Housepecker/data/model/property_model.dart';
import 'package:Housepecker/utils/AppIcon.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/api.dart';
import 'package:Housepecker/utils/constant.dart';
import 'package:Housepecker/utils/hive_utils.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../data/cubits/chatCubits/send_message.dart';
import '../../../data/model/category.dart';
import '../../../settings.dart';
import '../../../utils/AdMob/interstitialAdManager.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';
import '../userprofile/edit_profile.dart';
import '../userprofile/userProfileScreen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/shimmerLoadingContainer.dart';
import '../widgets/video_view_screen.dart';

Map<String, String> rentDurationMap = {
  "Quarterly": "Quarter",
  "Monthly": "Month",
  "Yearly": "Year"
};

class ProjectDetails extends StatefulWidget {
  final Map? property;
  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool fromSlider;
  final bool? fromPropertyAddSuccess;
  const ProjectDetails(
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
            // BlocProvider(
            //   create: (context) => ChangeInterestInPropertyCubit(),
            // ),
            // BlocProvider(
            //   create: (context) => UpdatePropertyStatusCubit(),
            // ),
            // BlocProvider(
            //   create: (context) => DeletePropertyCubit(),
            // ),
            // BlocProvider(
            //   create: (context) => PropertyReportCubit(),
            // ),
          ],
          child: ProjectDetails(
            property: arguments?['propertyData'],
            fromMyProperty: true,
            fromSlider: true,
            fromCompleteEnquiry: true,
            fromPropertyAddSuccess: true,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<ProjectDetails> {
  FlickManager? flickManager;
  // late Property propertyData;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List promotedProeprtiesIds = [];
  List similarProjectsList = [];
  List agentProjectsList = [];
  List reportCheckboxList = [];
  int? selectedPropertyId;
  bool toggleEnqButton = false;
  Map<String, dynamic>? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;
  bool likeLoading = false;
  bool showContact = false;
  BannerAd? _bannerAd;
  bool similarIsLoading = false;
  bool agentPropertiesIsLoading = false;

  List<bool> likeLoadingg = [];
  List<bool> likeLoadingg2 = [];
  @override
  bool get wantKeepAlive => true;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  List<ProjectDocument> gallary=[];
  String youtubeVideoThumbnail = "";
  bool? _isLoaded;
  double progress = 0;
  bool downloading = false;
  bool downloading2 = false;
  int _currentImage = 0;
  bool isLoading = false;

  InterstitialAdManager interstitialAdManager = InterstitialAdManager();

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    getAgentProperties();
    getSimilarProperties();
    getReportResponseList();
    _pageController.addListener(() {
      setState(() {
        _currentImage = _pageController.page!.round();
      });
    });
    // loadAd();
    // interstitialAdManager.load();
    // customListenerForConstant();
    //add title image along with gallary images1
    // context.read<FetchOutdoorFacilityListCubit>().fetch();

    // Future.delayed(
    //   const Duration(seconds: 3),
    //       () {
    //     showGoogleMap = true;
    //     if (mounted) setState(() {});
    //   },
    // );


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      final images = widget.property?['gallary_images'];

      if (images != null) {
        for (var i = 0; i < images.length; i++) {
          print("${images.length} ssssssss");
          gallary.add(ProjectDocument(
            id: 9999999,
            isVideo: false,
            image: "",
            imageUrl: images[i]['name'] ?? "",
          ));
        }
        print("${gallary.length} ssssssss");
        setState(() {});
      } else {
        print("No images available");
      }


      if (property?['video_link'] != null&&widget.property?['video_link']!= "") {
        injectVideoInGallary();
        setState(() {});
      }
    });

    if (widget.fromSlider) {
      getProperty();
    } else {
      property = widget.property as Map<String, dynamic>;
      setData();
    }

    // setViewdProperty();
    if (widget.property?['video_link'] != "" &&
        widget.property?['video_link'] != null &&
        !HelperUtils.isYoutubeVideo(widget.property?['video_link'] ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(property!['video_link']!),
        ),
      );
      flickManager?.onVideoEnd = () {};
    }

    if (widget.property?['video_link'] != "" &&
        widget.property?['video_link'] != null &&
        HelperUtils.isYoutubeVideo(widget.property?['video_link'] ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(property!['video_link']!);
      String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
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

  String getRelativeTimeString(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${difference.inDays ~/ 7} weeks ago';

  }
  }

  share(String slugId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text("copylink".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/project-details/$slugId";

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                      context, "copied".translate(context));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text("share".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/project-details/$slugId";

                String text =
                    "Exciting find! 🏡 Check out this amazing property I came across.  Let me know what you think! ⭐\n Here are the details:\n$deepLink.";
                await Share.share(text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getProperty() async {
    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty,
        {
          Api.id: widget.property!['id'],
        },
        true,
        context,
        passUserid: false);
    if (response != null) {
      var getdata = json.decode(response);
      if (!getdata[Api.error]) {
        getdata['data'];
        setData();
        setState(() {});
      }
    }
  }
  Future<void> getReportResponseList() async {

    var response = await Api.get(url: Api.apiGetReportPropertyReson, );
    if(!response['error']) {
      setState(() {
        reportCheckboxList = response['data'];
      });
    }
  }

  void setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  void setViewdProperty() {
    if (property!['addedBy'].toString() != HiveUtils.getUserId()) {
      context.read<SetPropertyViewCubit>().set(property!['id']!.toString());
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        (property?['latitude'] ?? "0"),
      ),
      double.parse(
        (property?['longitude'] ?? "0"),
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    flickManager?.dispose();

    super.dispose();
  }

  Future<void> getSimilarProperties() async {
    setState(() {
      similarIsLoading = true;
    });
    var response = await Api.get(url: Api.getProject, queryParameters: {
      'category_id': widget.property!['category']['id']!,
      'get_simiilar': 1,
      'id': widget.property!['id'],
      'current_user': HiveUtils.getUserId(),
    });
    if(!response['error']) {
      setState(() {
        similarProjectsList = response['data'];
        likeLoadingg = List.filled(response['data'].length, false);
        similarIsLoading = false;
      });
    }
  }

  Future<void> getAgentProperties() async {
    setState(() {
      agentPropertiesIsLoading  = true;
    });
    var response = await Api.get(url: Api.getProject, queryParameters: {
      'userid': widget.property!['added_by'],
      'current_user': HiveUtils.getUserId(),
    });
    if(!response['error']) {
      setState(() {
        agentProjectsList = response['data'];
        likeLoadingg2 = List.filled(response['data'].length, false);
        agentPropertiesIsLoading  = false;
      });
    }
  }

  Future<bool> _requestPermission() async {
    // if (Platform.isAndroid && android.sdkInt >= 33) {
      // Android 13 and above
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        print('Manage external storage permission granted');
        return true;
      } else {
        print('Manage external storage permission denied');
        return false;
      }
    // } else {
    //   // Android 12 and below
    //   final status = await Permission.storage.request();
    //   if (status.isGranted) {
    //     print('Storage permission granted');
    //     return true;
    //   } else {
    //     print('Storage permission denied');
    //     return false;
    //   }
    // }
  }

  Future<void> downloadFileToDownloads(String url, val) async {
    setState(() {
      if(val == 1) {
        downloading = true;
      } else {
        downloading2 = true;
      }
    });
    if (await _requestPermission()) {
      // final directory = await getExternalStorageDirectory();
      Directory? downloadsDirectory = await getDownloadsDirectory();
      final filePath = downloadsDirectory!.path;
      print('directory: ${filePath}');

      // Rest of your download logic using Dio (from previous example)
      await downloadFileWithDio(url, filePath, val);
    } else {
      print('Storage permission not granted. Download failed.');
    }
  }

  Future<void> downloadFileWithDio(String url, filePath, val) async {
    final dio = Dio();
    // final directory = await getApplicationDocumentsDirectory();
    // final filePath = directory.path + url.split('/').last;

    try {
      final response = await dio.download(
        url,
          '/storage/emulated/0/Housepecker' + '/' + url.split('/').last,
        onReceiveProgress: (received, total) {
          // Optional: Update progress indicator (if needed)
          setState(() {
            progress = (received / total) * 100;
          });
          print('Download progress: ${(received / total) * 100}%');
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          if(val == 1) {
            downloading = false;
          } else {
            downloading2 = false;
          }
          progress = 0;
        });
        HelperUtils.showSnackBarMessage(context, 'Download completed! File saved at: ${'/storage/emulated/0/Downloads' + '/' + url.split('/').last}',
            type: MessageType.success);
        print('Download completed! File saved at: ${'/storage/emulated/0/HousingRoyce' + '/' + url.split('/').last}');
      } else {
        setState(() {
          if(val == 1) {
            downloading = false;
          } else {
            downloading2 = false;
          }
          progress = 0;
        });
        HelperUtils.showSnackBarMessage(context, "Download failed with status code: ${response.statusCode}",
            type: MessageType.error);
        print('Download failed with status code: ${response.statusCode}');
      }
    } on DioError catch (e) {
      setState(() {
        if(val == 1) {
          downloading = false;
        } else {
          downloading2 = false;
        }
        progress = 0;
      });
      HelperUtils.showSnackBarMessage(context, "Download error: $e",
          type: MessageType.error);
      print('Download error: $e');
    }
  }

  void injectVideoInGallary() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (widget.property?['video'] != null) {
        gallary?.add(ProjectDocument(
            id: 99999999999,
            isVideo: true, image: widget.property?['video_link'], imageUrl: '')
        );
      }
    } else {
      gallary?.insert(
          0,
          ProjectDocument(
              id: 99999999999,
              image: widget.property?['video_link'],
              imageUrl: "",
              isVideo: true));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    String rentPrice = (property!['price']
    // .priceFormate(
    //   disabled: Constant.isNumberWithSuffix == false,
    // )
        .toString()
        .formatAmount(prefix: true));

    if (property?['rentduration'] != "" && property?['rentduration'] != null) {
      rentPrice =
          ("$rentPrice / ") + (rentDurationMap[property!['rentduration']] ?? "");
    }

    return SafeArea(
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(
          context: context,
        ),
        child: SafeArea(
            child: Scaffold(
                backgroundColor:const Color(0xFFFAF9F6),
              appBar: UiUtils.buildAppBar(context,
                  showBackButton: true,
                  title: property!['title']!,
                  actions: [

                  ]),
            /*  appBar: AppBar(
                  elevation: 0,
                  backgroundColor: tertiaryColor_,
                  title: Text(property!['title']!,style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                  ),),
                  // actions: [
                  //   if (!HiveUtils.isGuest()) ...[
                  //     if (int.parse(HiveUtils.getUserId() ?? "0") ==
                  //         property?['addedBy'])
                  //       IconButton(
                  //           onPressed: () {
                  //             Navigator.push(context, BlurredRouter(
                  //               builder: (context) {
                  //                 return AnalyticsScreen(
                  //                   interestUserCount: widget
                  //                       .property!['totalInterestedUsers']
                  //                       .toString(),
                  //                 );
                  //               },
                  //             ));
                  //           },
                  //           icon: Icon(
                  //             Icons.analytics,
                  //             color: context.color.tertiaryColor,
                  //           )),
                  //   ],
                   
                  //   if (property?['addedBy'].toString() == HiveUtils.getUserId() &&
                  //       property!['properyType'] != "Sold" &&
                  //       property?['status'] == 1)
                  //     PopupMenuButton<String>(
                  //       onSelected: (value) async {
                  //         var action = await UiUtils.showBlurredDialoge(
                  //           context,
                  //           dialoge: BlurredDialogBuilderBox(
                  //               title: "changePropertyStatus".translate(context),
                  //               acceptButtonName: "change".translate(context),
                  //               contentBuilder: (context, s) {
                  //                 return FittedBox(
                  //                   fit: BoxFit.none,
                  //                   child: Row(
                  //                     mainAxisAlignment: MainAxisAlignment.start,
                  //                     children: [
                  //                       Container(
                  //                         decoration: BoxDecoration(
                  //                             color: context.color.tertiaryColor,
                  //                             borderRadius:
                  //                             BorderRadius.circular(10)),
                  //                         width: s.maxWidth / 4,
                  //                         height: 50,
                  //                         child: Center(
                  //                             child: Text(property!['properyType']!
                  //                                 .translate(context))
                  //                                 .color(
                  //                                 context.color.buttonColor)),
                  //                       ),
                  //                       Text(
                  //                         "toArrow".translate(context),
                  //                       ),
                  //                       // Container(
                  //                       //   width: s.maxWidth / 4,
                  //                       //   decoration: BoxDecoration(
                  //                       //       color: context.color.tertiaryColor
                  //                       //           .withOpacity(0.4),
                  //                       //       borderRadius:
                  //                       //       BorderRadius.circular(10)),
                  //                       //   height: 50,
                  //                       //   child: Center(
                  //                       //       child: Text(_statusFilter(property!
                  //                       //           ['propery_type']!) ??
                  //                       //           "")
                  //                       //           .color(
                  //                       //           context.color.buttonColor)),
                  //                       // ),
                  //                     ],
                  //                   ),
                  //                 );
                  //               }),
                  //         );
                  //         // if (action == true) {
                  //         //   Future.delayed(Duration.zero, () {
                  //         //     context.read<UpdatePropertyStatusCubit>().update(
                  //         //       propertyId: property!['id'],
                  //         //       status: _getStatus(property!['properyType']),
                  //         //     );
                  //         //   });
                  //         // }
                  //       },
                  //       color: context.color.secondaryColor,
                  //       itemBuilder: (BuildContext context) {
                  //         return {
                  //           'changeStatus'.translate(context),
                  //         }.map((String choice) {
                  //           return PopupMenuItem<String>(
                  //             value: choice,
                  //             textStyle:
                  //             TextStyle(color: context.color.textColorDark),
                  //             child: Text(choice),
                  //           );
                  //         }).toList();
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  //         child: Icon(
                  //           Icons.more_vert_rounded,
                  //           color: context.color.tertiaryColor,
                  //         ),
                  //       ),
                  //     ),
                  //   const SizedBox(
                  //     width: 10,
                  //   )
                  // ]
              ),*/
              bottomNavigationBar: isPlayingYoutubeVideo == false
                  ? BottomAppBar(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: context.color.secondaryColor,
                      child: bottomNavBar()) : null,
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                            SizedBox(
                              height: 227.rh(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    if (gallary?.isNotEmpty ?? false) ...[
                                      PageView.builder(
                                        itemCount: (gallary?.length ?? 0) + 1,
                                        controller: _pageController,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {

                                          if (index == 0) {
                                            return GestureDetector(
                                              onTap: () {
                                                showGoogleMap = false;
                                                setState(() {});

                                                var images = [property!['image']!]
                                                    .followedBy(gallary!.map((e) => e.imageUrl).toList())
                                                    .toList();

                                                UiUtils.imageGallaryView(
                                                  context,
                                                  images: images,
                                                  initalIndex: index,
                                                  then: () {
                                                    showGoogleMap = true;
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.only(right: 13,left: 13),
                                                width: MediaQuery.of(context).size.width,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: UiUtils.getImage(
                                                    property!['image']!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: 227.rh(context),
                                                    showFullScreenImage: false,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          final galleryItem = gallary![index - 1];

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 13,left: 13),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(15),
                                              child: Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (galleryItem.isVideo == true) return;

                                                      showGoogleMap = false;
                                                      setState(() {});

                                                      var images = [property!['image']!]
                                                          .followedBy(gallary!.map((e) => e.imageUrl).toList())
                                                          .toList();

                                                      UiUtils.imageGallaryView(
                                                        context,
                                                        images: images,
                                                        initalIndex: index - 1,
                                                        then: () {
                                                          showGoogleMap = true;
                                                          setState(() {});
                                                        },
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: 227.rh(context),
                                                      child: galleryItem.isVideo == true
                                                          ? Container(
                                                        child: UiUtils.getImage(
                                                          youtubeVideoThumbnail,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                          : UiUtils.getImage(
                                                        galleryItem.imageUrl ?? "",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  if (galleryItem.isVideo == true)
                                                    Positioned.fill(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) {
                                                                return VideoViewScreen(
                                                                  videoUrl: galleryItem.image ?? "",
                                                                  flickManager: flickManager,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          color: Colors.black.withOpacity(0.3),
                                                          child: FittedBox(
                                                            fit: BoxFit.none,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: context.color.tertiaryColor.withOpacity(0.8),
                                                              ),
                                                              width: 30,
                                                              height: 30,
                                                              child: const Icon(
                                                                Icons.play_arrow,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )

                                    ]else GestureDetector(
                                      onTap: () {
                                        showGoogleMap = false;
                                        setState(() {});
                                        UiUtils.showFullScreenImage(
                                          context,
                                          provider: NetworkImage(
                                            property!['image']!,
                                          ),
                                          then: () {
                                            showGoogleMap = true;
                                            setState(() {});
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 13,left: 13),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: UiUtils.getImage(
                                            property!['image']!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 227.rh(context),
                                            showFullScreenImage: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                //     if (property?['gallary_images']?.isNotEmpty ?? false) ...[
                                //     PageView.builder(
                                //     itemCount: (property?['gallary_images']?.length ?? 0) + 1,
                                //     controller: _pageController,
                                //     scrollDirection: Axis.horizontal,
                                //     itemBuilder: (context, index) {
                                //       if (index == 0) {
                                //         return GestureDetector(
                                //           onTap: (){
                                //             showGoogleMap = false;
                                //             setState(() {});
                                //
                                //             var images = [property!['image']!]
                                //                 .followedBy(property?['gallary_images']!.map((e) => e['name']).toList())
                                //                 .toList();
                                //
                                //             UiUtils.imageGallaryView(
                                //               context,
                                //               images: images,
                                //               initalIndex: index,
                                //               then: () {
                                //                 showGoogleMap = true;
                                //                 setState(() {});
                                //               },
                                //             );
                                //           },
                                //           child: Container(
                                //             padding: const EdgeInsets.only(right: 13,left: 13),
                                //             width: MediaQuery.of(context).size.width,
                                //             decoration: BoxDecoration(
                                //               borderRadius: BorderRadius.circular(15),
                                //             ),
                                //             child: ClipRRect(
                                //               borderRadius: BorderRadius.circular(15),
                                //               child: UiUtils.getImage(
                                //                 property!['image']!,
                                //                 fit: BoxFit.cover,
                                //                 width: double.infinity,
                                //                 height: 227.rh(context),
                                //                 showFullScreenImage: false,
                                //               ),
                                //             ),
                                //           ),
                                //         );
                                //       }
                                //
                                // final galleryItem = property?['gallary_images']![index - 1];
                                //
                                // return Padding(
                                //   padding: const EdgeInsets.only(right: 13,left: 13),
                                //   child: ClipRRect(
                                //     borderRadius: BorderRadius.circular(10),
                                //     child: Stack(
                                //       children: [
                                //         GestureDetector(
                                //           onTap: () {
                                //
                                //             // if (property?['gallary_images']?[index].isVideo ==
                                //             //     true) return;
                                //             //
                                //             // showGoogleMap = false;
                                //             // setState(() {});
                                //             //
                                //             // var images = property?['gallary_images']
                                //             //     ?.map((e) => e.imageUrl)
                                //             //     .toList();
                                //             //
                                //             // UiUtils.imageGallaryView(
                                //             //   context,
                                //             //   images: images!,
                                //             //   initalIndex: index - 1,
                                //             //   then: () {
                                //             //     showGoogleMap = true;
                                //             //     setState(() {});
                                //             //   },
                                //             // );
                                //           },
                                //           child: SizedBox(
                                //             width: MediaQuery.of(context).size.width,
                                //             height: 227.rh(context),
                                //             child: galleryItem['isVideo'] == true
                                //                 ? Container(
                                //               child: UiUtils.getImage(
                                //
                                //                 youtubeVideoThumbnail,
                                //                 fit: BoxFit.cover,
                                //               ),
                                //             )
                                //                 : UiUtils.getImage(
                                //               galleryItem['name'] ?? "",
                                //               fit: BoxFit.cover,
                                //             ),
                                //           ),
                                //         ),
                                //         // if (galleryItem.isVideo == true)
                                //         //   Positioned.fill(
                                //         //     child: GestureDetector(
                                //         //       onTap: () {
                                //         //         Navigator.push(
                                //         //           context,
                                //         //           MaterialPageRoute(
                                //         //             builder: (context) {
                                //         //               return VideoViewScreen(
                                //         //                 videoUrl: galleryItem.image ?? "",
                                //         //                 flickManager: flickManager,
                                //         //               );
                                //         //             },
                                //         //           ),
                                //         //         );
                                //         //       },
                                //         //       child: Container(
                                //         //         color: Colors.black.withOpacity(0.3),
                                //         //         child: FittedBox(
                                //         //           fit: BoxFit.none,
                                //         //           child: Container(
                                //         //             decoration: BoxDecoration(
                                //         //               shape: BoxShape.circle,
                                //         //               color: context.color.tertiaryColor.withOpacity(0.8),
                                //         //             ),
                                //         //             width: 30,
                                //         //             height: 30,
                                //         //             child: Icon(
                                //         //               Icons.play_arrow,
                                //         //               color: Colors.white,
                                //         //             ),
                                //         //           ),
                                //         //         ),
                                //         //       ),
                                //         //     ),
                                //         //   ),
                                //       ],
                                //     ),
                                //   ),
                                // );
                                //                             },
                                //                           )]else
                                //     GestureDetector(
                                //       onTap: () {
                                //         showGoogleMap = false;
                                //         setState(() {});
                                //         UiUtils.showFullScreenImage(
                                //           context,
                                //           provider: NetworkImage(
                                //             property!['image']!,
                                //           ),
                                //           then: () {
                                //             showGoogleMap = true;
                                //             setState(() {});
                                //           },
                                //         );
                                //       },
                                //       child:Padding(
                                //         padding: const EdgeInsets.only(right: 13,left: 13),
                                //         child: ClipRRect(
                                //           borderRadius: BorderRadius.circular(15),
                                //           child: UiUtils.getImage(
                                //               property!['image'],
                                //             fit: BoxFit.cover,
                                //             width: double.infinity,
                                //             height: 227.rh(context),
                                //             showFullScreenImage: true,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                    // PositionedDirectional(
                                    //   top: 20,
                                    //   end: 20,
                                    //   child: LikeButtonWidget(
                                    //     onStateChange:
                                    //         (AddToFavoriteCubitState
                                    //     state) {
                                    //       if (state
                                    //       is AddToFavoriteCubitInProgress) {
                                    //         favoriteInProgress = true;
                                    //         setState(
                                    //               () {},
                                    //         );
                                    //       } else {
                                    //         favoriteInProgress = false;
                                    //         setState(
                                    //               () {},
                                    //         );
                                    //       }
                                    //     },
                                    //     property: property!,
                                    //   ),
                                    // ),
                                    Positioned(
                                      right: 20,
                                      top: 20,
                                      child: InkWell(
                                        onTap: () {
                                          GuestChecker.check(onNotGuest: () async {
                                            setState(() {
                                              likeLoading = true;
                                            });
                                            var body = {
                                              "type": property!['is_favourite'] == 1 ? 0 : 1,
                                              "project_id": property!['id']
                                            };
                                            var response = await Api.post(
                                                url: Api.addFavProject, parameter: body);
                                            if (!response['error']) {
                                              property!['is_favourite'] = (property!['is_favourite'] == 1 ? 0 : 1);
                                              setState(() {
                                                likeLoading = false;
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
                                                (likeLoading)
                                                    ? UiUtils.progress(width: 20, height: 20)
                                                    : property!['is_favourite'] == 1
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
                                    Positioned(
                                      right: 20,
                                      top: 60,
                                      child: InkWell(
                                        onTap: () {
                                          share(property!['slug_id'] ?? "");
                                        },
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
                                          child: Icon(
                                            Icons.share,
                                            color: context.color.tertiaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                 /*   PositionedDirectional(
                                      bottom: 5,
                                      end: 18,
                                      child: Visibility(
                                        visible:
                                        property?['image'] != "",
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              BlurredRouter(
                                                builder: (context) =>
                                                    PanaromaImageScreen(
                                                      imageUrl: property!
                                                      ['image']!,
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
                                    ),*/
                                    advertismentLable()
                                  ],
                                ),
                              ),
                            ),
                            if (gallary?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  (gallary?.length ?? 0) + 1,
                                      (index) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      alignment: Alignment.center,
                                      width: _currentImage == index ? 23 : 6.0,
                                      height: 6.0,
                                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: _currentImage == index
                                            ? const Color(0xff117af9)
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15,),
                              child: Wrap(
                                  direction: Axis.horizontal,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  alignment: WrapAlignment.start,
                                  children: [
                                // UiUtils.imageType(
                                //     property?.category!.image ?? "",
                                //     width: 18,
                                //     height: 18,
                                //     color: Constant.adaptThemeColorSvg
                                //         ? context.color.tertiaryColor
                                //         : null),

                                if(property!['project_details'][0]['furniture'] != null)
                                  Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfffff2c8),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Text(property!['project_details'][0]['furniture'], style: const TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500
                                      ),)
                                          .setMaxLines(lines: 1),
                                    ),
                                  ),
                                    if(property!['project_details'].length > 0)
                                      Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(7),
                                              color: const Color(0xff6c5555)),
                                          child: Text(
                                            property!['project_details'][0]['brokerage'] == 'yes' ? 'Brokerage' : 'No Brokerage'
                                                .toString()
                                                .translate(context),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11
                                            ),
                                          ),
                                        ),
                                      ),
                                if(property!['project_details'].length > 0)
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: context.color.tertiaryColor),
                                    child: Text(
                                      property!['project_details'][0]['project_status_name']
                                          .toString()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                    if(property!['code'].length > 0)
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xFFcff4fc)),
                                    child: Text(
                                      property!['code']
                                          .toString()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Color(0xff00557a),
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),

                                if(property!['project_details'].length > 0 && property!['project_details'][0]['gated_community'] == 'yes')
                                  Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(7),
                                          color: const Color(0xff6c5555)),
                                      child: Text(
                                        'Gated Community'
                                            .toString()
                                            .toLowerCase()
                                            .translate(context),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11
                                        ),
                                      ),
                                    ),
                                  ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['high_rise'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xff6c5555)),
                                    child: Text(
                                      'High-Rise Appartment'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['lake_view'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xff800020)),
                                    child: Text(
                                      'Lake View'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['near_by_metro'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xff3D3D3D)),
                                    child: Text(
                                      'Near Metro'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['veg_only'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xffA06392)),
                                    child: Text(
                                      'Veg Only'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['covered_parking'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xff785E46)),
                                    child: Text(
                                      'Covered Parking'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
                                      ),
                                    ),
                                  ),
                                ),
                                if(property!['project_details'].length > 0 && property!['project_details'][0]['open_parking'] == 'yes')
                                  Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        color: const Color(0xff334756)),
                                    child: Text(
                                      'Open Parking'
                                          .toString()
                                          .toLowerCase()
                                          .translate(context),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11
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
                              padding: const EdgeInsets.symmetric( horizontal: 15,),
                              child: Text(
                                property!['title']!,style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff333333)
                              ),),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            if(property!['min_price'] == null)
                              Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 15,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${property!['project_details'].length > 0 ? formatAmount(property!['project_details'][0]['avg_price'] ?? 0) : 0}'
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xff117af9),
                                          fontSize: 16,
                                          fontFamily: 'Robato',
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    //   child: Container(
                                    //     height: 12,
                                    //     width: 2,
                                    //     color: Colors.black54,
                                    //   ),
                                    // ),
                                    Text(
                                      '${property!['project_details'].length > 0 ? property!['project_details'][0]['size'].toInt() ?? 0 : '0'} Sq.ft',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if(property!['min_price'] != null)
                          ...[
                            Padding(
                              padding: const EdgeInsets.symmetric( horizontal: 15,),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${formatAmount(property!['min_price'] ?? 0)} - ${formatAmount(property!['max_price'] ?? 0)}'
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xff117af9),
                                        fontSize: 16,
                                        fontFamily: 'Robato',
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  if(property!['min_price'] != null)
                                    ...[   
                                      Row(
                                        children: [
                                          Text(
                                            '${property!['min_size']} - ${property!['max_size'].toInt()} Sq.ft'
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:  TextStyle(
                                                color:Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ],
                                      ),],
                                ],
                              ),
                            ),
                          ],


                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric( horizontal: 15,),
                              child: Row(
                                children: [
                                  Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                  const SizedBox(width: 5,),
                                  Expanded(
                                    child: Text(
                                      property!['address'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:  TextStyle(
                                          color:Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400
                                      ),),
                                  ),
                                ],
                              ),
                            ),

                            if(property!['customer'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            UiUtils.showFullScreenImage(context,
                                                provider:
                                                NetworkImage(widget.property?['profile'] ?? ""));
                                          },

                                          child: Container(
                                              width: 43,
                                              height: 43,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: const Color(0xffdfdfdf)
                                                  ),
                                                  borderRadius: BorderRadius.circular(50)),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: UiUtils.getImage(widget.property?['profile'] ?? "",
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
                                              const Text("Marketed by",style: TextStyle( color: Color(0xff7d7d7d),fontSize: 12,),),
                                              const SizedBox(height: 2,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      widget.property?['customer']?['company_name'] ?? "No Company Name",
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                      ),
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

                                  Text(getRelativeTimeString(DateTime.parse(property!['created_at'])),
                                    style: const TextStyle(
                                        color: Color(0xffa2a2a2),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400
                                    ),
                                  )

                                ],
                              ),
                            ),
                         const SizedBox(height: 15,),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              height: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration:  BoxDecoration(
                                color: const Color(0xffebedff), borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ],

                              ),
                              width: MediaQuery.sizeOf(context).width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/assets/Images/__offer.png",height: 28,),
                                  const SizedBox(width: 8,),
                                  const Text("Offer",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                                  const SizedBox(width: 5,),
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return Container(
                                        width: 1,
                                        height: 3,
                                        color: const Color(0xffa2a2a2),
                                        margin: const EdgeInsets.symmetric(vertical: 1),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 5,),
                                  Expanded(
                                    child: Text('${property!['project_details'][0]['offers']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:  TextStyle(
                                          color:Colors.grey[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 15,),
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
                            //         Text("Project Overview".translate(context),style: TextStyle(
                            //             fontSize: 14,
                            //             color: Color(0xff333333),
                            //             fontWeight: FontWeight.w600
                            //         ),),
                            //         SizedBox(height :10),
                            //         Wrap(
                            //           direction: Axis.horizontal,
                            //           crossAxisAlignment: WrapCrossAlignment.start,
                            //           runAlignment: WrapAlignment.start,
                            //           alignment: WrapAlignment.start,
                            //           children: List.generate(
                            //               property?['parameters']?.length ?? 0,
                            //                   (index) { Parameter? parameter = property?['parameters']![index];
                            //               bool isParameterValueEmpty =
                            //               (parameter?.value == "" ||
                            //                   parameter?.value == "0" ||
                            //                   parameter?.value == null ||
                            //                   parameter?.value == "null");
                            //
                            //               ///If it has no value
                            //               if (isParameterValueEmpty) {
                            //                 return const SizedBox.shrink();
                            //               }
                            //
                            //               return ConstrainedBox(
                            //                 constraints: BoxConstraints(
                            //                     minWidth:(context.screenWidth / 2) - 40),
                            //                 child: Padding(
                            //                   padding: const EdgeInsets.fromLTRB(
                            //                       0, 8, 8, 8),
                            //                   child: SizedBox(
                            //                     // height: 37,
                            //                     child: Row(
                            //                         crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                         mainAxisSize: MainAxisSize.min,
                            //                         children: [
                            //                           Container(
                            //                             width: 36.rw(context),
                            //                             height: 36.rh(context),
                            //                             alignment: Alignment.center,
                            //                             decoration: BoxDecoration(
                            //                                 color: context
                            //                                     .color.tertiaryColor
                            //                                     .withOpacity(0.2),
                            //                                 borderRadius:
                            //                                 BorderRadius.circular(
                            //                                     10)),
                            //                             child: SizedBox(
                            //                               height: 20.rh(context),
                            //                               width: 20.rw(context),
                            //                               child: FittedBox(
                            //                                 child: UiUtils.imageType(
                            //                                   parameter?.image ?? "",
                            //                                   fit: BoxFit.cover,
                            //                                   color: Constant
                            //                                       .adaptThemeColorSvg
                            //                                       ? context.color
                            //                                       .tertiaryColor
                            //                                       : null,
                            //                                 ),
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           SizedBox(
                            //                             width: 10.rw(context),
                            //                           ),
                            //                           Column(
                            //                             crossAxisAlignment:
                            //                             CrossAxisAlignment.start,
                            //                             mainAxisSize:
                            //                             MainAxisSize.min,
                            //                             children: [
                            //                               Text(parameter?.name ?? "")
                            //                                   .size(10)
                            //                                   .color(Color(0xff5d5d5d)),
                            //                               if (parameter
                            //                                   ?.typeOfParameter ==
                            //                                   "file") ...{
                            //                                 InkWell(
                            //                                   onTap: () async {
                            //                                     await urllauncher.launchUrl(
                            //                                         Uri.parse(
                            //                                             parameter!
                            //                                                 .value),
                            //                                         mode: LaunchMode
                            //                                             .externalApplication);
                            //                                   },
                            //                                   child: Text(
                            //                                     UiUtils
                            //                                         .getTranslatedLabel(
                            //                                         context,
                            //                                         "viewFile"),
                            //                                   ).underline().color(
                            //                                       context.color
                            //                                           .tertiaryColor),
                            //                                 ),
                            //                               } else if (parameter?.value
                            //                               is List) ...{
                            //                                 Text((parameter?.value
                            //                                 as List)
                            //                                     .join(","))
                            //                               } else ...[
                            //                                 if (parameter
                            //                                     ?.typeOfParameter ==
                            //                                     "textarea") ...[
                            //                                   SizedBox(
                            //                                     width: MediaQuery.of(
                            //                                         context)
                            //                                         .size
                            //                                         .width *
                            //                                         0.7,
                            //                                     child: Text(
                            //                                         "${parameter?.value}")
                            //                                         .size(12)
                            //                                         .bold(
                            //                                       weight:
                            //                                       FontWeight
                            //                                           .w600,
                            //                                     ),
                            //                                   )
                            //                                 ] else ...[
                            //                                   Text("${parameter?.value}")
                            //                                       .size(12)
                            //                                       .bold(
                            //                                     weight: FontWeight
                            //                                         .w500,
                            //                                   )
                            //                                 ]
                            //                               ]
                            //                             ],
                            //                           )
                            //                         ]),
                            //                   ),
                            //                 ),
                            //               );
                            //               }),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric( horizontal: 15,),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Project Overview".translate(context), style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600
                                    ),),
                                    const SizedBox(height :15),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Age of the property:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['project_age'] ?? '-'}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Total no of Units:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['total_units'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Total Project Area:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['size'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Launch Date:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['launch_date'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Possession Starts:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['possession_start'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Configurations :")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['configuration'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Rera No:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['rera_no'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: Text("Offers:")
                                    //             .size(11)
                                    //             .color(Color(0xff5d5d5d)),
                                    //       ),
                                    //       SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['offers']}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),


                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Avg Price:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['avg_price'] ?? '0'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Approved By:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['approved_by'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: const Text("Total Floors:")
                                                .size(11)
                                                .color(const Color(0xff5d5d5d)),
                                          ),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text("${property!['project_details'][0]['floors'] ?? '-'}")
                                                .size(11)
                                                .bold( weight: FontWeight.w500,),
                                          )
                                        ],
                                      ),
                                    ),

                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("City:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['city']}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Road Width:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['road_width'] ?? 0}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Project completed:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['project_completed'] ?? '-'}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Rate:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['rate_per_sqft'] ?? '-'}/sqft.")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Suitable for:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['suitable_for'] ?? '-'}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 10),
                                    //   child: Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: const Text("Project placed:")
                                    //             .size(11)
                                    //             .color(const Color(0xff5d5d5d)),
                                    //       ),
                                    //       const SizedBox(width: 10,),
                                    //       Expanded(
                                    //         child: Text("${property!['project_details'][0]['project_placed'] ?? '-'}")
                                    //             .size(11)
                                    //             .bold( weight: FontWeight.w500,),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // Text("Read More",style: TextStyle(
                                    //   fontSize: 13,
                                    //   fontWeight: FontWeight.w600,
                                    //   color: Color(0xff117af9),
                                    // ),),
                                  ],
                                ),
                              ),
                            ),

                            if(property!['project_details'][0]['highlights']!.isNotEmpty )
                            ...[
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 15,),
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfffffaf4),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Project Highlights".translate(context),style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w600
                                      ),),
                                      const SizedBox(height: 13, ),
                                      for(int i = 0; i < property!['project_details'][0]['highlights'].split(',').length; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Image.asset("assets/NewPropertydetailscreen/_-55.png",width: 13,height: 13,fit: BoxFit.cover,),
                                              const SizedBox(width: 10,),
                                              Expanded(
                                                child: Text("${property!['project_details'][0]['highlights'].split(',')[i]}")
                                                    .size(11)
                                                    .color(const Color(0xff5d5d5d)),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(
                              height: 15,
                            ),

                            if (property?['assignfacilities']
                                ?.isNotEmpty ??
                                false) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric( horizontal: 15,),
                                child: Text("Near by Places",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                  ),),
                              ),
                              const SizedBox(height: 10),
                               Padding(
                                padding: const EdgeInsets.only( left: 15,),
                                child: OutdoorFacilityListWidget(
                                  outdoorFacilityList:  List<AssignedOutdoorFacility>.from(
                                      (property!["assignfacilities"] as List).map((x) {
                                        return AssignedOutdoorFacility.fromJson({
                                          'id': x['id'],
                                          'property_id': x['property_id'],
                                          'facility_id': x['facility_id'],
                                          'distance': x['distance'],
                                          'created_at': x['created_at'],
                                          'updated_at': x['updated_at'],
                                          'image': x['outdoorfacilities']['image'],
                                          'name': x['outdoorfacilities']['name'],
                                        });
                                      })),),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                            ],


                            Padding(
                              padding: const EdgeInsets.symmetric( horizontal: 15,),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(UiUtils.getTranslatedLabel(
                                        context, "About this project"),style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600
                                    ),),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    ReadMoreText(
                                        text: property?['description'] ?? "",
                                        style: const TextStyle(
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
                                padding: const EdgeInsets.only( left: 15,right:15,bottom: 20),
                                child: SizedBox(
                                    width: _bannerAd?.size.width.toDouble(),
                                    height: _bannerAd?.size.height.toDouble(),
                                    child: AdWidget(ad: _bannerAd!)),
                              ),

                            // const SizedBox(
                            //   height: 20,
                            // ),


                            const SizedBox( height: 15,),
                            if (property?['gallary_images']?.isNotEmpty ?? false) ...[
                              Padding(
                                padding: const EdgeInsets.only( left: 15,right: 15),
                                child: Text(UiUtils.getTranslatedLabel(
                                  context, "Videos & Photos",),  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff333333),
                                    fontWeight: FontWeight.w600
                                ),),
                              ),
                              SizedBox(
                                height: 10.rh(context),
                              ),
                            ],
                            if (property?['gallary_images']?.isNotEmpty ?? false) ...[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only( left: 15,bottom: 15),
                                  child: Row(
                                      children: [
                                        if(property?['video_link'] != null && property?['video_link'] != '')
                                          Padding(
                                            padding: const EdgeInsets.only(right: 13),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(13),
                                              child: Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      // if (property?['gallary_images'].isVideo ==
                                                      //     true) return;
                                                      //
                                                      // //google map doesn't allow blur so we hide it:)
                                                      // showGoogleMap = false;
                                                      // setState(() {});
                                                      //
                                                      // var images = property?['gallary_images']
                                                      //     ?.map((e) => e.imageUrl)
                                                      //     .toList();
                                                      //
                                                      // UiUtils.imageGallaryView(
                                                      //   context,
                                                      //   images: images!,
                                                      //   initalIndex: index,
                                                      //   then: () {
                                                      //     showGoogleMap = true;
                                                      //     setState(() {});
                                                      //   },
                                                      // );
                                                    },
                                                    child: SizedBox(
                                                      width: 240.rw(context),
                                                      height: 150.rh(context),
                                                      child:
                                                      // property?['gallary_images']?[index]
                                                      //     .isVideo ==
                                                      //     true
                                                      //     ?
                                                      Container(
                                                        child: UiUtils.getImage(
                                                            property?['gallary_images'][0]['name'] ?? '',
                                                            fit:
                                                            BoxFit.cover),
                                                      ),
                                                      //     :
                                                      // UiUtils.getImage(
                                                      //     property?['gallary_images']?[index]['name']
                                                      //         ??
                                                      //         "",
                                                      //     fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  // if (property?['gallary_images']?[index].isVideo ==
                                                  //     true)
                                                  Positioned.fill(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(context,
                                                              MaterialPageRoute(
                                                                builder: (context) {
                                                                  return VideoViewScreen(
                                                                    videoUrl:
                                                                    property?['video_link'] ??
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
                                                              child: const Icon(
                                                                Icons.play_arrow,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                  // if (index == 3)
                                                  //   Positioned.fill(
                                                  //       child: GestureDetector(
                                                  //         onTap: () {
                                                  //           Navigator.push(context,
                                                  //               BlurredRouter(
                                                  //                 builder: (context) {
                                                  //                   return AllGallaryImages(
                                                  //                       youtubeThumbnail:
                                                  //                       property?['video_link'],
                                                  //                       images: property
                                                  //                       ?['gallary_images'] ??
                                                  //                           []);
                                                  //                 },
                                                  //               ));
                                                  //         },
                                                  //         child: Container(
                                                  //           alignment: Alignment.center,
                                                  //           color: Colors.black
                                                  //               .withOpacity(0.3),
                                                  //           child: Text(
                                                  //               "+${(property?['gallery']?.length ?? 0) - 3}")
                                                  //               .color(
                                                  //             Colors.white,
                                                  //           )
                                                  //               .size(
                                                  //               context.font.large)
                                                  //               .bold(),
                                                  //         ),
                                                  //       ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ...List.generate(
                                        (property?['gallary_images']?.length) ?? 0,
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
                                                      if (property?['gallary_images']?[index].isVideo ==
                                                          true) return;

                                                      //google map doesn't allow blur so we hide it:)
                                                      showGoogleMap = false;
                                                      setState(() {});

                                                      var images = property?['gallary_images']
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
                                                      child:
                                                      // property?['gallary_images']?[index]
                                                      //     .isVideo ==
                                                      //     true
                                                      //     ? Container(
                                                      //   child: UiUtils.getImage(
                                                      //       youtubeVideoThumbnail,
                                                      //       fit:
                                                      //       BoxFit.cover),
                                                      // )
                                                      //     :
                                                      UiUtils.getImage(
                                                          property?['gallary_images']?[index]['name']
                                                               ??
                                                              "",
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  // if (property?['gallary_images']?[index].isVideo ==
                                                  //     true)
                                                  //   Positioned.fill(
                                                  //       child: GestureDetector(
                                                  //         onTap: () {
                                                  //           Navigator.push(context,
                                                  //               MaterialPageRoute(
                                                  //                 builder: (context) {
                                                  //                   return VideoViewScreen(
                                                  //                     videoUrl:
                                                  //                     property?['gallary_images']?[index]
                                                  //                         .image ??
                                                  //                         "",
                                                  //                     flickManager:
                                                  //                     flickManager,
                                                  //                   );
                                                  //                 },
                                                  //               ));
                                                  //         },
                                                  //         child: Container(
                                                  //           color: Colors.black
                                                  //               .withOpacity(0.3),
                                                  //           child: FittedBox(
                                                  //             fit: BoxFit.none,
                                                  //             child: Container(
                                                  //               decoration: BoxDecoration(
                                                  //                   shape:
                                                  //                   BoxShape.circle,
                                                  //                   color: context.color
                                                  //                       .tertiaryColor
                                                  //                       .withOpacity(
                                                  //                       0.8)),
                                                  //               width: 30,
                                                  //               height: 30,
                                                  //               child: Icon(
                                                  //                 Icons.play_arrow,
                                                  //                 color: Colors.white,
                                                  //               ),
                                                  //             ),
                                                  //           ),
                                                  //         ),
                                                  //       )),
                                                  // if (index == 3)
                                                  //   Positioned.fill(
                                                  //       child: GestureDetector(
                                                  //         onTap: () {
                                                  //           Navigator.push(context,
                                                  //               BlurredRouter(
                                                  //                 builder: (context) {
                                                  //                   return AllGallaryImages(
                                                  //                       youtubeThumbnail:
                                                  //                       youtubeVideoThumbnail,
                                                  //                       images: property
                                                  //                       ?['gallery'] ??
                                                  //                           []);
                                                  //                 },
                                                  //               ));
                                                  //         },
                                                  //         child: Container(
                                                  //           alignment: Alignment.center,
                                                  //           color: Colors.black
                                                  //               .withOpacity(0.3),
                                                  //           child: Text(
                                                  //               "+${(property?['gallery']?.length ?? 0) - 3}")
                                                  //               .color(
                                                  //             Colors.white,
                                                  //           )
                                                  //               .size(
                                                  //               context.font.large)
                                                  //               .bold(),
                                                  //         ),
                                                  //       ))
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
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
                            if(property!['customer'] != null)
                            Padding(
                              padding: const EdgeInsets.only( left: 15,right: 15),
                              child: Text(UiUtils.getTranslatedLabel(
                                  context, "${widget.property?['customer']['role_id'] == 1 ? 'Owner' : widget.property?['customer']['role_id'] == 2 ? 'Agent' : 'Builder'} Profile"))
                                  .color(const Color(0xff333333))
                                  .size(14)
                                  .bold(weight: FontWeight.w600),
                            ),

                            if(property!['customer'] != null)
                              CusomterProfileWidget1(
                                data: property!['customer'], propertyID: widget.property!['id'],
                                reraId:  "${widget.property!['project_details']?.isNotEmpty == true ? widget.property!['project_details'][0]['rera_no'] ?? '' : ''}",
                                roleId: widget.property?['customer']['role_id'],
                              ),
                            Padding(
                              padding:const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: const Text("Property have inaccurate data ?",style: TextStyle(fontSize: 13),),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                            ),
                                            contentPadding: const EdgeInsets.all(0),
                                            content: ReportPropertyDialog(propertyID: widget.property!['id']!),
                                          );
                                        },
                                      );
                                      // showModalBottomSheet(
                                      //   context: context,
                                      //   shape: const RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      //   ),
                                      //   builder: (BuildContext context) {
                                      //     return  ReportPropertyBottomSheet(context,property!.id!,);
                                      //   },
                                      // );
                                    },
                                    child: Container(
                                      height: 35,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: const Color(0xffffe4e4)
                                      ),child: const Text("Report",style: TextStyle(color: Colors.red,fontSize: 13),),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if(property?['latitude'] != null && property?['longitude'] != null && property?['latitude'] != '' && property?['longitude'] != '')
                              Padding(
                                padding: const EdgeInsets.only(right: 15, left: 15),
                                child: SizedBox(
                                  height: 150,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: GoogleMap(
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
                                                double.parse((property?['latitude'] ?? "0.0")),
                                                double.parse((property?['longitude'] ?? "0.0"))))
                                      },
                                      mapType: AppSettings.googleMapType,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          double.parse(
                                            (property?['latitude'] ?? "0.0"),
                                          ),
                                          double.parse(
                                            (property?['longitude'] ?? "0.0"),
                                          ),
                                        ),
                                        zoom: 14.4746,
                                      ),
                                      onMapCreated: (GoogleMapController controller) {
                                        // if (!widget._controller.isCompleted) {
                                        //   widget._controller.complete(controller);
                                        // }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            
                            if(property!['amenity'] != null && property!['amenity'].length > 0)
                             ...[
                               Padding(
                                 padding: const EdgeInsets.only( left: 15,right: 15,top: 15),
                                 child: Text(UiUtils.getTranslatedLabel(
                                     context, "Amenities"),
                                   style: const TextStyle(
                                       fontSize: 14,
                                       color: Color(0xff333333),
                                       fontWeight: FontWeight.w600
                                   ),
                                 ),
                               ),
                               GridView.builder(
                                 padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                 shrinkWrap: true,
                                 itemCount: property!['amenity'].length,
                                 physics: const NeverScrollableScrollPhysics(),
                                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: 3,
                                   crossAxisSpacing: 8,
                                   mainAxisSpacing: 8,
                                   childAspectRatio: 1 / 0.7,
                                 ),
                                 itemBuilder: (context, index) {
                                   final Map<String, dynamic> griddata = property!['amenity'][index];
                                   return GestureDetector(
                                     onTap: () {
                                     },
                                     child: Container(
                                       padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                       decoration: BoxDecoration(
                                         color: const Color(0xffebf4ff),
                                         borderRadius: BorderRadius.circular(10),
                                       ),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Container(
                                             padding: const EdgeInsets.only(left: 10,right: 10,top: 6,bottom: 6),
                                             decoration: const BoxDecoration(
                                               color: Colors.white,
                                               borderRadius: BorderRadius.only(
                                                 bottomLeft: Radius.circular(10),
                                                 bottomRight: Radius.circular(10),
                                               ),
                                             ),
                                             child: Container(
                                               width: 23, height: 23,
                                               child: UiUtils.networkSvg(griddata["image"], fit: BoxFit.cover,color: const Color(0xff117af9)),
                                             ),
                                             // child: Image.asset(griddata["image"],width: 23,height: 23,),
                                           ),
                                           Text(
                                             "${griddata["name"]}",
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                           )
                                               .size(11)
                                               .color(const Color(0xff5d5d5d))
                                         ],
                                       ),
                                     ),
                                   );
                                 },
                               ),
                             ],
                            if (property != null && property?['documents'] != null && property?['documents'].length > 0)
                              Padding(
                              padding: const EdgeInsets.only( left: 15,right: 15,top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(UiUtils.getTranslatedLabel(
                                      context, "Download Broucher"),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  if(downloading)
                                  Container(
                                    width: 150,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.white,
                                      border: Border.all(
                                        width: 1,
                                        color: const Color(0xff117af9),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 5,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ],
                                    ),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                      backgroundColor: Colors.grey[200],
                                      minHeight: 10,
                                    ),
                                  ),
                                  if(!downloading)
                                  InkWell(
                                    onTap: () async {
                                      final Directory? downloadsDirectory = await getExternalStorageDirectory();

                                      final taskId = await FlutterDownloader.enqueue(
                                        url: property?['documents'][0]['name'],
                                        headers: {},
                                        saveInPublicStorage: true,// optional: header send with url (auth token etc)
                                        savedDir: '${downloadsDirectory!.path}',
                                        showNotification: true, // show download progress in status bar (for Android)
                                        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                                      );
                                    },
                                    child: Container(
                                      height: 30,
                                      padding: const EdgeInsets.only( left: 10, right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xff117af9),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 5,
                                            color: Colors.black.withOpacity(0.1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset("assets/NewPropertydetailscreen/_-76.png",width: 17,height: 17,),
                                          const SizedBox(width: 5,),
                                          const Text('Download',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xff117af9),
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.rh(context),
                            ),
                            if(property != null && property?['plans'] != null &&property?['plans']?.isNotEmpty)
                              ...[
                                Padding(
                                  padding: const EdgeInsets.only( left: 15,right: 15),
                                  child: Text(UiUtils.getTranslatedLabel(
                                    context, "Floor Plans",), style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only( left: 15,bottom: 15),
                                    child: Row(
                                      children: [
                                        ...List.generate(
                                          (property?['plans']?.length) ?? 0,
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
                                                        if (property?['plans']?[index].isVideo ==
                                                            true) return;

                                                        //google map doesn't allow blur so we hide it:)
                                                        showGoogleMap = false;
                                                        setState(() {});

                                                        var images = property?['plans']
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
                                                        child:
                                                        UiUtils.getImage(
                                                            property?['plans']?[index]['document']
                                                                ??
                                                                "",
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    PositionedDirectional(
                                                      bottom: 6,
                                                      start: 6,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5,),
                                                        height: 20,
                                                        decoration:  BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius:
                                                          BorderRadius.circular(4),
                                                        ),
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          property?['plans']?[index]['title'],
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
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                              ],

                            if(property?['project_details'][0]['payment_plan'] != null&&property?['project_details'][0]['payment_plan'].isNotEmpty)
                            ...[
                              Padding(
                                padding: const EdgeInsets.only( left: 15,right: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Image.asset("assets/assets/Images/__brouchre.png",height: 35,),
                                          const SizedBox(width: 5,),
                                          SizedBox(
                                            width:MediaQuery.of(context).size.width/2,
                                            child: Text(UiUtils.getTranslatedLabel(
                                                context, "Download Payment Plans"),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff333333),
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        // downloadFileToDownloads(property?['project_details'][0]['payment_plan'], 2);
                                        final Directory? downloadsDirectory = await getExternalStorageDirectory();

                                        final taskId = await FlutterDownloader.enqueue(
                                          url: property?['project_details'][0]['payment_plan'],
                                          headers: {},
                                          saveInPublicStorage: true,// optional: header send with url (auth token etc)
                                          savedDir: '${downloadsDirectory!.path}',
                                          showNotification: true, // show download progress in status bar (for Android)
                                          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                                        );
                                      },
                                      child: Container(
                                        height: 30,
                                        padding: const EdgeInsets.only( left: 10, right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xff117af9),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: const Offset(0, 1),
                                              blurRadius: 5,
                                              color: Colors.black.withOpacity(0.1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset("assets/NewPropertydetailscreen/_-76.png",width: 17,height: 17,),
                                            const SizedBox(width: 5,),
                                            const Text('Download',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xff117af9),
                                                  fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                            if (property?['project_details'] != null &&
                                property!['project_details'].isNotEmpty &&
                                property!['project_details'][0]['approved_banks'] != null &&
                                property!['project_details'][0]['approved_banks'].isNotEmpty)
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only( left: 15,right: 15),
                                  child: Text(UiUtils.getTranslatedLabel(
                                    context, "Approved Banks",), style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                                GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio:2/1.3,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0,
                                  ),
                                  itemCount: property?['project_details'][0]['approved_banks'].length,
                                  itemBuilder: (context, index) {
                                    final item = property?['project_details'][0]['approved_banks'][index];
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xffe5e5e5),
                                            width: 1
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),alignment: Alignment.center,
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            item['image']!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },

                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),

                            // Padding(
                            //   padding: const EdgeInsets.only( left: 15,right: 15),
                            //   child: Text(UiUtils.getTranslatedLabel(
                            //       context, "Builder"))
                            //       .color(context.color.textColorDark)
                            //       .size(context.font.large)
                            //       .bold(weight: FontWeight.w600),
                            // ),

                            // const SizedBox(
                            //   height: 15,
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only( left: 15,right: 15),
                            //   child: SizedBox(
                            //     height: 150,
                            //     child: ClipRRect(
                            //       borderRadius: BorderRadius.circular(10),
                            //       child: GoogleMapScreen(
                            //           property: PropertyModel.fromMap(property!),
                            //           kInitialPlace:_kInitialPlace,
                            //           controller:_controller
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                            //                             property: PropertyModel.fromMap(property!),
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
                       /*     const SizedBox(
                              height: 5,
                            ),*/
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(15),
                            //       boxShadow: [
                            //         const BoxShadow(
                            //           color: Color(0xfff0f0f0),
                            //           offset: Offset(0, 2),
                            //           blurRadius: 2.0,
                            //           spreadRadius: 2.0,
                            //         ),
                            //       ],
                            //     ),
                            //     padding: const EdgeInsets.only(left: 15,right: 15,top: 15, bottom: 15),
                            //     child: Column(
                            //       children: [
                            //         Row(
                            //           children: [
                            //             Expanded(
                            //               child: Row(
                            //                 children: [
                            //                   if(property!['customer'] != null)
                            //                     GestureDetector(
                            //                     onTap: () {
                            //                       UiUtils.showFullScreenImage(context,
                            //                           provider:
                            //                           NetworkImage(property!['customer']['profile']));
                            //                     },
                            //
                            //                     child: Container(
                            //                         width: 80,
                            //                         height: 80,
                            //                         clipBehavior: Clip.antiAlias,
                            //                         decoration: BoxDecoration(
                            //                             color: Colors.grey.shade200,
                            //                             border: Border.all(
                            //                                 width: 1,
                            //                                 color: const Color(0xffdfdfdf)
                            //                             ),
                            //                             borderRadius: BorderRadius.circular(50)),
                            //                         child: ClipRRect(
                            //                           borderRadius: BorderRadius.circular(50),
                            //                           child: UiUtils.getImage(property!['customer']['profile'] ?? "",
                            //                               fit: BoxFit.cover),
                            //                         )
                            //
                            //                       //  CachedNetworkImage(
                            //                       //   imageUrl: widget.propertyData?.customerProfile ?? "",
                            //                       //   fit: BoxFit.cover,
                            //                       // ),
                            //
                            //                     ),
                            //                   ),
                            //                   if(property!['customer'] != null)
                            //                     const SizedBox(
                            //                       width: 10,
                            //                     ),
                            //                   if(property!['customer'] != null)
                            //                    Expanded(
                            //                     child: Column(
                            //                       crossAxisAlignment: CrossAxisAlignment.start,
                            //                       children: [
                            //                         Text(property!['customer']['name'] ?? "")
                            //                             .size(17)
                            //                             .color(const Color(0xff4c4c4c))
                            //                             .bold(),
                            //                         const SizedBox(height: 5,),
                            //                         Row(
                            //                           children: [
                            //                             Image.asset("assets/NewPropertydetailscreen/__rara.png",width: 13,height: 13,fit: BoxFit.cover,),
                            //                             const SizedBox(width: 2,),
                            //                             const Text("RERA ID: ",
                            //                               style: TextStyle(
                            //                                   fontSize: 9,
                            //                                   fontWeight: FontWeight.w500,
                            //                                   color: Color(0xff009681)
                            //                               ),
                            //                             ),
                            //                             const Text("TN/29/A/0049/2019",
                            //                               style: TextStyle(
                            //                                   fontSize: 9,
                            //                                   fontWeight: FontWeight.w500,
                            //                                   color: Colors.black
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                         // SizedBox(height: 5,),
                            //                         // Row(
                            //                         //   children: [
                            //                         //     Text("42",
                            //                         //       style: TextStyle(
                            //                         //           fontSize: 18,
                            //                         //           fontWeight: FontWeight.w500,
                            //                         //           color: Colors.black
                            //                         //       ),
                            //                         //     ),
                            //                         //     SizedBox(width: 5,),
                            //                         //     Text("Total Projects",
                            //                         //       style: TextStyle(
                            //                         //           fontSize: 9,
                            //                         //           fontWeight: FontWeight.w500,
                            //                         //           color: Colors.black38
                            //                         //       ),
                            //                         //     ),
                            //                         //     SizedBox(width: 10,),
                            //                         //     Container(height: 15, width: 2, color: Colors.black45),
                            //                         //     SizedBox(width: 10,),
                            //                         //     Text("8",
                            //                         //       style: TextStyle(
                            //                         //           fontSize: 18,
                            //                         //           fontWeight: FontWeight.w500,
                            //                         //           color: Colors.black
                            //                         //       ),
                            //                         //     ),
                            //                         //     SizedBox(width: 5,),
                            //                         //     Text("In This City",
                            //                         //       style: TextStyle(
                            //                         //           fontSize: 9,
                            //                         //           fontWeight: FontWeight.w500,
                            //                         //           color: Colors.black38
                            //                         //       ),
                            //                         //     ),
                            //                         //   ],
                            //                         // ),
                            //                       ],
                            //                     ),
                            //                   )
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //         const SizedBox(height: 10),
                            //         Row(
                            //           children: [
                            //             Expanded(
                            //               child: InkWell(
                            //                 onTap: () async {
                            //                   var response = await Api.post(url: Api.interestedProjects, parameter: {
                            //                     'project_id': widget.property!['id'],
                            //                     'type': 1,
                            //                   });
                            //                   if(!response['error']) {
                            //                     HelperUtils.showSnackBarMessage(
                            //                         context, UiUtils.getTranslatedLabel(context, response['message']),
                            //                         type: MessageType.success, messageDuration: 3);
                            //                     HelperUtils.showSnackBarMessage(
                            //                         context, UiUtils.getTranslatedLabel(context, 'Our Executive will reach you shortly!'),
                            //                         type: MessageType.success, messageDuration: 5);
                            //                   }
                            //                 },
                            //                 child: Container(
                            //                   padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
                            //                   decoration: BoxDecoration(
                            //                       color: Colors.white,
                            //                       borderRadius: BorderRadius.circular(30),
                            //                       border: Border.all(
                            //                           width: 1,
                            //                           color: const Color(0xff2e8af9)
                            //                       )
                            //                   ),
                            //                   child: const Center(
                            //                     child: Text("Request a Callback",style: TextStyle(
                            //                         color: Color(0xff2e8af9),
                            //                         fontSize: 12,
                            //                         fontWeight: FontWeight.w500
                            //                     ),),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
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
                            // const SizedBox(
                            //   height: 15,
                            // ),

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

                            // if (Constant.showExperimentals &&
                            //     !reportedProperties
                            //         .contains(widget.property!['id']) &&
                            //     widget.property!['addedBy'].toString() !=
                            //         HiveUtils.getUserId())
                            //   Padding(
                            //     padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                            //     child: ReportProjectButton(
                            //       propertyId: property!['id']!,
                            //       onSuccess: () {
                            //         setState(
                            //               () {},
                            //         );
                            //       },
                            //     ),
                            //     ),
                            //   )
                          ],
                        ),
                      const SizedBox(height: 10,),
                      if (similarIsLoading)
                        Container(
                            color: const Color(0xffebf4ff),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 15,right: 15),
                                child: Row(
                                  children: [
                                    Text("Similar Projects",
                                      style: TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                child: buildPropertiesShimmer(context, 2),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        )
                     else if (similarProjectsList.isNotEmpty)
                        Container(
                          color: const Color(0xffebf4ff),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Similar Projects",
                                      style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 240,
                                child: ListView.separated(
                                  separatorBuilder: (context,index)=>const SizedBox(width:10),
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: similarProjectsList.length.clamp(0, 10),
                                  itemBuilder: (context, index) {
                                    final project = similarProjectsList[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProjectDetails(
                                              property: project,
                                              fromMyProperty: true,
                                              fromCompleteEnquiry: true,
                                              fromSlider: false,
                                              fromPropertyAddSuccess: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xffe0e0e0),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(15),
                                                    topLeft: Radius.circular(15),
                                                  ),
                                                  child: UiUtils.getImage(
                                                    project['image'] ?? "",
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    height: 130,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 8,
                                                  top: 8,
                                                  child: Row(
                                                    children: [
                                                      if(similarProjectsList![index]['gallary_images'] != null)
                                                        ...[
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(context,
                                                                  BlurredRouter(
                                                                    builder: (context) {
                                                                      return AllGallaryImages(
                                                                          images: similarProjectsList![index]['gallary_images'] ?? [],
                                                                          isProject: true);
                                                                    },
                                                                  ));
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
                                                                  )
                                                                ],
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  const Icon(
                                                                      Icons.image,
                                                                      color: Color(0xffe0e0e0),
                                                                      size: 15
                                                                  ),
                                                                  const SizedBox(width: 3,),
                                                                  Text('${similarProjectsList[index]['gallary_images']!.length}',
                                                                    style: const TextStyle(
                                                                        color: Color(0xffe0e0e0),
                                                                        fontSize: 10
                                                                    ),),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8,),
                                                        ],
                                                      InkWell(
                                                        onTap: () {
                                                          GuestChecker.check(onNotGuest: () async {
                                                            setState(() {
                                                              likeLoadingg[index] = true;
                                                            });
                                                            var body = {
                                                              "type": similarProjectsList[index]['is_favourite'] == 1 ? 0 : 1,
                                                              "project_id": similarProjectsList[index]['id']
                                                            };
                                                            var response = await Api.post(
                                                                url: Api.addFavProject, parameter: body);
                                                            if (!response['error']) {
                                                              similarProjectsList[index]['is_favourite'] = (similarProjectsList[index]['is_favourite'] == 1 ? 0 : 1);
                                                              setState(() {
                                                                likeLoadingg[index] = false;
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
                                                                (likeLoadingg[index])
                                                                    ? UiUtils.progress(width: 20, height: 20)
                                                                    : similarProjectsList[index]['is_favourite'] == 1
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

                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    project['title'] ?? '',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xff333333),
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if(similarProjectsList[index]['min_price'] == null)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '₹${similarProjectsList[index]['project_details'].length > 0 ? formatAmount(similarProjectsList[index]['project_details'][0]['avg_price'] ?? 0) : 0}'
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
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
                                                          '${(similarProjectsList[index]['project_details'].isNotEmpty && similarProjectsList[index]['project_details'][0]['size'] != null)
                                                              ? int.tryParse(similarProjectsList[index]['project_details'][0]['size'].toString()) ?? 0
                                                              : 0} Sq.ft',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if(similarProjectsList[index]['min_price'] != null)
                                                    ...[
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '₹${formatAmount(similarProjectsList[index]['min_price'] ?? 0)} - ${formatAmount(similarProjectsList[index]['max_price'] ?? 0)}'
                                                                .toString(),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                                color: Colors.black87,
                                                                fontSize: 12,
                                                                fontFamily: 'Robato',
                                                                fontWeight: FontWeight.w500
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/Home/__location.png",
                                                        width: 15,
                                                        fit: BoxFit.cover,
                                                        height: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          project['address'] ?? '',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),



                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "${similarProjectsList[index]['project_details']?.isNotEmpty == true ? similarProjectsList[index]['project_details'][0]['project_status_name'] ?? '' : ''}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xffa2a2a2),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),


                      if (agentPropertiesIsLoading )
                        Container(
                          color: const Color(0xffebf4ff),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(left: 15,right: 15,top: 15),
                                child: Row(
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
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                child: buildPropertiesShimmer(context, 2),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                    else if (agentProjectsList.isNotEmpty)
                        Container(
                          color: const Color(0xffebf4ff),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Other Project By Agent",
                                      style: TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 240,
                                child: ListView.separated(
                                  separatorBuilder: (context,index)=>const SizedBox(width:10),
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: agentProjectsList.length.clamp(0, 10),
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProjectDetails(
                                              property: agentProjectsList[i],
                                              fromMyProperty: true,
                                              fromCompleteEnquiry: true,
                                              fromSlider: false,
                                              fromPropertyAddSuccess: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xffe0e0e0),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(15),
                                                    topLeft: Radius.circular(15),
                                                  ),
                                                  child: UiUtils.getImage(
                                                    agentProjectsList[i]['image'] ?? "",
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    height: 130,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 8,
                                                  top: 8,
                                                  child: Row(
                                                    children: [
                                                      if(agentProjectsList[i]['gallary_images'] != null)
                                                        ...[
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(context,
                                                                  BlurredRouter(
                                                                    builder: (context) {
                                                                      return AllGallaryImages(
                                                                          images: agentProjectsList[i]['gallary_images'] ?? [],
                                                                          isProject: true);
                                                                    },
                                                                  ));
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
                                                                  )
                                                                ],
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  const Icon(
                                                                      Icons.image,
                                                                      color: Color(0xffe0e0e0),
                                                                      size: 15
                                                                  ),
                                                                  const SizedBox(width: 3,),
                                                                  Text('${agentProjectsList[i]['gallary_images']!.length}',
                                                                    style: const TextStyle(
                                                                        color: Color(0xffe0e0e0),
                                                                        fontSize: 10
                                                                    ),),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8,),
                                                        ],
                                                      InkWell(
                                                        onTap: () {
                                                          GuestChecker.check(onNotGuest: () async {
                                                            setState(() {
                                                              likeLoadingg2[i] = true;
                                                            });
                                                            var body = {
                                                              "type": agentProjectsList[i]['is_favourite'] == 1 ? 0 : 1,
                                                              "project_id": agentProjectsList[i]['id']
                                                            };
                                                            var response = await Api.post(
                                                                url: Api.addFavProject, parameter: body);
                                                            if (!response['error']) {
                                                              agentProjectsList[i]['is_favourite'] = (agentProjectsList[i]['is_favourite'] == 1 ? 0 : 1);
                                                              setState(() {
                                                                likeLoadingg2[i] = false;
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
                                                                (likeLoadingg2[i])
                                                                    ? UiUtils.progress(width: 20, height: 20)
                                                                    : agentProjectsList[i]['is_favourite'] == 1
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

                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "${agentProjectsList[i]['title']}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Color(0xff333333),
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w500),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if(agentProjectsList[i]['min_price'] == null)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '₹${agentProjectsList[i]['project_details'].length > 0 ? formatAmount(agentProjectsList[i]['project_details'][0]['avg_price'] ?? 0) : 0}'
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
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
                                                          '${(agentProjectsList[i]['project_details'].isNotEmpty && agentProjectsList[i]['project_details'][0]['size'] != null)
                                                              ? int.tryParse(agentProjectsList[i]['project_details'][0]['size'].toString()) ?? 0
                                                              : 0} Sq.ft',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.w500
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if(agentProjectsList[i]['min_price'] != null)
                                                    ...[
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '₹${formatAmount(agentProjectsList[i]['min_price'] ?? 0)} - ${formatAmount(agentProjectsList[i]['max_price'] ?? 0)}'
                                                                .toString(),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                                color: Colors.black87,
                                                                fontSize: 12,
                                                                fontFamily: 'Robato',
                                                                fontWeight: FontWeight.w500
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  const SizedBox(height: 6),
                                                  // const SizedBox(height: 6),
                                                  // Row(
                                                  //   children: [
                                                  //     Text(
                                                  //       formatAmount(agentProjectsList[i]['project_details'][0]['avg_price']).formatAmount(prefix: true,),
                                                  //       maxLines: 1,
                                                  //       overflow: TextOverflow.ellipsis,
                                                  //       style: const TextStyle(
                                                  //           color: Color(0xff333333),
                                                  //           fontSize: 11,
                                                  //           fontFamily: 'Robato',
                                                  //           fontWeight: FontWeight.w500),
                                                  //     ),
                                                  //     const SizedBox(width: 15),
                                                  //   ],
                                                  // ),
                                                  // const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/Home/__location.png",
                                                        width: 15,
                                                        fit: BoxFit.cover,
                                                        height: 15,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          "${agentProjectsList[i]['address']}",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 10.5,
                                                              fontWeight: FontWeight.w400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "${agentProjectsList[i]['project_details']?.isNotEmpty == true ? agentProjectsList[i]['project_details'][0]['project_status_name'] ?? '' : ''}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xffa2a2a2),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      //here
                      SizedBox(
                        height: 20.rh(context),
                      ),
                    ],
                  ),
                ),
              ),
            )),
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


  Widget advertismentLable() {
    if (property?['promoted'] == false || property?['promoted'] == null) {
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

  Widget ReportPropertyDialog({required int propertyID}) {
    List<Map<String, dynamic>> reportCheckboxListWithOther = List.from(reportCheckboxList)
      ..add({'id': 0, 'reason': 'Other'});

    TextEditingController controller = TextEditingController();
    String errorText = '';

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  height: 6,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Report Property",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Reasons",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xfff4f5f4),borderRadius: BorderRadius.circular(10)),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: reportCheckboxListWithOther.length,
                        itemBuilder: (context, index) {
                          final reason = reportCheckboxListWithOther[index];
                          final reasonId = reason['id'];
                          return Container(
                            alignment: Alignment.centerLeft,
                            height: 45,
                            child: CheckboxListTile(
                              title: Text(
                                reason['reason'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: selectedPropertyId == reasonId,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedPropertyId = reasonId;
                                  } else {
                                    selectedPropertyId = null;
                                  }
                                  errorText = '';
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedPropertyId == 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextFormField(
                          controller: controller,
                          style: const TextStyle(),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Write your reason here",
                            hintStyle: TextStyle(fontSize: 13),
                            contentPadding: EdgeInsets.only(bottom: 5),
                          ),
                        ),
                      ),
                    if(errorText.isNotEmpty)
                      Row(
                        children: [
                          const SizedBox(height: 5),
                          Text(errorText,style: const TextStyle(fontSize: 12,color: Colors.red),),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffff1e1e),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                errorText = '';
                              });
                              if (selectedPropertyId == null) {
                                setState(() {
                                  errorText = "Please select a reason for reporting.";
                                });
                                return;
                              }

                              if (selectedPropertyId == 0 && controller.text.isEmpty) {
                                setState(() {
                                  errorText = 'Please provide a reason when selecting "Other".';
                                });
                                return;
                              }
                              var response = await Api.post(url: Api.reportReason, parameter: {
                                'property_id': propertyID,
                                'reason_id': selectedPropertyId,
                                'other_message': selectedPropertyId == 0 ? controller.text : "",
                              });
                              if (!response['error']) {
                                Navigator.pop(context);
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(context, response['message']),
                                  type: MessageType.success,
                                  messageDuration: 3,
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xff117af9),
                              ),
                              child: const Text(
                                "Report",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (!HiveUtils.isGuest()) {
      if (int.parse(HiveUtils.getUserId() ?? "0") == property?  ['addedBy']) {
        return SizedBox(
          height: 65.rh(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
              builder: (context, state) {
                PropertyModel? model;

                if (state is FetchMyPropertiesSuccess) {
                  model = state.myProperty
                      .where((element) => element.id == property?['id'])
                      .first;
                }

                // model ??= widget.property;

                var isPromoted = (model?.promoted);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!HiveUtils.isGuest()) ...[
                      if (isPromoted == false &&
                          (property?['status'].toString() != "0")) ...[
                        Expanded(
                            child: UiUtils.buildButton(
                              context,
                              disabled: (property?['status'].toString() == "0"),
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
                                category: property?['category']['category'],
                                id: property?['category']['id']!.toString(),
                                image: property?['category']?.image,
                                parameterTypes: {
                                  "parameters": property?['parameters']
                                      ?.map((e) => e.toMap())
                                      .toList()
                                },
                              )
                            });
                            Navigator.pushNamed(
                                context, Routes.addPropertyDetailsScreen,
                                arguments: {
                                  "details": property
                                  // "details": {
                                  //   "id": property?['id'],
                                  //   "catId": property?['category']['id'],
                                  //   "propType": property?['properyType'],
                                  //   "name": property?['title'],
                                  //   "desc": property?['description'],
                                  //   "city": property?['city'],
                                  //   "state": property?['state'],
                                  //   "country": property?['country'],
                                  //   "latitude": property?['latitude'],
                                  //   "longitude": property?['longitude'],
                                  //   "address": property?['address'],
                                  //   "client": property?['clientAddress'],
                                  //   "price": property?['price'],
                                  //   'parms': property?['parameters'],
                                  //   "images": property?['gallery']
                                  //       ?.map((e) => e['imageUrl'])
                                  //       .toList(),
                                  //   "gallary_with_id": property?['gallery'],
                                  //   "rentduration": property?['rentduration'],
                                  //   "assign_facilities":
                                  //   property?['assignedOutdoorFacility'],
                                  //   "titleImage": property?['titleImage']
                                  // }
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
                                property?['status'].toString() == "1";

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
                                      .delete(property!['id']!);
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
      height: 65.rh(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: property != null && property!['view_contacts'] != 0 && showContact ? Row(
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
              setState(() {
                isLoading = true;
              });
              var response = await Api.post(url: Api.apiViewContact, parameter: {
                'property_id': '',
                'project_id': property!['id']
              });
              setState(() {
                isLoading = false;
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
            child: Center(child:isLoading
                ? const Text('Loading...').size(context.font.large)
                .bold().color(const Color(0xff117af9))
                :  const Text('View Contact').size(context.font.large)
                .bold().color(const Color(0xff117af9)),)),
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
    Constant.interestedPropertyIds.contains(widget.property?['id']);

    /// default icon
    dynamic icon = AppIcons.interested;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.property?['isInterested'] == 1) {
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
              Constant.interestedPropertyIds.contains(widget.property!['id']!);

              if (contains == true || widget.property!['isInterested'] == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                  propertyId: widget.property!['id']!.toString(),
                  interest: interest);
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.getTranslatedLabel(context, "interested")
                : UiUtils.getTranslatedLabel(context, "interest")),
            fontSize: context.font.large,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: (icon is String)
                  ? SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
              )
                  : Icon(
                icon,
                color: Theme.of(context).colorScheme.buttonColor,
                size: 22,
              ),
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

  Widget messageButton() {
    return UiUtils.buildButton(context,
        fontSize: 13,
        buttonColor: const Color(0xff25d366),
        outerPadding: const EdgeInsets.symmetric(vertical : 1),
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
        width: 35,
        onPressed: _onTapChat,
        prefixWidget: SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child:
            UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
          ),
        ));
  }
  Widget email() {
    return UiUtils.buildButton(context,
        fontSize: 13,
        buttonColor: const Color(0xffff5f7a),
        outerPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "Email"),
        onPressed: _onTapChat,
        prefixWidget: SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Image.asset("assets/Sale_RentPropertydetailscreen/gmail.png",),
          ),
        ));
  }
  _onTapCall() async {
    if(property!['view_contact'] == 1) {
      var contactNumber = property?['customer']['mobile'];

      var url = Uri.parse("tel: $contactNumber"); //{contactNumber.data}
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      HelperUtils.showSnackBarMessage(context, 'Buy a package to contact the owner/builder of this project',
          type: MessageType.warning);
    }
  }

  _onTapMessage() async {
    if(property!['view_contact'] == 1) {
      var contactNumber = property?['customer']['mobile'];

      var url = Uri.parse("sms:$contactNumber"); //{contactNumber.data}
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      HelperUtils.showSnackBarMessage(context, 'Buy a package to contact the owner/builder of this project',
          type: MessageType.warning);
    }
  }

  _onTapChat() {
    if(property!['view_contact'] == 1) {
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
                profilePicture: property?['customer']['profile'] ?? "",
                userName: property?['customer']['name'] ?? "",
                propertyImage: property?['image'] ?? "",
                proeprtyTitle: property?['title'] ?? "",
                userId: (property?['added_by']).toString(),
                from: "project",
                propertyId: (property?['id']).toString(),
              ),
            );
          },
        ));
      });
    } else {
      HelperUtils.showSnackBarMessage(context, 'Buy a package to contact the owner/builder of this project',
          type: MessageType.warning);
    }
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

  final ProjectDetails widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              UiUtils.showFullScreenImage(context,
                  provider:
                  NetworkImage(widget?.property?['customerProfile'] ?? ""));
            },

            child: Container(
                width: 55,
                height: 55,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        width: 1,
                        color: const Color(0xffdfdfdf)
                    ),
                    borderRadius: BorderRadius.circular(50)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: UiUtils.getImage(widget.property?['customerProfile'] ?? "",
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
                Text(widget.property?['customerName'] ?? "")
                    .size(context.font.large)
                    .bold(),
                Text(widget.property?['customerEmail'] ?? ""),
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
    required this.data,
    required this.propertyID,
    required this.reraId,
    required this.roleId
  });

  final Map data;
  final  int propertyID;
 final String? reraId;
 final int roleId;
  

  @override
  Widget build(BuildContext context) {
    return Container(
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
      margin: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
          
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider:
                            NetworkImage(data['profile'] ?? ""));
                      },
          
                      child: Container(
                          width: 43,
                          height: 43,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                  width: 1,
                                  color: const Color(0xffdfdfdf)
                              ),
                              borderRadius: BorderRadius.circular(50)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: UiUtils.getImage(data['profile'] ?? "",
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
                          Text(data['company_name'] ?? "")
                              .size(13)
                              .color(const Color(0xff4c4c4c))
                              .bold(),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                               Text(roleId == 1 ? 'Owner' : roleId == 2 ? 'Agent' : 'Builder',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xff7d7d7d)
                                ),
                              ),
                              const SizedBox(width: 5,),
                              if(reraId != null && reraId!.isNotEmpty)
                                Row(
                                  children: [
                                    Image.asset('assets/rera_tic.png', height: 14, width:14),
                                    const SizedBox(width: 2),
                                    Container(
                                      width: MediaQuery.of(context).size.width/3,
                                      child: Text(
                                        'RERA ID : ${reraId}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9ea1a7),

                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 10),
                          //   child: Row(
                          //     children: [
                          //       Expanded(
                          //         child: const Text("Rera No:")
                          //             .size(11)
                          //             .color(const Color(0xff5d5d5d)),
                          //       ),
                          //       const SizedBox(width: 10,),
                          //       Expanded(
                          //         child: Text("${property!['project_details'][0]['rera_no'] ?? '-'}")
                          //             .size(11)
                          //             .bold( weight: FontWeight.w500,),
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if(roleId!=1)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        UserDetailProfileScreen(id: data['id'], isAgent: roleId==2?true:false)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          width: 1,
                          color: const Color(0xff2e8af9)
                      )
                  ),
                  child: const Text("Profile",style: TextStyle(
                      color: Color(0xff2e8af9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                  ),),
                ),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      print("eeeeeeeeee$propertyID");
                      var response = await Api.post(url: Api.interestedUsers, parameter: {
                        'property_id': propertyID,
                        'type': 1,
                      });
                      if(!response['error']) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)
                              ),
                              title: Text(
                                UiUtils.getTranslatedLabel(context, response['message']).toString().replaceFirstMapped(
                                  RegExp(r'^[a-z]'),
                                      (match) => match.group(0)!.toUpperCase(),
                                ),
                              ),
                              content: Text(UiUtils.getTranslatedLabel(context, 'Our Executive will reach you shortly!')),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Done'),
                                ),
                              ],
                            );
                          },
                        );
                        // HelperUtils.showSnackBarMessage(
                        //     context, UiUtils.getTranslatedLabel(context, response['message']),
                        //     type: MessageType.success, messageDuration: 3);
                        // HelperUtils.showSnackBarMessage(
                        //     context, UiUtils.getTranslatedLabel(context, 'Our Executive will reach you shortly!'),
                        //     type: MessageType.success, messageDuration: 5);
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 0,right: 0,top: 5,bottom: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xff2e8af9),
                        borderRadius: BorderRadius.circular(20),

                      ),
                      child: const Center(
                        child: Text("Request a Callback",style: TextStyle(
                            color: Colors.white,
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

    return  SizedBox(
      height: 65,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15),
        separatorBuilder: (context,i)=>SizedBox(width: 10,),
        scrollDirection: Axis.horizontal,
        itemCount: outdoorFacilityList.length,
        itemBuilder: (context, index) {
          AssignedOutdoorFacility facility = outdoorFacilityList[index];

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: const Color(0xffe9e9e9),
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
                          color: const Color(0xfffff1db),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "${facility.name ?? ""}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff585858),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${facility.distance} KM",
                              style: const TextStyle(
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
