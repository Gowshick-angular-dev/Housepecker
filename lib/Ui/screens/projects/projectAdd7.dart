import 'dart:io';

import 'package:Housepecker/Ui/screens/projects/projectAdd6.dart';
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

class ProjectFormSeven extends StatefulWidget {
  final Map? body;
  final Map? data;
  final bool? isEdit;
  const ProjectFormSeven({super.key, this.body, this.isEdit, this.data});

  @override
  State<ProjectFormSeven> createState() => _ProjectFormThreeState();
}

class _ProjectFormThreeState extends State<ProjectFormSeven> {

  List<ValueItem> selectedLoansWidget = [];
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
    var responseAme = await Api.get(url: Api.getAmenities, queryParameters: {
      'post': '1'
    });
    if(!responseAme['error']) {
      setState(() {
        amenityList = responseAme['data'];
        loading = false;
      });
      print('uuuuuuuuuuuuuuuuuuuuuuuuuu: ${widget.isEdit!}');
      if(widget.isEdit!) {
        List filteredData = [];
        // List filteredData = responseAme['data']
        //     .map((item) => widget.data!['amenity_id'].split(',').contains(item['id'].toString()))
        //     .toList();

        for(int i = 0; i < responseAme['data'].length; i++) {
          if(widget.data!['amenity_id'].split(',').contains(responseAme['data'][i]['id'].toString())) {
            filteredData.add(responseAme['data'][i]);
          }
        }
        print('uuuuuuuuuuuuuuuuuuuuuuuuuu: ${filteredData}');
        setState(() {
          selectedAmenities = filteredData;
        });
      }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15,),
                    Column(
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
                                        amenities.add({
                                          'amenity_id': amenityList![index]['id'],
                                        });
                                        setState(() {});
                                      }
                                    },
                                    child: Chip(
                                        avatar: ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: SvgPicture.network(
                                            amenityList![index]['image'],
                                            color: Color(0xff117af9),
                                            width: 18.0,
                                            height: 18.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        shape: StadiumBorder(
                                            side: BorderSide(color: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                                                ? Color(0xffffa920)
                                                : Color(0xffd9d9d9))),
                                        backgroundColor: selectedAmenities.any((item) => item['id'] == amenityList![index]['id'])
                                            ? Color(0xfffffbf3)
                                            : Color(0xfff2f2f2),
                                        padding: const EdgeInsets.all(1),
                                        label: Padding(
                                            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                                            child: Text('${amenityList![index]['name']}',style: TextStyle(
                                              color: Color(0xff333333),
                                              fontSize: 11,
                                            ),)
                                        )
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    SizedBox(height: 25,),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if(!loading) {
                  var body = {
                    'amenity_id': selectedAmenities.map((item) => item['id']).toList(),
                    ...widget.body!
                  };
                  print('ffffffffffffffff: ${body}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ProjectFormsixth(body: body, isEdit: widget.isEdit, data: widget.data)),
                  );
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
