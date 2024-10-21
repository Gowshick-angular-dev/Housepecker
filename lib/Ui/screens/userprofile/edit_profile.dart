import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/Personalized/personalized_property_screen.dart';
import 'package:Housepecker/Ui/screens/widgets/custom_text_form_field.dart';
import 'package:Housepecker/Ui/screens/widgets/image_cropper.dart';
import 'package:Housepecker/data/cubits/auth/auth_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_nearby_property_cubit.dart';
import 'package:Housepecker/data/cubits/property/fetch_promoted_properties_cubit.dart';
import 'package:Housepecker/data/cubits/slider_cubit.dart';
import 'package:Housepecker/data/cubits/system/user_details.dart';
import 'package:Housepecker/data/helper/custom_exception.dart';
import 'package:Housepecker/data/helper/designs.dart';
import 'package:Housepecker/data/model/user_model.dart';
import 'package:Housepecker/utils/AppIcon.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/constant.dart';
import 'package:Housepecker/utils/hive_utils.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:Housepecker/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes.dart';
import '../../../data/helper/widgets.dart';
import '../../../data/model/google_place_model.dart';
import '../../../utils/api.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_keys.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/BottomSheets/choose_location_bottomsheet.dart';

class UserProfileScreen extends StatefulWidget {
  final String from;
  final bool? navigateToHome;
  final bool? popToCurrent;
  const UserProfileScreen({
    Key? key,
    required this.from,
    this.navigateToHome,
    this.popToCurrent,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => UserProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
      builder: (_) => UserProfileScreen(
        from: arguments['from'] as String,
        popToCurrent: arguments['popToCurrent'] as bool?,
        navigateToHome: arguments['navigateToHome'] as bool?,
      ),
    );
  }
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController pintrestController = TextEditingController();
  final TextEditingController reraController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController completedProjectController = TextEditingController();
  final TextEditingController currentProjectController = TextEditingController();
  final TextEditingController officeTimingController = TextEditingController();
  final TextEditingController webLinkController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController rentNumberController = TextEditingController();
  final TextEditingController saleNumberController = TextEditingController();

  final FocusNode placesFocusNode = FocusNode();

  dynamic size;
  dynamic city, _state, country, placeid;
  String? name, email, address;
  File? fileUserimg;
  bool isNotificationsEnabled = true;
  bool roleError = false;
  List roleList = [];
  String selectedRole = '';
  ValueItem? selectedRoleWidget;
  String selectedResidentType = '';
  ValueItem? selectedResidentTypeWidget;

  List<File> gallary = [];
  List gallaryEdit = [];
  List gallaryImages = [];
  List<File> documents = [];
  List documentFiles = [];
  List documentEdit = [];

  @override
  void initState() {
    super.initState();

    city = HiveUtils.getCityName();
    _state = HiveUtils.getStateName();
    country = HiveUtils.getCountryName();
    placeid = HiveUtils.getCityPlaceId();
    phoneController.text = _saperateNumber();
    nameController.text = HiveUtils.getUserDetails().name ?? "";
    emailController.text = HiveUtils.getUserDetails().email ?? "";
    addressController.text = HiveUtils.getUserDetails().address ?? "";
    selectedRole = HiveUtils.getUserDetails().role ?? "";
    aboutController.text = HiveUtils.getUserDetails().aboutMe ?? '';
    facebookController.text = HiveUtils.getUserDetails().facebookId ?? '';
    twitterController.text = HiveUtils.getUserDetails().twitterId ?? '';
    instagramController.text = HiveUtils.getUserDetails().instagramId ?? '';
    pintrestController.text = HiveUtils.getUserDetails().pintrestId ?? '';
    reraController.text = HiveUtils.getUserDetails().rera ?? '';
    companyController.text = HiveUtils.getUserDetails().companyName ?? '';
    completedProjectController.text = HiveUtils.getUserDetails().completedProject ?? '';
    currentProjectController.text = HiveUtils.getUserDetails().currentProject ?? '';
    officeTimingController.text = HiveUtils.getUserDetails().officeTiming ?? '';
    webLinkController.text = HiveUtils.getUserDetails().webLink ?? '';
    gstController.text = HiveUtils.getUserDetails().gstNo ?? '';
    experienceController.text = HiveUtils.getUserDetails().experience ?? '';
    rentNumberController.text = HiveUtils.getUserDetails().rentNumber ?? '';
    saleNumberController.text = HiveUtils.getUserDetails().saleNumber ?? '';
    selectedResidentType = HiveUtils.getUserDetails().residentType ?? '';
    gallaryEdit = HiveUtils.getUserDetails().gallery ?? [];
    selectedResidentTypeWidget = HiveUtils.getUserDetails().residentType != null ? ValueItem(
        label: HiveUtils.getUserDetails().residentType!, value: HiveUtils.getUserDetails().residentType!) : null;

    isNotificationsEnabled =
        HiveUtils.getUserDetails().notification == 1 ? true : false;

    _saperateNumber();
    getRoles();
  }

  Future<void> getRoles() async {
    var response = await Api.get(url: Api.roles);
    if(!response['error']) {
      for(int i = 0; i < response['data'].length; i++) {
        if(response['data'][i]['id'].toString() == HiveUtils.getUserDetails().role.toString()) {
          setState(() {
            selectedRoleWidget = ValueItem(label: response['data'][i]['name'], value: response['data'][i]['id'].toString());
          });
        }
      }
      setState(() {
        roleList = response['data'];
      });
    }
  }

  String _saperateNumber() {
    // FirebaseAuth.instance.currentUser.sendEmailVerification();
    String? mobile = HiveUtils.getUserDetails().mobile;

    String? countryCode = HiveUtils.getCountryCode();

    int countryCodeLength = (countryCode?.length ?? 0);

    String mobileNumber = mobile!.substring(countryCodeLength, mobile.length);

    mobileNumber = "+$mobile";
    return mobileNumber;
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
  }

  galleryImages() async {
    CropImage.init(context);
    var images = await ImagePicker().pickMultiImage();
    if (images.length > 0) {
      for(int i = 0; i < images.length; i++) {
        gallary.add(File(images[i].path));
        gallaryImages.add(await MultipartFile.fromFile(File(images[i].path).path));
        setState(() {});
      }
    } else {
      gallary = [];
    }
    setState(() {});
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg', 'jpeg', 'pdf'
      ],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      List<PlatformFile> filteredFiles = files.where((file) {
        return file.size <= 2 * 1024 * 1024;
      }).toList();

      List<File> docFiles = [];
      List docMulFiles = [];
      for(int i = 0; i < filteredFiles.length; i++) {
        docMulFiles.add(await MultipartFile.fromFile(File(filteredFiles[i].path!).path));
        docFiles.add(File(filteredFiles[i].path!));
      }
      setState(() {
        documents = [...documents, ...docFiles];
        documentFiles = [...documentFiles, ...docMulFiles];
      });

      if (documents!.length < files.length) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Some files were excluded because they exceed the 2MB size limit.'),
        ));
      }
    }
  }

  void _onTapChooseLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      if (Constant.isDemoModeOn) {
        HelperUtils.showSnackBarMessage(context, "Not valid in demo mode");

        return;
      }
    }

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
      placeid = place.placeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: safeAreaCondition(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: widget.from == "login"
              ? null
              : UiUtils.buildAppBar(context, title: "Profile", showBackButton: true),
          body: ScrollConfiguration(
            behavior: RemoveGlow(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  color: Color(0xfff9f9f9),
                                  child: Padding(
                                    padding: const EdgeInsets.all(25),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: buildProfilePicture(),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xfff9f9f9),
                                  ),
                                  child:      Container(
                                    height: 20,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        topLeft: Radius.circular(30),
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20,right: 20,),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildTextField(
                                        context,
                                        title: "Name",
                                        controller: nameController,
                                        validator: CustomTextFieldValidator.nullCheck,
                                      ),
                                      buildTextField(
                                        context,
                                        title: "companyEmailLbl",
                                        controller: emailController,
                                        validator: CustomTextFieldValidator.email,
                                      ),
                                      buildTextField(
                                        context,
                                        title: "phoneNumber",
                                        controller: phoneController,
                                        validator: CustomTextFieldValidator.nullCheck,
                                        readOnly: true,
                                      ),
                                      if(selectedRole == '1')
                                        Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10.rh(context),
                                          ),
                                          Text(UiUtils.getTranslatedLabel(context, 'Resident Type'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 10.rh(context),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: MultiSelectDropDown(
                                                  backgroundColor: Color(0xfff5f5f5),
                                                  borderColor: Color(0xffededed),
                                                  borderWidth: 1.3,
                                                  padding: EdgeInsets.all(15),
                                                  onOptionSelected: (List<ValueItem> selectedOptions) {
                                                    setState(() {
                                                      selectedResidentType = selectedOptions[0].value!;
                                                      selectedResidentTypeWidget = selectedOptions[0];
                                                    });
                                                  },
                                                  selectedOptions: selectedResidentTypeWidget == null ? [] : [selectedResidentTypeWidget!],
                                                  options: [
                                                    ValueItem(label: 'RI', value: 'RI'),
                                                    ValueItem(label: 'NRI', value: 'NRI'),
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
                                          SizedBox(height: 15,),
                                        ],
                                      ),
                                      if(selectedRole == '3' || selectedRole == '2')
                                        buildTextField(
                                          context,
                                          title: "Company Name",
                                          controller: companyController,
                                          // validator: selectedRole == '3' ? CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10.rh(context),
                                          ),
                                          Text(UiUtils.getTranslatedLabel(context, 'Role')),
                                          SizedBox(
                                            height: 10.rh(context),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: MultiSelectDropDown(
                                                  backgroundColor: Color(0xfff5f5f5),
                                                  borderColor: roleError ? Colors.red : Color(0xffededed),
                                                  borderWidth: 1.3,
                                                  padding: EdgeInsets.all(15),
                                                  onOptionSelected: (List<ValueItem> selectedOptions) {
                                                    if(selectedOptions.length > 0) {
                                                      setState(() {
                                                        selectedRole =
                                                        selectedOptions[0]
                                                            .value!;
                                                        selectedRoleWidget =
                                                        selectedOptions[0];
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedRole = '';
                                                        selectedRoleWidget = null;
                                                      });
                                                    }
                                                  },
                                                  selectedOptions: selectedRoleWidget == null ? [] : [selectedRoleWidget!],
                                                  options: [
                                                    for(int i = 0; i < roleList.length; i++)
                                                      ValueItem(label: roleList[i]['name'], value: roleList[i]['id'].toString()),
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
                                          if(roleError)
                                            Column(
                                              children: [
                                                SizedBox(height: 5,),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: Text('Field must not be empty',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 11
                                                  ),),
                                                ),
                                              ],
                                            ),
                                          SizedBox(height: 15,),
                                        ],
                                      ),
                                      if(selectedRole == '2' || selectedRole == '3')
                                        buildTextField(
                                          context,
                                          title: "RERA Number",
                                          controller: reraController,
                                          // validator: selectedRole == '2' || selectedRole == '3' ?
                                          // CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      if(selectedRole == '3')
                                        buildTextField(
                                          context,
                                          title: "Web Site",
                                          controller: webLinkController,
                                          // validator: selectedRole == '3' ? CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      if(selectedRole == '2' || selectedRole == '3')
                                        buildTextField(
                                          context,
                                          title: "Office Timing",
                                          controller: officeTimingController,
                                          // validator: selectedRole == '2' || selectedRole == '3' ?
                                          // CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      if(selectedRole == '2' || selectedRole == '3')
                                        buildTextField(
                                          context,
                                          title: "Since",
                                          controller: experienceController,
                                          // validator: selectedRole == '2' || selectedRole == '3' ?
                                          // CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      if(selectedRole == '2')
                                        buildTextField(
                                          context,
                                          title: "Rent No",
                                          controller: rentNumberController,
                                          // validator: selectedRole == '2' ? CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      if(selectedRole == '2')
                                        buildTextField(
                                          context,
                                          title: "Sale No",
                                          controller: saleNumberController,
                                          // validator: selectedRole == '2' ? CustomTextFieldValidator.nullCheck : null,
                                        ),
                                        buildTextField(
                                          context,
                                          title: "GST No.",
                                          controller: gstController,
                                          // validator: selectedRole == '2' || selectedRole == '3' ? CustomTextFieldValidator.nullCheck : null,
                                        ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10,),
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Location",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                                // TextSpan(
                                                //   text: " *",
                                                //   style: TextStyle(
                                                //       color: Colors.red), // Customize asterisk color
                                                // ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          GooglePlaceAutoCompleteTextField(
                                            // boxDecoration: BoxDecoration(),
                                            textEditingController: addressController,
                                            focusNode: placesFocusNode,
                                            inputDecoration: const InputDecoration(
                                                hintText: 'Enter location..',
                                                // filled: true,
                                                // fillColor: Color(0xfff5f5f5),
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
                                                    )
                                                )
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
                                              addressController.text = prediction.description!;
                                              addressController.selection =
                                                  TextSelection.fromPosition(TextPosition(
                                                      offset: prediction.description!.length));
                                              print('yyyyyyyyyyyyyyyyyyyyyyyyyy: ${prediction.lat}, ${prediction.lng}');
                                              List address = prediction.description!.split(',').reversed.toList();
                                              // if(address.length >= 3) {
                                              //   cityControler.text = address[2];
                                              //   StateController.text = address[1];
                                              //   ContryControler.text = address[0];
                                              //   setState(() { });
                                              // } else if(address.length == 2) {
                                              //   cityControler.text = address[1];
                                              //   StateController.text = address[1];
                                              //   ContryControler.text = address[0];
                                              //   setState(() { });
                                              // } else if(address.length == 1) {
                                              //   cityControler.text = address[0];
                                              //   StateController.text = address[0];
                                              //   ContryControler.text = address[0];
                                              //   setState(() { });
                                              // } else if(address.length == 0) {
                                              //   cityControler.text = '';
                                              //   StateController.text = '';
                                              //   ContryControler.text = '';
                                              //   setState(() { });
                                              // }
                                              // cityControler.text = place.locality ?? '';
                                              // StateController.text = place.administrativeArea ?? '';
                                              // ContryControler.text = place.country ?? '';
                                              // setState(() { });
                                              // getAddressFromLatLng(prediction.placeId);
                                            },
                                            itemBuilder: (context, index, Prediction prediction) {
                                              return Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.location_on),
                                                    SizedBox(
                                                      width: 7,
                                                    ),
                                                    Expanded(
                                                        child:
                                                        Text("${prediction.description ?? ""}"))
                                                  ],
                                                ),
                                              );
                                            },
                                            seperatedBuilder: Divider(),
                                            isCrossBtnShown: true,
                                            containerHorizontalPadding: 10,
                                            placeType: PlaceType.geocode,
                                          ),
                                        ],
                                      ),
                                      buildAddressTextField(
                                        context,
                                        title: "addressLbl",
                                        controller: addressController,
                                        validator: CustomTextFieldValidator.nullCheck,
                                      ),
                                      buildAddressTextField(
                                        context,
                                        title: "About Me",
                                        controller: aboutController,
                                        // validator: CustomTextFieldValidator.nullCheck,
                                      ),





                                      // if(selectedRole == '3')
                                      //   buildTextField(
                                      //     context,
                                      //     title: "Completed Project",
                                      //     controller: completedProjectController,
                                      //     validator: selectedRole == '3' ?
                                      //     CustomTextFieldValidator.nullCheck : null,
                                      //   ),
                                      // if(selectedRole == '3')
                                      //   buildTextField(
                                      //     context,
                                      //     title: "Current Project",
                                      //     controller: currentProjectController,
                                      //     validator: selectedRole == '3' ? CustomTextFieldValidator.nullCheck : null,
                                      //   ),
                                      // buildTextField(
                                      //   context,
                                      //   title: "Facebook",
                                      //   controller: facebookController,
                                      //   validator: null,
                                      // ),
                                      // buildTextField(
                                      //   context,
                                      //   title: "Twitter",
                                      //   controller: twitterController,
                                      //   validator: null,
                                      // ),
                                      // buildTextField(
                                      //   context,
                                      //   title: "Instagram",
                                      //   controller: instagramController,
                                      //   validator: null,
                                      // ),
                                      // buildTextField(
                                      //   context,
                                      //   title: "Pintrest",
                                      //   controller: pintrestController,
                                      //   validator: null,
                                      // ),


                                      const SizedBox(
                                        height: 15,
                                      ),
                                      if(selectedRole == '2' || selectedRole == '3')
                                        Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(text: "Galary Images",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  galleryImages();
                                                },
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Color(0xffe1e1e1)
                                                    ),
                                                    color: Color(0xfff5f5f5),
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                  child: Center(
                                                    child: Text('+',
                                                      style: TextStyle(
                                                          color: Colors.black26,
                                                          fontSize: 70,
                                                          fontWeight: FontWeight.w100
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(text: "(Upload each image size below 2 mb)",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w400
                                                      ),),
                                                    // TextSpan(
                                                    //   text: " *",
                                                    //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15,),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                mainAxisSpacing: 10, crossAxisCount: 3, height: 100, crossAxisSpacing: 10),
                                            itemCount: gallary.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Color(0xffe1e1e1)
                                                        ),
                                                        color: Color(0xfff5f5f5),
                                                        borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        child: Image.file(gallary[index]),
                                                        // child: Image.file(gallary[index]),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          gallary.removeAt(index);
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          SizedBox(height: 10,),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                mainAxisSpacing: 10, crossAxisCount: 3, height: 100, crossAxisSpacing: 10),
                                            itemCount: gallaryEdit.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Color(0xffe1e1e1)
                                                        ),
                                                        color: Color(0xfff5f5f5),
                                                        borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        child: Image.network(gallaryEdit[index]),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            useSafeArea: true,
                                                            builder: (BuildContext context) {
                                                              return AnnotatedRegion(
                                                                value: SystemUiOverlayStyle(
                                                                  statusBarColor: Colors.black.withOpacity(0),
                                                                ),
                                                                child: SafeArea(
                                                                  child: Center(
                                                                    child: UiUtils.progress(
                                                                      normalProgressColor: context.color.tertiaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                        var responseAgent = await Api.get(
                                                            url: Api.getUserData, queryParameters: {
                                                          'remove_gallery[${index}]': gallaryEdit[index].split['/'].toList().last,
                                                        });
                                                        if (!responseAgent['error']) {
                                                          setState(() {
                                                            gallaryEdit.removeAt(index);
                                                          });
                                                          Widgets.hideLoder(context);
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          SizedBox(height: 10,),
                                        ],
                                      ),
                                      if(selectedRole == '2')
                                        Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(text: "Verified",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                                TextSpan(text: "  (Note: GST, PAN, Aadhar, Company Registation copy)",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  _pickFiles();
                                                },
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Color(0xffe1e1e1)
                                                    ),
                                                    color: Color(0xfff5f5f5),
                                                    borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                                  ),
                                                  child: Center(
                                                    child: Text('+',
                                                      style: TextStyle(
                                                          color: Colors.black26,
                                                          fontSize: 70,
                                                          fontWeight: FontWeight.w100
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15,),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(text: "(Upload each file size below 2 mb)",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w400
                                                      ),),
                                                    // TextSpan(
                                                    //   text: " *",
                                                    //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                mainAxisSpacing: 10, crossAxisCount: 3, height: 130, crossAxisSpacing: 10),
                                            itemCount: documents.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 130,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Color(0xffe1e1e1)
                                                        ),
                                                        color: Color(0xfff5f5f5),
                                                        borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                              child: documents[index].path.split('/').last.split('.').last == 'pdf' ?
                                                              Image.asset("assets/pdf.png") :
                                                              documents[index].path.split('/').last.split('.').last == 'doc' ?
                                                              Image.asset("assets/doc.png") :
                                                              documents[index].path.split('/').last.split('.').last == 'docx' ?
                                                              Image.asset("assets/docx.png") :
                                                              documents[index].path.split('/').last.split('.').last == 'csv' ?
                                                              Image.asset("assets/csv.png") :
                                                              documents[index].path.split('/').last.split('.').last == 'xls' ?
                                                              Image.asset("assets/xls.png") :
                                                              documents[index].path.split('/').last.split('.').last == 'xlsx' ?
                                                              Image.asset("assets/xlsx.png") :
                                                              Image.file(documents[index]),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text('${documents[index].path.split('/').last}',
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 7,
                                                                  fontWeight: FontWeight.w400
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          documents.removeAt(index);
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      // Text("enablesNewSection".translate(context))
                                      //     .size(context.font.small)
                                      //     .bold(weight: FontWeight.w300)
                                      //     .color(
                                      //       context.color.textColorDark.withOpacity(0.8),
                                      //     ),
                                      // SizedBox(
                                      //   height: 20.rh(context),
                                      // ),
                                      Text(
                                        UiUtils.getTranslatedLabel(
                                            context, "notification"),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 10.rh(context),
                                      ),
                                      buildNotificationEnableDisableSwitch(context),
                                      SizedBox(
                                        height: 25.rh(context),
                                      ),


                                    ],
                                  ),
                                )
                              ]))),

                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10,top: 10,left: 15,right: 15 ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: UiUtils.buildButton(
                    fontSize: 13,
                    context,
                    onPressed: () {
                      if (city != null && city != "") {
                        HiveUtils.setLocation(
                            city: city,
                            state: _state,
                            country: country,
                            placeId: placeid ?? '');
                        Hive.box(HiveKeys.userDetailsBox)
                            .put(HiveKeys.cityTeemp, city);
                        context
                            .read<FetchNearbyPropertiesCubit>()
                            .fetch(forceRefresh: true);

                        context
                            .read<FetchMostViewedPropertiesCubit>()
                            .fetch();
                        context
                            .read<FetchPromotedPropertiesCubit>()
                            .fetch();
                        context
                            .read<SliderCubit>()
                            .fetchSlider(context);
                      } else {
                        HiveUtils.clearLocation();
                        context
                            .read<FetchMostViewedPropertiesCubit>()
                            .fetch();
                        context
                            .read<FetchNearbyPropertiesCubit>()
                            .fetch(forceRefresh: true);

                        context
                            .read<FetchPromotedPropertiesCubit>()
                            .fetch();
                        context
                            .read<SliderCubit>()
                            .fetchSlider(context);
                      }
                      validateData();
                    },
                    height: 48.rh(context),
                    buttonTitle: UiUtils.getTranslatedLabel(
                      context, "Save",),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget locationWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
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
                        onTap: () {
                          city = "";
                          _state = "";
                          country = "";
                          setState(() {});
                        },
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
                  color: Color(0xfff5f5f5),
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

  Widget safeAreaCondition({required Widget child}) {
    if (widget.from == "login") {
      return SafeArea(child: child);
    }
    return child;
  }

  Widget buildNotificationEnableDisableSwitch(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: context.color.borderColor,
          ),
          borderRadius: BorderRadius.circular(10),
          color: Color(0xfff5f5f5)),
      height: 55.rh(context),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(UiUtils.getTranslatedLabel(
                    context, isNotificationsEnabled ? "enabled" : "disabled"))
                .size(13).color(Color(0xff929292)),
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              activeColor: Color(0xffebf4ff),
              thumbColor: Color(0xff117af9),
              value: isNotificationsEnabled,
              onChanged: (value) {
                isNotificationsEnabled = value;
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildTextField(BuildContext context,
      {required String title,
      required TextEditingController controller,
      CustomTextFieldValidator? validator,
      bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: UiUtils.getTranslatedLabel(context, title),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if(validator == CustomTextFieldValidator.nullCheck || validator == CustomTextFieldValidator.password
              || validator == CustomTextFieldValidator.phoneNumber || validator == CustomTextFieldValidator.email)
                TextSpan(
                  text: " *",
                  style: TextStyle(
                      color: Colors.red), // Customize asterisk color
                ),
            ],
          ),
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          // formaters: [FilteringTextInputFormatter.deny(RegExp(","))],
          fillColor: Color(0xfff5f5f5),
        ),
      ],
    );
  }

  Widget buildAddressTextField(BuildContext context,
      {required String title,
      required TextEditingController controller,
      CustomTextFieldValidator? validator,
      bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: UiUtils.getTranslatedLabel(context, title),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if(validator == CustomTextFieldValidator.nullCheck || validator == CustomTextFieldValidator.password
                  || validator == CustomTextFieldValidator.phoneNumber || validator == CustomTextFieldValidator.email)
                TextSpan(
                  text: " *",
                  style: TextStyle(
                      color: Colors.red), // Customize asterisk color
                ),
            ],
          ),
        ),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          controller: controller,
          maxLine: 5,
          minLine: 5,
          action: TextInputAction.newline,
          isReadOnly: readOnly,
          validator: validator,
          fillColor: Color(0xfff5f5f5),
        ),
        // const SizedBox(
        //   width: 10,
        // ),
        // locationWidget(context),
      ],
    );
  }

  Widget getProfileImage() {
    if (fileUserimg != null) {
      return Image.file(
        fileUserimg!,
        fit: BoxFit.cover,
      );
    } else {
      if (widget.from == "login") {
        if (HiveUtils.getUserDetails().profile != "" &&
            HiveUtils.getUserDetails().profile != null) {
          return UiUtils.getImage(
            HiveUtils.getUserDetails().profile!,
            fit: BoxFit.cover,
          );
        }

        return UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          fit: BoxFit.none,
        );
      } else {
        if ((HiveUtils.getUserDetails().profile ?? "").isEmpty) {
          return UiUtils.getSvg(
            AppIcons.defaultPersonLogo,
            color: context.color.tertiaryColor,
            fit: BoxFit.none,
          );
        } else {
          return UiUtils.getImage(
            HiveUtils.getUserDetails().profile!,
            fit: BoxFit.cover,
          );
        }
      }
    }
  }

  Widget buildProfilePicture() {
    return Stack(
      children: [
        Container(
          height: 106.rh(context),
          width: 106.rw(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            width: 106.rw(context),
            height: 106.rh(context),
            child: getProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: InkWell(
            onTap: showPicker,
            child: Container(
                height: 37.rh(context),
                width: 37.rw(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfffe5f55)),
                child: Image.asset("assets/AddPostforms/_-101.png",width: 20,height: 20,fit: BoxFit.cover,)),
          ),
        )
      ],
    );
  }

  Future<void> validateData() async {
    if (_formKey.currentState!.validate() && selectedRole != '') {
      setState(() {
        roleError = false;
      });
      bool checkinternet = await HelperUtils.checkInternet();
      if (!checkinternet) {
        Future.delayed(
          Duration.zero,
          () {
            HelperUtils.showSnackBarMessage(context,
                UiUtils.getTranslatedLabel(context, "lblchecknetwork"));
          },
        );
        return;
      }
      process();
    } else if(selectedRole != '') {
      setState(() {
        roleError = false;
      });
    } else {
      setState(() {
        roleError = true;
      });
    }
  }

  process() async {
    Widgets.showLoader(context);
    try {
      var response = await context.read<AuthCubit>().updateUserData(context,
          name: nameController.text.trim(),
          mobile: HiveUtils.getUserDetails().mobile,
          email: emailController.text.trim(),
          role: selectedRole,
          residentType: selectedResidentType,
          fileUserimg: fileUserimg,
          city: city,
          state: _state,
          country: country,
          address: addressController.text,
          aboutMe: aboutController.text,
          facebookId: facebookController.text,
          twiiterId: twitterController.text,
          instagramId: instagramController.text,
          pintrestId: pintrestController.text,
          rera: reraController.text,
          companyName: companyController.text,
          completedProject: completedProjectController.text,
          currentProject: currentProjectController.text,
          officeTiming: officeTimingController.text,
          webLink: webLinkController.text,
          gstNo: gstController.text,
          experience: experienceController.text,
          gallery: gallaryImages,
          verifiedUpload: documentFiles,
          rentNo: rentNumberController.text,
          saleNo: saleNumberController.text,
          notification: isNotificationsEnabled == true ? "1" : "0");

      Future.delayed(
        Duration.zero,
        () {
          context
              .read<UserDetailsCubit>()
              .copy(UserModel.fromJson(response['data']));
        },
      );

      Future.delayed(
        Duration.zero,
        () {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(
            context,
            UiUtils.getTranslatedLabel(context, "profileupdated"),
            onClose: () {
              if (mounted) Navigator.pop(context);
            },
          );
          if (widget.navigateToHome ?? false) {
            Navigator.pop(context);
          }
        },
      );

      if (widget.from == "login" && widget.popToCurrent != true) {
        Future.delayed(
          Duration.zero,
          () {
            HelperUtils.killPreviousPages(
                context, Routes.personalizedPropertyScreen, {
              "type": PersonalizedVisitType.FirstTime,
            });

            // HelperUtils.killPreviousPages(
            //     context, Routes.main, {"from": widget.from});
          },
        );
      } else if (widget.from == "login" && widget.popToCurrent == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
            ..pop()
            ..pop();
        });
      }
    } on CustomException catch (e) {
      Future.delayed(Duration.zero, () {
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(context, e.toString());
      });
    }
  }

  void showPicker() {
    showModalBottomSheet(
        context: context,
        shape: setRoundedBorder(10),
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(UiUtils.getTranslatedLabel(context, "gallery")),
                    onTap: () {
                      _imgFromGallery(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(UiUtils.getTranslatedLabel(context, "camera")),
                  onTap: () {
                    _imgFromGallery(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                if (fileUserimg != null && widget.from == 'login')
                  ListTile(
                    leading: const Icon(Icons.clear_rounded),
                    title:
                        Text(UiUtils.getTranslatedLabel(context, "lblremove")),
                    onTap: () {
                      fileUserimg = null;

                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
              ],
            ),
          );
        });
  }

  _imgFromGallery(ImageSource imageSource) async {
    CropImage.init(context);

    final pickedFile = await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      CroppedFile? croppedFile;
      croppedFile = await CropImage.crop(filePath: pickedFile.path);
      if (croppedFile == null) {
        fileUserimg = null;
      } else {
        fileUserimg = File(croppedFile.path);
      }
    } else {
      fileUserimg = null;
    }
    setState(() {});
  }
}
