import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Housepecker/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import '../../../utils/AdMob/bannerAdLoadWidget.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/constant.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/promoted_widget.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'loanAdForm.dart';

class MyAdvertismentScreen extends StatefulWidget {
  const MyAdvertismentScreen({super.key});

  @override
  State<MyAdvertismentScreen> createState() => _MyAdvertismentScreenState();
}

class _MyAdvertismentScreenState extends State<MyAdvertismentScreen> {
  final ScrollController _pageScrollController = ScrollController();

  List myAdvertisementList = [];
  bool loading = false;

  @override
  void initState() {
    getMyAdvertisements();
    super.initState();
  }

  Future<void> getMyAdvertisements() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.myAdvertisements);
    if(!response['error']) {
      setState(() {
        myAdvertisementList = response['data'];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(context, "myAds")),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          if(!loading)
            Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              controller: _pageScrollController,
              itemCount: myAdvertisementList.length,
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1 / 0.4,
              ),

              itemBuilder: (context, index) {
                var item = myAdvertisementList[index];
                String displayText = "";

                switch (item['category_id']) {
                  case 1:
                    displayText = item['post_type_name'] ?? '';
                    break;
                  case 2:
                    displayText = (item['post_details'] != null && item['post_details'].isNotEmpty)
                        ? (item['post_details'][0]['property_type_name'] is List
                        ? (item['post_details'][0]['property_type_name'] as List)
                        .map((property) => property.toString())
                        .join(', ')
                        : item['post_details'][0]['property_type_name'] ?? '')
                        : '';
                    break;
                  case 3:
                    displayText = (item['post_details'] != null && item['post_details'].isNotEmpty)
                        ? (item['post_details'][0]['service_type_name'] is List
                        ? (item['post_details'][0]['service_type_name'] as List)
                        .map((service) => service.toString())
                        .join(', ')
                        : item['post_details'][0]['service_type_name'] ?? '')
                        : '';
                    break;
                  case 4:
                    displayText = (item['post_details'] != null && item['post_details'].isNotEmpty)
                        ? (item['post_details'][0]['loan_type_name'] is List
                        ? (item['post_details'][0]['loan_type_name'] as List)
                        .map((loan) => loan.toString())
                        .join(', ')
                        : item['post_details'][0]['loan_type_name'] ?? '')
                        : '';
                    break;
                  default:
                    displayText = '';
                }
                return GestureDetector(
                  onLongPress: () {
                    // HelperUtils.share(context, property.id!, property?.slugId ?? "");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            width: 1,
                            color: Color(0xffe0e0e0)
                        )
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: Container(
                                      height: 130,
                                      width: 130,
                                      child: UiUtils.getImage(
                                        item['image'][0] ?? "",
                                        width: double.infinity,fit: BoxFit.cover,height: 103,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5,),
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item['category']['name'] ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 15,),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Container(
                                    //       padding: EdgeInsets.only(left: 5, right: 5),
                                    //       decoration: BoxDecoration(
                                    //           color: item['status'] == 0 ? Colors.redAccent : Colors.green,
                                    //           borderRadius: BorderRadius.circular(15),
                                    //           // border: Border.all(
                                    //           //     width: 1,
                                    //           //     color: Color(0xffe0e0e0)
                                    //           // )
                                    //       ),
                                    //       child: Text('${item['status'] == 0 ? 'InActive' : 'Active'}',
                                    //         style: TextStyle(
                                    //             fontSize: 9,
                                    //             color: Colors.white,
                                    //             fontWeight: FontWeight.w500),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Text(item['title']??'',
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w600),
                                    ),
                              
                                    
                                    Row(
                                      children: [
                                        Image.asset("assets/Home/__location.png",width:12,fit: BoxFit.cover,height: 12,),
                                        SizedBox(width: 2,), Container(
                                       //   color: Colors.red,
                                          width: MediaQuery.of(context).size.width/2-20,
                                          child: Expanded(
                                            child: Text('${item['post_details'][0]['location']}',
                                                                            
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Color(0xff333333),
                                                fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      displayText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text('Posted On : ${item['post_time']}',
                                      maxLines: 2,overflow:TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    if (item['post_details'] != null &&
                                        item['post_details'].isNotEmpty &&
                                        item['post_details'][0]['brokerage'] != null)
                                      Text(
                                        'Brokerage :   ${item['post_details'][0]['brokerage']}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                          /*              Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => LoanAdForm(cat: item['category'], isEdit: true, id: item['id'])),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              children: [
                                                Text('Edit',style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500),
                                                ),
                                                SizedBox(width: 5,),
                                                Icon(Icons.edit,color:Colors.white,size: 13,),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                // return object of type Dialog
                                                return Dialog(
                                                  elevation: 0.0,
                                                  shape:
                                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                                  child: Wrap(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(20.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Text('Are You Sure',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xff333333),
                                                                  fontWeight: FontWeight.w600
                                                              ),
                                                            ),
                                                            SizedBox(height: 15,),
                                                            Text('Do you want to delete this ?'),
                                                            SizedBox(height: 15,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.green,
                                                                      borderRadius: BorderRadius.circular(15),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Cancel',style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    var response = await Api.post(url: Api.advertisementDelete + '/${item['id']}', parameter: {});
                                                                    if(!response['error']) {
                                                                      HelperUtils.showSnackBarMessage(
                                                                          context, UiUtils.getTranslatedLabel(context, "${response['message']}"),
                                                                          type: MessageType.warning, messageDuration: 3);
                                                                      Navigator.pop(context);
                                                                      getMyAdvertisements();
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.red,
                                                                      borderRadius: BorderRadius.circular(15),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Delete',style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              children: [
                                                Text('Delete',style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500),
                                                ),
                                                SizedBox(width: 5,),
                                                Icon(Icons.delete, color:Colors.white, size: 13,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),*/
                                    Container(
                                      height: 28,
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: item['approved'] == 0 ?Color(0xfffff1f1):Color(0xffd9efcf),
                                          border: Border.all(color: item['approved'] == 0 ?Colors.red:Colors.green)
                                      ),child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(item['approved'] == 0 ? "InActive" : "Active",style: TextStyle(fontSize: 12,color: item['approved'] == 0 ?Colors.red: Colors.green),)
                                      ],
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            top: 0,
                            right: 0,
                            child:  PopupMenuButton<int>(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Colors.black,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoanAdForm(cat: item['category'], isEdit: true, id: item['id'])),
                                    );
                                  },
                                  value: 1,
                                  child:  const Row(
                                    children: [
                                      Icon(Icons.edit,color:Color(0xff117af9),size: 17,),
                                      SizedBox(width: 8,),
                                      Text("Edit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),


                                    ],
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return Dialog(
                                          elevation: 0.0,
                                          shape:
                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                          child: Wrap(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(20.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('Are You Sure',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xff333333),
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('Do you want to delete this ?'),
                                                    SizedBox(height: 15,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {

                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                            decoration: BoxDecoration(
                                                              color: Colors.green,
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text('Cancel',style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        InkWell(
                                                          onTap: () async {
                                                            var response = await Api.post(url: Api.advertisementDelete + '/${item['id']}', parameter: {});
                                                            if(!response['error']) {
                                                              HelperUtils.showSnackBarMessage(
                                                                context,
                                                                UiUtils.getTranslatedLabel(context, response['message']),
                                                                type: MessageType.success,
                                                                messageDuration: 3,
                                                              );
                                                              Navigator.pop(context);
                                                              getMyAdvertisements();
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                                            decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text('Delete',style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  value: 2,
                                  child: const Row(
                                    children: [

                                      Icon(Icons.delete, color:Colors.red, size: 17,),
                                      SizedBox(width: 8,),
                                      Text("Delete", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),

                                    ],
                                  ),
                                ),
                              ],

                              color: Color(0xFFFFFFFF),
                            )
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if(loading)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(15),
                        child: CustomShimmer(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if(myAdvertisementList.length == 0 && !loading)
            Container(
              height: MediaQuery.sizeOf(context).height * 0.85,
              child: Center(child: NoDataFound()))
        ],
      ),
    );
  }
}
