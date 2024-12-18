import 'package:Housepecker/exports/main_export.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../data/cubits/category/fetch_category_cubit.dart';
import '../../../../data/model/category.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/blurred_dialoge_box.dart';

class PropertyParametersPage extends StatefulWidget {
  final Map? details;
  final Map? propertyDetails;
  final bool? isUpdate;
  const PropertyParametersPage({this.details, this.isUpdate, this.propertyDetails});
  @override
  _PropertyParametersPageState createState() => _PropertyParametersPageState();
}

class _PropertyParametersPageState extends State<PropertyParametersPage> {

  bool loading = false;
  List propertyParametersValues = [];

  List parameters = [];
  List categories = [];

  TextEditingController sampleControler = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List cat = context.watch<FetchCategoryCubit>().getCategories();
    if(widget.propertyDetails != null) {
      print('7777777777777777777777: ${widget.propertyDetails}');
      List allparameters = [];
      if(Category.fromJson(widget.propertyDetails!['category']).id == (Constant.addProperty['category'] as Category).id) {
        allparameters =
        cat.firstWhere((item) => item.id == Category.fromJson(widget.propertyDetails!['category']).id).parameterTypes!['parameters'].map((
            item) {
          // widget.propertyDetails?.firstWhere((item) => item[''] == )
          Map newOne = {
            ...item,
            'selectedVal': (item['type_of_parameter'] == 'dropdown')
                ? ''
                : (item['type_of_parameter'] ==
                'textbox' || item['type_of_parameter'] == 'textarea' ||
                item['type_of_parameter'] == 'number')
                ? TextEditingController() : (item['type_of_parameter'] ==
                'checkbox') ? [] : '',
          };
          return newOne;
        }).toList();
      } else {
        allparameters =
        cat.firstWhere((item) => item.id == (Constant.addProperty['category'] as Category).id).parameterTypes!['parameters'].map((
            item) {
          // widget.propertyDetails?.firstWhere((item) => item[''] == )
          Map newOne = {
            ...item,
            'selectedVal': (item['type_of_parameter'] == 'dropdown')
                ? ''
                : (item['type_of_parameter'] ==
                'textbox' || item['type_of_parameter'] == 'textarea' ||
                item['type_of_parameter'] == 'number')
                ? TextEditingController() : (item['type_of_parameter'] ==
                'checkbox') ? [] : '',
          };
          return newOne;
        }).toList();
      }

      List fhif = allparameters.map((dat) {
        for(int i = 0; i < widget.propertyDetails!['parameters'].length; i++) {
          if(widget.propertyDetails!['parameters'][i]['id'] == dat['id']) {
            if(dat['type_of_parameter'] == 'checkbox') {
              print('00000000000000000000000000000000: ${widget.propertyDetails!['parameters'][i]['value']}');
            }
            dat['selectedVal'] = (dat['type_of_parameter'] == 'dropdown')
                ? '${widget.propertyDetails!['parameters'][i]['value']}' : (dat['type_of_parameter'] ==
                'textbox' || dat['type_of_parameter'] == 'textarea' ||
                dat['type_of_parameter'] == 'number')
                ? TextEditingController(text: '${widget.propertyDetails!['parameters'][i]['value']}') : (dat['type_of_parameter'] ==
                'checkbox') ? widget.propertyDetails!['parameters'][i]['value'].split(',') : '';
          }
        }
        return dat;
      }).toList();
      print('000000000000000000000000000${fhif}');
      parameters = fhif;
    }
  }

  @override
  void initState() {
    print('tttttttttttttttttttttttt: ${Constant.addProperty['category']}');
    if(!widget.isUpdate!) {
      parameters =
          Constant.addProperty['category']?.parameterTypes!['parameters'].map((
              item) {
            Map newOne = {
              ...item,
              'selectedVal': (item['type_of_parameter'] == 'dropdown')
                  ? ''
                  : (item['type_of_parameter'] ==
                  'textbox' || item['type_of_parameter'] == 'textarea' ||
                  item['type_of_parameter'] == 'number')
                  ? TextEditingController() : (item['type_of_parameter'] ==
                  'checkbox') ? [] : '',
            };
            return newOne;
          }).toList();
    }
    super.initState();
  }

  Widget dropDownField(
      int id,
      List menuList,
      String selectedValue,
      String title,
      bool required,
      Function(String?) onChange
      ) {

    List menuItems = [];
    if(id == 4 || id == 13) {
      if(widget.details!['property_type'] == '0') {
        Map saleType = parameters.where((data) => data['id'] == 33).firstOrNull;
        List filteredMenu = [];
        for(int i = 0; i < menuList.length; i++) {
          if (saleType != null && menuList[i].toString().contains(
              '&${saleType['selectedVal'].toString().toLowerCase()}')) {
            filteredMenu.add(menuList[i]);
          }
        }
        setState(() {
          menuItems = filteredMenu;
        });
      } else {
        Map rentType = parameters.where((data) => data['id'] == 42).firstOrNull;
        List filteredMenu = [];
        for(int i = 0; i < menuList.length; i++) {
          if (rentType != null && menuList[i].toString().contains(
              '&${rentType['selectedVal'].toString().toLowerCase()}')) {
            filteredMenu.add(menuList[i]);
          }
        }
        setState(() {
          menuItems = filteredMenu;
        });
      }
    } else {
      menuItems = menuList;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if(required)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                      color: Colors.red), // Customize asterisk color
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                borderRadius: BorderRadius.circular(8),
                elevation: 1,
                dropdownColor:Colors.white,
                value: selectedValue,
                style: const TextStyle(
                  color: Color(0xff848484),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
                // icon: Icon(Icons.keyboard_arrow_down,color:Colors.black,size: 15,),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('select', maxLines: 1,style: TextStyle(fontFamily: 'Manrope',fontSize: 12),),
                    enabled: false,
                  ),
                  ...menuItems.map((items) {
                      return DropdownMenuItem(
                          value: items.toString(),
                          child: Text(items.toString().split('-')[0], maxLines: 1,
                            style: TextStyle(
                                fontSize: 14, color: Colors.black87),)
                      );
                  }
                  ).toList(),
                ],
                onChanged: onChange,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15,)
      ],
    );
  }

  Widget inputField(
      TextEditingController textControler,
      String title,
      String hintText,
      bool required,
      bool textArea,
      bool number
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if(required)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                      color: Colors.red), // Customize asterisk color
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Color(0xffe1e1e1)
            ),
            color: Color(0xfff5f5f5),
            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 5),
            child: TextFormField(
              controller: textControler,
              minLines: textArea ? 4 : 1,
              maxLines: textArea ? 4 : 1,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  color: Color(0xff9c9c9c),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  )
                )
              ),
            ),
          ),
        ),
        const SizedBox(height: 15,)
      ],
    );
  }

  Widget radioField(
      List menuList,
      List selectedValues,
      String title,
      bool required,
      Function(List?) onSelect
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              if(required)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                      color: Colors.red), // Customize asterisk color
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: menuList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    List hfiuhr = selectedValues;
                    if(hfiuhr.any((item) => item == menuList[index])) {
                      hfiuhr.remove(menuList[index]);
                    } else {
                      hfiuhr.add(menuList[index]);
                    }
                    onSelect(hfiuhr);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedValues.any((
                            item) => item == menuList[index])
                            ? Color(0xfffffbf3)
                            : Color(0xfff2f2f2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 1.5,
                          color: selectedValues.any((
                              item) => item == menuList[index])
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
                            Text(menuList[index].toString(),
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
        const SizedBox(height: 15,)
      ],
    );
  }

  void alertPop() {
    Future.delayed(Duration.zero, () {
      UiUtils.showBlurredDialoge(context,
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
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Please fill all the "',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: "*",
                    style: TextStyle(
                        color:
                        Colors.red), // Customize asterisk color
                  ),
                  TextSpan(
                    text: '" fields!',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ));
    });
  }

  void _onTapContinue() async {
    List postParamData = [];
    for(int i = 0; i < parameters.length; i++) {
      Map? param;
      if(parameters[i]['selectedVal'].runtimeType == String && parameters[i]['selectedVal'] != '') {
        param = {
          'parameter_id': parameters[i]['id'],
          'value': parameters[i]['selectedVal']
        };
      } else if(parameters[i]['selectedVal'].runtimeType == TextEditingController && parameters[i]['selectedVal'].text != '') {
        param = {
          'parameter_id': parameters[i]['id'],
          'value': parameters[i]['selectedVal'].text
        };
      } else if(parameters[i]['selectedVal'].runtimeType == List && parameters[i]['selectedVal'].isNotEmpty) {
        param = {
          'parameter_id': parameters[i]['id'],
          'value': parameters[i]['selectedVal']
        };
      } else {
        continue;
      }
      postParamData.add(param);
    }
    print('777777777777777777777777777 :${postParamData}, ${widget.details!}');
    if(widget.details!['category_id'] == 4 || widget.details!['category_id'] == '4') {
      if(widget.details!['property_type'] == '0') {
        if(!(postParamData.any((item) => item['parameter_id'] == 33) &&
            postParamData.any((item) => item['parameter_id'] == 4) &&
            postParamData.any((item) => item['parameter_id'] == 1) &&
            postParamData.any((item) => item['parameter_id'] == 2))) {
          alertPop();
          return;
        }
      } else {
        if(!(postParamData.any((item) => item['parameter_id'] == 42) &&
            postParamData.any((item) => item['parameter_id'] == 4) &&
            postParamData.any((item) => item['parameter_id'] == 1) &&
            postParamData.any((item) => item['parameter_id'] == 2))) {
          alertPop();
          return;
        }
      }
    } else if(widget.details!['category_id'] == 2 || widget.details!['category_id'] == '2') {
      if(widget.details!['property_type'] == '0') {
        if(!(postParamData.any((item) => item['parameter_id'] == 33) &&
            postParamData.any((item) => item['parameter_id'] == 13))) {
          alertPop();
          return;
        }
      } else {
        if(!(postParamData.any((item) => item['parameter_id'] == 42) &&
            postParamData.any((item) => item['parameter_id'] == 13))) {
          alertPop();
          return;
        }
      }
    } else if(widget.details!['category_id'] == 1 || widget.details!['category_id'] == '1') {
      if(!(postParamData.any((item) => item['parameter_id'] == 52) &&
          postParamData.any((item) => item['parameter_id'] == 12) &&
          postParamData.any((item) => item['parameter_id'] == 45) &&
          postParamData.any((item) => item['parameter_id'] == 1) &&
          postParamData.any((item) => item['parameter_id'] == 2))) {
        alertPop();
        return;
      }
    } else {
      if(widget.details!['property_type'] == '0') {
        if(!postParamData.any((item) => item['parameter_id'] == 11)) {
          alertPop();
          return;
        }
      } else {
        if(!(postParamData.any((item) => item['parameter_id'] == 42) &&
            postParamData.any((item) => item['parameter_id'] == 11))) {
          alertPop();
          return;
        }
      }
    }

    // if(postParamData.any((item) => item['parameter_id'] == 33) && )
    Map<String, dynamic> reqData = {
      ...widget.details!,
      'parameters': postParamData,
      'updateDetails': widget.propertyDetails,
      'isUpdate': widget.isUpdate
    };
    print('tttttttttttttttttttttttt: ${postParamData}');
    Navigator.pushNamed(context, Routes.selectOutdoorFacility,
        arguments: reqData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
        title: widget.propertyDetails != null ? "Edit Property" : 'Post Properties',
        showBackButton: true,
      ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              const Text("Overview",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              ...parameters.map((item) {
                if(item['type_of_parameter'] == 'dropdown') {
                  if(widget.details!['property_type'] == '0' && item['id'] == 33) {
                    return dropDownField(
                        item['id'],
                        item['type_values'],
                        item['selectedVal'],
                        item['name'],
                        item['required'] == 1,
                        (val) {
                          item['selectedVal'] = val;
                          if(Constant.addProperty['category']?.id == '4') {
                            int index = parameters.indexWhere((item) => item['id'] == 4);
                            if (index != -1) {
                              parameters[index]['selectedVal'] = '';
                            }
                          } else {
                            int index = parameters.indexWhere((item) => item['id'] == 13);
                            if (index != -1) {
                              parameters[index]['selectedVal'] = '';
                            }
                          }
                          setState(() { });
                        }
                    );
                  } else if(widget.details!['property_type'] == '1' && item['id'] == 42) {
                    return dropDownField(
                        item['id'],
                        item['type_values'],
                        item['selectedVal'],
                        item['name'],
                        item['required'] == 1,
                        (val) {
                          if(Constant.addProperty['category']?.id == '4') {
                            int index = parameters.indexWhere((item) => item['id'] == 4);
                            if (index != -1) {
                              parameters[index]['selectedVal'] = '';
                            }
                          } else {
                            int index = parameters.indexWhere((item) => item['id'] == 13);
                            if (index != -1) {
                              parameters[index]['selectedVal'] = '';
                            }
                          }
                          item['selectedVal'] = val;
                          setState(() { });
                        }
                    );
                  } else if(item['id'] != 33 && item['id'] != 42) {
                    return dropDownField(
                        item['id'],
                        item['type_values'],
                        item['selectedVal'],
                        item['name'],
                        item['required'] == 1,
                        (val) {
                          item['selectedVal'] = val;
                          setState(() { });
                        }
                    );
                  } else {
                    return Container();
                  }
                } else if(item['type_of_parameter'] == 'textbox') {
                  return inputField(
                      item['selectedVal'],
                      item['name'],
                      '',
                      item['required'] == 1,
                      false,
                      false
                  );
                } else if(item['type_of_parameter'] == 'textarea') {
                  return inputField(
                      item['selectedVal'],
                      item['name'],
                      '',
                      item['required'] == 1,
                      true,
                      false
                  );
                } else if(item['type_of_parameter'] == 'number') {
                  return inputField(
                      item['selectedVal'],
                      item['name'],
                      '',
                      item['required'] == 1,
                      false,
                      true
                  );
                } else if(item['type_of_parameter'] == 'checkbox') {
                  return radioField(
                      item['type_values'],
                      item['selectedVal'],
                      item['name'],
                      item['required'] == 1,
                      (val) {
                        item['selectedVal'] = val;
                        setState(() { });
                      }
                  );
                } else {
                  return Container();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
