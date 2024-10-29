import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';

import '../../../app/routes.dart';
import '../../../data/Repositories/system_repository.dart';
import '../../../data/helper/designs.dart';
import '../../../data/helper/widgets.dart';
import '../../../utils/api.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'loanAdForm.dart';

class LoanAdForm extends StatefulWidget {
  final Map? cat;
  final bool isEdit;
  final int? id;

  const LoanAdForm({super.key, this.cat, this.isEdit = false, this.id});

  @override
  State<LoanAdForm> createState() => _LoanHomeState();
}

class _LoanHomeState extends State<LoanAdForm> {

  bool loading = false;
  List packages = [];
  dynamic freepackage = [];

  FocusNode locationFocusnode = FocusNode();

  TextEditingController searchControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();
  TextEditingController branchControler = TextEditingController();
  TextEditingController nameControler = TextEditingController();
  TextEditingController phoneControler = TextEditingController();
  TextEditingController whatsappControler = TextEditingController();
  TextEditingController emailControler = TextEditingController();
  TextEditingController addressControler = TextEditingController();
  TextEditingController cityControler = TextEditingController();
  TextEditingController timingControler = TextEditingController();
  TextEditingController construnctionRoleControler = TextEditingController();
  TextEditingController experienceControler = TextEditingController();
  TextEditingController projectControler = TextEditingController();
  TextEditingController descriptionControler = TextEditingController();
  TextEditingController landSizeControler = TextEditingController();
  TextEditingController companyControler = TextEditingController();
  TextEditingController priceControler = TextEditingController();
  TextEditingController urlControler = TextEditingController();

  int remainFreeProPost = 0;
  String selectedRole = 'Free Listing';
  int? selectedPackage = 0;
  int freeDuration = 0;

  List bankList = [];
  List loanList = [];
  List roleList = [];
  List ventureCategoryList = [];
  List propertyList = [];
  List serviceList = [];
  List agentList = [];
  bool bankLoading = true;
  bool tapped = false;
  String agentType = '';
  String selectedBank = '';
  String brokerage = '';
  String constRole = '';
  String myRole = '';
  List loanType = [];
  List<ValueItem> loanTypeWidget = [];
  String selectedVenture = '';
  List serviceType = [];
  List<ValueItem> serviceTypeWidget = [];
  String mainService = '';
  List<ValueItem> mainServiceWidget = [];
  List propertyType = [];
  List<ValueItem> propertyTypeWidget = [];
  File? fileUserimg;
  List<File> gallary = [];
  List gallaryEdit = [];
  List gallaryImages = [];
  List<File> documents = [];
  List documentFiles = [];
  List documentEdit = [];
  File? photo;
  var photoFiles;
  var photoEdit;

  final int _sizeLimit = 2 * 1024 * 1024;

  List<ValueItem> selectedVentureWidget = [];
  List<ValueItem> brokerageWidget = [];
  List<ValueItem> constRoleWidget = [];
  List<ValueItem> myRoleWidget = [];

  @override
  void initState() {
    if (widget.cat!['id'] == 4) {
      getBanks();
      getLoanTypes();
    } else if (widget.cat!['id'] == 2) {
      getPropertyTypes();
    } else if (widget.cat!['id'] == 3) {
      getServiceTypes();
    } else {
      getVentureCategories();
      getRoles();
    }

    if (widget.isEdit && widget.id != null) {
      Timer(const Duration(seconds: 2), () {
        getEditDetails();
      });
    }
    getPackages();

    super.initState();
  }

  Future<void> getPackages() async {
    try {
      setState(() {
        loading = true;
      });

      final SystemRepository _systemRepository = SystemRepository();
      Map settings = await _systemRepository.fetchSystemSettings(isAnonymouse: false);

      List allPacks = settings['data']['package'] != null ? settings['data']['package']['user_purchased_package'] : [];
      Map freepackage = settings['data']['free_package'];

      if (freepackage != null) {
        setState(() {
          remainFreeProPost = freepackage['advertisement_limit'] - freepackage['used_advertisement_limit'];
          freeDuration = freepackage['duration'] ?? 0;
        });
      }

      List temp = [];
      if (settings['data']['package'] != null && allPacks != null) {
        for (int i = 0; i < allPacks.length; i++) {
          print('hhhhhhhhhhhhhhhhhhhhhhhhhhh2: ${allPacks[i]['used_limit_for_advertisement']}, ${allPacks[i]['package']['advertisement_limit']}');

          if (((allPacks[i]['package']['advertisement_limit'] ?? 0) -
              (allPacks[i]['used_limit_for_advertisement'] ?? 0)) >
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

  Future<void> getBanks() async {
    setState(() {
      bankLoading = true;
    });
    var response = await Api.get(url: Api.banksList, queryParameters: {
      'loan': '',
      'search': '',
      'location': '',
      'branch': '',
    });
    if (!response['error']) {
      setState(() {
        bankList = response['data'];
        bankLoading = false;
      });
    }
  }

  Future<void> getEditDetails() async {
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
              child: PopScope(
                child: Center(
                  child: UiUtils.progress(
                    normalProgressColor: context.color.tertiaryColor,
                  ),
                ),
                canPop: false,
              ),
            ),
          );
        });
    var response =
        await Api.get(url: Api.advertisementGetById + '/${widget.id}');
    if (!response['error']) {
      try {
        if (widget.cat!['id'] == 4) {
          branchControler.text = response['data']['branch'] ?? '';
          selectedBank = response['data']['subcategory_id'].toString();
          agentType = response['data']['agent_type'] ?? '';
          loanTypeWidget = loanList
              .where((user) => response['data']['loan_type']
                  .split(',')
                  .toList()
                  .contains(user['id'].toString()))
              .toList()
              .map((item) {
            return ValueItem(label: item['name'], value: item['id'].toString());
          }).toList();
          loanType = response['data']['loan_type']
              .split(',')
              .toList()
              .map((item) => int.parse(item))
              .toList();
        } else if (widget.cat!['id'] == 3) {
          priceControler.text = response['data']['price'] ?? '';
          companyControler.text = response['data']['company_name'] ?? '';
          urlControler.text = response['data']['website_link'] ?? '';
          serviceTypeWidget = serviceList
              .where((user) => response['data']['service_type']
                  .split(',')
                  .toList()
                  .contains(user['id'].toString()))
              .toList()
              .map((item) {
            return ValueItem(label: item['name'], value: item['id'].toString());
          }).toList();
          serviceType = response['data']['service_type']
              .split(',')
              .toList()
              .map((item) => int.parse(item))
              .toList();
        } else if (widget.cat!['id'] == 2) {
          companyControler.text = response['data']['company_name'] ?? '';
          urlControler.text = response['data']['website_link'] ?? '';
          experienceControler.text = response['data']['experience'] ?? '';
          projectControler.text = response['data']['projects'] ?? '';
          propertyTypeWidget = propertyList
              .where((user) => response['data']['property_type']
                  .split(',')
                  .toList()
                  .contains(user['id'].toString()))
              .toList()
              .map((item) {
            return ValueItem(label: item['name'], value: item['id'].toString());
          }).toList();
          propertyType = response['data']['property_type']
              .split(',')
              .toList()
              .map((item) => int.parse(item))
              .toList();

          constRole = response['data']['construnction_role'].toString();
          if (response['data']['construnction_role'] == 1) {
            constRoleWidget = [ValueItem(label: 'Engineer', value: '1')];
          } else if (response['data']['construnction_role'] == 2) {
            constRoleWidget = [ValueItem(label: 'Constructor', value: '2')];
          } else {
            constRoleWidget = [ValueItem(label: 'Builder', value: '3')];
          }
          setState(() {});
        } else {
          landSizeControler.text = response['data']['land_size'] ?? '';
          companyControler.text = response['data']['company_name'] ?? '';
          for (int i = 0; i < ventureCategoryList.length; i++) {
            if (ventureCategoryList[i]['id'] ==
                response['data']['subcategory_id']) {
              selectedVentureWidget = [
                ValueItem(
                    label: ventureCategoryList[i]['name'],
                    value: ventureCategoryList[i]['id'].toString())
              ];
              selectedVenture = ventureCategoryList[i]['id'].toString();
              setState(() {});
            }
          }
        }
        locationControler.text = response['data']['location'] ?? '';
        nameControler.text = response['data']['title'] ?? '';
        phoneControler.text = response['data']['phone'] ?? '';
        emailControler.text = response['data']['email'] ?? '';
        cityControler.text = response['data']['city'] ?? '';

        for (int i = 0; i < roleList.length; i++) {
            print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii: ${roleList[i]['id'] == response['data']['role']}');
          if (roleList[i]['id'] ==
              response['data']['role']) {
            myRoleWidget = [
              ValueItem(
                  label: roleList[i]['name'],
                  value: roleList[i]['id'].toString())
            ];
            myRole = roleList[i]['id'].toString();
            setState(() {});
          }
        }

        brokerage = response['data']['brokerage'];
        if (response['data']['brokerage'] == 'yes') {
          brokerageWidget = [ValueItem(label: 'Yes', value: 'yes')];
        } else {
          brokerageWidget = [ValueItem(label: 'No', value: 'no')];
        }

        addressControler.text = response['data']['address'] ?? '';
        experienceControler.text = response['data']['experience'] ?? '';
        timingControler.text = response['data']['timing'] ?? '';
        descriptionControler.text = response['data']['description'] ?? '';
        whatsappControler.text = response['data']['whatsapp_number'] ?? '';
        urlControler.text = response['data']['website_link'] ?? '';
        gallaryEdit = response['data']['image'] ?? [];
        documentEdit = response['data']['documents'] ?? [];
        photoEdit = response['data']['photo'] ?? [];

        setState(() {});
        Widgets.hideLoder(context);
      } catch (err) {
        Widgets.hideLoder(context);
      }
    }
  }

  Future<void> getLoanTypes() async {
    var response = await Api.get(url: Api.loanTypes);
    if (!response['error']) {
      setState(() {
        loanList = response['data'];
      });
    }
  }

  Future<void> getRoles() async {
    var response = await Api.get(url: Api.roles);
    if (!response['error']) {
      setState(() {
        roleList = response['data'];
      });
    }
  }

  Future<void> getVentureCategories() async {
    var response = await Api.get(url: Api.ventureCategories);
    if (!response['error']) {
      setState(() {
        ventureCategoryList = response['data'];
      });
    }
  }

  Future<void> getPropertyTypes() async {
    var response = await Api.get(url: Api.constructionTypes);
    if (!response['error']) {
      setState(() {
        propertyList = response['data'];
      });
    }
  }

  Future<void> getServiceTypes() async {
    var response = await Api.get(url: Api.services);
    if (!response['error']) {
      setState(() {
        serviceList = response['data'];
      });
    }
  }

  _imgFromGallery() async {
    var images = await ImagePicker().pickMultiImage();
    if (images.length > 0) {
      for (int i = 0; i < images.length; i++) {
        int fileSize = await images[i].length();
        if (fileSize < _sizeLimit) {
          gallary.add(File(images[i].path));
          gallaryImages
              .add(await MultipartFile.fromFile(File(images[i].path).path));
          setState(() {});
        } else {
          HelperUtils.showSnackBarMessage(
              context,
              UiUtils.getTranslatedLabel(
                  context, "Large images were eliminated"),
              type: MessageType.warning,
              messageDuration: 3);
        }
      }
    } else {
      gallary = [];
    }
    setState(() {});
  }

  profImgFromGallery() async {
    CropImage.init(context);
    var images = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (images != null) {
      int fileSize = await images.length();
      if (fileSize < _sizeLimit) {
        photo = File(images.path);
        photoFiles = await MultipartFile.fromFile(File(images.path).path);
        setState(() {});
      } else {
        HelperUtils.showSnackBarMessage(context,
            UiUtils.getTranslatedLabel(context, "Upload image size below 2mb!"),
            type: MessageType.warning, messageDuration: 3);
      }
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      List<PlatformFile> filteredFiles = files.where((file) {
        return file.size <= 2 * 1024 * 1024;
      }).toList();

      List<File> docFiles = [];
      List docMulFiles = [];
      for (int i = 0; i < filteredFiles.length; i++) {
        docMulFiles.add(
            await MultipartFile.fromFile(File(filteredFiles[i].path!).path));
        docFiles.add(File(filteredFiles[i].path!));
      }
      setState(() {
        documents = [...documents, ...docFiles];
        documentFiles = [...documentFiles, ...docMulFiles];
      });

      if (documents!.length < files.length) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Some files were excluded because they exceed the 2MB size limit.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tertiaryColor_,
        title: Text(
          widget.isEdit ? 'Update Advertisement' : 'Post Advertisement',
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!widget.isEdit)
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
                                    color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        if (selectedRole == 'Free Listing' && !loading)
                          Text(
                            remainFreeProPost > 0 ? "Note: This post is valid for $freeDuration months from the date of posting." : "Free Listing limit exceeded.",
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
                                                selectedPackage = 0;
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
                                if(packages.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xffe5e5e5),
                                          width: 1
                                      ),
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
                                                selectedPackage = packages[i]['package']['id'];
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: selectedPackage != packages[i]['package']['id'] ? Color(0xfff9f9f9) : Color(0xfffffbf3),
                                                  border: Border.all(
                                                      color: selectedPackage != packages[i]['package']['id'] ? Color(0xffe5e5e5) : Color(0xffffa920),
                                                      width: 1
                                                  ),
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                // alignment: Alignment.center,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Color(0xffe5e5e5),
                                                                width: 1
                                                            ),
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: selectedPackage == packages[i]['package']['id'] ? Container(
                                                            height: 10,
                                                            width: 10,
                                                            decoration: BoxDecoration(
                                                              color: Color(0xffffa920),
                                                              border: Border.all(
                                                                  color: Color(0xffffffff),
                                                                  width: 3
                                                              ),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ) : Container(),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Text(packages[i]['package']['name'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Color(0xff646464),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          child: Text('Total Listings',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(':  ${packages[i]['package']['advertisement_limit']}',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          child: Text('Available Listings',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(':  ${packages[i]['package']['advertisement_limit'] - packages[i]['used_limit_for_advertisement']}',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          child: Text('Valid until',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(':  ${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))}',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Color(0xff646464),
                                                              fontWeight: FontWeight.w400,
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
                                if(packages.isEmpty)
                                  Column(
                                    children: [
                                      Text('You dont have any active packages for post a Advertisement. If you want to buy click here!',
                                        style: const TextStyle(color: Colors.red, fontSize: 12),),
                                      SizedBox(height: 10,),
                                      InkWell(
                                        onTap: () {
                                          GuestChecker.check(onNotGuest: () {
                                            Navigator.pushNamed(
                                                context, Routes.subscriptionPackageListRoute);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                                          width: double.infinity,
                                          height: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: Color(0xff117af9),
                                          ),
                                          child: Text('Buy Subscription Plan',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if(packages.isEmpty)
                                  const SizedBox(height: 10),
                              ],
                            ]
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    if (widget.cat!['id'] == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Construction Role",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      constRole = selectedOptions[0].value!;
                                      constRoleWidget = selectedOptions;
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit ? constRoleWidget : [],
                                  options: [
                                    ValueItem(label: "Engineer", value: "1"),
                                    ValueItem(label: "Constructor", value: "2"),
                                    ValueItem(label: "Builder", value: "3"),
                                    ValueItem(label: "Supplier", value: "4"),
                                    ValueItem(label: "Dealer", value: "5"),
                                  ],
                                  selectionType: SelectionType.single,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select Service type deal in",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      propertyType =
                                          selectedOptions.map((item) {
                                            return item.value;
                                          }).toList();
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit ? propertyTypeWidget : [],
                                  options: propertyList.map((items) {
                                    return ValueItem(
                                        label: items['name'],
                                        value: items['id'].toString());
                                  }).toList(),
                                  selectionType: SelectionType.multi,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select Loan Type Deals In",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      loanType = selectedOptions
                                          .map((item) => item.value)
                                          .toList();
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit ? loanTypeWidget : [],
                                  options: loanList.map((items) {
                                    return ValueItem(
                                        label: items['name'],
                                        value: items['id'].toString());
                                  }).toList(),
                                  selectionType: SelectionType.multi,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Service",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      mainService = selectedOptions[0].value!;
                                      mainServiceWidget = selectedOptions;
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit ? mainServiceWidget : [],
                                  options: serviceList.map((items) {
                                    return ValueItem(
                                        label: items['name'],
                                        value: items['id'].toString());
                                  }).toList(),
                                  selectionType: SelectionType.single,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select Service Type Deals In (Other Service)",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
                                      serviceType = selectedOptions.map((item) {
                                        return item.value;
                                      }).toList();
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit ? serviceTypeWidget : [],
                                  options: serviceList.map((items) {
                                    return ValueItem(
                                        label: items['name'],
                                        value: items['id'].toString());
                                  }).toList(),
                                  selectionType: SelectionType.multi,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 4 ||
                        widget.cat!['id'] == 2 ||
                        widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Timings",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                      controller: timingControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Timing..',
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
                    if (widget.cat!['id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select Bank",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          if (!bankLoading)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2 / 1.3,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemCount: bankList.length,
                              itemBuilder: (context, index) {
                                final item = bankList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedBank = item['id'].toString();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: item['id'].toString() ==
                                              selectedBank
                                              ? Color(0xffffb239)
                                              : Color(0xffe5e5e5),
                                          width: item['id'].toString() ==
                                              selectedBank
                                              ? 3
                                              : 1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Image.network(
                                        item['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (bankLoading)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        clipBehavior:
                                        Clip.antiAliasWithSaveLayer,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CustomShimmer(
                                            height: 90, width: 90),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    if (widget.cat!['id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select designation Type",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    agentType = 'DST';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 10, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: agentType == 'DST'
                                        ? Color(0xfffffbf3)
                                        : Color(0xfff2f2f2),
                                    border: Border.all(
                                        color: agentType == 'DST'
                                            ? Color(0xffffb239)
                                            : Color(0xffdcdcdc),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Text(
                                        'DST',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff333333)),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/Loans/_-113.png',
                                          width: 18.0,
                                          height: 18.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    agentType = 'DSA';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 10, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: agentType == 'DSA'
                                        ? Color(0xfffffbf3)
                                        : Color(0xfff2f2f2),
                                    border: Border.all(
                                        color: agentType == 'DSA'
                                            ? Color(0xffffb239)
                                            : Color(0xffdcdcdc),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Text(
                                        'DSA',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff333333)),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          'assets/Loans/_-113.png',
                                          width: 18.0,
                                          height: 18.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10,),
                              // InkWell(
                              //   onTap: () {
                              //     setState(() {
                              //       agentType = '';
                              //     });
                              //   },
                              //   child: Container(
                              //     padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                              //     decoration: BoxDecoration(
                              //       color: agentType == '' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                              //       border: Border.all(
                              //           color: agentType == '' ? Color(0xffffb239) : Color(0xffdcdcdc), width: 1
                              //       ),
                              //       borderRadius: BorderRadius.circular(30),
                              //     ),alignment: Alignment.center,
                              //     child: Center(
                              //       child: Text('Both', style: TextStyle(
                              //           fontSize: 13,
                              //           fontWeight: FontWeight.w500,
                              //           color: Color(0xff333333)
                              //       ),),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    if (widget.cat!['id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Branch",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      controller: branchControler,
                                      // onChanged: (String? val) {
                                      //   getBanks(loanType, searchControler.text, locationControler.text, val!);
                                      // },
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Branch..',
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
                    if (widget.cat!['id'] == 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Select Post type",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      selectedVentureWidget = selectedOptions;
                                      selectedVenture =
                                      selectedOptions[0].value!;
                                    });
                                  },
                                  selectedOptions: widget.isEdit
                                      ? selectedVentureWidget
                                      : [],
                                  options: ventureCategoryList.map((item) {
                                    return ValueItem(
                                        label: item['name'],
                                        value: item['id'].toString());
                                  }).toList(),
                                  selectionType: SelectionType.single,
                                  chipConfig:
                                  const ChipConfig(wrapType: WrapType.wrap),
                                  dropdownHeight: 300,
                                  optionTextStyle:
                                  const TextStyle(fontSize: 16),
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
                    if (widget.cat!['id'] == 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Land Size",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      controller: landSizeControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Land Size..',
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
                    if (widget.cat!['id'] != 2 && widget.cat!['id'] != 3)
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
                                    brokerage = selectedOptions[0].value!;
                                    brokerageWidget = selectedOptions;
                                  });
                                },
                                selectedOptions:
                                widget.isEdit ? brokerageWidget : [],
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
                    if (widget.cat!['id'] == 1)
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "I am",
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
                                    myRole = selectedOptions[0].value!;
                                    myRoleWidget = selectedOptions;
                                  });
                                },
                                selectedOptions: widget.isEdit ? myRoleWidget : [],
                                options: [
                                  for(int i = 0; i < roleList.length; i++)
                                    ValueItem(label: "${roleList[i]['name']}", value: "${roleList[i]['id']}"),
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
                    if (widget.cat!['id'] == 1 ||
                        widget.cat!['id'] == 2 ||
                        widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Your Name/Company Name",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Customize asterisk color
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
                                      controller: companyControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Company Name..',
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
                    if (widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Min Service Charge",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
                                      controller: priceControler,
                                      decoration: const InputDecoration(
                                          hintText:
                                          'Enter Min Service Charge..',
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
                                text: "Phone Number",
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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('+91 '),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 5),
                                        child: TextFormField(
                                          controller: phoneControler,
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          decoration: const InputDecoration(
                                              hintText: 'Enter Phone Number..',
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14.0,
                                                color: Color(0xff9c9c9c),
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none,
                                              ),
                                              enabledBorder:
                                              UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              focusedBorder:
                                              UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ))),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                text: "Email Address",
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
                                    controller: emailControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Email..',
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
                                text: "Whatsapp Number",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('+91 '),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 5),
                                        child: TextFormField(
                                          controller: whatsappControler,
                                          maxLength: 10,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              hintText:
                                              'Enter Whatsapp Number..',
                                              counterText: "",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14.0,
                                                color: Color(0xff9c9c9c),
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none,
                                              ),
                                              enabledBorder:
                                              UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              focusedBorder:
                                              UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ))),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  text: "Since",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
                                      controller: experienceControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Ex 2011',
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
                    if (widget.cat!['id'] == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "No of Projects Completed",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
                                      controller: projectControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Projects..',
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
                                  text: "Web site",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                      controller: urlControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Company Website..',
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
                                text: "City",
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
                                    controller: cityControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter City..',
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
                                text: "Location",
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
                                child: GooglePlaceAutoCompleteTextField(
                                  textEditingController: locationControler,
                                  focusNode: locationFocusnode,
                                  inputDecoration: const InputDecoration(
                                      hintText: 'Enter location..',
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
                                    locationControler.text = prediction.description!;
                                    locationControler.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: prediction.description!.length));
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
                                text: "Address",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (widget.cat!['id'] == 2)
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: addressControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Address..',
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
                                text: "Title Image",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                profImgFromGallery();
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Color(0xffe1e1e1)),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Optional: Add border radius
                                    ),
                                    child: photo != null
                                        ? Image.file(photo!)
                                        : Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 70,
                                            fontWeight: FontWeight.w100),
                                      ),
                                    ),
                                  ),
                                  if (photo != null)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            photo = null;
                                            photoFiles = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "(Upload image size below 2 mb)",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: " *",
                                    style: TextStyle(
                                        color: Colors
                                            .red), // Customize asterisk color
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if(widget.isEdit && photoEdit != null)
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Color(0xffe1e1e1)),
                              color: Color(0xfff5f5f5),
                              borderRadius: BorderRadius.circular(
                                  15.0), // Optional: Add border radius
                            ),
                            child: Image.network(photoEdit ?? '')
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
                                text: "Gallary Images",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _imgFromGallery();
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  color: Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Optional: Add border radius
                                ),
                                child: Center(
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                        color: Colors.black26,
                                        fontSize: 70,
                                        fontWeight: FontWeight.w100),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "(Upload each image size below 2 mb)",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: " *",
                                    style: TextStyle(
                                        color: Colors
                                            .red), // Customize asterisk color
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              mainAxisSpacing: 10,
                              crossAxisCount: 3,
                              height: 100,
                              crossAxisSpacing: 10),
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
                                          width: 1, color: Color(0xffe1e1e1)),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Optional: Add border radius
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                      child: Image.file(gallary[index]),
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
                        SizedBox(
                          height: 10,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              mainAxisSpacing: 10,
                              crossAxisCount: 3,
                              height: 100,
                              crossAxisSpacing: 10),
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
                                          width: 1, color: Color(0xffe1e1e1)),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Optional: Add border radius
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
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
                                                statusBarColor:
                                                Colors.black.withOpacity(0),
                                              ),
                                              child: SafeArea(
                                                child: PopScope(
                                                  child: Center(
                                                    child: UiUtils.progress(
                                                      normalProgressColor: context
                                                          .color.tertiaryColor,
                                                    ),
                                                  ),
                                                  canPop: false,
                                                ),
                                              ),
                                            );
                                          });
                                      var responseAgent = await Api.get(
                                          url: Api.advertisementGetById +
                                              '/${widget.id}',
                                          queryParameters: {
                                            'remove_images[${index}]':
                                            gallaryEdit[index]
                                                .split['/']
                                                .toList()
                                                .last,
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
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    if (widget.cat!['id'] == 4 ||
                        widget.cat!['id'] == 2 ||
                        widget.cat!['id'] == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "For Verified Tag",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
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
                                        width: 1, color: Color(0xffe1e1e1)),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Optional: Add border radius
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                          color: Colors.black26,
                                          fontSize: 70,
                                          fontWeight: FontWeight.w100),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                            "(Upload each file size below 2 mb)",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          TextSpan(
                                            text: " *",
                                            style: TextStyle(
                                                color: Colors
                                                    .red), // Customize asterisk color
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '(Note:  GST Copy, Company Registation copy)',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                mainAxisSpacing: 10,
                                crossAxisCount: 4,
                                height: 110,
                                crossAxisSpacing: 10),
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
                                            width: 1, color: Color(0xffe1e1e1)),
                                        color: Color(0xfff5f5f5),
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Optional: Add border radius
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              child: documents[index]
                                                  .path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'pdf'
                                                  ? Image.asset("assets/pdf.png")
                                                  : documents[index]
                                                  .path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'doc'
                                                  ? Image.asset(
                                                  "assets/doc.png")
                                                  : documents[index]
                                                  .path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'docx'
                                                  ? Image.asset(
                                                  "assets/docx.png")
                                                  : documents[index]
                                                  .path
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'csv'
                                                  ? Image.asset(
                                                  "assets/csv.png")
                                                  : documents[index]
                                                  .path
                                                  .split(
                                                  '/')
                                                  .last
                                                  .split(
                                                  '.')
                                                  .last ==
                                                  'xls'
                                                  ? Image.asset(
                                                  "assets/xls.png")
                                                  : documents[index]
                                                  .path
                                                  .split(
                                                  '/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'xlsx'
                                                  ? Image.asset("assets/xlsx.png")
                                                  : Image.file(documents[index]),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
                                            child: Text(
                                              '${documents[index].path.split('/').last}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w400),
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
                          SizedBox(
                            height: 10,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                mainAxisSpacing: 10,
                                crossAxisCount: 3,
                                height: 110,
                                crossAxisSpacing: 10),
                            itemCount: documentEdit.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Color(0xffe1e1e1)),
                                        color: Color(0xfff5f5f5),
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Optional: Add border radius
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              child: documentEdit[index]
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'pdf'
                                                  ? Image.asset("assets/pdf.png")
                                                  : documentEdit[index]
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'doc'
                                                  ? Image.asset(
                                                  "assets/doc.png")
                                                  : documentEdit[index]
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'docx'
                                                  ? Image.asset(
                                                  "assets/docx.png")
                                                  : documentEdit[index]
                                                  .split('/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'csv'
                                                  ? Image.asset(
                                                  "assets/csv.png")
                                                  : documentEdit[index]
                                                  .split(
                                                  '/')
                                                  .last
                                                  .split(
                                                  '.')
                                                  .last ==
                                                  'xls'
                                                  ? Image.asset(
                                                  "assets/xls.png")
                                                  : documentEdit[index]
                                                  .split(
                                                  '/')
                                                  .last
                                                  .split('.')
                                                  .last ==
                                                  'xlsx'
                                                  ? Image.asset("assets/xlsx.png")
                                                  : Image.network(documentEdit[index]),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
                                            child: Text(
                                              '${documentEdit[index].split('/').last}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w400),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Description",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: descriptionControler,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Description..',
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
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!tapped)
            InkWell(
              onTap: () async {
                setState(() {
                  tapped = true;
                });
                var body;
                if (widget.cat!['id'] == 1) {
                  if (nameControler.text != '' &&
                      phoneControler.text != '' &&
                      brokerage != '' &&
                      locationControler.text != '' &&
                      companyControler.text != '' &&
                      landSizeControler.text != '' &&
                      selectedVenture != '' &&
                      myRole != '' &&
                      cityControler.text != '' &&
                      emailControler.text != '' &&
                      (widget.isEdit || ((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0))) {
                    body = {
                      'package_id': selectedPackage,
                      'category': widget.cat!['id'],
                      'subcategory': selectedVenture,
                      'title': nameControler.text,
                      'phone': phoneControler.text,
                      'email': emailControler.text,
                      'whatsapp_number': whatsappControler.text,
                      'description': descriptionControler.text,
                      'image': gallaryImages,
                      'photo': photoFiles,
                      'role': myRole,
                      'brokerage': brokerage,
                      'experience': experienceControler.text,
                      'location': locationControler.text,
                      'land_size': landSizeControler.text,
                      'company_name': companyControler.text,
                      'website_link': urlControler.text,
                      'address': addressControler.text,
                      'city': cityControler.text,
                    };
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(context,
                            "Please fill all the required (*) fields!"),
                        type: MessageType.warning,
                        messageDuration: 3);
                    setState(() {
                      tapped = false;
                    });
                  }
                } else if (widget.cat!['id'] == 2) {
                  if (nameControler.text != '' &&
                      phoneControler.text != '' &&
                      // brokerage != '' &&
                      locationControler.text != '' &&
                      companyControler.text != '' &&
                      propertyType.length > 0 &&
                      emailControler.text != ''&&
                      addressControler.text != '' &&
                      cityControler.text != '' &&
                      constRole != '' &&
                      (widget.isEdit || ((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0))) {
                    body = {
                      'package_id': selectedPackage,
                      'category': widget.cat!['id'],
                      'title': nameControler.text,
                      'phone': phoneControler.text,
                      'email': emailControler.text,
                      'whatsapp_number': whatsappControler.text,
                      'property_type': propertyType,
                      'description': descriptionControler.text,
                      'image': gallaryImages,
                      'photo': photoFiles,
                      'brokerage': brokerage,
                      'location': locationControler.text,
                      'company_name': companyControler.text,
                      'website_link': urlControler.text,
                      'address': addressControler.text,
                      'city': cityControler.text,
                      'experience': experienceControler.text,
                      'projects': projectControler.text,
                      'timing': timingControler.text,
                      'construnction_role': constRole,
                      'documents': documentFiles,
                    };
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(context,
                            "Please fill all the required (*) fields!"),
                        type: MessageType.warning,
                        messageDuration: 3);
                    setState(() {
                      tapped = false;
                    });
                  }
                } else if (widget.cat!['id'] == 3) {
                  if (nameControler.text != '' &&
                      phoneControler.text != '' &&
                      locationControler.text != '' &&
                      emailControler.text != ''&&
                      companyControler.text != '' &&
                      mainService != '' &&
                      cityControler.text != '' &&
                      (widget.isEdit || ((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0))) {
                    body = {
                      'package_id': selectedPackage,
                      'category': widget.cat!['id'],
                      'subcategory': mainService,
                      'title': nameControler.text,
                      'phone': phoneControler.text,
                      'email': emailControler.text,
                      'whatsapp_number': whatsappControler.text,
                      'description': descriptionControler.text,
                      'image': gallaryImages,
                      'photo': photoFiles,
                      'brokerage': brokerage,
                      'location': locationControler.text,
                      'service_type': serviceType,
                      'company_name': companyControler.text,
                      'website_link': urlControler.text,
                      'price': priceControler.text,
                      'address': addressControler.text,
                      'city': cityControler.text,
                      'timing': timingControler.text,
                      'documents': documentFiles,
                    };
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(context,
                            "Please fill all the required (*) fields!"),
                        type: MessageType.warning,
                        messageDuration: 3);
                    setState(() {
                      tapped = false;
                    });
                  }
                } else {
                  if (nameControler.text != '' &&
                      phoneControler.text != '' &&
                      brokerage != '' &&
                      selectedBank != '' &&
                      agentType != '' &&
                      locationControler.text != '' &&
                      branchControler.text != '' &&
                      loanType.length > 0 &&
                      cityControler.text != '' &&
                      emailControler.text != "" &&
                      (widget.isEdit || ((remainFreeProPost > 0 && selectedPackage == 0 && selectedRole == 'Free Listing') || selectedPackage != 0))) {
                    body = {
                      'package_id': selectedPackage,
                      'category': widget.cat!['id'],
                      'subcategory': selectedBank,
                      'title': nameControler.text,
                      'phone': phoneControler.text,
                      'email': emailControler.text,
                      'whatsapp_number': whatsappControler.text,
                      'description': descriptionControler.text,
                      'image': gallaryImages,
                      'photo': photoFiles,
                      'agent_type': agentType,
                      'branch': branchControler.text,
                      'brokerage': brokerage,
                      'location': locationControler.text,
                      'loan_type': loanType,
                      'address': addressControler.text,
                      'city': cityControler.text,
                      'timing': timingControler.text,
                      'documents': documentFiles,
                    };
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(context,
                            "Please fill all the required (*) fields!"),
                        type: MessageType.warning,
                        messageDuration: 3);
                    setState(() {
                      tapped = false;
                    });
                  }
                }
                try {
                  if(body != null) {
                    print('pppppppppppp: ${body}');
                    if (widget.isEdit) {
                      var responseAgent = await Api.post(
                          url: Api.advertisementUpdate +
                              '?post_id=${widget.id}',
                          parameter: body);
                      if (!responseAgent['error']) {
                        setState(() {
                          tapped = false;
                        });
                        HelperUtils.showSnackBarMessage(
                            context,
                            UiUtils.getTranslatedLabel(
                                context, "${responseAgent['message']}"),
                            type: MessageType.success,
                            messageDuration: 3);
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          tapped = false;
                        });
                        HelperUtils.showSnackBarMessage(
                            context,
                            UiUtils.getTranslatedLabel(
                                context, "${responseAgent['message']}"),
                            type: MessageType.error,
                            messageDuration: 3);
                      }
                    } else {
                      var responseAgent = await Api.post(
                          url: Api.advertisementPost, parameter: body);
                      if (!responseAgent['error']) {
                        setState(() {
                          tapped = false;
                        });
                        HelperUtils.showSnackBarMessage(
                            context,
                            UiUtils.getTranslatedLabel(
                                context, "${responseAgent['message']}"),
                            type: MessageType.success,
                            messageDuration: 3);
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pushReplacementNamed(Routes
                              .main,
                              arguments: {'from': "main"});
                        });
                      } else {
                        setState(() {
                          tapped = false;
                        });
                        HelperUtils.showSnackBarMessage(
                            context,
                            UiUtils.getTranslatedLabel(
                                context, "${responseAgent['message']}"),
                            type: MessageType.error,
                            messageDuration: 3);
                      }
                    }
                  }
                } catch (err) {
                  print('errrcatch : ${err}');
                  setState(() {
                    tapped = false;
                  });
                  HelperUtils.showSnackBarMessage(context,
                      UiUtils.getTranslatedLabel(context, err.toString()),
                      type: MessageType.error, messageDuration: 3);
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
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          if (tapped)
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
            )
        ],
      ),
    );
  }
}
