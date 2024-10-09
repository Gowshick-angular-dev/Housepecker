import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Housepecker/Ui/screens/projects/projectDetailsScreen.dart';
import 'package:Housepecker/Ui/screens/widgets/promoted_widget.dart';

import '../../app/routes.dart';
import '../../data/cubits/Utility/like_properties.dart';
import '../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../data/cubits/favorite/fetch_favorites_cubit.dart';
import '../../data/helper/designs.dart';
import '../../data/model/property_model.dart';
import '../../utils/AppIcon.dart';
import '../../utils/Extensions/extensions.dart';
import '../../utils/api.dart';
import '../../utils/guestChecker.dart';
import '../../utils/responsiveSize.dart';
import '../../utils/ui_utils.dart';
import 'home/Widgets/property_horizontal_card.dart';
import 'widgets/AnimatedRoutes/blur_page_route.dart';
import 'widgets/Erros/no_data_found.dart';
import 'widgets/Erros/no_internet.dart';
import 'widgets/Erros/something_went_wrong.dart';
import 'widgets/shimmerLoadingContainer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => BlocProvider(
        create: (context) => FetchFavoritesCubit(),
        child: const FavoritesScreen(),
      ),
    );
  }

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ScrollController _pageScrollController = ScrollController();
  List favProjectsList = [];
  bool projectLoading = false;
  bool projectLikeLoading = false;

  @override
  void initState() {
    getFavProjects();
    _pageScrollController.addListener(_pageScrollListen);
    context.read<FetchFavoritesCubit>().fetchFavorites();
    super.initState();
  }

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchFavoritesCubit>().hasMoreData()) {
        context.read<FetchFavoritesCubit>().fetchFavoritesMore();
      }
    }
  }

  Future<void> getFavProjects() async {
    setState(() {
      projectLoading = true;
    });
    var staResponse = await Api.get(url: Api.favProjects);
    if(!staResponse['error']) {
      setState(() {
        favProjectsList = staResponse['data'];
        projectLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: context.color.tertiaryColor,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: false,
          title: UiUtils.getTranslatedLabel(
            context,
            "Shortlist",
          ),
        ),
        body: DefaultTabController(
          length: 2,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  tabs: [
                    Tab(
                        child: Text('Properties',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                    ),
                    Tab(
                        child: Text('Projects',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                    ),
                  ],
                ),
                Expanded( // Use Expanded for TabBarView to fill remaining space
                  child: TabBarView(
                    children: [
                      BlocBuilder<FetchFavoritesCubit, FetchFavoritesState>(
                        builder: (context, state) {
                          if (state is FetchFavoritesInProgress) {
                            return shimmerEffect();
                          }
                          if (state is FetchFavoritesFailure) {
                            if (state.errorMessage is ApiException) {
                              if ((state.errorMessage as ApiException).errorMessage ==
                                  "no-internet") {
                                return NoInternet(
                                  onRetry: () {
                                    context.read<FetchFavoritesCubit>().fetchFavorites();
                                  },
                                );
                              }
                            }
                            return const SomethingWentWrong();
                          }
                          if (state is FetchFavoritesSuccess) {
                            if (state.propertymodel.isEmpty) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: SizedBox(
                                  height: context.screenHeight - 100.rh(context),
                                  child: Center(
                                    child: NoDataFound(
                                      onTap: () {
                                        context.read<FetchFavoritesCubit>().fetchFavorites();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(15),
                                    shrinkWrap: true,
                                    controller: _pageScrollController,
                                    itemCount: state.propertymodel.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1 / 1.2,
                                    ),

                                    itemBuilder: (context, index) {
                                      PropertyModel property = state.propertymodel[index];
                                      context.read<LikedPropertiesCubit>().add(property.id);
                                      return BlocProvider(
                                        create: (context) => AddToFavoriteCubitCubit(),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.propertyDetails,
                                              arguments: {
                                                'propertyData': property,
                                                'fromMyProperty': true,
                                              },
                                            );
                                          },
                                          child: PropertyHorizontalCard(
                                            property: property,
                                            onLikeChange: (type) {
                                              if (type == FavoriteType.add) {
                                                context
                                                    .read<FetchFavoritesCubit>()
                                                    .add(state.propertymodel[index]);
                                              } else {
                                                context
                                                    .read<FetchFavoritesCubit>()
                                                    .remove(state.propertymodel[index].id);
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (state.isLoadingMore)
                                  UiUtils.progress(
                                    normalProgressColor: context.color.tertiaryColor,
                                  )
                              ],
                            );
                          }

                          return Container();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            if(favProjectsList.length > 0)
                            Expanded(
                              child: GridView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: favProjectsList.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  mainAxisExtent: 230,
                                ),
                                itemBuilder: (context, index) {
                                  if(!projectLoading) {
                                    return Container(
                                      width: 230,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>
                                                  ProjectDetails(property: favProjectsList[index], fromMyProperty: true,
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
                                                                favProjectsList[index]['image'] ?? "",
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
                                                                        child: Text(favProjectsList[index]['category'] != null ?
                                                                          favProjectsList[index]['category']['category'] : '',
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
                                                              Positioned(
                                                                right: 8,
                                                                top: 8,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    GuestChecker.check(onNotGuest: () async {
                                                                      var body = {
                                                                        "type": 0,
                                                                        "project_id": favProjectsList[index]['id']
                                                                      };
                                                                      var response = await Api.post(
                                                                          url: Api.addFavProject, parameter: body);
                                                                      if (!response['error']) {
                                                                        favProjectsList.removeAt(index);
                                                                        setState(() {});
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
                                                                          UiUtils.getSvg(
                                                                            AppIcons.like_fill,
                                                                            color: context.color.tertiaryColor,
                                                                          )
                                                                      ),
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
                                                            favProjectsList[index]['title'],
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Color(0xff333333),
                                                                fontSize: 12.5,
                                                                fontWeight: FontWeight.w500
                                                            ),
                                                          ),
                                                          SizedBox(height: 4,),
                                                          if (favProjectsList[index]['address'] != "")
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 4),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                                                  SizedBox(width: 5,),
                                                                  Expanded(
                                                                      child: Text(
                                                                        favProjectsList[index]['address']?.trim() ?? "",  maxLines: 1,
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
                                                            '${favProjectsList[index]['project_details'].length > 0 ? favProjectsList[index]['project_details'][0]['avg_price'] : 0}'
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
                                  } else {
                                    return ClipRRect(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      child: CustomShimmer(height: 90, width: 90),
                                    );
                                  }
                                },
                              ),
                            ),
                            if(favProjectsList.length == 0)
                              Center(
                                child: NoDataFound(
                                  onTap: () {
                                    context.read<FetchFavoritesCubit>().fetchFavorites();
                                  },
                                ),
                              ),
                            // if (state.isLoadingMore)
                            //   UiUtils.progress(
                            //     normalProgressColor: context.color.tertiaryColor,
                            //   )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GridView shimmerEffect() {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      shrinkWrap: true,
      controller: _pageScrollController,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.2,
      ),

      // separatorBuilder: (context, index) {
      //   return const SizedBox(
      //     height: 12,
      //   );
      // },
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
}
