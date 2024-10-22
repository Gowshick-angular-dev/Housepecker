import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../data/model/google_place_model.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';

class ProjectFilterPage extends StatefulWidget {
  @override
  _ProjectFilterPageState createState() => _ProjectFilterPageState();
}

class _ProjectFilterPageState extends State<ProjectFilterPage> {

  bool loading = false;
  List statusList = [];
  List amenityList = [];
  List roleList = [];
  List categoryList = [];
  List selectedAmenities = [];
  List amenities = [];
  List selectedCityList = [];
  List possessionDates = ['0-1 year', '1-2 years', '2-3 years', 'Greater than 4 years'];
  List projectTypeComm = [
    "Shop",
    "Office Space",
    "Showroom",
    "Bare Shell Office Space",
    "Ware House",
    "Godown",
    "Commercial Land",
    "Cold Storage"
  ];
  List projectTypeRes = [
    "Apartment",
    "Indipentant House/Villa",
    "Row House",
    "Plot",
    "Floor Villa",
    "1RK / Studio Apartment",
    "Doublex",
    "Penthouse",
    "Form House",
    "Form Land"
  ];
  List<GooglePlaceModel>? cities;
  String selectedPostDate = '';
  String selectedPossessionDate = '';

  TextEditingController minController =
  TextEditingController(text: Constant.propertyFilter?.minPrice);
  TextEditingController maxController =
  TextEditingController(text: Constant.propertyFilter?.maxPrice);
  TextEditingController minAreaController =
  TextEditingController();
  TextEditingController maxAreaController =
  TextEditingController();
  TextEditingController locationControler = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getMasters();
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
            itemCount: categoryList.isNotEmpty ? 2 : 0,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // selectedProjectBHK.add(categoriesList[index]['category']);
                    // if(selectedProjectCat.any((item) => item == categoryList[index]['id'])) {
                    //   selectedProjectCat.removeWhere((element) => element == categoryList[index]['id']);
                    //   setState(() {});
                    // } else {
                    //   selectedProjectCat.add(categoryList[index]['id']);
                    //   setState(() {});
                    // }
                    selectedProjectCat = [categoryList[index]['id']];
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

  // List selectedProjectTypes = [];
  // projectTypes() {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           // Image.asset("assets/FilterSceen/4.png",width: 18,height: 18,fit: BoxFit.cover,),
  //           // SizedBox(width: 6,),
  //           Text(UiUtils.getTranslatedLabel(context, 'BHK'),
  //             style: TextStyle(
  //                 fontSize: 14,
  //                 color: Color(0xff333333),
  //                 fontWeight: FontWeight.w600
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 15,),
  //       SizedBox(
  //         height: 45,
  //         child: ListView.builder(
  //           itemCount: 6,
  //           scrollDirection: Axis.horizontal,
  //           itemBuilder: (context, index) {
  //             return GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   // selectedProjectBHK.add(categoriesList[index]['category']);
  //                   if(selectedProjectBHK.any((item) => item == categoriesList[index]['category'])) {
  //                     selectedProjectBHK.removeWhere((element) => element == categoriesList[index]['category']);
  //                     setState(() {});
  //                   } else {
  //                     selectedProjectBHK.add(categoriesList[index]['category']);
  //                     setState(() {});
  //                   }
  //                 });
  //               },
  //               child: Padding(
  //                 padding: const EdgeInsets.all(1.0),
  //                 child: Container(
  //                   alignment: Alignment.center,
  //                   decoration: BoxDecoration(
  //                     color: selectedProjectBHK.any((item) => item == categoriesList[index]['category']) ? Color(0xfffffbf3) : Color(0xfff2f2f2),
  //                     borderRadius: BorderRadius.circular(100),
  //                     border: Border.all(
  //                       width: 1.5,
  //                       color: selectedProjectBHK.any((item) => item == categoriesList[index]['category']) ? Color(0xffffbf59) : Color(0xfff2f2f2),
  //                     ),
  //                   ),
  //                   height: 30,
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 16.0, vertical: 8),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         Text(
  //                           categoriesList[index]['category'],
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         // Other child widgets here
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //
  //     ],
  //   );
  // }

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

  possessionStatrts() {
    return Column(
      children: [
        Row(
          children: [
            // Image.asset("assets/FilterSceen/3.png",width: 18,height: 18,fit: BoxFit.cover,),
            // SizedBox(width: 6,),
            Text(UiUtils.getTranslatedLabel(context, 'Possession Starts'),style: TextStyle(
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
              for(int i = 0; i < possessionDates.length; i++)
                InkWell(
                onTap: () {
                  setState(() {
                    selectedPossessionDate = possessionDates[i];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedPossessionDate == possessionDates[i] ? const Color(0xfffffbf3) : const Color(0xfff2f2f2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 1.5,
                        color: selectedPossessionDate == possessionDates[i] ? const Color(0xffffbf59) : const Color(0xfff2f2f2),
                      ),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(possessionDates[i],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
          title: 'Filter', showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 15),
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

                            if (selectedCityList.isNotEmpty && selectedCityList[0] == selectedCity) {
                              selectedCityList.add(prediction.description!.split(',')[0]);
                              locationControler.text = '';
                            } else if(selectedCityList.isEmpty) {
                              selectedCityList.add(selectedCity);
                              locationControler.text = '';
                            } else {
                              locationControler.text = '';
                              HelperUtils.showSnackBarMessage(
                                context,
                                UiUtils.getTranslatedLabel(context, "Add a location near ${selectedCityList.first}"),
                                type: MessageType.success,
                                messageDuration: 3,
                              );
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
              projectCat(),
              const SizedBox(height: 15),
              Divider(thickness: 1,color: Color(0xffdddddd),),
              const SizedBox(height: 15),
              Row(
                children: [
                  // Image.asset("assets/FilterSceen/2.png",width: 18,height: 18,fit: BoxFit.cover,),
                  // SizedBox(width: 6,),
                  Text(UiUtils.getTranslatedLabel(context, 'budgetLbl'),style: const TextStyle(
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
              postedSince(),
              const SizedBox(height: 15),
              Divider(thickness: 1,color: Color(0xffdddddd),),
              const SizedBox(height: 15),
              possessionStatrts(),
              const SizedBox(height: 15),
              Divider(thickness: 1,color: Color(0xffdddddd),),
              const SizedBox(height: 15),




              projectbhk(),
              const SizedBox(height: 15),
              Divider(thickness: 1,color: Color(0xffdddddd),),
              // const SizedBox(height: 15),
              // Row(
              //   children: [
              //     // Image.asset("assets/FilterSceen/5.png",width: 18,height: 18,fit: BoxFit.cover,),
              //     // SizedBox(width: 6,),
              //     Text(UiUtils.getTranslatedLabel(context, 'Project Age'),style: TextStyle(
              //         fontSize: 14,
              //         color: Color(0xff333333),
              //         fontWeight: FontWeight.w600
              //     ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 10),
              // projectAgeOption(),
              // const SizedBox(height: 15),
              // Divider(thickness: 1,color: Color(0xffdddddd),),
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
        ),
      ),
    );
  }
}
