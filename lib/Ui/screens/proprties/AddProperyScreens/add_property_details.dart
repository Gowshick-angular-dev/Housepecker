import 'dart:io';

import 'package:Housepecker/Ui/screens/proprties/AddProperyScreens/propertyParameters.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../../app/routes.dart';
import '../../../../data/Repositories/property_repository.dart';
import '../../../../data/Repositories/system_repository.dart';
import '../../../../data/model/category.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/api.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/guestChecker.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/hive_utils.dart';
import '../../../../utils/imagePicker.dart';
import '../../../../utils/responsiveSize.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../widgets/blurred_dialoge_box.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/panaroma_image_view.dart';
import '../../widgets/propert_text_form_field.dart';

class AddPropertyDetails extends StatefulWidget {
  final Map? propertyDetails;
  final int catid;

  const AddPropertyDetails(
      {super.key, this.propertyDetails, required this.catid});

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return AddPropertyDetails(
          propertyDetails: arguments?['details'],
          catid: 1,
        );
      },
    );
  }

  @override
  State<AddPropertyDetails> createState() => _AddPropertyDetailsState();
}

class _AddPropertyDetailsState extends State<AddPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String PropertyTyperole = '';
  String? selectedDuration;

  int remainFreeProPost = 0;
  String selectedRole = 'Free Listing';
  int? selectedPackage = 0;
  int freeDuration = 0;

  FocusNode placesFocusNode = FocusNode();

  late final TextEditingController _propertyNameController =
      TextEditingController(text: widget.propertyDetails?['title']);
  late final TextEditingController _reraController =
      TextEditingController(text: widget.propertyDetails?['rera']);
  late final TextEditingController _FLoorController =
      TextEditingController(text: widget.propertyDetails?['floor_no']);
  late final TextEditingController _sqftController =
      TextEditingController(text: widget.propertyDetails?['sqft'].toString());
  late final TextEditingController _highlightController =
      TextEditingController(text: widget.propertyDetails?['highlight']);
  late final TextEditingController _brokerageControler =
      TextEditingController(text: (widget.propertyDetails?['brokerage'] ?? '')!.toLowerCase());
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.propertyDetails?['description']);
  late final TextEditingController _priceController =
      TextEditingController(text: widget.propertyDetails?['price']);
  late final TextEditingController _clientAddressController =
      TextEditingController(text: widget.propertyDetails?['client']);


  ///
  Map propertyData = {};

  final PickImage _pick360deg = PickImage();

  List editPropertyImageList = [];

  String selectedRentType = "Monthly";

  List amenityList = [];
  List selectedAmenities = [];
  List amenities = [];

  bool loading = false;
  List packages = [];



  @override
  void initState() {

    print("dddddddd${widget.propertyDetails}");
    if(widget.propertyDetails != null) {
      print('rrrrrrrrrrrrrrrrrrrrrrrrrrr: ${widget.propertyDetails?['floor_no']}');
      PropertyTyperole = widget.propertyDetails!['property_type'] == 'sell' ? 'Sell' : 'Rent/Lease';
      selectedDuration = widget.propertyDetails?['rentduration'];
    }

    getPackages();
    print(
        'THe selected Property Details ................................................${widget.propertyDetails?['id']}');

    if ((widget.propertyDetails != null)) {
      selectedRentType = widget.propertyDetails?['rentduration'] ?? "Monthly";
    }
    super.initState();
  }

  Future<void> getPackages() async {
    try {
      setState(() {
        loading = true;
      });

      final SystemRepository _systemRepository = SystemRepository();
      Map settings =
          await _systemRepository.fetchSystemSettings(isAnonymouse: false);

      List allPacks = settings['data']['package'] != null ? settings['data']['package']['user_purchased_package'] : [];
      Map freepackage = settings['data']['free_package'];
      if (freepackage != null) {
        setState(() {
          freeDuration = freepackage['duration'] ?? 0;
          remainFreeProPost = freepackage['property_limit'] - freepackage['used_property_limit'];
        });
      }

      // print('dflksndlsdgkdsg${allPacks}');

      List temp = [];
      if (settings['data']['package'] != null && allPacks != null) {
        for (int i = 0; i < allPacks.length; i++) {
          print(
              'hhhhhhhhhhhhhhhhhhhhhhhhhhh2: ${allPacks[i]['used_limit_for_project']}, ${allPacks[i]['package']['project_limit']}');

          if (((allPacks[i]['package']['project_limit'] ?? 0) -
                  (allPacks[i]['used_limit_for_project'] ?? 0)) >
              0) {
            temp.add(allPacks[i]);
          }
        }
      }
      setState(() {
        packages = temp;
        print('dfsdklgnsdlgnsdlkgn${packages}');
      });

      // Update state with the filtered packages
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

  // void _onTapContinue() async {
  //     _formKey.currentState?.save();
  //
  //     if (_propertyNameController.text == '' || PropertyTyperole == '' || (PropertyTyperole == 'Rent/Lease' && selectedDuration == '') ||  _priceController.text == '' ||
  //         _descriptionController.text == '' || _sqftController.text == '' || _brokerageControler.text == '' || ((Constant.addProperty['category']
  //         as Category).id != '3' && _FLoorController.text == '') || !((remainFreeProPost > 0 &&
  //         selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0)) {
  //       Future.delayed(Duration.zero, () {
  //         UiUtils.showBlurredDialoge(context,
  //             sigmaX: 5,
  //             sigmaY: 5,
  //             dialoge: BlurredDialogBox(
  //               svgImagePath: AppIcons.warning,
  //               title: UiUtils.getTranslatedLabel(context, "incomplete"),
  //               showCancleButton: false,
  //               acceptTextColor: context.color.buttonColor,
  //               onAccept: () async {
  //                 // Navigator.pop(context);
  //               },
  //               content: RichText(
  //                 text: const TextSpan(
  //                   children: [
  //                     TextSpan(
  //                       text: 'Please fill all the "',
  //                       style: TextStyle(
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w600),
  //                     ),
  //                     TextSpan(
  //                       text: "*",
  //                       style: TextStyle(
  //                           color:
  //                           Colors.red), // Customize asterisk color
  //                     ),
  //                     TextSpan(
  //                       text: '" fields!',
  //                       style: TextStyle(
  //                           color: Colors.black,
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w600),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ));
  //       });
  //       return;
  //     }
  //
  //     propertyData.addAll({
  //       'userid': HiveUtils.getUserId(),
  //       'package_id': selectedPackage.toString(),
  //       "title": _propertyNameController.text,
  //       "rera": _reraController.text,
  //       "sqft": _sqftController.text,
  //       "rentduration": selectedDuration,
  //       "highlight": _highlightController.text,
  //       "brokerage": _brokerageControler.text.toLowerCase(),
  //       "description": _descriptionController.text,
  //       "client_address": _clientAddressController.text,
  //       "price": _priceController.text,
  //       "floor_no": _FLoorController.text,
  //       "category_id": (Constant.addProperty['category'] as Category).id,
  //       "property_type": PropertyTyperole == 'Rent/Lease' ? '1' : '0',
  //       if ((widget.propertyDetails == null
  //                   ? (Constant.addProperty['propertyType'] as PropertyType)
  //                       .name
  //                   : widget.propertyDetails?['propType'])
  //               .toString()
  //               .toLowerCase() ==
  //           "rent")
  //       "rentduration": selectedRentType,
  //     });
  //
  //     if (widget.propertyDetails?.containsKey("assign_facilities") ?? false) {
  //       propertyData?["assign_facilities"] =
  //           widget.propertyDetails!['assign_facilities'];
  //     }
  //     if (widget.propertyDetails != null) {
  //       propertyData['id'] = widget.propertyDetails?['id'];
  //       propertyData['action_type'] = "0";
  //     }
  //
  //     Future.delayed(
  //       Duration.zero,
  //       () {
  //
  //         Navigator.push(context,
  //           MaterialPageRoute(
  //               builder:
  //                   (context) => PropertyParametersPage(
  //               details: propertyData,
  //               propertyDetails: widget.propertyDetails,
  //               isUpdate: (widget.propertyDetails != null)
  //         )));
  //
  //         // Navigator.pushNamed(
  //         //   context,
  //         //   Routes.setPropertyParametersScreen,
  //         //   arguments: {
  //         //     "details": propertyData,
  //         //     "isUpdate": (widget.propertyDetails != null)
  //         //   },
  //         // ).then((value) {
  //         //   _pickTitleImage.resumeSubscription();
  //         // });
  //       },
  //     );
  //   // }
  // }

  void _onTapContinue() async {
    if(loading) {
      return;
    }
    _formKey.currentState?.save();

    if (!((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0)) {
      Future.delayed(Duration.zero, () {
        UiUtils.showBlurredDialoge(
          context,
          sigmaX: 5,
          sigmaY: 5,
          dialoge: BlurredDialogBox(
            svgImagePath: AppIcons.warning,
            title: "",
            showCancleButton: false,
            acceptTextColor: context.color.buttonColor,
            onAccept: () async {
              // Navigator.pop(context);
            },
            content: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Property type dose not match this package",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }else{
      List<String> missingFields = [];

      if (_propertyNameController.text == '') missingFields.add("Property Name");
      if (PropertyTyperole == '') missingFields.add("Property Type Role");
      if (_priceController.text == '') missingFields.add("Price");
      if (_brokerageControler.text == '') missingFields.add("Brokerage");
      if (_descriptionController.text == '') missingFields.add("Description");
      if (_sqftController.text == '') missingFields.add("Square Feet");
      if ((Constant.addProperty['category'] as Category).id != '3' && _FLoorController.text == '') {
        missingFields.add("Floor");
      }




      if (missingFields.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialoge: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.getTranslatedLabel(context, "incomplete"),
              showCancleButton: false,
              acceptTextColor: context.color.buttonColor,
              onAccept: () async {
                // Navigator.pop(context);
              },
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Please fill in the following required fields:\n',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    ...missingFields.map((field) => TextSpan(
                      text: "- $field\n",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    )),
                  ],
                ),
              ),
            ),
          );
        });
        return;
      }
      propertyData.addAll({
        'userid': HiveUtils.getUserId(),
        'package_id': selectedPackage.toString(),
        "title": _propertyNameController.text,
        "rera": _reraController.text,
        "sqft": _sqftController.text,
        "highlight": _highlightController.text,
        "brokerage": _brokerageControler.text,
        "description": _descriptionController.text,
        "client_address": _clientAddressController.text,
        "price": _priceController.text,
        "floor": _FLoorController.text,
        "category_id": (Constant.addProperty['category'] as Category).id,
        "property_type": PropertyTyperole == 'Rent/Lease' ? '1' : '0',
        if ((widget.propertyDetails == null
            ? (Constant.addProperty['propertyType'] as PropertyType)
            .name
            : widget.propertyDetails?['propType'])
            .toString()
            .toLowerCase() ==
            "rent")
          "rentduration": selectedRentType,
      });

      if (widget.propertyDetails?.containsKey("assign_facilities") ?? false) {
        propertyData?["assign_facilities"] =
        widget.propertyDetails!['assign_facilities'];
      }
      if (widget.propertyDetails != null) {
        propertyData['id'] = widget.propertyDetails?['id'];
        propertyData['action_type'] = "0";
      }

      Future.delayed(
        Duration.zero,
            () {

          Navigator.push(context,
              MaterialPageRoute(
                  builder:
                      (context) => PropertyParametersPage(
                      details: propertyData,
                      propertyDetails: widget.propertyDetails,
                      isUpdate: (widget.propertyDetails != null)
                  )));

          // Navigator.pushNamed(
          //   context,
          //   Routes.setPropertyParametersScreen,
          //   arguments: {
          //     "details": propertyData,
          //     "isUpdate": (widget.propertyDetails != null)
          //   },
          // ).then((value) {
          //   _pickTitleImage.resumeSubscription();
          // });
        },
      );
    }


    // if (propertyNameController.text == '' || PropertyTyperole == '' ||  priceController.text == '' ||
    //     descriptionController.text == '' || sqftController.text == '' || ((Constant.addProperty['category']
    // as Category).id != '3' && _FLoorController.text == '') || !((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0)) {
    //   Future.delayed(Duration.zero, () {
    //     UiUtils.showBlurredDialoge(context,
    //         sigmaX: 5,
    //         sigmaY: 5,
    //         dialoge: BlurredDialogBox(
    //           svgImagePath: AppIcons.warning,
    //           title: UiUtils.getTranslatedLabel(context, "incomplete"),
    //           showCancleButton: false,
    //           acceptTextColor: context.color.buttonColor,
    //           onAccept: () async {
    //             // Navigator.pop(context);
    //           },
    //           content: RichText(
    //             text: const TextSpan(
    //               children: [
    //                 TextSpan(
    //                   text: 'Please fill all the "',
    //                   style: TextStyle(
    //                       color: Colors.black,
    //                       fontSize: 15,
    //                       fontWeight: FontWeight.w600),
    //                 ),
    //                 TextSpan(
    //                   text: "*",
    //                   style: TextStyle(
    //                       color:
    //                       Colors.red), // Customize asterisk color
    //                 ),
    //                 TextSpan(
    //                   text: '" fields!',
    //                   style: TextStyle(
    //                       color: Colors.black,
    //                       fontSize: 15,
    //                       fontWeight: FontWeight.w600),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ));
    //   });
    //   return;
    // }


    // }
  }



  @override
  void dispose() {
    _propertyNameController.dispose();
    _highlightController.dispose();
    _sqftController.dispose();
    _reraController.dispose();
    _FLoorController.dispose();
    _brokerageControler.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _clientAddressController.dispose();
    _pick360deg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: _onTapContinue,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "next")),
        ),
      ),
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.propertyDetails == null
            ? 'Post Property'
            : 'Edit Property',
        actions: const [
          Text(
            "2/5",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 14,
          ),
        ],
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('${widget.propertyDetails}'),
                  const Text("Property Details",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  if(widget.propertyDetails == null)
                    Column(
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
                      if (selectedRole == 'Free Listing' && !loading)
                        Text(
                          remainFreeProPost > 0
                              ? HiveUtils.getUserDetails().role == '3' ? "Note: This post is valid for 1 year from the date of posting." : "Note: This post is valid for $freeDuration months from the date of posting."
                              // ? "Note: This post is valid for 1 year from the date of posting."
                              : "Free Listing limit exceeded.",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display loader if data is being fetched
                          if (loading) // Assuming 'isLoading' is a boolean to track the loading state
                            Center(
                              child: const CupertinoActivityIndicator(
                                radius:
                                    8, // You can adjust the size of the loader here
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
                                              selectedPackage = 0;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Free Listing (${remainFreeProPost})",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
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
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (packages.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffe5e5e5), width: 1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      // Expanded(
                                      //   child: MultiSelectDropDown(
                                      //     onOptionSelected: (List<ValueItem> selectedOptions) {
                                      //       setState(() {
                                      //         selectedPackage = int.parse(selectedOptions[0].value!);
                                      //       });
                                      //     },
                                      //     options: [
                                      //       for (int i = 0; i < packages.length; i++)
                                      //         ValueItem(
                                      //           label: '${packages[i]['package']['name']}, Listing (${packages[i]['package']['project_limit']}), Units (${packages[i]['package']['no_of_units'] ?? 0}), Valid until (${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))})',
                                      //           value: '${packages[i]['package']['id']}',
                                      //         ),
                                      //     ],
                                      //     selectionType: SelectionType.single,
                                      //     chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                      //     dropdownHeight: 300,
                                      //     optionTextStyle: const TextStyle(fontSize: 16),
                                      //     selectedOptionIcon: const Icon(Icons.check_circle),
                                      //   ),
                                      // ),
                                      for (int i = 0; i < packages.length; i++)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPackage =
                                                  packages[i]['package']['id'];
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: selectedPackage !=
                                                        packages[i]['package']
                                                            ['id']
                                                    ? Color(0xfff9f9f9)
                                                    : Color(0xfffffbf3),
                                                border: Border.all(
                                                    color: selectedPackage !=
                                                            packages[i]
                                                                    ['package']
                                                                ['id']
                                                        ? Color(0xffe5e5e5)
                                                        : Color(0xffffa920),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              // alignment: Alignment.center,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffe5e5e5),
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: selectedPackage ==
                                                                packages[i][
                                                                        'package']
                                                                    ['id']
                                                            ? Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xffffa920),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xffffffff),
                                                                      width: 3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        packages[i]['package']
                                                            ['name'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xff646464),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Total Listings',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${packages[i]['package']['advertisement_limit']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Available Listings',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${packages[i]['package']['advertisement_limit'] - packages[i]['used_limit_for_advertisement']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Valid until',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              if (packages.isEmpty)
                                Column(
                                  children: [
                                    Text(
                                      'You dont have any active packages for post a project. If you want to buy click here!',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        GuestChecker.check(onNotGuest: () {
                                          Navigator.pushNamed(
                                              context,
                                              Routes
                                                  .subscriptionPackageListRoute);
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 10, left: 15, right: 15),
                                        width: double.infinity,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color(0xff117af9),
                                        ),
                                        child: Text(
                                          'Buy Subscription Plan',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (packages.isEmpty) const SizedBox(height: 10),
                            ],
                          ]
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
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
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                                    value: 'Sell',
                                    groupValue: PropertyTyperole,
                                    onChanged: (value) {
                                      if(widget.propertyDetails == null) {
                                        setState(() {
                                          PropertyTyperole = value!;
                                        });
                                      }
                                    },
                                  ),
                                  Text(
                                    "Sell",
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
                                    value: 'Rent/Lease',
                                    groupValue: PropertyTyperole,
                                    onChanged: (value) {
                                      if(widget.propertyDetails == null) {
                                        setState(() {
                                          PropertyTyperole = value!;
                                        });
                                      }
                                    },
                                  ),
                                  const Text(
                                    "Rent/Lease",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
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
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _propertyNameController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: 'Enter Property Title',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.propertyDetails == null
                          ? (Constant.addProperty['propertyType']
                      as PropertyType)
                          .name
                          : widget.propertyDetails?['propType'])
                          .toString()
                          .toLowerCase() ==
                          "rent") ...[
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Rent Price",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        RichText(
                          text: const TextSpan(
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
                                    color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField1(
                              action: TextInputAction.next,
                              prefix: Text("${Constant.currencySymbol} ",
                              style: TextStyle(
                                  color: Color(0xff929292),
                                  fontSize: 13,
                                  fontFamily: 'Roboto'),
                              ),
                              controller: _priceController,
                              formaters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d*')),
                              ],
                              isReadOnly: false,
                              keyboard: TextInputType.number,
                              // validator: CustomTextFieldValidator1.nullCheck,
                              hintText: "Enter proprty price (₹)",
                            ),
                          ),
                          if ((widget.propertyDetails == null
                              ? (Constant.addProperty['propertyType']
                          as PropertyType)
                              .name
                              : widget.propertyDetails?['propType'])
                              .toString()
                              .toLowerCase() ==
                              "rent") ...[
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: context.color.secondaryColor,
                                  border: Border.all(
                                      color: context.color.borderColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: DropdownButton<String>(
                                  value: selectedRentType,
                                  dropdownColor: context.color.primaryColor,
                                  underline: const SizedBox.shrink(),
                                  items: [
                                    DropdownMenuItem(
                                      value: "Daily",
                                      child: Text(
                                        "Daily".translate(context),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "Monthly",
                                      child: Text("Monthly".translate(context)),
                                    ),
                                    DropdownMenuItem(
                                      value: "Quarterly",
                                      child: Text("Quarterly".translate(context)),
                                    ),
                                    DropdownMenuItem(
                                      value: "Yearly",
                                      child: Text("Yearly".translate(context)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    selectedRentType = value ?? "";
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  if (PropertyTyperole == 'Rent/Lease')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Rent Duration",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  color:
                                      Colors.red, // Customize asterisk color
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: 10), // Add spacing between text and dropdown
                        Container(
                          width: size.width,
                          height: 60,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15), // Add horizontal padding
                          decoration: BoxDecoration(
                            color: Color(
                                0xFFf4f5f4), // Background color for the container
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                            // border: Border.all(color: Colors.grey), // Border styling
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text('Select duration'),
                              value:
                                  selectedDuration, // Store selected value in a variable
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDuration = newValue!;
                                });
                              },
                              items: <String>[
                                'Daily',
                                'Monthly',
                                'Quarterly',
                                'Yearly'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.rh(context),
                        ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "About Property",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        action: TextInputAction.next,
                        controller: _descriptionController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        hintText: 'Enter About Property',
                        maxLine: 100,
                        minLine: 6,
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text("More Information",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RERA No.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField1(
                        controller: _reraController,
                        action: TextInputAction.next,
                        hintText: 'Sdsd/213232/Fsf/6',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Size(Sq.Ft)",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField1(
                        controller: _sqftController,
                        keyboard: TextInputType.number,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: '2650 Sq.Ft',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     RichText(
                  //       text: const TextSpan(
                  //         children: [
                  //           TextSpan(
                  //             text: "Brokerage",
                  //             style: TextStyle(
                  //                 color: Colors.black,
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //           TextSpan(
                  //             text: " *",
                  //             style: TextStyle(
                  //                 color:
                  //                 Colors.red), // Customize asterisk color
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     const SizedBox(
                  //       height: 10,
                  //     ),
                  //     Row(
                  //       children: [
                  //         Expanded(
                  //           child: MultiSelectDropDown(
                  //             onOptionSelected:
                  //                 (List<ValueItem> selectedOptions) {
                  //               setState(() {
                  //                 _brokerageControler.text =
                  //                 selectedOptions[0].value!;
                  //               });
                  //             },
                  //             options: [
                  //               const ValueItem(label: "Yes", value: "yes"),
                  //               const ValueItem(label: "No", value: "no"),
                  //             ],
                  //             selectionType: SelectionType.single,
                  //             chipConfig:
                  //             const ChipConfig(wrapType: WrapType.wrap),
                  //             dropdownHeight: 300,
                  //             optionTextStyle: const TextStyle(fontSize: 15),
                  //             selectedOptionIcon:
                  //             const Icon(Icons.check_circle),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     const SizedBox(
                  //       height: 15,
                  //     ),
                  //   ],
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Brokerage",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                color:
                                Colors.red, // Customize asterisk color
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: 10), // Add spacing between text and dropdown
                      Container(
                        width: size.width,
                        height: 60,
                        padding: EdgeInsets.symmetric(
                            horizontal: 15), // Add horizontal padding
                        decoration: BoxDecoration(
                          color: Color(
                              0xFFf4f5f4), // Background color for the container
                          borderRadius:
                          BorderRadius.circular(8), // Rounded corners
                          // border: Border.all(color: Colors.grey), // Border styling
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text('Select'),
                            value: _brokerageControler.text == '' ? null : _brokerageControler.text, // Store selected value in a variable
                            onChanged: (String? newValue) {
                              setState(() {
                                _brokerageControler.text = newValue!;
                              });
                            },
                            items: <String>[
                              'yes',
                              'no'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Property Highlights",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '  (Note: Add highlights using commas ",")',
                              style: TextStyle(color: Colors.red, fontSize: 11), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _highlightController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: '',
                        minLine: 4,
                        maxLine: 4,
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  if((Constant.addProperty['category'] as Category).id != '3')
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Floor No",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _FLoorController,
                        keyboard: TextInputType.number,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: 'Enter floors',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              )),
        ),
      ),
    );
  }




}

class ChooseLocationFormField extends FormField<bool> {
  ChooseLocationFormField(
      {super.key,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool? initialValue,
      required Widget Function(FormFieldState<bool> state) build,
      bool autovalidateMode = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return build(state);
            });
}

class ImageAdapter extends StatelessWidget {
  final dynamic image;
  ImageAdapter({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    if (image is String) {
      return Image.network(
        image,
        fit: BoxFit.cover,
      );
    } else if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }
}
