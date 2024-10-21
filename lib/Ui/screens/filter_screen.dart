// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Housepecker/Ui/screens/projects/projectsListScreen.dart';
import 'package:Housepecker/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:Housepecker/Ui/screens/widgets/BottomSheets/choose_location_bottomsheet.dart';
import 'package:Housepecker/app/routes.dart';
import 'package:Housepecker/data/cubits/category/fetch_category_cubit.dart';
import 'package:Housepecker/data/model/category.dart';
import 'package:Housepecker/data/model/propery_filter_model.dart';
import 'package:Housepecker/utils/AdMob/bannerAdLoadWidget.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../data/Repositories/location_repository.dart';
import '../../data/model/google_place_model.dart';
import '../../utils/AppIcon.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/helper_utils.dart';
import '../../utils/ui_utils.dart';
import 'main_activity.dart';

dynamic city = "";
dynamic _state = "";
dynamic country = "";

class FilterScreen extends StatefulWidget {
  final bool? showPropertyType;
  const FilterScreen({
    Key? key,
    this.showPropertyType,
  }) : super(key: key);

  @override
  FilterScreenState createState() => FilterScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => FilterScreen(
        showPropertyType: arguments?['showPropertyType'],
      ),
    );
  }
}

class FilterScreenState extends State<FilterScreen> {
  TextEditingController minController =
      TextEditingController(text: Constant.propertyFilter?.minPrice);
  TextEditingController maxController =
      TextEditingController(text: Constant.propertyFilter?.maxPrice);
  TextEditingController minAreaController =
  TextEditingController();
  TextEditingController maxAreaController =
  TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  //String properyType = Constant.valSellBuy;
  String properyType = Constant.propertyFilter?.propertyType ?? "";
  String Saletype = Constant.propertyFilter?.SaleType ?? "";

  String filterType = "Property";
  String postedOn = Constant.propertyFilter?.postedSince ??
      Constant.filterAll; // = 2; // 0: last_week   1: yesterday
  dynamic defaultCategoryID = currentVisitingCategoryId;
  dynamic defaultCategory = currentVisitingCategory;

  int selectedIndex2 = -1;

  List statusList = [];
  List amenityList = [];
  List selectedCityList = [];
  List selectedAmenities = [];
  List amenities = [];
  List categoryList = [];
  List parameterList = [];
  Map? parameterValues;
  List parameterId = [];
  List roleList = [];
  Category? currentCategory;
  bool loading = false;
  int rera = 0;
  int offers = 0;
  bool enable = false;

  Timer? _timer;
  String previouseSearchQuery = "";
  bool loadintCitiesInProgress = false;
  List<GooglePlaceModel>? cities;
  Map? cityCod;
  String? locationValue='';
  TextEditingController locationControler = TextEditingController();
  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

/*  Future<void> searchDelayTimer() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    _timer = Timer(
      const Duration(milliseconds: 500),
          () async {
        if (_searchController.text.isNotEmpty) {
          if (previouseSearchQuery != _searchController.text) {
            try {
              loadintCitiesInProgress = true;
              if(selectedCityList.isEmpty) {
                cities = await GooglePlaceRepository().serchCities(
                  _searchController.text,
                );
              } else {
                List<GooglePlaceModel>? clist = [];
                var likecities = await GooglePlaceRepository().serchOnlyCities(
                  _searchController.text, cityCod
                );
                for(int i = 0; i < likecities.length; i++) {
                  if(likecities[i].description.contains(selectedCityList[0])) {
                    clist.add(likecities[i]);
                  }
                }
                cities = clist;
              }
              print('errrrrrrrrrrr: ${cities}');
              loadintCitiesInProgress = false;
            } catch (e) {
              print('errrrrrrrrrrr: ${e}');
              loadintCitiesInProgress = false;
            }

            setState(() {});
            previouseSearchQuery = _searchController.text;
          }
        } else {
          cities = null;
        }
      },
    );
    setState(() {});
  }*/

  @override
  void initState() {
    super.initState();
    selectedCategory = null;
    _searchController.addListener(() {
   //   searchDelayTimer();
    });
    getMasters();
    // getMasters2();
    // getMasters3();
    // getMasters4();
    // getRoles();
    setDefaultVal(isrefresh: false);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        print('TextField is focused');
        setState(() {
          enable = true;
        });
      } else {
        print('TextField is not focused');
        setState(() {
          enable = false;
        });
      }
    });
  }

  Future<void> getMasters() async {
    setState(() {
      loading = true;
    });
    var staResponse = await Api.get(url: Api.status);
    if(!staResponse['error']) {
      setState(() {
        statusList = staResponse['data'];
      });
    }
    var responseAme = await Api.get(url: Api.getAmenities);
    if(!responseAme['error']) {
      setState(() {
        amenityList = responseAme['data'];
      });
    }
    var response = await Api.get(url: Api.roles);
    if(!response['error']) {
      setState(() {
        roleList = response['data'];
      });
    }
    var catResponse = await Api.get(url: Api.apiGetCategories);
    if(!catResponse['error']) {
      setState(() {
        categoryList = catResponse['data'];
        loading = false;
      });
    }
  }

  Future<void> getMasters2() async {
    var responseAme = await Api.get(url: Api.getAmenities);
    if(!responseAme['error']) {
      setState(() {
        amenityList = responseAme['data'];
      });
    }
  }

  Future<void> getMasters3() async {
    var catResponse = await Api.get(url: Api.apiGetCategories);
    if(!catResponse['error']) {
      setState(() {
        categoryList = catResponse['data'];
      });
    }
  }

  // Future<void> getMasters4() async {
  //   var catResponse = await Api.get(url: Api.getParameters);
  //   if(!catResponse['error']) {
  //     Map data = {};
  //     for(int i = 0; i < catResponse['data'].length; i++) {
  //       data[catResponse['data'][i]['id']] = [];
  //     }
  //     setState(() {
  //       parameterList = catResponse['data'];
  //       parameterValues = data;
  //       loading = false;
  //     });
  //   }
  // }

  Future<void> getRoles() async {
    var response = await Api.get(url: Api.roles);
    if(!response['error']) {
      setState(() {
        roleList = response['data'];
      });
    }
  }

  void setDefaultVal({bool isrefresh = true}) {
    if (isrefresh) {
      postedOn = Constant.filterAll;
      Constant.propertyFilter = null;
      searchbody[Api.postedSince] = Constant.filterAll;
      properyType = "";
      selectedcategoryId = "0";
      city = "";
      _state = "";
      country = "";
      selectedcategoryName = "";
      selectedCategory = defaultCategory;

      minController.clear();
      maxController.clear();
      checkFilterValSet();
    }
  }

  bool checkFilterValSet() {
    if (postedOn != Constant.filterAll ||
        properyType.isNotEmpty ||
        minController.text.trim().isNotEmpty ||
        maxController.text.trim().isNotEmpty ||
        selectedCategory != defaultCategory) {
      return true;
    }

    return false;
  }

  void _onTapChooseLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var result = await showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return const ChooseLocatonBottomSheet();
      },
    );
    if (result != null) {
      GooglePlaceModel place = (result as GooglePlaceModel);

      city = place.city;
      country = place.country;
      _state = place.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        checkFilterValSet();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: UiUtils.buildAppBar(
          context,
          onbackpress: () {
            checkFilterValSet();
          },
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(context, "filterTitle"),
          actions: [
            if ((checkFilterValSet() == true)) ...[
              InkWell(
                  onTap: () {
                    setDefaultVal(isrefresh: true);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Image.asset("assets/Home/filter.png",width: 25,height: 25,fit: BoxFit.cover,color: Colors.white,),
                  ))
              // FittedBox(
              //   fit: BoxFit.none,
              //   child: UiUtils.buildButton(
              //     context,
              //     onPressed: () {
              //       setDefaultVal(isrefresh: true);
              //       setState(() {});
              //     },
              //     width: 100,
              //     height: 50,
              //     fontSize: context.font.normal,
              //     buttonColor: context.color.secondaryColor,
              //     showElevation: false,
              //     textColor: context.color.textColorDark,
              //     buttonTitle: UiUtils.getTranslatedLabel(
              //       context,
              //       "clearfilter",
              //     ),
              //   ),
              // )
            ]
          ],
        ),
        bottomNavigationBar: loading ? Center(child: UiUtils.progress()) : BottomAppBar(
          child: UiUtils.buildButton(context,
              outerPadding:const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              fontSize: 14,
              height: 50.rh(context), onPressed: () {
            //this will set name of previous screen app bar
            //   if(filterType == "Project") {
            //     Map filter = {
            //       'max_price': _currentRangeValues.end == 0 ? '' : _currentRangeValues.end,
            //       'min_price': _currentRangeValues.start == 0 ? '' : _currentRangeValues.start,
            //       'bhk': selectedProjectBHK.join(','),
            //       'project_age': projectAge == 0 ? '' : projectAge,
            //       'offers': projectOffer,
            //       'max_size': ProjectSizeRange.end == 0 ? '' : ProjectSizeRange.end,
            //       'min_size': ProjectSizeRange.start == 0 ? '' : ProjectSizeRange.start,
            //       'status': selectedProjectStatus.join(','),
            //       'amenities': amenities.join(','),
            //       'category_id': selectedProjectCat.join(','),
            //     };
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) =>
            //           ProjectViewAllScreen(filter: filter)),
            //     );
            //   } else {


                // if (widget.showPropertyType ?? false) {
                //   if (selectedCategory == null) {
                //     selectedcategoryName = "";
                //   } else {
                //     selectedcategoryName =
                //         (selectedCategory as Category).category ?? "";
                //   }
                // }

                List parameterIds = [];
                List parametersValues = [];
                if(parameterValues != null) {
                  for (var key in parameterValues!.keys) {
                    if (parameterValues![key].length > 0) {
                      parameterIds.add(key);
                      parametersValues.add(parameterValues![key].join(','));
                    }
                  }
                }
                Constant.propertyFilter = PropertyFilterModel(
                  propertyType: properyType,
                  maxPrice: maxController.text,
                  minPrice: minController.text,
                  categoryId: ((selectedCategory is String)
                      ? selectedCategory
                      : selectedCategory?.id) ??
                      "",
                  postedSince: postedOn,
                  city: city,
                  state: _state,
                  country: country,
                  area: selectedCityList.join(','),
                  allProperties: '1',
                  amenities: amenities.join(',').toString(),
                  post_by: selectedRole.join(',').toString(),
                  max_size: maxAreaController.text,
                  min_size: minAreaController.text,
                  parametersId: parameterIds.join(',').toString(),
                  parametersVal: jsonEncode(parametersValues),
                );

                Navigator.pushNamed(context, Routes.searchScreenRoute, arguments: {
                  'autoFocus': false,
                  'openFilterScreen': false,
                });

                // Navigator.pop(context, true);

          }, buttonTitle: UiUtils.getTranslatedLabel(context, "Search")),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

           /*     Container(
                    height: 50.rh(context),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                        Border.all(width: 1.5, color: context.color.borderColor),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: context.color.secondaryColor),
                    child: TextFormField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          border: InputBorder.none, //OutlineInputBorder()
                          fillColor: Theme.of(context).colorScheme.secondaryColor,
                          hintStyle: TextStyle(
                            fontSize: 12,
                          ),
                          hintText: UiUtils.getTranslatedLabel(context, "Search City"),
                          prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: UiUtils.getSvg(AppIcons.search,
                                  color: context.color.tertiaryColor)),
                          prefixIconConstraints:
                          const BoxConstraints(minHeight: 5, minWidth: 5),
                        ),
                        enableSuggestions: true,
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          //change prefix icon color to primary
                        }
                        ),
                ),*/
                Container(
                  padding: EdgeInsets.only(left: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border:   Border.all(width: 1.5, color: context.color.borderColor),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                      SizedBox(width: 10,),
                      Expanded(
                        child: GooglePlaceAutoCompleteTextField(
                          boxDecoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent)
                          ),
                          textEditingController: locationControler,
                          textStyle: TextStyle(fontSize: 14),
                          inputDecoration:   const InputDecoration(
                            hintText: 'Enter City,Locality...',
                            hintStyle: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff9c9c9c),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),

                          googleAPIKey: "AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8",
                          debounceTime: 800,
                          countries: ["in"],
                          isLatLngRequired: true,
                          getPlaceDetailWithLatLng: (Prediction prediction) {
                            print("placeDetails" + prediction.lng.toString());
                            // lat = prediction.lat.toString();
                            // lng = prediction.lng.toString();
                            setState(() { });
                          },
                          itemClick: (Prediction prediction) {
                            if (selectedCityList.length < 3) {
                              locationControler.text = prediction.description!;
                              locationControler.selection = TextSelection.fromPosition(
                                TextPosition(offset: prediction.description!.length),
                              );

                              List<String> address = prediction.description!.split(',').reversed.toList();
                              String selectedCity;
                              if (address.length >= 3) {
                                selectedCity = address[2];
                              } else if (address.length == 2) {
                                selectedCity = address[1];
                              } else {
                                selectedCity = address[0];
                              }

                              if (!selectedCityList.contains(selectedCity)) {
                                selectedCityList.add(selectedCity);
                                locationControler.text = '';
                              }

                              setState(() {});
                            } else {
                              HelperUtils.showSnackBarMessage(
                                context,
                                UiUtils.getTranslatedLabel(context, "You can only select a maximum of 3 locations."),
                                type: MessageType.success,
                                messageDuration: 3,
                              );
                            }
                          },
                          itemBuilder: (context, index, Prediction prediction) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                                  const SizedBox(width: 7,),
                                  Expanded(
                                      child:
                                      Text("${prediction.description ?? ""}",style: TextStyle(fontSize: 14,color: Colors.black),))
                                ],
                              ),
                            );
                          },
                          seperatedBuilder: Divider(),
                          isCrossBtnShown: true,
                          placeType: PlaceType.geocode,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: List.generate(
                      (selectedCityList.length),
                          (index) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Chip(
                            shape: StadiumBorder(
                              side: BorderSide(color: Color(0xffd9d9d9)
                              ),
                            ),
                            backgroundColor: Color(0xfffffbf3),
                            padding: const EdgeInsets.all(1),
                            label: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                              child: Text('${selectedCityList[index]}', style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 11,
                              ),
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                if(index == 0) {
                                  selectedCityList.clear();
                                  cities = [];
                                } else {
                                  selectedCityList.remove(
                                      selectedCityList[index]);
                                }
                              });
                            },
                            deleteIconColor: Colors.red,
                          ),
                        );
                      }),
                ),
                const SizedBox(height: 10),
                if(enable)
                  Container(
                  height: 400,
                  color: context.color.backgroundColor,
                  child: ListView.builder(
                    itemCount: cities?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 10, left: 5, right: 5),
                        child: InkWell(
                          onTap: () async {
                            if(selectedCityList.isEmpty) {
                              Map<String,
                                  dynamic> jdfgsd = await GooglePlaceRepository()
                                  .getPlaceDetails(cities![index].placeId);
                              print('rrrrrrrrrrrrrrrrrrr: ${jdfgsd['result']['geometry']['location']}');
                              cityCod = jdfgsd['result']['geometry']['location'];
                            }
                            if(!selectedCityList.contains(cities![index].city) && selectedCityList.length < 3) {
                              selectedCityList.add(cities![index].city);
                              cities = [];
                              _searchController.text = '';
                            }
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                width: 25,
                                height: 25,
                                AppIcons.location,
                                color: context.color.textColorDark,
                              ),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cities?.elementAt(index).city ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  Text("${cities?.elementAt(index).state ?? ""},${cities?.elementAt(index).country ?? ""}",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // propOrProjOption(),
                if(filterType == "Property")
                  Column(
                  children: [
                    const SizedBox(height: 15),

                      Row(
                        children: [
                          // Image.asset("assets/FilterSceen/1.png",width: 18,height: 18,fit: BoxFit.cover,),
                          // SizedBox(width: 6,),
                          Text(UiUtils.getTranslatedLabel(context, "Categories"),style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.w600
                          ),),
                        ],
                      ),
                      const SizedBox(height: 15),
                      BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
                        builder: (context, state) {
                          if (state is FetchCategorySuccess) {
                            List<Category> categoriesList = List.from(state.categories);
                            categoriesList.insert(0, Category(id: ""));
                            return SizedBox(
                              height: 40,
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: List.generate(
                                  categoriesList.length.clamp(0, 8),
                                      (int index) {
                                    if (index == 0) {
                                      return allCategoriesFilterButton(context);
                                    }
                                    if (index == 7) {
                                      return Padding(
                                        padding: const EdgeInsetsDirectional.only(start: 5.0),
                                        child: moreCategoriesButton(context),
                                      );
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        selectedCategory = categoriesList[index];
                                        currentCategory = categoriesList[index];
                                        Map data = {};
                                        for(int i = 0; i < categoriesList[index].parameterTypes!['parameters'].length; i++) {
                                          data[categoriesList[index].parameterTypes!['parameters'][i]['id']] = [];
                                        }
                                        parameterValues = data;
                                        parameterList = categoriesList[index].parameterTypes!['parameters'];
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selectedCategory ==
                                                categoriesList[index]
                                                ? Color(0xfffffbf3)
                                                : Color(0xfff2f2f2),
                                            borderRadius:
                                            BorderRadius.circular(100),
                                            border: Border.all(
                                              width: 1.5,
                                              color: selectedCategory ==
                                                  categoriesList[index]
                                                  ? Color(0xffffbf59)
                                                  : Color(0xfff2f2f2),
                                            ),
                                          ),
                                          height: 30,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // UiUtils.imageType(
                                                //   categoriesList[index].image!,
                                                //   height: 20.rh(context),
                                                //   width: 20.rw(context),
                                                //   color: selectedCategory ==
                                                //           categoriesList[index]
                                                //       ? context
                                                //           .color.secondaryColor
                                                //       : context
                                                //           .color.tertiaryColor,
                                                // ),
                                                // SizedBox(
                                                //   width: 10.rw(context),
                                                // ),
                                                Text(
                                                  categoriesList[index]
                                                      .category
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                )
                                                    .color(selectedCategory ==
                                                    categoriesList[index]
                                                    ? Color(0xff333333)
                                                    : Color(0xff333333),)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                      if(currentCategory != null && currentCategory!.id != '1')
                        const SizedBox(height: 30),
                      if(currentCategory != null && currentCategory!.id != '1' )
                        buyORsellOption(),
                      const SizedBox(
                        height: 15,
                      ),
                      // if( currentCategory != null &&  currentCategory!.id != '1' && currentCategory!.id != '3')
                      //   Salestype(),
                      const SizedBox(
                        height: 15,
                      ),

                    Divider(thickness: 1, color: Color(0xffdddddd),),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        // Image.asset("assets/FilterSceen/2.png",width: 18,height: 18,fit: BoxFit.cover,),
                        // SizedBox(width: 6,),
                        Text(UiUtils.getTranslatedLabel(context, 'budgetLbl'),style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.w600
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    budgetOption(),
                    const SizedBox(height: 10),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Image.asset("assets/FilterSceen/5.png",width: 18,height: 18,fit: BoxFit.cover,),
                        // SizedBox(width: 6,),
                        Text(UiUtils.getTranslatedLabel(context, 'Area (SqFt.)'),style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w600
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    projectSizeOption(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    postedby(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    brokerage(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    postedSince(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Image.asset("assets/FilterSceen/3.png",width: 18,height: 18,fit: BoxFit.cover,),
                    //         SizedBox(width: 6,),
                    //         Text(UiUtils.getTranslatedLabel(context, 'RERA'),style: TextStyle(
                    //             fontSize: 14,
                    //             color: Color(0xff333333),
                    //             fontWeight: FontWeight.w600
                    //         ),
                    //         ),
                    //       ],
                    //     ),
                    //     Switch(
                    //       value: rera == 1,
                    //       onChanged: (bool value) {
                    //         print(value);
                    //         if( value ) {
                    //           rera = 1;
                    //         } else {
                    //           rera = 0;
                    //         }
                    //         setState(() {});
                    //       }
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 15),
                    // Divider(thickness: 1,color: Color(0xffdddddd),),

                    projectAmenities(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    for(int i = 0; i< parameterList.length; i++)
                      if(parameterList[i]['type_of_parameter'] == 'dropdown')
                        attributesWidget(parameterList[i])
                  ],
                ),
                if(filterType == "Project")
                  Column(
                  children: [
                    const SizedBox(height: 15),
                    projectCat(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Image.asset("assets/FilterSceen/2.png",width: 18,height: 18,fit: BoxFit.cover,),
                        // SizedBox(width: 6,),
                        Text(UiUtils.getTranslatedLabel(context, 'budgetLbl'),style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w600
                        ),),
                      ],
                    ),
                    const SizedBox(height: 10),
                    budgetOption(),
                    const SizedBox(
                      height: 15,
                    ),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    projectbhk(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Image.asset("assets/FilterSceen/5.png",width: 18,height: 18,fit: BoxFit.cover,),
                        // SizedBox(width: 6,),
                        Text(UiUtils.getTranslatedLabel(context, 'Project Age'),style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w600
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    projectAgeOption(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // Image.asset("assets/FilterSceen/5.png",width: 18,height: 18,fit: BoxFit.cover,),
                        // SizedBox(width: 6,),
                        Text(UiUtils.getTranslatedLabel(context, 'Area (SqFt.)'),style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w600
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    projectSizeOption(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    projectStatus(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    projectOffers(),
                    const SizedBox(height: 15),
                    Divider(thickness: 1,color: Color(0xffdddddd),),
                    const SizedBox(height: 15),
                    projectAmenities(),
                    const SizedBox(height: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  attributesWidget(data) {
    if(properyType == '1') {
      if(data['name'] == 'Rent type') {
        return Column(
          children: [
            Row(
              children: [
                // Image.asset("assets/FilterSceen/6.png", width: 18,
                //   height: 18,
                //   fit: BoxFit.cover,),
                // SizedBox(width: 6,),
                Text(UiUtils.getTranslatedLabel(context, '${data['name']}'),
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w600
                  ),),
              ],
            ),
            SizedBox(height: 15,),
            if(data['type_values'] != null)
              SizedBox(
                height: 45,
                child: ListView.builder(
                  itemCount: data['type_values']!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // if (parameterValues![data['id']].any((item) =>
                        // item == data['type_values'][index])) {
                        //   parameterValues![data['id']].remove(
                        //       data['type_values'][index]);
                        //   setState(() {});
                        // } else {
                        //   parameterValues![data['id']].add(
                        //       data['type_values'][index]);
                        //
                        // }
                        setState(() {
                          parameterValues![data['id']] = [data['type_values'][index]];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: parameterValues![data['id']].any((
                                item) => item == data['type_values'][index])
                                ? Color(0xfffffbf3)
                                : Color(0xfff2f2f2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              width: 1.5,
                              color: parameterValues![data['id']].any((
                                  item) => item == data['type_values'][index])
                                  ? Color(0xffffbf59)
                                  : Color(0xfff2f2f2),
                            ),
                          ),
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  data['type_values'][index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Other child widgets here
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 15,),
            Divider(thickness: 1, color: Color(0xffdddddd),),
            const SizedBox(height: 15),
          ],
        );
      } else if(data['name'] != 'Sale Type'){
        if(data['name'] == 'Residential' || data['name'] == 'Commercial') {
          return Column(
            children: [
              Row(
                children: [
                  // Image.asset("assets/FilterSceen/6.png", width: 18,
                  //   height: 18,
                  //   fit: BoxFit.cover,),
                  // SizedBox(width: 6,),
                  Text(UiUtils.getTranslatedLabel(context, 'Property Type'),
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w600
                    ),),
                ],
              ),
              SizedBox(height: 15,),
              // Text('${parameterValues![42]}'),
              if(data['type_values'] != null && parameterValues![42].isNotEmpty)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    itemCount: data['type_values']!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if(data['type_values'][index].split('-')[1].split('&')[0] == 'rent' && data['type_values'][index].split('-')[1].split('&')[1] == parameterValues![42][0].toLowerCase()) {
                        return GestureDetector(
                        onTap: () {
                          if (parameterValues![data['id']].any((item) =>
                          item == data['type_values'][index])) {
                            parameterValues![data['id']].remove(
                                data['type_values'][index]);
                            setState(() {});
                          } else {
                            parameterValues![data['id']].add(
                                data['type_values'][index]);
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: parameterValues![data['id']].any((
                                  item) => item == data['type_values'][index])
                                  ? Color(0xfffffbf3)
                                  : Color(0xfff2f2f2),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                width: 1.5,
                                color: parameterValues![data['id']].any((
                                    item) => item == data['type_values'][index])
                                    ? Color(0xffffbf59)
                                    : Color(0xfff2f2f2),
                              ),
                            ),
                            height: 30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Text(data['type_values'][index].split('-')[0],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Other child widgets here
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
                  ),
                ),
              SizedBox(height: 15,),
              Divider(thickness: 1, color: Color(0xffdddddd),),
              const SizedBox(height: 15),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  // Image.asset("assets/FilterSceen/6.png", width: 18,
                  //   height: 18,
                  //   fit: BoxFit.cover,),
                  // SizedBox(width: 6,),
                  Text(UiUtils.getTranslatedLabel(context, '${data['name']}'),
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w600
                    ),),
                ],
              ),
              SizedBox(height: 15,),
              if(data['type_values'] != null)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    itemCount: data['type_values']!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (parameterValues![data['id']].any((item) =>
                          item == data['type_values'][index])) {
                            parameterValues![data['id']].remove(
                                data['type_values'][index]);
                            setState(() {});
                          } else {
                            parameterValues![data['id']].add(
                                data['type_values'][index]);
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: parameterValues![data['id']].any((
                                  item) => item == data['type_values'][index])
                                  ? Color(0xfffffbf3)
                                  : Color(0xfff2f2f2),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                width: 1.5,
                                color: parameterValues![data['id']].any((
                                    item) => item == data['type_values'][index])
                                    ? Color(0xffffbf59)
                                    : Color(0xfff2f2f2),
                              ),
                            ),
                            height: 30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Text(
                                    data['type_values'][index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Other child widgets here
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 15,),
              Divider(thickness: 1, color: Color(0xffdddddd),),
              const SizedBox(height: 15),
            ],
          );
        }
      }
    } else if(properyType == '0') {
      if(data['name'] == 'Sale Type') {
        return Column(
          children: [
            Row(
              children: [
                // Image.asset("assets/FilterSceen/6.png", width: 18,
                //   height: 18,
                //   fit: BoxFit.cover,),
                // SizedBox(width: 6,),
                Text(UiUtils.getTranslatedLabel(context, '${data['name']}'),
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w600
                  ),),
              ],
            ),
            SizedBox(height: 15,),
            if(data['type_values'] != null)
              SizedBox(
                height: 45,
                child: ListView.builder(
                  itemCount: data['type_values']!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // if (parameterValues![data['id']].any((item) =>
                        // item == data['type_values'][index])) {
                        //   parameterValues![data['id']].remove(
                        //       data['type_values'][index]);
                        //   setState(() {});
                        // } else {
                        //   parameterValues![data['id']].add(
                        //       data['type_values'][index]);
                        //   setState(() {});
                        // }
                        setState(() {
                          parameterValues![data['id']] = [data['type_values'][index]];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: parameterValues![data['id']].any((
                                item) => item == data['type_values'][index])
                                ? Color(0xfffffbf3)
                                : Color(0xfff2f2f2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              width: 1.5,
                              color: parameterValues![data['id']].any((
                                  item) => item == data['type_values'][index])
                                  ? Color(0xffffbf59)
                                  : Color(0xfff2f2f2),
                            ),
                          ),
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  data['type_values'][index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Other child widgets here
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 15,),
            Divider(thickness: 1, color: Color(0xffdddddd),),
            const SizedBox(height: 15),
          ],
        );
      } else if(data['name'] != 'Rent type'){
        if(data['name'] == 'Residential' || data['name'] == 'Commercial') {
          return Column(
            children: [
              Row(
                children: [
                  // Image.asset("assets/FilterSceen/6.png", width: 18,
                  //   height: 18,
                  //   fit: BoxFit.cover,),
                  // SizedBox(width: 6,),
                  Text(UiUtils.getTranslatedLabel(context, 'Property Type'),
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w600
                    ),),
                ],
              ),
              SizedBox(height: 15,),
              // Text('${parameterValues![42]}'),
              if(data['type_values'] != null && parameterValues![33].isNotEmpty)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    itemCount: data['type_values']!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if(data['type_values'][index].split('-')[1].split('&')[0] == 'buy' && data['type_values'][index].split('-')[1].split('&')[1] == parameterValues![33][0].toLowerCase()) {
                        return GestureDetector(
                          onTap: () {
                            if (parameterValues![data['id']].any((item) =>
                            item == data['type_values'][index])) {
                              parameterValues![data['id']].remove(
                                  data['type_values'][index]);
                              setState(() {});
                            } else {
                              parameterValues![data['id']].add(
                                  data['type_values'][index]);
                              setState(() {});
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: parameterValues![data['id']].any((
                                    item) => item == data['type_values'][index])
                                    ? Color(0xfffffbf3)
                                    : Color(0xfff2f2f2),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  width: 1.5,
                                  color: parameterValues![data['id']].any((
                                      item) => item == data['type_values'][index])
                                      ? Color(0xffffbf59)
                                      : Color(0xfff2f2f2),
                                ),
                              ),
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text(data['type_values'][index].split('-')[0],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    // Other child widgets here
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
                  ),
                ),
              SizedBox(height: 15,),
              Divider(thickness: 1, color: Color(0xffdddddd),),
              const SizedBox(height: 15),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  // Image.asset("assets/FilterSceen/6.png", width: 18,
                  //   height: 18,
                  //   fit: BoxFit.cover,),
                  // SizedBox(width: 6,),
                  Text(UiUtils.getTranslatedLabel(context, '${data['name']}'),
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff333333),
                        fontWeight: FontWeight.w600
                    ),),
                ],
              ),
              SizedBox(height: 15,),
              if(data['type_values'] != null)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    itemCount: data['type_values']!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (parameterValues![data['id']].any((item) =>
                          item == data['type_values'][index])) {
                            parameterValues![data['id']].remove(
                                data['type_values'][index]);
                            setState(() {});
                          } else {
                            parameterValues![data['id']].add(
                                data['type_values'][index]);
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: parameterValues![data['id']].any((
                                  item) => item == data['type_values'][index])
                                  ? Color(0xfffffbf3)
                                  : Color(0xfff2f2f2),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                width: 1.5,
                                color: parameterValues![data['id']].any((
                                    item) => item == data['type_values'][index])
                                    ? Color(0xffffbf59)
                                    : Color(0xfff2f2f2),
                              ),
                            ),
                            height: 30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Text(
                                    data['type_values'][index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Other child widgets here
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 15,),
              Divider(thickness: 1, color: Color(0xffdddddd),),
              const SizedBox(height: 15),
            ],
          );
        }
      }
    }
    return Container();
  }

  projectAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "Amenities",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                ),),
              // TextSpan(
              //   text: " *",
              //   style: TextStyle(color: Colors.red), // Customize asterisk color
              // ),
            ],
          ),
        ),
        SizedBox(height: 15,),
        Wrap(
          children: List.generate(
              (amenityList!.length),
                  (index) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: GestureDetector(
                    onTap: () {
                      if(selectedAmenities.any((item) => item['id'].toString() == amenityList![index]['id'].toString())) {
                        selectedAmenities.removeWhere((element) => element['id'] == amenityList![index]['id']);
                        amenities.removeWhere((element) => element['facility_id'] == amenityList![index]['id']);
                        setState(() {});
                      } else {
                        selectedAmenities.add(amenityList![index]);
                        amenities.add(amenityList![index]['id']);
                        setState(() {});
                      }
                    },
                    child: Chip(
                        avatar: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SvgPicture.network(
                            amenityList![index]['image'],
                            width: 18.0,
                            height: 18.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(color: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                            ? Color(0xffffa920)
                            : Color(0xffd9d9d9)
                          ),
                        ),
                        backgroundColor: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                          ? Color(0xfffffbf3)
                          : Color(0xfff2f2f2),
                        padding: const EdgeInsets.all(1),
                        label: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                            child: Text('${amenityList![index]['name']}', style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 11,
                            ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
        SizedBox(height: 25,),
      ],
    );
  }

  List selectedRole = [];
  String selectedBrokerage = '';
  String selectedPostDate = '';
  postedby() {
     return Column(
       children: [
         Row(
           children: [
             // Image.asset("assets/FilterSceen/3.png",width: 18,height: 18,fit: BoxFit.cover,),
             // SizedBox(width: 6,),
             Text(UiUtils.getTranslatedLabel(context, 'Posted by'),style: TextStyle(
                 fontSize: 14,
                 color: Color(0xff333333),
                 fontWeight: FontWeight.w600
             ),),
           ],
         ),
         SizedBox(height: 15,),

         SizedBox(
           height: 45,
           child: ListView.builder(
             itemCount: roleList.length,
             scrollDirection: Axis.horizontal,
             itemBuilder: (context, index) {
               return GestureDetector(
                 onTap: () {
                   setState(() {
                     // selectedRole = index;
                     if(selectedRole.any((item) => item == roleList[index]['id'])) {
                       selectedRole.removeWhere((element) => element == roleList[index]['id']);
                       setState(() {});
                     } else {
                       selectedRole.add(roleList[index]['id']);
                       setState(() {});
                     }
                   });
                 },
                 child: Padding(
                   padding: const EdgeInsets.all(1.0),
                   child: Container(
                     alignment: Alignment.center,
                     decoration: BoxDecoration(
                       color: selectedRole.any((item) => item == roleList[index]['id']) ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                       borderRadius: BorderRadius.circular(100),
                       border: Border.all(
                         width: 1.5,
                         color: selectedRole.any((item) => item == roleList[index]['id']) ? Color(0xffffbf59) : Color(0xfff2f2f2),
                       ),
                     ),
                     height: 30,
                     child: Padding(
                       padding: const EdgeInsets.symmetric(
                           horizontal: 16.0, vertical: 8),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                           Text(
                             roleList[index]['name'],
                             style: TextStyle(
                               fontSize: 11,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                           // Other child widgets here
                         ],
                       ),
                     ),
                   ),
                 ),
               );
             },
           ),
         ),

       ],
     );
  }

  brokerage() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/3.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Brokerage'),style: TextStyle(
                fontSize: 14,
                color: Color(0xff333333),
                fontWeight: FontWeight.w600
            ),),
          ],
        ),
        SizedBox(height: 15,),

        SizedBox(
          height: 45,
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedBrokerage = 'Yes';
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedBrokerage == 'Yes' ? const Color(0xfffffbf3) : const Color(0xfff2f2f2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 1.5,
                            color: selectedBrokerage == 'Yes' ? const Color(0xffffbf59) : const Color(0xfff2f2f2),
                          ),
                        ),
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedBrokerage = 'No';
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedBrokerage == 'No' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 1.5,
                            color: selectedBrokerage == 'No' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                          ),
                        ),
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  postedSince() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/3.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Posted On'),style: TextStyle(
                fontSize: 14,
                color: Color(0xff333333),
                fontWeight: FontWeight.w600
            ),),
          ],
        ),
        SizedBox(height: 15,),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Yesterday';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Yesterday' ? const Color(0xfffffbf3) : const Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Yesterday' ? const Color(0xffffbf59) : const Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Yesterday',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Last Week';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Last Week' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Last Week' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Last Week',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Last 2 Week';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Last 2 Week' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Last 2 Week' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Last 2 Week',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Last Month';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Last Month' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Last Month' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Last Month',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Last 2 Month';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Last 2 Month' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Last 2 Month' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Last 2 Month',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPostDate = 'Last 4 Month';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPostDate == 'Last 4 Month' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPostDate == 'Last 4 Month' ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Last 4 Month',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  List selectedProjectBHK = [];
  projectbhk() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/4.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'BHK'),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff333333),
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: 6,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> categoriesList = [
                {"category": "1 RK"},
                {"category": "1 BHK"},
                {"category": "2 BHK"},
                {"category": "3 BHK"},
                {"category": "4 BHK"},
                {"category": "4+"},
              ];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // selectedProjectBHK.add(categoriesList[index]['category']);
                    if(selectedProjectBHK.any((item) => item == categoriesList[index]['category'])) {
                      selectedProjectBHK.removeWhere((element) => element == categoriesList[index]['category']);
                      setState(() {});
                    } else {
                      selectedProjectBHK.add(categoriesList[index]['category']);
                      setState(() {});
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedProjectBHK.any((item) => item == categoriesList[index]['category']) ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedProjectBHK.any((item) => item == categoriesList[index]['category']) ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            categoriesList[index]['category'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Other child widgets here
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }

  List selectedProjectCat = [];
  projectCat() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/4.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Category'),
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff333333),
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: categoryList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // selectedProjectBHK.add(categoriesList[index]['category']);
                    if(selectedProjectCat.any((item) => item == categoryList[index]['id'])) {
                      selectedProjectCat.removeWhere((element) => element == categoryList[index]['id']);
                      setState(() {});
                    } else {
                      selectedProjectCat.add(categoryList[index]['id']);
                      setState(() {});
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedProjectCat.any((item) => item == categoryList[index]['id']) ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedProjectCat.any((item) => item == categoryList[index]['id']) ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            categoryList[index]['category'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Other child widgets here
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }

  List selectedProjectStatus = [];
  projectStatus() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/4.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Project Status'),
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff333333),
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: statusList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if(selectedProjectStatus.any((item) => item == statusList[index]['id'])) {
                      selectedProjectStatus.removeWhere((element) => element == statusList[index]['id']);
                      setState(() {});
                    } else {
                      selectedProjectStatus.add(statusList[index]['id']);
                      setState(() {});
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedProjectStatus.any((item) => item == statusList[index]['id']) ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedProjectStatus.any((item) => item == statusList[index]['id']) ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            statusList[index]['name'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }

  int projectOffer = 1;
  projectOffers() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/2.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Offers'),style: TextStyle(
                fontSize: 14,
                color: Color(0xff333333),
                fontWeight: FontWeight.w600
            ),),
          ],
        ),
        SizedBox(height: 15,),

        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final List categoriesList = ['Disabled', 'Enabled'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    projectOffer = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: projectOffer == index ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: projectOffer == index ? Color(0xffffbf59) : Color(0xfff2f2f2),
                      ),
                    ),
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            categoriesList[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Other child widgets here
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }


  Widget locationWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                  color: context.color.textLightColor.withOpacity(00.01),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.color.borderColor,
                    width: 1.5,
                  )),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: (city != "" && city != null)
                            ? Text("$city,$_state,$country")
                            : Text(UiUtils.getTranslatedLabel(
                                context, "selectLocationOptional"))),
                  ),
                  const Spacer(),
                  if (city != "" && city != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
                      child: GestureDetector(
                        onTap: _onTapChooseLocation,
                        child: Icon(
                          Icons.close,
                          color: context.color.textColorDark,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: _onTapChooseLocation,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                  color: context.color.textLightColor.withOpacity(00.01),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.color.borderColor,
                    width: 1.5,
                  )),
              child: Icon(
                Icons.location_searching_sharp,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget allCategoriesFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectedCategory = null;
        setState(() {});
      },
      child: Container(
        width: 60,
        margin: const EdgeInsetsDirectional.only(end: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedCategory == null
              ? Color(0xfffffbf3)
              : Color(0xfff2f2f2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1.5,
            color: selectedCategory == null
                ? Color(0xffffbf59)
                : Color(0xfff2f2f2),
          ),
        ),
        height: 25,
        child: Text(UiUtils.getTranslatedLabel(context, "lblall"), style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500
        ),).color(
            selectedCategory == null
                ? Color(0xff333333)
                : Color(0xff333333)
        ),
      ),
    );
  }

  GestureDetector moreCategoriesButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.categories,
            arguments: {"from": Routes.filterScreen}).then(
          (dynamic value) {
            if (value != null) {
              selectedCategory = value;
              setState(() {});
            }
          },
        );
      },
      child: Container(
        height: 25,
        width: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xffffbf59),
            border: Border.all(
              color: Color(0xffffbf59),
              width: 1.5,
            )),
        alignment: Alignment.center,
        child: Text(UiUtils.getTranslatedLabel(context, "more"), style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black
        ),),
      ),
    );
  }

  Widget saveFilter() {
    //save prefs & validate fields & call API
    return IconButton(
        onPressed: () {
          Constant.propertyFilter = PropertyFilterModel(
            propertyType: properyType,
            maxPrice: maxController.text,
            city: city,
            state: _state,
            country: country,
            minPrice: minController.text,
            categoryId: selectedCategory?.id ?? "",
            postedSince: postedOn,
          );

          Navigator.pop(context, true);
        },
        icon: const Icon(Icons.check));
  }

  Widget buyORsellOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Looking For',style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xffe4e4e4),
                  width: 1
                ),

                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 45.rw(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //buttonSale
                    Expanded(
                      child: SizedBox(
                        height: 46.rh(context),
                        child: UiUtils.buildButton(context, onPressed: () {
                          if (properyType == Constant.valSellBuy) {
                            searchbody[Api.propertyType] = "";
                            properyType = "";
                            setState(() {});
                          } else {
                            setPropertyType(Constant.valSellBuy);
                          }
                        },
                            showElevation: false,
                            textColor: properyType == Constant.valSellBuy
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                            buttonColor: properyType == Constant.valSellBuy
                                ? Theme.of(context).colorScheme.tertiaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .tertiaryColor
                                    .withOpacity(0.0),
                            fontSize: 13,
                            radius: 10,
                            buttonTitle: UiUtils.getTranslatedLabel(context,
                                UiUtils.getTranslatedLabel(context, "Buy"))),
                      ),
                    ),
                    //buttonRent
                    Expanded(
                      child: SizedBox(
                          height: 46.rh(context),
                          child: UiUtils.buildButton(context, onPressed: () {
                            if (properyType == Constant.valRent) {
                              searchbody[Api.propertyType] = "";
                              properyType = "";
                              setState(() {});
                            } else {
                              setPropertyType(Constant.valRent);
                            }
                          },
                              showElevation: false,
                              radius: 10,
                              textColor: properyType == Constant.valRent
                                  ? context.color.buttonColor
                                  : context.color.textColorDark,
                              buttonColor: properyType == Constant.valRent
                                  ? Theme.of(context).colorScheme.tertiaryColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .tertiaryColor
                                      .withOpacity(0.0),
                              fontSize: 13,
                              buttonTitle: UiUtils.getTranslatedLabel(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "Rent")))),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget Salestype() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sale Type',style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xffe4e4e4),
                  width: 1
                ),

                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 45.rw(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //buttonSale
                    Expanded(
                      child: SizedBox(
                        height: 46.rh(context),
                        child: UiUtils.buildButton(context, onPressed: () {
                          if (Saletype == Constant.Newsale) {
                            searchbody[Api.Saletype] = "";
                            Saletype = "";
                            setState(() {});
                          } else {
                            setPropertyType(Constant.Newsale);
                          }
                        },
                            showElevation: false,
                            textColor: Saletype == Constant.Newsale
                                ? context.color.buttonColor
                                : context.color.textColorDark,
                            buttonColor: Saletype == Constant.Newsale
                                ? Theme.of(context).colorScheme.tertiaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .tertiaryColor
                                    .withOpacity(0.0),
                            fontSize: 13,
                            radius: 10,
                            buttonTitle: UiUtils.getTranslatedLabel(context,
                                UiUtils.getTranslatedLabel(context, "New"))),
                      ),
                    ),
                    //buttonRent
                    Expanded(
                      child: SizedBox(
                          height: 46.rh(context),
                          child: UiUtils.buildButton(context, onPressed: () {
                            if (Saletype == Constant.Resale) {
                              searchbody[Api.Saletype] = "";
                              Saletype = "";
                              setState(() {});
                            } else {
                              setPropertyType(Constant.Resale);
                            }
                          },
                              showElevation: false,
                              radius: 10,
                              textColor: Saletype == Constant.Resale
                                  ? context.color.buttonColor
                                  : context.color.textColorDark,
                              buttonColor: Saletype == Constant.Resale
                                  ? Theme.of(context).colorScheme.tertiaryColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .tertiaryColor
                                      .withOpacity(0.0),
                              fontSize: 13,
                              buttonTitle: UiUtils.getTranslatedLabel(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "Resale")))),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget propOrProjOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Color(0xffe4e4e4),
                  width: 1
              ),

              borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 45.rw(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //buttonSale
                Expanded(
                  child: SizedBox(
                    height: 46.rh(context),
                    child: UiUtils.buildButton(context, onPressed: () {
                      // if (filterType == "Property") {
                      //   filterType = "";
                      //   setState(() {});
                      // } else {
                      //   filterType = "";
                      // }
                      setState(() {
                        filterType = "Property";
                      });
                    },
                    showElevation: false,
                    textColor: filterType == "Property"
                        ? context.color.buttonColor
                        : context.color.textColorDark,
                    buttonColor: filterType == "Property"
                        ? Theme.of(context).colorScheme.tertiaryColor
                        : Theme.of(context)
                        .colorScheme
                        .tertiaryColor
                        .withOpacity(0.0),
                    fontSize: 13,
                    radius: 10,
                    buttonTitle: UiUtils.getTranslatedLabel(context,
                        UiUtils.getTranslatedLabel(context, "Property"))),
                  ),
                ),
                //buttonRent
                Expanded(
                  child: SizedBox(
                      height: 46.rh(context),
                      child: UiUtils.buildButton(context, onPressed: () {
                          // if (filterType == Constant.valRent) {
                          //   searchbody[Api.propertyType] = "";
                          //   filterType = "";
                          //   setState(() {});
                          // } else {
                          //   setPropertyType(Constant.valRent);
                          // }
                          setState(() {
                            filterType = "Project";
                          });
                        },
                        showElevation: false,
                        radius: 10,
                        textColor: filterType == "Project"
                            ? context.color.buttonColor
                            : context.color.textColorDark,
                        buttonColor: filterType == "Project"
                            ? Theme.of(context).colorScheme.tertiaryColor
                            : Theme.of(context)
                            .colorScheme
                            .tertiaryColor
                            .withOpacity(0.0),
                        fontSize: 13,
                        buttonTitle: UiUtils.getTranslatedLabel(
                            context,
                            UiUtils.getTranslatedLabel(
                                context, "Project")
                        )
                      )
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void setPropertyType(String val) {
    searchbody[Api.propertyType] = val;

    setState(() {
      properyType = val;
    });
  }

  RangeValues _currentRangeValues = const RangeValues(0, 0);
  Widget budgetOption() {
    return Column(
      children: [
        RangeSlider(
          values: _currentRangeValues,
          min: 0,
          max: 50000000,
          divisions: 1000,
          labels: RangeLabels(
            _currentRangeValues.start.round().toString(),
            _currentRangeValues.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentRangeValues = values;
              minController.text = values.start.toStringAsFixed(0);
              maxController.text = values.end.toStringAsFixed(0);
            });
          },
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: TextFormField(
                  controller: minController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                    hintText: "Min Budget",
                  ),
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     double minValue = double.tryParse(value) ?? _currentRangeValues.start;
                  //     _currentRangeValues = RangeValues(minValue, _currentRangeValues.end);
                  //   });
                  // },
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: TextFormField(
                  controller: maxController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                    hintText: "Max Budget",
                  ),
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     double maxValue = double.tryParse(value) ?? _currentRangeValues.end;
                  //     _currentRangeValues = RangeValues(_currentRangeValues.start, maxValue);
                  //   });
                  // },
                ),
              ),
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text('${(_currentRangeValues.start.toInt())}'),
        //     Text('${_currentRangeValues.end.toInt()}'),
        //   ],
        // ),
      ],
    );
  }

  RangeValues ProjectSizeRange = const RangeValues(0, 0);
  Widget projectSizeOption() {
    return Column(
      children: [
        RangeSlider(
          values: ProjectSizeRange,
          min: 0,
          max: 10000,
          divisions: 1000,
          labels: RangeLabels(
            ProjectSizeRange.start.round().toString(),
            ProjectSizeRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              ProjectSizeRange = values;
              minAreaController.text = values.start.toStringAsFixed(0);
              maxAreaController.text = values.end.toStringAsFixed(0);
            });
          },
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: TextFormField(
                  controller: minAreaController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                    hintText: "Min Budget",
                  ),
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     double minValue = double.tryParse(value) ?? _currentRangeValues.start;
                  //     _currentRangeValues = RangeValues(minValue, _currentRangeValues.end);
                  //   });
                  // },
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: TextFormField(
                  controller: maxAreaController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                    hintText: "Max Budget",
                  ),
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     double maxValue = double.tryParse(value) ?? _currentRangeValues.end;
                  //     _currentRangeValues = RangeValues(_currentRangeValues.start, maxValue);
                  //   });
                  // },
                ),
              ),
            ),
          ],
        ),
        // SizedBox(height: 10,),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text('${(ProjectSizeRange.start.toInt())}'),
        //     Text('${ProjectSizeRange.end.toInt()}'),
        //   ],
        // ),
      ],
    );
  }

  double projectAge = 0.0;
  Widget projectAgeOption() {
    return Slider(
      label: "${projectAge} years",
      value: projectAge,
      onChanged: (value) {
        setState(() {
          projectAge = value;
        });
      },
      min: 0,
      max: 30,
      divisions: 60,
    );
    // return Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: <Widget>[
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           minMaxTFF(
    //             UiUtils.getTranslatedLabel(context, "minLbl"),
    //           )
    //         ],
    //       ),
    //     ),
    //     const SizedBox(height: 10),
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           minMaxTFF(UiUtils.getTranslatedLabel(context, "maxLbl")),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget minMaxTFF(String minMax) {
    return Container(
        padding: EdgeInsetsDirectional.only(
            end: minMax == UiUtils.getTranslatedLabel(context, "minLbl")
                ? 5
                : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.backgroundColor),
        child: TextFormField(
            controller:
                (minMax == UiUtils.getTranslatedLabel(context, "minLbl"))
                    ? minController
                    : maxController,
            onChanged: ((value) {
              bool isEmpty = value.trim().isEmpty;
              if (minMax == UiUtils.getTranslatedLabel(context, "minLbl")) {
                if (isEmpty && searchbody.containsKey(Api.minPrice)) {
                  searchbody.remove(Api.minPrice);
                } else {
                  searchbody[Api.minPrice] = value;
                }
              } else {
                if (isEmpty && searchbody.containsKey(Api.maxPrice)) {
                  searchbody.remove(Api.maxPrice);
                } else {
                  searchbody[Api.maxPrice] = value;
                }
              }
            }),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                isDense: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor)),
                labelStyle: TextStyle(color: context.color.tertiaryColor),
                hintText: "00",
                label: Text(
                  minMax,
                ),
                prefixText: '${Constant.currencySymbol} ',
                prefixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.tertiaryColor),
                fillColor: Theme.of(context).colorScheme.secondaryColor,
                border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            style:
                TextStyle(color: Theme.of(context).colorScheme.tertiaryColor),
            /* onSubmitted: () */
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]));
  }

  Widget postedSinceOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: <Widget>[
        //     // Text(
        //     setMessageText(
        //         titleTxt: UiUtils.getTranslatedLabel(context, "postedSinceLbl"),
        //         txtColor: Theme.of(context).colorScheme.blackColor,
        //         txtStyle: Theme.of(context).textTheme.titleMedium,
        //         fontWeight: FontWeight.w500,
        //         context: context),
        //     Container(
        //       color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
        //       height: 1,
        //       width: MediaQuery.of(context).size.width * 0.45,
        //     ),
        //   ],
        // ),
        Text(UiUtils.getTranslatedLabel(context, "postedSinceLbl"))
            .size(context.font.large),
        SizedBox(
          height: 10.rh(context),
        ),

        SizedBox(
          height: 45,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              UiUtils.buildButton(
                context,
                fontSize: context.font.small,
                showElevation: false,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                buttonColor: searchbody[Api.postedSince] == Constant.filterAll
                    ? context.color.tertiaryColor
                    : context.color.tertiaryColor.withOpacity(0.05),
                textColor: searchbody[Api.postedSince] == Constant.filterAll
                    ? context.color.secondaryColor
                    : context.color.textColorDark,
                buttonTitle: UiUtils.getTranslatedLabel(context, "anytimeLbl"),
                onPressed: () {
                  onClickPosted(
                    Constant.filterAll,
                  );
                  setState(() {});
                },
              ),
              SizedBox(
                width: 5.rw(context),
              ),
              UiUtils.buildButton(
                fontSize: context.font.small,
                context,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                textColor:
                    searchbody[Api.postedSince] == Constant.filterLastWeek
                        ? context.color.secondaryColor
                        : context.color.textColorDark,
                showElevation: false,
                buttonColor:
                    searchbody[Api.postedSince] == Constant.filterLastWeek
                        ? context.color.tertiaryColor
                        : context.color.tertiaryColor.withOpacity(0.05),
                buttonTitle: UiUtils.getTranslatedLabel(context, "lastWeekLbl"),
                onPressed: () {
                  onClickPosted(
                    Constant.filterLastWeek,
                  );
                },
              ),
              SizedBox(
                width: 5.rw(context),
              ),
              UiUtils.buildButton(
                fontSize: context.font.small,
                context,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                showElevation: false,
                textColor:
                    searchbody[Api.postedSince] == Constant.filterYesterday
                        ? context.color.secondaryColor
                        : context.color.textColorDark,
                buttonColor:
                    searchbody[Api.postedSince] == Constant.filterYesterday
                        ? context.color.tertiaryColor
                        : context.color.tertiaryColor.withOpacity(0.05),
                buttonTitle:
                    UiUtils.getTranslatedLabel(context, "yesterdayLbl"),
                onPressed: () {
                  onClickPosted(
                    Constant.filterYesterday,
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  void onClickPosted(String val) {
    if (val == Constant.filterAll && searchbody.containsKey(Api.postedSince)) {
      searchbody[Api.postedSince] = "";
    } else {
      searchbody[Api.postedSince] = val;
    }

    postedOn = val;
    setState(() {});
  }
}
