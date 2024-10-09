import 'dart:ui';

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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
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
                          SizedBox(width: 15,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item['category']['name']}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff333333),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          color: item['status'] == 0 ? Colors.redAccent : Colors.green,
                                          borderRadius: BorderRadius.circular(15),
                                          // border: Border.all(
                                          //     width: 1,
                                          //     color: Color(0xffe0e0e0)
                                          // )
                                      ),
                                      child: Text('${item['status'] == 0 ? 'InActive' : 'Active'}',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6,),
                                Text('${item['category']['name']}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 3,),
                                Row(
                                  children: [
                                    Image.asset("assets/Home/__location.png",width:12,fit: BoxFit.cover,height: 12,),
                                    SizedBox(width: 2,),
                                    Text('${item['post_details'][0]['location']}',style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                SizedBox(height: 3,),
                                Row(
                                  children: [
                                    Text('Brokerage :   ${item['post_details'][0]['brokerage']}',style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                SizedBox(height: 11,),
                                Row(
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if(loading)
            SingleChildScrollView(
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
          if(myAdvertisementList.length == 0 && !loading)
            Container(
              height: MediaQuery.sizeOf(context).height * 0.85,
              child: Center(child: NoDataFound()))
        ],
      ),
    );
  }
}
