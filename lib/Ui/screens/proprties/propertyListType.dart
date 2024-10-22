import 'dart:developer';

import 'package:Housepecker/Ui/screens/widgets/Erros/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/routes.dart';
import '../../../data/cubits/Utility/like_properties.dart';
import '../../../data/cubits/property/fetch_property_from_category_cubit.dart';
import '../../../data/cubits/property/fetch_property_from_type_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/AdMob/bannerAdLoadWidget.dart';
import '../../../utils/AdMob/interstitialAdManager.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../home/Widgets/property_horizontal_card.dart';
import '../main_activity.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/shimmerLoadingContainer.dart';

class PropertiesListType extends StatefulWidget {
  final String? type, typeName;

  const PropertiesListType({Key? key, this.type, this.typeName})
      : super(key: key);

  @override
  PropertiesListTypeState createState() => PropertiesListTypeState();
  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => PropertiesListType(
        type: arguments?['type'] as String,
        typeName: arguments?['typeName'] ?? "",
      ),
    );
  }
}

class PropertiesListTypeState extends State<PropertiesListType> {
  int offset = 0, total = 0;

  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  int adPosition = 9;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  @override
  void initState() {
    super.initState();
    searchbody = {};
    loadAd();
    interstitialAdManager.load();
    Constant.propertyFilter = null;
    controller = ScrollController()..addListener(_loadMore);
    context.read<FetchPropertyFromTypeCubit>().fetchPropertyFromType(
        widget.type!,
        showPropertyType: false);

    Future.delayed(Duration.zero, () {
      selectedtype = widget.type!;
      selectedtypeName = widget.typeName!;
      searchbody[Api.propertyType] = widget.type;
      setState(() {});
    });
  }

  BannerAd? _bannerAd;
  bool _isLoaded = false;
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

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    super.dispose();
  }

  void _loadMore() async {
    if (controller.isEndReached()) {
      if (context.read<FetchPropertyFromTypeCubit>().hasMoreData()) {
        context
            .read<FetchPropertyFromTypeCubit>()
            .fetchPropertyFromTypeMore();
      }
    }
  }

  Widget? noInternetCheck(error) {
    if (error is ApiException) {
      if ((error).errorMessage == 'no-internet') {
        return NoInternet(
          onRetry: () {
            context
                .read<FetchPropertyFromTypeCubit>()
                .fetchPropertyFromType(
                widget.type!,
                showPropertyType: false);
          },
        );
      }
    }
    return null;
  }

  int itemIndex = 0;
  @override
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  Widget bodyWidget() {
    return WillPopScope(
      onWillPop: () async {
        await interstitialAdManager.show();
        Constant.propertyFilter = null;
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true,
              title: selectedtypeName == ""
                  ? widget.typeName
                  : selectedtypeName,
              actions: [
                filterOptionsBtn(),
              ]),
          bottomNavigationBar: const BottomAppBar(
            child: BannerAdWidget(bannerSize: AdSize.banner),
          ),
          body: BlocBuilder<FetchPropertyFromTypeCubit,
              FetchPropertyFromTypeState>(builder: (context, state) {
            if (state is FetchPropertyFromTypeInProgress) {
              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return buildPropertiesShimmer(context);
                },
              );
            }

            if (state is FetchPropertyFromTypeFailure) {
              var error = noInternetCheck(state.errorMessage);
              if (error != null) {
                return error;
              }
              return Center(
                child: Text(state.errorMessage.toString()),
              );
            }
            if (state is FetchPropertyFromTypeSuccess) {
              if (state.propertymodel.isEmpty) {
                return Center(
                  child: NoDataFound(
                    onTap: () {
                      context
                          .read<FetchPropertyFromTypeCubit>()
                          .fetchPropertyFromType(
                          widget.type!,
                          showPropertyType: false);
                    },
                  ),
                );
              }

              return Column(
                children: [
                  // Expanded(
                  //   child: ListView.separated(
                  //     shrinkWrap: true,
                  //     controller: controller,
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 15, vertical: 3),
                  //     itemCount: state.propertymodel.length,
                  //     physics: const BouncingScrollPhysics(),
                  //     separatorBuilder: (context, index) {
                  //       if ((index + 1) % adPosition == 0) {
                  //         return (_bannerAd == null)
                  //             ? Container()
                  //             : Builder(builder: (context) {
                  //                 return BannerAdWidget();
                  //               });
                  //       }
                  //
                  //       return const SizedBox.shrink();
                  //     },
                  //     itemBuilder: (context, index) {
                  //       PropertyModel property = state.propertymodel[index];
                  //       return GestureDetector(
                  //         onTap: () {
                  //           Navigator.pushNamed(
                  //             context,
                  //             Routes.propertyDetails,
                  //             arguments: {
                  //               'propertyData': property,
                  //               'propertiesList': state.propertymodel,
                  //               'fromMyProperty': false,
                  //             },
                  //           );
                  //         },
                  //         child: PropertyHorizontalCard(
                  //           property: property,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(15),
                      shrinkWrap: true,
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.propertymodel.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1 / 1.2,
                      ),
                      // separatorBuilder: (context, index) {
                      //   if ((index + 1) % adPosition == 0) {
                      //     return (_bannerAd == null)
                      //         ? Container()
                      //         : Builder(builder: (context) {
                      //       return BannerAdWidget();
                      //     });
                      //   }
                      //
                      //   return const SizedBox.shrink();
                      // },
                      itemBuilder: (context, index) {
                        PropertyModel property = state.propertymodel[index];
                        // context.read<LikedPropertiesCubit>().add(property.id);
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.propertyDetails,
                              arguments: {
                                'propertyData': property,
                                'propertiesList': state.propertymodel,
                                'fromMyProperty': false,
                              },
                            );
                          },
                          child: PropertyHorizontalCard(
                            property: property,
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore) UiUtils.progress()
                ],
              );
            }
            return Container();
          })),
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
              border: Border.all(
                  width: 1,
                  color: Color(0xffe0e0e0)
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
                SizedBox(height: 8,),
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
                        SizedBox(height: 5,),
                        const CustomShimmer(
                          height: 13,
                        ),
                        SizedBox(height: 5,),
                        CustomShimmer(
                          height: 12,
                          width: c.maxWidth / 1.2,
                        ),
                        SizedBox(height: 8,),
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

  Widget filterOptionsBtn() {
    return IconButton(
        onPressed: () {
          // show filter screen

          // Constant.propertyFilter = null;
          Navigator.pushNamed(context, Routes.filterScreen,
              arguments: {"showPropertyType": false}).then((value) {
            if (value == true) {
              context
                  .read<FetchPropertyFromTypeCubit>()
                  .fetchPropertyFromType(widget.type!,
                  showPropertyType: false);
            }
            setState(() {});
          });
        },
        icon: Icon(
          Icons.filter_list_rounded,
          color: Colors.white,
        ));
  }
}
