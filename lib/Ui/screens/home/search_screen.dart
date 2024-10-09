import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:Housepecker/Ui/screens/widgets/Erros/no_internet.dart';
import 'package:Housepecker/utils/AdMob/bannerAdLoadWidget.dart';
import 'package:Housepecker/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/routes.dart';
import '../../../data/cubits/property/search_property_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../projects/projectDetailsScreen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../widgets/promoted_widget.dart';
import 'Widgets/property_horizontal_card.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocus;
  final bool openFilterScreen;
  const SearchScreen(
      {Key? key, required this.autoFocus, required this.openFilterScreen})
      : super(key: key);
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SearchScreen(
          autoFocus: arguments?['autoFocus'],
          openFilterScreen: arguments?['openFilterScreen'],
        );
      },
    );
  }

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  bool isFocused = false;
  String previouseSearchQuery = "";
  static TextEditingController searchController = TextEditingController();
  int offset = 0;
  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List idlist = [];
  Timer? _searchDelay;
  bool showContent = true;
  @override
  void initState() {
    super.initState();
    if (widget.openFilterScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamed(context, Routes.filterScreen);
      });
    }
    // context.read<PropertyCubit>().fetchProperty(context, {});
    context.read<SearchPropertyCubit>().searchProperty("", offset: 0);
    searchController = TextEditingController();
    searchController.addListener(searchPropertyListener);
    controller = ScrollController()..addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<SearchPropertyCubit>().hasMoreData()) {
        context.read<SearchPropertyCubit>().fetchMoreSearchData();
      }
    }
  }

//this will listen and manage search
  void searchPropertyListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), propertySearch);
  }

  ///This will call api after some delay
  void propertySearch() {
    // if (searchController.text.isNotEmpty) {
    if (previouseSearchQuery != searchController.text) {
      context
          .read<SearchPropertyCubit>()
          .searchProperty(searchController.text, offset: 0);
      previouseSearchQuery = searchController.text;
    }
    // } else {
    // context.read<SearchPropertyCubit>().clearSearch();
    // }
  }

  Widget filterOptionsBtn() {
    return IconButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.filterScreen).then((value) {
            if (value == true && searchController.text != "") {
              context
                  .read<SearchPropertyCubit>()
                  .searchProperty(searchController.text, offset: 0);
            }
          });
        },
        icon: Icon(
          Icons.filter_list_rounded,
          color: Theme.of(context).colorScheme.blackColor,
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: context.color.tertiaryColor,
        ),
        elevation: 0,
        backgroundColor: tertiaryColor_,
        title: searchTextField(),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          // BlocBuilder<PropertyCubit, PropertyState>(
          //   builder: (context, state) {
          //     log("state isss $state");
          //     if (state is PropertyFetchSuccess) {
          //       return SingleChildScrollView(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Padding(
          //               padding: EdgeInsets.symmetric(horizontal: 16.0),
          //               child: Text("Latest properties"),
          //             ),
          //             ListView.builder(
          //               shrinkWrap: true,
          //               physics: const NeverScrollableScrollPhysics(),
          //               padding: const EdgeInsets.symmetric(horizontal: 16),
          //               itemCount: state.propertylist.length,
          //               itemBuilder: (context, index) {
          //                 return PropertyHorizontalCard(
          //                     property: state.propertylist[index]);
          //               },
          //             ),
          //           ],
          //         ),
          //       );
          //     }
          //     if (state is PropertyFetchFailure) {
          //       log(state.errmsg);
          //       return Container(
          //         child: Text(state.errmsg.toString()),
          //       );
          //     }
          //     return Container();
          //   },
          // ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchPropertyCubit, SearchPropertyState>(
              builder: (context, state) {
                return listWidget(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget(SearchPropertyState state) {
    if (state is SearchPropertyFetchProgress) {
      return Center(
        child:
            UiUtils.progress(normalProgressColor: context.color.tertiaryColor),
      );
    }
    if (state is SearchPropertyFailure) {
      if (state.errorMessage is ApiException) {
        return NoInternet(
          onRetry: () {
            context.read<SearchPropertyCubit>().searchProperty("", offset: 0);
          },
        );
      }
      return const SomethingWentWrong();
    }

    if (state is SearchPropertySuccess) {
      if (state.searchedroperties.isEmpty) {
        return Center(
          child: Text(
            UiUtils.getTranslatedLabel(context, "nodatafound"),
          ),
        );
      }
      // if (searchController.text == "") {
      //   return Center(
      //     child: Text(
      //       UiUtils.getTranslatedLabel(context, "nodatafound"),
      //     ),
      //   );
      // }
      return SingleChildScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
               GridView.builder(
                  shrinkWrap: true,
                              padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
                     physics: NeverScrollableScrollPhysics(),
                  itemCount: [...state.searchedroperties, ...?state.searchedProjects].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1 / 1.2,
                  ),
         
                  itemBuilder: (context, index) {
                    List data = [...state.searchedroperties, ...?state.searchedProjects];
                    data.shuffle(Random());
                    PropertyModel? property;
                    Map? projects;
                    var type = '';
                    if(data[index].type == 'property') {
                      property = data[index];
                      type = 'property';
                    } else {
                      projects = data[index];
                      type = 'project';
                    }
                    List propertiesList = state.searchedroperties;
                  return type == 'property' ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        HelperUtils.goToNextPage(
                            Routes.propertyDetails, context, false, args: {
                          'propertyData': property,
                          'propertiesList': propertiesList
                        });
                      },
                      child: PropertyHorizontalCard(property: property!),
                    ),
                  ) : Container(
                    width: 230,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ProjectDetails(property: projects!, fromMyProperty: true,
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
                                              projects!['image'] ?? "",
                                              width: double.infinity,fit: BoxFit.cover,height: 103,
                                            ),
                                            const PositionedDirectional(
                                                start: 5,
                                                top: 5,
                                                child: PromotedCard(
                                                    type: PromoteCardType.icon)),
                                            PositionedDirectional(
                                              bottom: 6,
                                              start: 6,
                                              child: Container(
                                                height: 19,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                    color: context.color.secondaryColor
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                    BorderRadius.circular(4)),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 2, sigmaY: 3),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                    child: Center(
                                                      child: Text(projects![index]['category'] != null ?
                                                      projects![index]['category']!['category'] : '',
                                                      )
                                                          .color(
                                                        context.color.textColorDark,
                                                      )
                                                          .bold(weight: FontWeight.w500)
                                                          .size(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Positioned(
                                            //   right: 8,
                                            //   top: 8,
                                            //   child: InkWell(
                                            //     onTap: () {
                                            //       GuestChecker.check(onNotGuest: () async {
                                            //         setState(() {
                                            //           widget.likeLoading![index] = true;
                                            //         });
                                            //         var body = {
                                            //           "type": widget.projectList![index]['is_favourite'] == 1 ? 0 : 1,
                                            //           "project_id": widget.projectList![index]['id']
                                            //         };
                                            //         var response = await Api.post(
                                            //             url: Api.addFavProject, parameter: body);
                                            //         if (!response['error']) {
                                            //           widget.projectList![index]['is_favourite'] = (widget.projectList![index]['is_favourite'] == 1 ? 0 : 1);
                                            //           setState(() {
                                            //             widget.likeLoading![index] = false;
                                            //           });
                                            //
                                            //         }
                                            //       });
                                            //     },
                                            //     child: Container(
                                            //       width: 32,
                                            //       height: 32,
                                            //       decoration: BoxDecoration(
                                            //         color: context.color.secondaryColor,
                                            //         shape: BoxShape.circle,
                                            //         boxShadow: const [
                                            //           BoxShadow(
                                            //             color:
                                            //             Color.fromARGB(12, 0, 0, 0),
                                            //             offset: Offset(0, 2),
                                            //             blurRadius: 15,
                                            //             spreadRadius: 0,
                                            //           )
                                            //         ],
                                            //       ),
                                            //       child: Container(
                                            //         width: 32,
                                            //         height: 32,
                                            //         decoration: BoxDecoration(
                                            //           color: context.color.primaryColor,
                                            //           shape: BoxShape.circle,
                                            //           boxShadow: const [
                                            //             BoxShadow(
                                            //                 color: Color.fromARGB(33, 0, 0, 0),
                                            //                 offset: Offset(0, 2),
                                            //                 blurRadius: 15,
                                            //                 spreadRadius: 0)
                                            //           ],
                                            //         ),
                                            //         child: Center(
                                            //             child:
                                            //             (widget.likeLoading![index])
                                            //                 ? UiUtils.progress(width: 20, height: 20)
                                            //                 : widget.projectList![index]['is_favourite'] == 1
                                            //                 ?
                                            //             UiUtils.getSvg(
                                            //               AppIcons.like_fill,
                                            //               color: context.color.tertiaryColor,
                                            //             )
                                            //                 : UiUtils.getSvg(AppIcons.like,
                                            //                 color: context.color.tertiaryColor)
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
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
                                          projects![index]['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xff333333),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        if (projects![index]['address'] != "")
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                                SizedBox(width: 5,),
                                                Expanded(
                                                    child: Text(
                                                      projects![index]['address']?.trim() ?? "",  maxLines: 1,
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
                                        Text(
                                          '${projects![index]['project_details'].length > 0 ? projects![index]['project_details'][0]['avg_price'] : 0}'
                                              .toString()
                                              .formatAmount(
                                            prefix: true,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xff333333),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        Text("Ready To Move",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color(0xffa2a2a2),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400
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
                    ),
                  );
                  },
                ),

              // Wrap(
              //   direction: Axis.horizontal,
              //   children:
              //       List.generate(state.searchedroperties.length, (index) {
              //     PropertyModel property = state.searchedroperties[index];
              //     List propertiesList = state.searchedroperties;
              //     return Padding(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 16.0,
              //         vertical: 0,
              //       ),
              //       child: GestureDetector(
              //         onTap: () {
              //           FocusScope.of(context).unfocus();
              //           HelperUtils.goToNextPage(
              //               Routes.propertyDetails, context, false, args: {
              //             'propertyData': property,
              //             'propertiesList': propertiesList
              //           });
              //         },
              //         child: PropertyHorizontalCard(property: property),
              //       ),
              //     );
              //   }),
              // ),
              if (state.isLoadingMore) UiUtils.progress()
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search,
            color: context.color.tertiaryColor));
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  Widget searchTextField() {
    return LayoutBuilder(builder: (context, c) {
      return SizedBox(
        width: c.maxWidth,
        child: FittedBox(
          fit: BoxFit.none,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 270.rw(context),
                  height: 40.rh(context),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.5, color: context.color.borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: context.color.secondaryColor),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: TextFormField(
                        autofocus: widget.autoFocus ?? false,
                        controller: searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Theme.of(context).colorScheme.secondaryColor,
                          hintStyle: TextStyle(
                            fontSize: 13,
                          ),
                          hintText: UiUtils.getTranslatedLabel(
                              context, "searchHintLbl"),
                          prefixIcon: setSearchIcon(),
                          prefixIconConstraints:
                              const BoxConstraints(minHeight: 5, minWidth: 5),
                        ),
                        enableSuggestions: true,
                        onEditingComplete: () {
                          setState(
                            () {
                              isFocused = false;
                            },
                          );
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          //change prefix icon color to primary
                          setState(() {
                            isFocused = true;
                          });
                        }),
                  )),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.filterScreen,
                  ).then((value) {
                    if (value == true) {
                      context
                          .read<SearchPropertyCubit>()
                          .searchProperty(searchController.text, offset: 0);
                    }
                  });
                },
                child: Container(
                  width: 40.rw(context),
                  height: 40.rh(context),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor),
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: UiUtils.getSvg(AppIcons.filter,
                        color: context.color.tertiaryColor),
                  ),
                ),
              ),
              SizedBox(
                width: c.maxWidth * 0.06,
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
