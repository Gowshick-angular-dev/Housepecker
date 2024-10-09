import 'package:Housepecker/Ui/screens/widgets/Erros/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:Housepecker/utils/ui_utils.dart';

import '../../../../app/routes.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AdMob/bannerAdLoadWidget.dart';
import '../../../../utils/api.dart';
import '../../../../utils/hive_utils.dart';
import '../../home/Widgets/property_horizontal_card.dart';
import '../../widgets/shimmerLoadingContainer.dart';

class PropertiesListWidget extends StatefulWidget {
  final String? typeName;

  const PropertiesListWidget({Key? key, this.typeName})
      : super(key: key);

  @override
  PropertiesListWidgetState createState() => PropertiesListWidgetState();
}

class PropertiesListWidgetState extends State<PropertiesListWidget> {
  int offset = 0, total = 0;

  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List propertyLikeLoading = [];

  bool propertyLoading = false;
  bool propertyLoadingMore = false;

  @override
  void initState() {
    super.initState();
    getProperties();
    controller = ScrollController()..addListener(_loadMore);
  }

  Future<void> getProperties() async {
    setState(() {
      propertyLoading = true;
    });
    var response = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'offset': offset,
      'limit': 10,
      'premium': widget.typeName == "Premium Properties For Sale" ? 1 : '',
      'deal_of_month': widget.typeName == "Deal Of The Month" ? 1 : '',
      'current_user': HiveUtils.getUserId()
    });
    if(!response['error']) {
      List<PropertyModel> props = (response['data'] as List).where((e) => e['is_type'] == 'property').toList()
          .map((item) => PropertyModel.fromMap(item)).toList();
      setState(() {
        total = response['total'];
        propertylist = props;
        propertyLikeLoading = List.filled(response['total'], false);
        propertyLoading = false;
        offset += 10;
      });
    }
  }

  Future<void> getPropertiesMore() async {
    setState(() {
      propertyLoadingMore = true;
    });
    var response = await Api.get(url: Api.apiGetProprty, queryParameters: {
      'offset': offset,
      'limit': 10,
      'primium': 1,
      'current_user': HiveUtils.getUserId()
    });
    if(!response['error']) {
      setState(() {
        propertylist.addAll((response['data'] as List).where((e) => e['is_type'] == 'property').toList()
            .map((item) => PropertyModel.fromMap(item)).toList());
        propertyLoadingMore = false;
        offset += 10;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    super.dispose();
  }

  void _loadMore() async {
    if (controller.isEndReached()) {
      if (total > propertylist.length && !propertyLoading && !propertyLoadingMore) {
        getPropertiesMore();
      }
    }
  }

  int itemIndex = 0;
  @override
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  Widget bodyWidget() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: widget.typeName,
        ),
        bottomNavigationBar: const BottomAppBar(
          child: BannerAdWidget(bannerSize: AdSize.banner),
        ),
        body: Column(
          children: [
            if(propertyLoading)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: buildPropertiesShimmer(context),
                ),
              ),
            if(!propertyLoading)
              Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(15),
                shrinkWrap: true,
                controller: controller,
                physics: const BouncingScrollPhysics(),
                itemCount: propertylist.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1 / 1.2,
                ),
                itemBuilder: (context, index) {
                  PropertyModel property = propertylist[index];
                  // context.read<LikedPropertiesCubit>().add(property.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.propertyDetails,
                        arguments: {
                          'propertyData': property,
                          'propertiesList': propertylist,
                          'fromMyProperty': false,
                        },
                      );
                    },
                    child: PropertyHorizontalCard(
                        property: property,
                      ),
                    );
                  },
                ),
              ),
            if (propertyLoadingMore) UiUtils.progress()
          ],
        ));
  }

  Widget buildPropertiesShimmer(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1 / 1.2,
      ),

      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 1,
                  color: Color(0xffe0e0e0)
              )
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft:Radius.circular(15),
                  ),
                  child: CustomShimmer(width: double.infinity,height: 110,),
                ),
                SizedBox(height: 8,),
                LayoutBuilder(builder: (context, c) {
                  return Padding(
                    padding: const EdgeInsets.only(left:10,right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        CustomShimmer(
                          height: 14,
                          width: c.maxWidth - 50,
                        ),
                        SizedBox(height: 5,),
                        const CustomShimmer(
                          height: 13,
                        ),
                        SizedBox(height: 5,),
                        CustomShimmer(
                          height: 12,
                          width: c.maxWidth / 1.2,
                        ),
                        SizedBox(height: 8,),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: CustomShimmer(
                            width: c.maxWidth / 4,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ]),
        );
      },
    );
  }

  // Widget filterOptionsBtn() {
  //   return IconButton(
  //       onPressed: () {
  //         // show filter screen
  //
  //         // Constant.propertyFilter = null;
  //         Navigator.pushNamed(context, Routes.filterScreen,
  //             arguments: {"showPropertyType": false}).then((value) {
  //           if (value == true) {
  //             context
  //                 .read<FetchPropertyFromTypeCubit>()
  //                 .fetchPropertyFromType(widget.type!,
  //                 showPropertyType: false);
  //           }
  //           setState(() {});
  //         });
  //       },
  //       icon: Icon(
  //         Icons.filter_list_rounded,
  //         color: Colors.white,
  //       ));
  // }
}
