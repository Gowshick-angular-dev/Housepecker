import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd2.dart';

import '../../../app/routes.dart';
import '../../../data/Repositories/system_repository.dart';
import '../../../data/helper/designs.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ProjectFormSecond extends StatefulWidget {
  final Map? data;
  final Map? body;
  final bool? isEdit;
  const ProjectFormSecond({super.key, this.isEdit, this.data, this.body});

  @override
  State<ProjectFormSecond> createState() => _ProjectFormSecondState();
}

class _ProjectFormSecondState extends State<ProjectFormSecond> {
  int? selectedPackage = 0;
  TextEditingController locationControler = TextEditingController();
  TextEditingController descriptionControler = TextEditingController();
  TextEditingController minPriceControler = TextEditingController();
  TextEditingController maxPriceControler = TextEditingController();
  TextEditingController avgPriceControler = TextEditingController();
  TextEditingController nameControler = TextEditingController();
  TextEditingController offersControler = TextEditingController();
  TextEditingController cityControler = TextEditingController();
  TextEditingController StateController = TextEditingController();
  TextEditingController ContryControler = TextEditingController();
  TextEditingController AdresssController = TextEditingController();
  List packages = [];
  String projectType = 'Sell';
  String selectedRole = 'Free Listing';
  String brokerage = '';
  int remainFreeProPost = 0;
  List<ValueItem> brokerageWidget = [];
  String propertyType = '';
  List<ValueItem> propertyTypeWidget = [];
  String status = '';
  List<ValueItem> statusWidget = [];
  String category = '';
  List<ValueItem> categoryWidget = [];
  String lat = '';
  String lng = '';

  List categoryList = [];
  List statusList = [];

  bool loading = false;

  @override
  void initState() {
    getMasters();
    getPackages();
    super.initState();
  }

  Future<void> getPackages() async {
    try {
      // Start loading
      setState(() {
        loading = true;
      });

      final SystemRepository _systemRepository = SystemRepository();
      Map settings = await _systemRepository.fetchSystemSettings(isAnonymouse: false);

      print('hhhhhhhhhhhhhhhhhhhhhhhhhhh: ${settings['data']}');

      List allPacks = settings['data']['package']['user_purchased_package'];
      Map freepackage = settings['data']['free_package'];

      if (freepackage != null) {
        setState(() {
          remainFreeProPost = freepackage['project_limit'] -
              freepackage['used_project_limit'];
        });
      }

      List temp = [];
      if (settings['data']['package'] != null && allPacks != null) {
        for (int i = 0; i < allPacks.length; i++) {
          print('hhhhhhhhhhhhhhhhhhhhhhhhhhh2: ${allPacks[i]['used_limit_for_project']}, ${allPacks[i]['package']['project_limit']}');

          if (((allPacks[i]['package']['project_limit'] ?? 0) -
              (allPacks[i]['used_limit_for_project'] ?? 0)) >
              0) {
            temp.add(allPacks[i]);
          }
        }
      }
      setState(() {
        packages = temp;
        print('fjbsdjfbdn${packages}');
      });
      // Update state with the filtered packages
      // setState(() {
      //   packages = temp;
      // });

    } catch (e, stacktrace) {
      // Handle any error that occurs in the try block
      print('An error occurred: $e');
      print('Stacktrace: $stacktrace');

      // Optionally, you can show an error message to the user using a Snackbar or AlertDialog
    } finally {
      // Stop loading, whether an error occurred or not
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getUpdateProject() async {
    locationControler.text = widget.data!['address'];
    descriptionControler.text = widget.data!['description'];
    nameControler.text = widget.data!['title'];
    cityControler.text = widget.data!['city'];
    projectType = widget.data!['project_type']!.toString();
    minPriceControler.text = widget.data!['price'].toString();
    maxPriceControler.text = widget.data!['price'].toString();
    offersControler.text = widget.data!['project_details'][0]['offers'] ?? '';
    avgPriceControler.text = widget.data!['project_details'][0]['avg_price'] ?? '';
    brokerage = widget.data!['project_details'][0]['brokerage'] ?? '';
    propertyType = widget.data!['project_details'][0]['property_type'] ?? '';
    status = widget.data!['project_details'][0]['project_status'].toString();
    // category = widget.data!['category_id'].toString();
    lat = widget.data!['latitude'];
    lng = widget.data!['longitude'];

    // categoryWidget = categoryList.where((element) => element['id'].toString() == widget.data!['category_id'].toString()).toList().map((item) {
    //   return ValueItem(
    //       label: item['category'], value: item['id'].toString());
    // }).toList();

    statusWidget = statusList
        .where((element) =>
            element['id'].toString() ==
            widget.data!['project_details'][0]['project_status'].toString())
        .toList()
        .map((item) {
      return ValueItem(label: item['name'], value: item['id'].toString());
    }).toList();

    if (widget.data!['project_details'][0]['brokerage'] == 'yes') {
      brokerageWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      brokerageWidget = [ValueItem(label: 'No', value: 'no')];
    }

    propertyTypeWidget = [ValueItem(label: widget.data!['project_details'][0]['property_type'], value: widget.data!['project_details'][0]['property_type'])];

    setState(() {
      loading = false;
    });
  }

  Future<void> getMasters() async {
    setState(() {
      loading = true;
    });
    var staResponse = await Api.get(url: Api.status);
    if (!staResponse['error']) {
      setState(() {
        statusList = staResponse['data'];
      });
    }
    if (widget.isEdit!) {
      getUpdateProject();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  String getAddress(Placemark place) {
    try {
      String address = "";
      if (place.street == null && place.subLocality != null) {
        address = place.subLocality!;
      } else if (place.street == null && place.subLocality == null) {
        address = "";
      } else {
        address = "${place.street ?? ""},${place.subLocality ?? ""}";
      }

      return address;
    } catch (e, st) {
      throw Exception("$st");
    }
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      // Extract and format the address
      Placemark place = placemarks.first;
      String address =
          '${place.street} ${place.thoroughfare}, ${place.subLocality} ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
      return address;
    } catch (e) {
      print("Error fetching address: $e");
      return ""; // Or return a default error message
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: UiUtils.getTranslatedLabel(
            context,
            "Add Project",
          ),
          actions: const [
            Text("1/5", style: TextStyle(color: Colors.white)),
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
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Continue With",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: " *",
                            style: TextStyle(
                                color: Colors.red), // Customize asterisk color
                          ),
                        ],
                      ),
                    ),
                    if (selectedRole == 'Free Listing')
                      Text(
                        remainFreeProPost > 0 ? "Note: This post is valid for 10 days from the date of posting." : "Free Listing limit exceeded.",
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    const SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display loader if data is being fetched
                        if (loading) // Assuming 'isLoading' is a boolean to track the loading state
                          Center(
                            child: const CupertinoActivityIndicator(
                              radius: 8, // You can adjust the size of the loader here
                            ),
                          )
                        else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  height: size.height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        activeColor: Colors.blue,
                                        value: 'Free Listing',
                                        groupValue: selectedRole,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRole = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Free Listing (${remainFreeProPost})",
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height: size.height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        activeColor: Colors.blue,
                                        value: 'Package',
                                        groupValue: selectedRole,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRole = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Package",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          if (selectedRole == 'Package') ...[
                            const SizedBox(height: 15),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Package",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: " *",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: MultiSelectDropDown(
                                    onOptionSelected: (List<ValueItem> selectedOptions) {
                                      setState(() {
                                        selectedPackage = int.parse(selectedOptions[0].value!);
                                      });
                                    },
                                    options: [
                                      for (int i = 0; i < packages.length; i++)
                                        ValueItem(
                                          label: '${packages[i]['package']['name']}, Listing (${packages[i]['package']['project_limit']}), Units (${packages[i]['package']['no_of_units'] ?? 0}), Valid until (${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))})',
                                          value: '${packages[i]['package']['id']}',
                                        ),
                                    ],
                                    selectionType: SelectionType.single,
                                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                    dropdownHeight: 300,
                                    optionTextStyle: const TextStyle(fontSize: 16),
                                    selectedOptionIcon: const Icon(Icons.check_circle),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ]
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Property Type",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                    Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      propertyType = selectedOptions[0].value!;
                                    } else {
                                      propertyType = '';
                                    }
                                    propertyTypeWidget = selectedOptions;
                                  });
                                },
                                selectedOptions:
                                widget.isEdit! ? propertyTypeWidget : [],
                                options: widget.body!['category_id'] == 2 ? [
                                  ValueItem(label: "Shop", value: "Shop"),
                                  ValueItem(label: "Office Space", value: "Office Space"),
                                  ValueItem(label: "Showroom", value: "Showroom"),
                                  ValueItem(label: "Bare Shell Office Space", value: "Bare Shell Office Space"),
                                  ValueItem(label: "Ware House", value: "Ware House"),
                                  ValueItem(label: "Godown", value: "Godown"),
                                  ValueItem(label: "Commercial Land", value: "Commercial Land"),
                                  ValueItem(label: "Cold Storage", value: "Cold Storage"),
                                  ] : [
                                  ValueItem(label: "Apartment", value: "Apartment"),
                                  ValueItem(label: "Indipentant House/Villa", value: "Indipentant House/Villa"),
                                  ValueItem(label: "Row House", value: "Row House"),
                                  ValueItem(label: "Plot", value: "Plot"),
                                  ValueItem(label: "Floor Villa", value: "Floor Villa"),
                                  ValueItem(label: "1RK / Studio Apartment", value: "1RK / Studio Apartment"),
                                  ValueItem(label: "Doublex", value: "Doublex"),
                                  ValueItem(label: "Penthouse", value: "Penthouse"),
                                  ValueItem(label: "Form House", value: "Form House"),
                                  ValueItem(label: "Form Land", value: "Form Land"),
                                ],
                                selectionType: SelectionType.single,
                                chipConfig:
                                const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                optionTextStyle: const TextStyle(fontSize: 16),
                                selectedOptionIcon:
                                const Icon(Icons.check_circle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Title",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: nameControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Title..',
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
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Brokerage",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                    Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      brokerage = selectedOptions[0].value!;
                                    } else {
                                      brokerage = '';
                                    }
                                    brokerageWidget = selectedOptions;
                                  });
                                },
                                selectedOptions:
                                widget.isEdit! ? brokerageWidget : [],
                                options: [
                                  ValueItem(label: "Yes", value: "yes"),
                                  ValueItem(label: "No", value: "no")
                                ],
                                selectionType: SelectionType.single,
                                chipConfig:
                                const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                optionTextStyle: const TextStyle(fontSize: 16),
                                selectedOptionIcon:
                                const Icon(Icons.check_circle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Status",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                    Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      status = selectedOptions[0].value!;
                                    } else {
                                      status = '';
                                    }
                                    statusWidget = selectedOptions;
                                  });
                                },
                                selectedOptions: widget.isEdit! ? statusWidget : [],
                                options: statusList.map((item) {
                                  return ValueItem(
                                      label: "${item['name']}",
                                      value: "${item['id']}");
                                }).toList(),
                                selectionType: SelectionType.single,
                                chipConfig:
                                const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                optionTextStyle: const TextStyle(fontSize: 16),
                                selectedOptionIcon:
                                const Icon(Icons.check_circle),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Price",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: minPriceControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Min Price..',
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
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    controller: maxPriceControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Max Price..',
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
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    // if (widget.body!['category_id'] == 4)
                    //   Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       RichText(
                    //         text: TextSpan(
                    //           children: [
                    //             TextSpan(
                    //               text: "Avg Price",
                    //               style: TextStyle(
                    //                   color: Colors.black,
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.w600),
                    //             ),
                    //             TextSpan(
                    //               text: " *",
                    //               style: TextStyle(
                    //                   color: Colors
                    //                       .red), // Customize asterisk color
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         height: 10,
                    //       ),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                 border: Border.all(
                    //                     width: 1, color: Color(0xffe1e1e1)),
                    //                 color: Color(0xfff5f5f5),
                    //                 borderRadius: BorderRadius.circular(
                    //                     10.0), // Optional: Add border radius
                    //               ),
                    //               child: Padding(
                    //                 padding: const EdgeInsets.only(
                    //                     left: 8.0, right: 5),
                    //                 child: TextFormField(
                    //                   controller: avgPriceControler,
                    //                   keyboardType: TextInputType.number,
                    //                   decoration: const InputDecoration(
                    //                       hintText: 'Enter Avg Price..',
                    //                       hintStyle: TextStyle(
                    //                         fontFamily: 'Poppins',
                    //                         fontSize: 14.0,
                    //                         color: Color(0xff9c9c9c),
                    //                         fontWeight: FontWeight.w500,
                    //                         decoration: TextDecoration.none,
                    //                       ),
                    //                       enabledBorder: UnderlineInputBorder(
                    //                         borderSide: BorderSide(
                    //                           color: Colors.transparent,
                    //                         ),
                    //                       ),
                    //                       focusedBorder: UnderlineInputBorder(
                    //                           borderSide: BorderSide(
                    //                         color: Colors.transparent,
                    //                       ))),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       SizedBox(
                    //         height: 25,
                    //       ),
                    //     ],
                    //   ),


                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Offer section",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //           Colors.red), // Customize asterisk color
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    maxLines: 4,
                                    controller: offersControler,
                                    // onChanged: (String? val) {
                                    //   getBanks(categories, searchControler.text, val!, branchControler.text);
                                    // },
                                    decoration: const InputDecoration(
                                        hintText: 'Offer details..',
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
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "About Project",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color:
                                        Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Optional: Add border radius
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 5),
                                  child: TextFormField(
                                    maxLines: 4,
                                    controller: descriptionControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter description..',
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
                                        ))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if(loading)
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff117af9),
              ),
              child: Text(
                'Please wait...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          if(!loading)
            InkWell(
            onTap: () {
                if (nameControler.text != '' &&
                    minPriceControler.text != '' &&
                    maxPriceControler.text != '' &&
                    brokerage != '' &&
                    status != '' &&
                    descriptionControler.text != '' &&
                    ((remainFreeProPost > 0 && selectedPackage == 0) ||
                        (selectedPackage != 0 && remainFreeProPost < 1))) {
                  var body = {
                    'package_id': selectedPackage,
                    'title': nameControler.text,
                    'min_price': minPriceControler.text,
                    'max_price': maxPriceControler.text,
                    'avg_price': avgPriceControler.text,
                    'property_type': propertyType,
                    'project_status': status,
                    'brokerage': brokerage,
                    'project_status': status,
                    'offers': offersControler.text,
                    'description': descriptionControler.text,
                    ...widget.body!
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProjectFormTwo(
                            body: body,
                            isEdit: widget.isEdit,
                            data: widget.data)),
                  );
                } else {
                  HelperUtils.showSnackBarMessage(
                      context,
                      UiUtils.getTranslatedLabel(
                          context, "Please fill all the (*) marked fields!"),
                      type: MessageType.warning,
                      messageDuration: 5);
                }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
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
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
