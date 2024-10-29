// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:Housepecker/Ui/screens/widgets/like_button_widget.dart';
import 'package:Housepecker/Ui/screens/widgets/promoted_widget.dart';
import 'package:Housepecker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:Housepecker/utils/AppIcon.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:Housepecker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/routes.dart';
import '../../../../data/cubits/property/delete_property_cubit.dart';
import '../../../../data/cubits/property/fetch_my_properties_cubit.dart';
import '../../../../data/model/category.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/api.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/hive_utils.dart';
import '../../../../utils/ui_utils.dart';
import '../../proprties/interested_users_details.dart';
import '../../proprties/my_properties_screen.dart';
import '../../proprties/property_details.dart';
import '../../widgets/blurred_dialoge_box.dart';

class PropertyHorizontalCard1 extends StatelessWidget {
  final PropertyModel property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton1? statusButton1;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  const PropertyHorizontalCard1(
      {super.key,
        required this.property,
        this.useRow,
        this.addBottom,
        this.additionalHeight,
        this.onLikeChange,
        this.statusButton1,
        this.showDeleteButton,
        this.onDeleteTap,
        this.showLikeButton,
        this.additionalImageWidth});


  String formatAmount(int number) {
    String result = '';
    if(number >= 10000000) {
      result = '${(number/10000000).toStringAsFixed(2)} Cr';
    } else if(number >= 100000) {
      result = '${(number/100000).toStringAsFixed(2)} Laks';
    } else {
      result = '$number';
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.price!
        // .priceFormate(
        //   disabled: Constant.isNumberWithSuffix == false,
        // )
        // .toString()
        // .formatAmount(prefix: true)
    );

    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice =
          ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    }

    String propStatus = property.properyType!.toTitleCase();

    List addOnsList = property.addOn ?? [];

    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              GestureDetector(
                onLongPress: () {
                  HelperUtils.share(context, property.id!, property?.slugId ?? "");
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  height: addBottom == null ? 135 : (135 + (additionalHeight ?? 0)),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          width: 1,
                          color: Color(0xffe0e0e0)
                      )
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      children: [

                                        UiUtils.getImage(
                                          property.titleImage ?? "",
                                          width:110,fit: BoxFit.cover,height: double.infinity,
                                        ),
                                        // Text(property.promoted.toString()),
                                        // if (showLikeButton ?? true)
                                        //   Positioned(
                                        //     right: 8,
                                        //     top: 8,
                                        //     child: Container(
                                        //       width: 32,
                                        //       height: 32,
                                        //       decoration: BoxDecoration(
                                        //         color: context.color.secondaryColor,
                                        //         shape: BoxShape.circle,
                                        //         boxShadow: const [
                                        //           BoxShadow(
                                        //             color:
                                        //             Color.fromARGB(12, 0, 0, 0),
                                        //             offset: Offset(0, 2),
                                        //             blurRadius: 15,
                                        //             spreadRadius: 0,
                                        //           )
                                        //         ],
                                        //       ),
                                        //       child: LikeButtonWidget(
                                        //         property: property,
                                        //         onLikeChanged: onLikeChange,
                                        //       ),
                                        //     ),
                                        //   ),
                                        if (property.promoted ?? false)
                                          const PositionedDirectional(
                                              start: 5,
                                              top: 5,
                                              child: PromotedCard(
                                                  type: PromoteCardType.icon)),
                                        // PositionedDirectional(
                                        //   bottom: 6,
                                        //   start: 6,
                                        //   child: Container(
                                        //     height: 19,
                                        //     clipBehavior: Clip.antiAlias,
                                        //     decoration: BoxDecoration(
                                        //         color: context.color.secondaryColor
                                        //             .withOpacity(0.7),
                                        //         borderRadius:
                                        //         BorderRadius.circular(4)),
                                        //     child: BackdropFilter(
                                        //       filter: ImageFilter.blur(
                                        //           sigmaX: 2, sigmaY: 3),
                                        //       child: Padding(
                                        //         padding: const EdgeInsets.symmetric(
                                        //             horizontal: 8.0),
                                        //         child: Center(
                                        //           child: Text(
                                        //             property.properyType!
                                        //                 .translate(context),
                                        //           )
                                        //               .color(
                                        //             context.color.textColorDark,
                                        //           )
                                        //               .bold()
                                        //               .size(context.font.smaller),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
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
                                        property.category?.category??'',
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
                              // if ( statusButton1!= null)
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //         vertical: 3.0, horizontal: 3.0),
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //           color: statusButton1!.color,
                              //           borderRadius: BorderRadius.circular(4)),
                              //
                              //       child: Center(
                              //           child: Text(statusButton1!.lable)
                              //               .size(context.font.small)
                              //               .bold()
                              //               .color(statusButton1?.textColor ??
                              //               Colors.black)),
                              //     ),
                              //   )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left:10,right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Color(0xffffbf59)),
                                      color: Color(0xfffffbf3)
                                    ),
                                    child: Text(propStatus,
                                      style: TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                  Text(
                                    property.title!.firstUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  if (property.city != "")
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                          SizedBox(width: 5,),
                                          Expanded(
                                              child: Text(
                                                property.city?.trim() ?? "", maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w400
                                                ),)
                                          )
                                        ],
                                      ),
                                    ),
                                  // UiUtils.imageType(
                                  //     property.category!.image ?? "",
                                  //     width: 18,
                                  //     height: 18,
                                  //     color: Constant.adaptThemeColorSvg
                                  //         ? context.color.tertiaryColor
                                  //         : null),
                                  // const SizedBox(
                                  //   width: 5,
                                  // ),
                                  // Text(property.category!.category!)
                                  //     .setMaxLines(lines: 1)
                                  //     .size(
                                  //       context.font.small
                                  //           .rf(context),
                                  //     )
                                  //     .bold(
                                  //       weight: FontWeight.w400,
                                  //     )
                                  //     .color(
                                  //       context.color.textLightColor,
                                  //     ),

                                  if (property.properyType
                                      .toString()
                                      .toLowerCase() ==
                                      "rent") ...[
                                    Text(
                                      rentPrice,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      formatAmount(int.parse(property.price!),
                                      ).formatAmount(prefix: true),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Color(0xff333333),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                      ),
                                    )
                                  ],
                                  Row(
                                    children: [
                                      Text('${property.totalView} Views',
                                        maxLines: 2,overflow:TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(width: 5,),
                                      const Text("|", style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xffa2a2a2),
                                          fontWeight: FontWeight.w500),),
                                      SizedBox(width: 5,),
                                      Text(' ${property.postCreated}',
                                        maxLines: 2,overflow:TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xffa2a2a2),
                                            fontWeight: FontWeight.w500),
                                      ),

                                    ],
                                  ),
                                  SizedBox(),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InterestedUsersDetails(propertyId:property.id ,),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 28,
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Color(0xff117af9))
                                          ),child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset("assets/assets/Images/eye-icon.png",height: 15,),
                                            SizedBox(width: 5,),
                                            Text(property.totalInterestedUsers?.toString()??"0",style: TextStyle(fontSize: 12,color:  Color(0xff117af9)),)
                                          ],
                                        ),
                                        ),
                                      ),SizedBox(width: 10,),
                                      Container(
                                        height: 28,
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: property.status==0?Color(0xfffff1f1):Color(0xffd9efcf),
                                            border: Border.all(color:  property.status==0?Colors.red:Colors.green)
                                        ),child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text( property.status == 0 ? "InActive" : "Active",style: TextStyle(fontSize: 12,color:property.status == 0 ?Colors.red: Colors.green),)
                                        ],
                                      ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          if (useRow == false || useRow == null) ...addBottom ?? [],

                          if (useRow == true) ...{Row(children: addBottom ?? [])}

                          // ...addBottom ?? []
                        ],
                      ),
                      if (showDeleteButton ?? false)
                        PositionedDirectional(
                          top: 32 * 2,
                          end: 12,
                          child: InkWell(
                            onTap: () {
                              onDeleteTap?.call();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color.fromARGB(33, 0, 0, 0),
                                      offset: Offset(0, 2),
                                      blurRadius: 15,
                                      spreadRadius: 0)
                                ],
                              ),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: FittedBox(
                                  fit: BoxFit.none,
                                  child: SvgPicture.asset(
                                    AppIcons.bin,
                                    color: context.color.tertiaryColor,
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                              ),
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
                  child: PopupMenuButton<int>(
                    padding: EdgeInsets.all(0),
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.black,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        onTap: () async {
                          Constant.addProperty.addAll({
                            "category": Category(
                              category: property?.category!.category,
                              id: property?.category?.id!.toString(),
                              image: property?.category?.image,
                              parameterTypes: {
                                "parameters": property?.parameters
                                    ?.map((e) => e.toMap())
                                    .toList()
                              },
                            )
                          });
                          Navigator.pushNamed(
                              context, Routes.selectPropertyTypeScreen,
                              arguments: {
                                "details": property.toMap()
                                //   "details": {
                                //   "id": property?.id,
                                //   "catId": property?.category?.id,
                                //   "propType": property?.properyType,
                                //   "name": property?.title,
                                //   "desc": property?.description,
                                //   "city": property?.city,
                                //   "state": property?.state,
                                //   "country": property?.country,
                                //   "latitude": property?.latitude,
                                //   "longitude": property?.longitude,
                                //   "address": property?.address,
                                //   "client": property?.clientAddress,
                                //   "price": property?.price,
                                //   'parms': property?.parameters,
                                //   'rera': property?.rera,
                                //   'highlight': property?.highlight,
                                //   'brokerage': property?.brokerage,
                                //   'customerRole': property?.customerRole,
                                //   'amenity': property?.amenity,
                                //    'sqft': property?.sqft,
                                //   "images": property?.gallery
                                //       ?.map((e) => e.imageUrl)
                                //       .toList(),
                                //   "gallary_with_id": property?.gallery,
                                //   "rentduration": property?.rentduration,
                                //   "assign_facilities":
                                //   property?.assignedOutdoorFacility,
                                //   "titleImage": property?.titleImage
                                // }
                              });
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
                      if(addOnsList.any((item) => item['type'] == 'premium') && property.properyType != 'sold' && property.properyType != 'rented')
                        PopupMenuItem<int>(
                          onTap: () async {
                            var staResponse = await Api.post(url: Api.updatePropertyStatus, parameter: {
                              'project_id': '',
                              'property_id': property.id,
                              'deal': '',
                              'premium': 1,
                              'package_id': addOnsList.firstWhere((item) => item['type'] == 'premium')['id']
                            });
                            if (!staResponse['error']) {
                              setState(() {});
                              HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "Premium added successfully!"),
                                  type: MessageType.warning,
                                  messageDuration: 3);
                            }
                          },
                          value: 2,
                          child:  Row(
                            children: [
                              Image.asset("assets/assets/Images/premium.png",height: 14,width: 14,color: Colors.yellow[900],),
                              SizedBox(width: 8,),
                              Text("Added Premium", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),
                            ],
                          ),
                        ),
                      if(addOnsList.any((item) => item['type'] == 'deal_of_month') && property.properyType != 'sold' && property.properyType != 'rented')
                        PopupMenuItem<int>(
                        onTap: () async {
                          var staResponse = await Api.post(url: Api.updatePropertyStatus, parameter: {
                            'project_id': '',
                            'property_id': property.id,
                            'deal': 1,
                            'premium': '',
                            'package_id': addOnsList.firstWhere((item) => item['type'] == 'premium')['id']
                          });
                          if (!staResponse['error']) {
                            setState(() {});
                            HelperUtils.showSnackBarMessage(
                                context,
                                UiUtils.getTranslatedLabel(
                                    context, "Deal of month added successfully!"),
                                type: MessageType.warning,
                                messageDuration: 3);
                          }
                        },
                        value: 2,
                        child:  Row(
                          children: [

                            Image.asset("assets/assets/Images/offer (1).png",height: 14,width: 14,),
                            SizedBox(width: 8,),
                            Text("Added Deal of Month", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),

                          ],
                        ),
                      ),
                      if(property.status != 0)
                      PopupMenuItem<int>(
                        onTap: () async {
                          Future.delayed(Duration.zero, () {
                            UiUtils.showBlurredDialoge(context,
                                sigmaX: 5,
                                sigmaY: 5,
                                dialoge: BlurredDialogBox(
                                  svgImagePath: AppIcons.warning,
                                  title: 'Are you sure?',
                                  showCancleButton: true,
                                  acceptButtonName: 'Yes',
                                  acceptTextColor: context.color.buttonColor,
                                  onAccept: () async {
                                    var staResponse = await Api.post(url: Api.updatePropertyStatus, parameter: {
                                      'property_id': property?.id,
                                      'status': (property.properyType == 'sell') ? 2 : (property.properyType == 'rent') ? 3 : (property.properyType == 'sold') ? 0 : 1
                                    });
                                    if (!staResponse['error']) {
                                      // propStatus = property.properyType == 'sell' ? 'Sold' : property.properyType == 'rent' ? 'Rented' : property.properyType == 'sold' ? 'Sell' : 'Rent';
                                      context
                                          .read<FetchMyPropertiesCubit>()
                                          .fetchMyProperties(type: propertyScreenCurrentPage == 0 ? 'sell' : propertyScreenCurrentPage == 1 ? 'rent' : '');
                                      setState(() {});
                                      HelperUtils.showSnackBarMessage(
                                          context,
                                          UiUtils.getTranslatedLabel(
                                              context, "Status changed successfully!"),
                                          type: MessageType.warning,
                                          messageDuration: 3);
                                      // Navigator.pop(context);
                                    }
                                  },
                                  content: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Do you want to change the status from ${property.properyType!.toTitleCase()} to ${property.properyType == 'sell' ? 'Sold' : property.properyType == 'rent' ? 'Rented' : property.properyType == 'sold' ? 'Sell' : 'Rent'}?',
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
                        },
                        value: 2,
                        child:  Row(
                          children: [

                            Image.asset("assets/assets/Images/tag.png",height: 13,width: 13,),
                            SizedBox(width: 8,),
                            Text("Change Status", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),

                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        onTap: () async {
                          bool isPropertyActive =
                              property?.status.toString() == "1";

                          bool isDemoNumber = HiveUtils.getUserDetails().mobile ==
                              "${Constant.demoCountryCode}${Constant.demoMobileNumber}";

                          if (Constant.isDemoModeOn &&
                              isPropertyActive &&
                              isDemoNumber) {
                            HelperUtils.showSnackBarMessage(context,
                                "Active property cannot be deleted in demo app.");

                            return;
                          }

                          var delete = await UiUtils.showBlurredDialoge(
                            context,
                            dialoge: BlurredDialogBox(
                              title: UiUtils.getTranslatedLabel(
                                context,
                                "deleteBtnLbl",
                              ),
                              content: Text(
                                UiUtils.getTranslatedLabel(
                                    context, "deletepropertywarning"),
                              ),
                            ),
                          );
                          if (delete == true) {
                            Future.delayed(
                              Duration.zero,
                                  () {
                                // if (Constant.isDemoModeOn) {
                                //   HelperUtils.showSnackBarMessage(
                                //       context,
                                //       UiUtils.getTranslatedLabel(
                                //           context, "thisActionNotValidDemo"));
                                // } else {
                                context
                                    .read<DeletePropertyCubit>()
                                    .delete(property!.id!);
                                // }
                              },
                            );
                          }
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
          );
        }
      ),
    );
  }
}

class StatusButton1 {
  final String lable;
  final Color color;
  final Color? textColor;
  StatusButton1({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
