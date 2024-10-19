import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd3.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';

class ProjectFormTwo extends StatefulWidget {
  final Map? body;
  final Map? data;
  final bool? isEdit;
  const ProjectFormTwo({super.key, this.body, this.isEdit, this.data});

  @override
  State<ProjectFormTwo> createState() => _ProjectFormTwoState();
}

class _ProjectFormTwoState extends State<ProjectFormTwo> {

  TextEditingController totalUnitsControler = TextEditingController();
  TextEditingController projectAreaControler = TextEditingController();
  TextEditingController sizeControler = TextEditingController();
  TextEditingController sqftRateControler = TextEditingController();
  TextEditingController roadWidthControler = TextEditingController();
  TextEditingController projectCompletedControler = TextEditingController();
  TextEditingController configurationsControler = TextEditingController();
  TextEditingController reraControler = TextEditingController();
  TextEditingController totalFloorsControler = TextEditingController();
  TextEditingController approvedControler = TextEditingController();
  TextEditingController MAxsf = TextEditingController();
  TextEditingController Minsf = TextEditingController();
  TextEditingController nearByMetroControler = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime possessionDate = DateTime.now();
  DateTime completionDate = DateTime.now();

  String nearByMetro = '';
  List<ValueItem> nearByMetroWidget = [];
  String vegOnly = '';
  List<ValueItem> vegOnlyWidget = [];
  String coveredParking = '';
  List<ValueItem> coveredParkingWidget = [];
  String openParking = '';
  List<ValueItem> openParkingWidget = [];
  String gatedCommunity = '';
  List<ValueItem> gatedCommunityWidget = [];
  String lakeView = '';
  List<ValueItem> lakeViewWidget = [];
  String highRiseApartment = '';
  List<ValueItem> highRiseApartmentWidget = [];

  String suitableFor = '';
  List<ValueItem> suitableForWidget = [];
  String projectPlaced = '';
  List<ValueItem> projectPlacedWidget = [];

  String projectFurnished = '';
  List<ValueItem> projectFurnishedWidget = [];
  String projectFacing = '';
  List<ValueItem> projectFacingWidget = [];

  List suitableForList = [];
  List projectPlacedList = [];

  bool loading = false;

  Future<void> getMasters() async {
    setState(() {
      loading = true;
    });
    var suitResponse = await Api.get(url: Api.getSuitable);
    if (!suitResponse['error']) {
      setState(() {
        suitableForList = suitResponse['data'];
      });
    }
    var placeResponse = await Api.get(url: Api.getProjectPlaced);
    if (!placeResponse['error']) {
      setState(() {
        projectPlacedList = placeResponse['data'];
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

  Future<void> getUpdateProject() async {
    totalUnitsControler.text = widget.data!['project_details'][0]['total_units'] ?? '';
    projectAreaControler.text = widget.data!['project_details'][0]['total_project'] ?? '';
    sizeControler.text = widget.data!['project_details'][0]['size'].toString();
    Minsf.text = widget.data!['min_size'].toString();
    MAxsf.text = widget.data!['max_size'].toString();
    configurationsControler.text = widget.data!['project_details'][0]['configuration'] ?? '';
    reraControler.text = widget.data!['project_details'][0]['rera_no'] ?? '';
    totalFloorsControler.text = widget.data!['project_details'][0]['floors'].toString();
    sqftRateControler.text = widget.data!['project_details'][0]['rate_per_sqft'] ?? '';
    approvedControler.text = widget.data!['project_details'][0]['approved_by'] ?? '';
    roadWidthControler.text = widget.data!['project_details'][0]['road_width'] ?? '';
    suitableFor = widget.data!['project_details'][0]['suitable_for'].toString();
    projectFacing = widget.data!['project_details'][0]['facing'].toString();
    projectFurnished = widget.data!['project_details'][0]['furniture'].toString();
    projectPlaced = widget.data!['project_details'][0]['project_placed'].toString();
    nearByMetroControler.text = widget.data!['project_details'][0]['near_by_metro'] ?? '';
    vegOnly = widget.data!['project_details'][0]['veg_only'] ?? '';
    coveredParking = widget.data!['project_details'][0]['covered_parking'] ?? '';
    openParking = widget.data!['project_details'][0]['open_parking'] ?? '';
    gatedCommunity = widget.data!['project_details'][0]['gated_community'] ?? '';
    lakeView = widget.data!['project_details'][0]['lake_view'] ?? '';
    highRiseApartment = widget.data!['project_details'][0]['high_rise'] ?? '';
    selectedDate = DateTime.parse(widget.data!['project_details'][0]['launch_date']);
    possessionDate = widget.data!['project_details'][0]['possession_start'] != null ? DateTime.parse(widget.data!['project_details'][0]['possession_start']) : DateTime.now();
    projectCompletedControler.text = widget.data!['project_details'][0]['project_completed'];

    suitableForWidget = suitableForList
        .where((element) =>
    element['id'].toString() ==
        widget.data!['project_details'][0]['suitable_for'].toString())
        .toList()
        .map((item) {
      return ValueItem(label: item['name'], value: item['id'].toString());
    }).toList();

    projectPlacedWidget = projectPlacedList
        .where((element) =>
    element['id'].toString() ==
        widget.data!['project_details'][0]['project_placed'].toString())
        .toList()
        .map((item) {
      return ValueItem(label: item['name'], value: item['id'].toString());
    }).toList();

    // if (widget.data!['project_details'][0]['near_by_metro'] == 'yes') {
    //   nearByMetroWidget = [ValueItem(label: 'Yes', value: 'yes')];
    // } else {
    //   nearByMetroWidget = [ValueItem(label: 'No', value: 'no')];
    // }

    if (widget.data!['project_details'][0]['veg_only'] == 'yes') {
      vegOnlyWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      vegOnlyWidget = [ValueItem(label: 'No', value: 'no')];
    }

    if (widget.data!['project_details'][0]['facing'] == '0') {
      projectFacingWidget = [ValueItem(label: 'North', value: '0')];
    } else if(widget.data!['project_details'][0]['facing'] == '1') {
      projectFacingWidget = [ValueItem(label: 'East', value: '1')];
    } else if(widget.data!['project_details'][0]['facing'] == '2') {
      projectFacingWidget = [ValueItem(label: 'South', value: '2')];
    } else {
      projectFacingWidget = [ValueItem(label: 'West', value: '3')];
    }

    if (widget.data!['project_details'][0]['furniture'] == '0') {
      projectFurnishedWidget = [ValueItem(label: 'Furnished', value: '0')];
    } else if(widget.data!['project_details'][0]['furniture'] == '1') {
      projectFurnishedWidget = [ValueItem(label: 'Unfurnished', value: '1')];
    } else {
      projectFurnishedWidget = [ValueItem(label: 'Semi-Furnished', value: '2')];
    }

    if (widget.data!['project_details'][0]['covered_parking'] == 'yes') {
      coveredParkingWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      coveredParkingWidget = [ValueItem(label: 'No', value: 'no')];
    }

    if (widget.data!['project_details'][0]['open_parking'] == 'yes') {
      openParkingWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      openParkingWidget = [ValueItem(label: 'No', value: 'no')];
    }

    if (widget.data!['project_details'][0]['gated_community'] == 'yes') {
      gatedCommunityWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      gatedCommunityWidget = [ValueItem(label: 'No', value: 'no')];
    }

    if (widget.data!['project_details'][0]['lake_view'] == 'yes') {
      lakeViewWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      lakeViewWidget = [ValueItem(label: 'No', value: 'no')];
    }

    if (widget.data!['project_details'][0]['high_rise'] == 'yes') {
      highRiseApartmentWidget = [ValueItem(label: 'Yes', value: 'yes')];
    } else {
      highRiseApartmentWidget = [ValueItem(label: 'No', value: 'no')];
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getMasters();
    super.initState();
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
            Text("2/5",style: TextStyle(color: Colors.white)),
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
                    Text('Overview',
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
                              TextSpan(text: "Total Units ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(text: "(Max ${widget.body!['unit_limit'] ?? 0} Units)",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: totalUnitsControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Total Units Count..',
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Total Project Area",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: projectAreaControler,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Project Area..',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "No of Floors/Towers",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: totalFloorsControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
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
                                            ))
                                    ),
                                  ),
                                ),
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
                              TextSpan(text: "Launch Date",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate, // Optional: pre-select a date
                                    firstDate: DateTime.now(), // Optional: restrict selectable dates (start)
                                    lastDate: DateTime(2060),  // Optional: restrict selectable dates (end)
                                  );
                                  if (picked != null && picked != selectedDate) {
                                    setState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
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
                                    padding: const EdgeInsets.all(15),
                                    child: Text('${DateFormat('MMM yyyy').format(selectedDate)}'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    if (widget.body!['category_id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Possession starts",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(color: Colors.red), // Customize asterisk color
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate, // Optional: pre-select a date
                                      firstDate: DateTime.now(), // Optional: restrict selectable dates (start)
                                      lastDate: DateTime(2050),  // Optional: restrict selectable dates (end)
                                    );
                                    if (picked != null && picked != possessionDate) {
                                      setState(() {
                                        possessionDate = picked;
                                      });
                                    }
                                  },
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
                                      padding: const EdgeInsets.all(15),
                                      child: Text('${DateFormat('MMM yyyy').format(possessionDate)}'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Min Size (Sqft.)",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: Minsf,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Min Per Sqft..',
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
                            SizedBox(width: 10,),
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
                                    controller: MAxsf,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Max Per Sqft..',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Configurations",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: configurationsControler,
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
                                            ))
                                    ),
                                  ),
                                ),
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
                              TextSpan(text: "RERA No",
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
                                    controller: reraControler,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter RERA..',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Rate Per Sq.ft",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
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
                                    controller: sqftRateControler,
                                    keyboardType: TextInputType.number,
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
                                            ))
                                    ),
                                  ),
                                ),
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
                              TextSpan(text: "Approved By",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red), // Customize asterisk color
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
                                    controller: approvedControler,
                                    decoration: const InputDecoration(
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
                                            ))
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                      ],
                    ),
                    if (widget.body!['category_id'] == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Suitable For",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(
                                //       color:
                                //       Colors.red), // Customize asterisk color
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
                                child: MultiSelectDropDown(
                                  onOptionSelected:
                                      (List<ValueItem> selectedOptions) {
                                    setState(() {
                                      if(selectedOptions.length > 0) {
                                        suitableFor = selectedOptions[0].value!;
                                      } else {
                                        suitableFor = '';
                                      }
                                      suitableForWidget = selectedOptions;
                                    });
                                  },
                                  selectedOptions: widget.isEdit! ? suitableForWidget : [],
                                  options: suitableForList.map((item) {
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
                    if (widget.body!['category_id'] == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Project Placed",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(
                                //       color:
                                //       Colors.red), // Customize asterisk color
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
                                child: MultiSelectDropDown(
                                  onOptionSelected:
                                      (List<ValueItem> selectedOptions) {
                                    setState(() {
                                      if(selectedOptions.length > 0) {
                                        projectPlaced = selectedOptions[0].value!;
                                      } else {
                                        projectPlaced = '';
                                      }
                                      projectPlacedWidget = selectedOptions;
                                    });
                                  },
                                  selectedOptions: widget.isEdit! ? projectPlacedWidget : [],
                                  options: projectPlacedList.map((item) {
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
                                  text: "Gated Community",
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
                                      if(selectedOptions.length > 0) {
                                        gatedCommunity = selectedOptions[0].value!;
                                      } else {
                                        gatedCommunity = '';
                                      }
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit! ? gatedCommunityWidget : [],
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
                    if (widget.body!['category_id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "High-rise Apartment",
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
                                      if(selectedOptions.length > 0) {
                                        highRiseApartment = selectedOptions[0].value!;
                                      } else {
                                        highRiseApartment = '';
                                      }
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit! ? highRiseApartmentWidget : [],
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
                    if (widget.body!['category_id'] == 4)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Lake View",
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
                                      if(selectedOptions.length > 0) {
                                        lakeView = selectedOptions[0].value!;
                                      } else {
                                        lakeView = '';
                                      }
                                    });
                                  },
                                  selectedOptions:
                                  widget.isEdit! ? lakeViewWidget : [],
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
                              TextSpan(text: "Nearby metro km",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
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
                                    controller: nearByMetroControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter metro distance..',
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
                        SizedBox(height: 15,),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Veg Only",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //       Colors.red), // Customize asterisk color
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
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      vegOnly = selectedOptions[0].value!;
                                    } else {
                                      vegOnly = '';
                                    }
                                  });
                                },
                                selectedOptions:
                                widget.isEdit! ? vegOnlyWidget : [],
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
                                text: "Facing",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //       Colors.red), // Customize asterisk color
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
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      projectFacing = selectedOptions[0].value!;
                                    } else {
                                      projectFacing = '';
                                    }
                                  });
                                },
                                selectedOptions: widget.isEdit! ? projectFacingWidget : [],
                                options: [
                                  ValueItem(label: "North", value: "0"),
                                  ValueItem(label: "East", value: "1"),
                                  ValueItem(label: "South", value: "2"),
                                  ValueItem(label: "West", value: "3"),
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
                                text: "Furniture",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //       Colors.red), // Customize asterisk color
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
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  print('rrrrrrrrrrrrrrrrrrrrrr: ${selectedOptions}');
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      projectFurnished = selectedOptions[0].value!;
                                    } else {
                                      projectFurnished = '';
                                    }
                                  });
                                },
                                selectedOptions: widget.isEdit! ? projectFurnishedWidget : [],
                                options: [
                                  ValueItem(label: "Furnished", value: "0"),
                                  ValueItem(label: "Unfurnished", value: "1"),
                                  ValueItem(label: "Semi-Furnished", value: "2"),
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
                                text: "Covered Parking",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //       Colors.red), // Customize asterisk color
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
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      coveredParking = selectedOptions[0].value!;
                                    } else {
                                      coveredParking = '';
                                    }
                                  });
                                },
                                selectedOptions:
                                widget.isEdit! ? coveredParkingWidget : [],
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
                                text: "Open Parking",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              // TextSpan(
                              //   text: " *",
                              //   style: TextStyle(
                              //       color:
                              //       Colors.red), // Customize asterisk color
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
                              child: MultiSelectDropDown(
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  setState(() {
                                    if(selectedOptions.length > 0) {
                                      openParking = selectedOptions[0].value!;
                                    } else {
                                      openParking = '';
                                    }
                                  });
                                },
                                selectedOptions:
                                widget.isEdit! ? openParkingWidget : [],
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
                              TextSpan(text: "Road Width",
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
                                    controller: roadWidthControler,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Road Width..',
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
                        SizedBox(height: 15,),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Project Completed on",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),),
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
                                    controller: projectCompletedControler,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                        hintText: 'Completed on..',
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
                    SizedBox(height: 25,),
                  ],
                ),
              ),
            ),
          ),
          if(loading)
            Container(
              margin: EdgeInsets.only(bottom: 10,left: 15,right: 15),
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
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          if(!loading)
            InkWell(
            onTap: () {
              if(widget.body!['category_id'] == 4) {
                if (totalUnitsControler.text != '' &&
                    MAxsf.text != '' && Minsf.text != '' &&
                    projectAreaControler.text != '' &&
                    totalFloorsControler.text != '' &&
                    selectedDate != null && selectedDate != '' &&
                    possessionDate != null && possessionDate != '' &&
                    approvedControler.text != '' &&
                    configurationsControler.text != ''
                ) {
                  if(widget.body!['unit_limit'] >= int.parse(totalUnitsControler.text)) {
                    if(int.parse(Minsf.text) < int.parse(MAxsf.text)) {
                      var body = {
                        'total_units': totalUnitsControler.text,
                        'total_project': projectAreaControler.text,
                        'launch_date': selectedDate,
                        'possession_start': possessionDate,
                        'size': sizeControler.text,
                        'configuration': configurationsControler.text,
                        'rera_no': reraControler.text,
                        'floors': totalFloorsControler.text,
                        'approved_by': approvedControler.text,
                        'gated_community': gatedCommunity,
                        'high_rise': highRiseApartment,
                        'lake_view': lakeView,
                        'min_size': Minsf.text,
                        'max_size': MAxsf.text,
                        'near_by_metro': nearByMetroControler.text,
                        'veg_only': vegOnly,
                        'covered_parking': coveredParking,
                        'open_parking': openParking,
                        'rate_per_sqft': sqftRateControler.text,
                        'furniture': projectFurnished,
                        'facing': projectFacing,
                        'road_width': roadWidthControler.text,
                        'project_completed': projectCompletedControler.text,
                        ...widget.body!
                      };
                      print('ffffffffffffffff: ${body}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ProjectFormThree(body: body,
                                isEdit: widget.isEdit,
                                data: widget.data
                            )
                        ),
                      );
                    } else {
                      HelperUtils.showSnackBarMessage(
                          context, UiUtils.getTranslatedLabel(
                          context, "Max size should be greater than min size!"),
                          type: MessageType.warning, messageDuration: 5);
                    }
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context, UiUtils.getTranslatedLabel(
                        context, "Max units limit exceeded!"),
                        type: MessageType.warning, messageDuration: 5);
                  }
                } else {
                  HelperUtils.showSnackBarMessage(
                      context, UiUtils.getTranslatedLabel(
                      context, "Please fill all the (*) marked fields!"),
                      type: MessageType.warning, messageDuration: 5);
                }
              } else {
                if (totalUnitsControler.text != '' &&
                    projectAreaControler.text != '' &&
                    MAxsf.text != '' &&
                    Minsf.text != '' &&
                    selectedDate != null &&
                    selectedDate != '' &&
                    totalFloorsControler.text != '' &&
                    approvedControler.text != '' &&
                    configurationsControler.text != ''
                ) {
                  if(widget.body!['unit_limit'] >= int.parse(totalUnitsControler.text)) {
                    if(int.parse(Minsf.text) < int.parse(MAxsf.text)) {
                      var body = {
                        'total_units': totalUnitsControler.text,
                        'total_project': projectAreaControler.text,
                        'launch_date': selectedDate,
                        'configuration': configurationsControler.text,
                        'rera_no': reraControler.text,
                        'floors': totalFloorsControler.text,
                        'min_size': Minsf.text,
                        'max_size': MAxsf.text,
                        'approved_by': approvedControler.text,
                        'rate_per_sqft': sqftRateControler.text,
                        'suitable_for': suitableFor,
                        'furniture': projectFurnished,
                        'facing': projectFacing,
                        'project_placed': projectPlaced,
                        'near_by_metro': nearByMetroControler.text,
                        'veg_only': vegOnly,
                        'gated_community': gatedCommunity,
                        'covered_parking': coveredParking,
                        'open_parking': openParking,
                        'road_width': roadWidthControler.text,
                        'project_completed': projectCompletedControler.text,
                        ...widget.body!
                      };
                      print('ffffffffffffffff: ${body}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ProjectFormThree(body: body,
                                isEdit: widget.isEdit,
                                data: widget.data)),
                      );
                    } else {
                      HelperUtils.showSnackBarMessage(
                          context, UiUtils.getTranslatedLabel(
                          context, "Max units limit exceeded!"),
                          type: MessageType.warning, messageDuration: 5);
                    }
                  } else {
                    HelperUtils.showSnackBarMessage(
                        context, UiUtils.getTranslatedLabel(
                        context, "Max size should be greater than min size!"),
                        type: MessageType.warning, messageDuration: 5);
                  }
                } else {
                  HelperUtils.showSnackBarMessage(
                      context, UiUtils.getTranslatedLabel(
                      context, "Please fill all the (*) marked fields!"),
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
