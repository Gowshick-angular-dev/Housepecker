import 'dart:io';

import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd4.dart';

import '../../../data/helper/designs.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ProjectFormThree extends StatefulWidget {
  final Map? body;
  final Map? data;
  final bool? isEdit;
  const ProjectFormThree({super.key, this.body, this.isEdit, this.data});

  @override
  State<ProjectFormThree> createState() => _ProjectFormThreeState();
}

class _ProjectFormThreeState extends State<ProjectFormThree> {

  TextEditingController highlightsControler = TextEditingController();

  List selectedLoans = [];
  List<ValueItem> selectedLoansWidget = [];
  List facilityList = [];
  List homeLoanList = [];
  bool loading = false;
  List amenityList = [];
  List selectedAmenities = [];
  List amenities = [];

  @override
  void initState() {
    getServiceTypes();
    super.initState();
  }

  Future<void> getServiceTypes() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.homeLoanOffers);
    if(!response['error']) {
      setState(() {
        homeLoanList = response['data'];
      });
      if(widget.isEdit!) {
        highlightsControler.text = widget.data!['project_details'][0]['highlights'];
        selectedLoans = widget.data!['project_details'][0]['approved_banks'].map((item) => item['name']).toList();
        // selectedLoansWidget = homeLoanList.where((user) => widget.data!['project_details'][0]['home_loans'].split(',').toList().contains(user['id'].toString())).toList().map((item) {
        //   return ValueItem(
        //       label: item['name'], value: item['id'].toString());
        // }).toList();
        selectedLoansWidget = widget.data!['project_details'][0]['approved_banks']!.map<ValueItem>((item) {
          return ValueItem(label: item['name'], value: item['id'].toString());
        }).toList();
        setState(() {});
      }
    }

    var responseAme = await Api.get(url: Api.getAmenities, queryParameters: {
      'post': '1'
    });
    if(!responseAme['error']) {
      setState(() {
        amenityList = responseAme['data'];
      });
    }

    var responseFac = await Api.get(url: Api.getOutdoorFacilites);
    if(!responseFac['error']) {
      setState(() {
        facilityList = responseFac['data'];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: UiUtils.getTranslatedLabel(
            context,
            "Add Project",
          ),
          actions: const [
            Text("3/5",style: TextStyle(color: Colors.white)),
            SizedBox(
              width: 14,
            ),
          ],
          showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15,),
                    Text('More Information',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    SizedBox(height: 15,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Approved Banks",
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
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropDown(
                                onOptionSelected: (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    selectedLoans = selectedOptions.map((item) {
                                      return item.value;
                                    }).toList();
                                    selectedLoansWidget = selectedOptions;
                                  });
                                },
                                selectedOptions: widget.isEdit! ? selectedLoansWidget : [],
                                options:
                                homeLoanList.map((items) {
                                  return ValueItem(
                                      label: items['name'], value: items['id'].toString());
                                }).toList(),
                                selectionType: SelectionType.multi,
                                chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                optionTextStyle: const TextStyle(fontSize: 16),
                                selectedOptionIcon: const Icon(Icons.check_circle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Key Highlights",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
                              ),
                              TextSpan(
                                text: '  (Notes: Add highlights using commas ",")',
                                style: TextStyle(color: Colors.red, fontSize: 11), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Color(0xffe1e1e1)
                                  ),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0,right: 5),
                                  child: TextFormField(
                                    maxLines: 4,
                                    controller: highlightsControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Highlights..',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          color: Color(0xff9c9c9c),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                            ))
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     RichText(
                    //       text: TextSpan(
                    //         children: [
                    //           TextSpan(text: "Amenities",
                    //             style: TextStyle(
                    //                 color: Colors.black,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w600
                    //             ),),
                    //           // TextSpan(
                    //           //   text: " *",
                    //           //   style: TextStyle(color: Colors.red), // Customize asterisk color
                    //           // ),
                    //         ],
                    //       ),
                    //     ),
                    //     SizedBox(height: 15,),
                    //     Wrap(
                    //       children: List.generate(
                    //           (amenityList!.length),
                    //               (index) {
                    //             return Padding(
                    //               padding: const EdgeInsets.all(3.0),
                    //               child: GestureDetector(
                    //                 onTap: () {
                    //                   if(selectedAmenities.any((item) => item['id'].toString() == amenityList![index]['id'].toString())) {
                    //                     selectedAmenities.removeWhere((element) => element['id'] == amenityList![index]['id']);
                    //                     amenities.removeWhere((element) => element['facility_id'] == amenityList![index]['id']);
                    //                     setState(() {});
                    //                   } else {
                    //                     selectedAmenities.add(amenityList![index]);
                    //                     amenities.add({
                    //                       'amenity_id': amenityList![index]['id'],
                    //                     });
                    //                     setState(() {});
                    //                   }
                    //                 },
                    //                 child: Chip(
                    //                     avatar: ClipRRect(
                    //                       borderRadius: BorderRadius.circular(10.0),
                    //                       child: SvgPicture.network(
                    //                         amenityList![index]['image'],
                    //                         color: Color(0xff117af9),
                    //                         width: 18.0,
                    //                         height: 18.0,
                    //                         fit: BoxFit.cover,
                    //                       ),
                    //                     ),
                    //                     shape: StadiumBorder(
                    //                         side: BorderSide(color: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                    //                             ? Color(0xffffa920)
                    //                             : Color(0xffd9d9d9))),
                    //                     backgroundColor: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                    //                         ? Color(0xfffffbf3)
                    //                         : Color(0xfff2f2f2),
                    //                     padding: const EdgeInsets.all(1),
                    //                     label: Padding(
                    //                         padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                    //                         child: Text('${amenityList![index]['name']}',style: TextStyle(
                    //                           color: Color(0xff333333),
                    //                           fontSize: 11,
                    //                         ),)
                    //                     )
                    //                 ),
                    //               ),
                    //             );
                    //           }),
                    //     ),
                    //     SizedBox(height: 25,),
                    //   ],
                    // ),
                    SizedBox(height: 25,),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if(!loading) {
                if(highlightsControler.text != '') {
                  var body = {
                    'approved_banks': selectedLoans,
                    'highlights': highlightsControler.text,
                    ...widget.body!
                  };
                  print('ffffffffffffffff: ${body}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ProjectFormFour(body: body, facilityList: facilityList, isEdit: widget.isEdit, data: widget.data)),
                  );
                } else {
                  HelperUtils.showSnackBarMessage(
                      context, UiUtils.getTranslatedLabel(context, "Please fill all the (*) marked fields!"),
                      type: MessageType.warning, messageDuration: 5);
                }
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10,left: 15,right: 15),
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff117af9),
              ),
              child: Text(
                '${loading ? 'Please wait...' : 'Next'}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
