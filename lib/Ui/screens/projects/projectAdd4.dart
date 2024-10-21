import 'dart:io';

import 'package:Housepecker/Ui/screens/projects/projectAdd6.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd7.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd2.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd5.dart';

import '../../../data/helper/designs.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ProjectFormFour extends StatefulWidget {
  final Map? body;
  final List? facilityList;
  final Map? data;
  final bool? isEdit;
  const ProjectFormFour({super.key, this.body, this.facilityList, this.isEdit, this.data});

  @override
  State<ProjectFormFour> createState() => _ProjectFormFourState();
}

class _ProjectFormFourState extends State<ProjectFormFour> {

  List selectedFacilities = [];
  List facilities = [];

  @override
  void initState() {
    if(widget.isEdit!) {
      selectedFacilities = widget.data!['assignfacilities'].map((item) {
        return item['outdoorfacilities'];
      }).toList();
      facilities = widget.data!['assignfacilities'].map((item) {
        return {
        'facility_id': item['outdoorfacilities']['id'],
        'distance': item['distance'],
        };
      }).toList();
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: widget.isEdit! ? "Update Project" : "Add Project",
          actions: const [
            Text("4/5",style: TextStyle(color: Colors.white)),
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
                    Text('OUTDOOR FACILITIES',
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
                              TextSpan(text: "Select Nearest Places",
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
                            (widget.facilityList!.length),
                                  (index) {
                                return Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if(selectedFacilities.any((item) => item['id'].toString() == widget.facilityList![index]['id'].toString())) {
                                        selectedFacilities.removeWhere((element) => element['id'] == widget.facilityList![index]['id']);
                                        facilities.removeWhere((element) => element['facility_id'] == widget.facilityList![index]['id']);
                                        setState(() {});
                                      } else {
                                        selectedFacilities.add(widget.facilityList![index]);
                                        facilities.add({
                                          'facility_id': widget.facilityList![index]['id'],
                                          'distance': ''
                                        });
                                        setState(() {});
                                      }
                                    },
                                    child: Chip(
                                        avatar: ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: SvgPicture.network(
                                            widget.facilityList![index]['image'],
                                            color: Color(0xff117af9),
                                            width: 18.0,
                                            height: 18.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        shape: StadiumBorder(
                                            side: BorderSide(color: selectedFacilities.any((item) => item['id'] == widget.facilityList![index]['id'])
                                                ? Color(0xffffa920)
                                                : Color(0xffd9d9d9))),
                                        backgroundColor: selectedFacilities.any((item) => item['id'] == widget.facilityList![index]['id'])
                                            ? Color(0xfffffbf3)
                                            : Color(0xfff2f2f2),
                                        padding: const EdgeInsets.all(1),
                                        label: Padding(
                                            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                                            child: Text('${widget.facilityList![index]['name']}',style: TextStyle(
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
                    SizedBox(height: 15,),
                    if(selectedFacilities.length > 0)
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Selected Places",
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
                        for(int i = 0; i < selectedFacilities.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Color(0xffffe9b6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: SvgPicture.network(
                                          selectedFacilities[i]['image'],
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Text('${selectedFacilities[i]['name']}',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 5),
                                          child: TextFormField(
                                            // controller: phoneControler,
                                            initialValue: facilities[i] != null ? facilities[i]['distance'].toString() : '',
                                            keyboardType: TextInputType.number,
                                            maxLength: 10,
                                            onChanged: (String? val) {
                                              setState(() {
                                                facilities[i]['distance'] = val!;
                                              });
                                            },
                                            decoration: const InputDecoration(
                                                // hintText: 'Enter Phone Number..',
                                                counterText: "",
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('km'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
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
              var body = {
                'facilities': facilities,
                ...widget.body!
              };
              print('ffffffffffffffff: ${body}');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ProjectFormSeven(body: body, isEdit: widget.isEdit, data: widget.data)),
              );
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
                'Next',
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
