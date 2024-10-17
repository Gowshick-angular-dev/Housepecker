// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

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

import '../../../../data/model/property_model.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/ui_utils.dart';
import '../../proprties/property_details.dart';
import '../../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../widgets/all_gallary_image.dart';

class PropertyHorizontalCard extends StatelessWidget {
  final PropertyModel property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  const PropertyHorizontalCard(
      {super.key,
      required this.property,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.onLikeChange,
      this.statusButton,
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
    String rentPrice = formatAmount(int.parse(property.price!));

    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice =
          ("$rentPrice/") + (rentDurationMap[property.rentduration] ?? "");
    }

    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property?.slugId ?? "");
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
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft:Radius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            UiUtils.getImage(
                              property.titleImage ?? "",
                              width: double.infinity,fit: BoxFit.cover,height: 103,
                            ),
                            // Positioned(
                            //   left: 8,
                            //   top: 8,
                            //   child: Container(
                            //     padding: EdgeInsets.symmetric(horizontal: 5),
                            //     height: 19,
                            //     clipBehavior: Clip.antiAlias,
                            //     decoration: BoxDecoration(
                            //         color: context.color.secondaryColor
                            //             .withOpacity(0.7),
                            //         borderRadius:
                            //         BorderRadius.circular(4)),
                            //     child: Row(
                            //       children: [
                            //         Image.asset("assets/Home/Offers.png", width:12, height: 12, color: Colors.blue),
                            //         SizedBox(width: 3,),
                            //         Text('offer').size(10)
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // Text(property.promoted.toString()),
                            if(property.isPremium == 1)
                              Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(child: Image.asset("assets/Home/__Premium.png",width: 18,height: 18,)),
                                  )
                              ),
                            if(property.isDeal == 1)
                              Positioned(
                                  top: 10,
                                  left: -5,
                                  child: Container(
                                    child: Stack(
                                      children: [
                                        Image.asset("assets/Home/offer.png", height: 20,),
                                        Positioned(
                                          top: 2,
                                          left: 15,
                                          child: Text('Offer',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ),
                            if (showLikeButton ?? true)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: context.color.secondaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color:
                                        Color.fromARGB(12, 0, 0, 0),
                                        offset: Offset(0, 2),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: LikeButtonWidget(
                                    property: property,
                                    onLikeChanged: onLikeChange,
                                  ),
                                ),
                              ),
                            if(property.gallery != null)
                              Positioned(
                                right: 48,
                                top: 8,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        BlurredRouter(
                                          builder: (context) {
                                            return AllGallaryImages(
                                                images: property
                                                    ?.gallery ??
                                                    []);
                                          },
                                        ));
                                  },
                                  child: Container(
                                    width: 35,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Color(0xff000000).withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(width: 1, color: Color(0xffe0e0e0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromARGB(12, 0, 0, 0),
                                          offset: Offset(0, 2),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.image,
                                            color: Color(0xffe0e0e0),
                                            size: 15
                                        ),
                                        SizedBox(width: 3,),
                                        Text('${property.gallery!.length}',
                                          style: TextStyle(
                                              color: Color(0xffe0e0e0),
                                              fontSize: 10
                                          ),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                            //             BorderRadius.circular(4)),
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
                            //                 context.color.textColorDark,
                            //               )
                            //               .bold(weight: FontWeight.w500)
                            //               .size(10),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      if (statusButton != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 3.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: statusButton!.color,
                                borderRadius: BorderRadius.circular(4)),

                            child: Center(
                                child: Text(statusButton!.lable)
                                    .size(11)
                                    .bold(weight: FontWeight.w500)
                                    .color(statusButton?.textColor ??
                                        Colors.black)),
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:10,right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(height: 6,),
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
                        SizedBox(height: 4,),
                        Row(
                          children: [
                            if (property.properyType
                                .toString()
                                .toLowerCase() ==
                                "rent") ...[
                              Text(
                                '₹${rentPrice}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ] else ...[
                              Text(
                                '₹${formatAmount(int.parse(property.price!))}',
                                // // .priceFormate(
                                // //     disabled:
                                // //         Constant.isNumberWithSuffix ==
                                // //             false)
                                //     .toString()
                                //     .formatAmount(
                                //   prefix: true,
                                // ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                height: 12,
                                width: 2,
                                color: Colors.black54,
                              ),
                            ),
                            Text("${property.sqft} Sq.ft",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xffa2a2a2),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4,),
                        if (property.city != "")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: Text(
                                      property.address?.trim() ?? "",  maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xffa2a2a2),
                                        fontSize: 9,
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

                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Posted By ${property.customerRole == 1 ? 'Owner' : property.customerRole == 2 ? 'Agent' : property.customerRole == 3 ? 'Builder' : 'Housepecker'}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xffa2a2a2),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // if (useRow == false || useRow == null) ...addBottom ?? [],
                  //
                  // if (useRow == true) ...{Row(children: addBottom ?? [])}

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
    );
  }
}

class PropertyVerticalCard extends StatelessWidget {
  final PropertyModel property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  const PropertyVerticalCard({
    super.key,
    required this.property,
    this.useRow,
    this.addBottom,
    this.additionalHeight,
    this.onLikeChange,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.additionalImageWidth,
  });

  String formatAmount(int number) {
    String result = '';
    if (number >= 10000000) {
      result = '${(number / 10000000).toStringAsFixed(2)} Cr';
    } else if (number >= 100000) {
      result = '${(number / 100000).toStringAsFixed(2)} Lakhs';
    } else {
      result = '$number';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.price!);

    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice = ("$rentPrice/") + (rentDurationMap[property.rentduration] ?? "");
    }

    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property.slugId ?? "");
        },
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 1, color: Color(0xffe0e0e0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    UiUtils.getImage(
                      property.titleImage ?? "",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 130,
                    ),
                    // Positioned(
                    //   left: 8,
                    //   top: 8,
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 5),
                    //     height: 19,
                    //     clipBehavior: Clip.antiAlias,
                    //     decoration: BoxDecoration(
                    //       color: context.color.secondaryColor.withOpacity(0.7),
                    //       borderRadius: BorderRadius.circular(4),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Image.asset(
                    //           "assets/Home/Offers.png",
                    //           width: 12,
                    //           height: 12,
                    //           color: Colors.blue,
                    //         ),
                    //         SizedBox(width: 3),
                    //         Text('Offer').size(10),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    if(property.isPremium == 1)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Image.asset("assets/Home/__Premium.png",width: 18,height: 18,)),
                        )
                      ),
                    if(property.isDeal == 1)
                      Positioned(
                          top: 10,
                          left: -5,
                          child: Container(
                            child: Stack(
                              children: [
                                Image.asset("assets/Home/offer.png", height: 20,),
                                Positioned(
                                  top: 2,
                                  left: 15,
                                  child: Text('Offer',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                      ),
                    if (showLikeButton ?? true)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(12, 0, 0, 0),
                                offset: Offset(0, 2),
                                blurRadius: 15,
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: LikeButtonWidget(
                            property: property,
                            onLikeChanged: onLikeChange,
                          ),
                        ),
                      ),
                    if(property.gallery != null)
                      Positioned(
                      right: 48,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              BlurredRouter(
                                builder: (context) {
                                  return AllGallaryImages(
                                      images: property
                                          ?.gallery ??
                                          []);
                                },
                              ));
                        },
                        child: Container(
                          width: 35,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Color(0xff000000).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 1, color: Color(0xffe0e0e0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(12, 0, 0, 0),
                                offset: Offset(0, 2),
                                blurRadius: 15,
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Color(0xffe0e0e0),
                                size: 15
                              ),
                              SizedBox(width: 3,),
                              Text('${property.gallery!.length}',
                              style: TextStyle(
                                color: Color(0xffe0e0e0),
                                fontSize: 10
                              ),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (property.promoted ?? false)
                      const PositionedDirectional(
                        start: 5,
                        top: 5,
                        child: PromotedCard(type: PromoteCardType.icon),
                      ),
                    // PositionedDirectional(
                    //   bottom: 6,
                    //   start: 6,
                    //   child: Container(
                    //     height: 19,
                    //     clipBehavior: Clip.antiAlias,
                    //     decoration: BoxDecoration(
                    //       color: context.color.secondaryColor.withOpacity(0.7),
                    //       borderRadius: BorderRadius.circular(4),
                    //     ),
                    //     child: BackdropFilter(
                    //       filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //         child: Center(
                    //           child: Text(
                    //             property.properyType!.translate(context),
                    //           )
                    //               .color(context.color.textColorDark)
                    //               .bold(weight: FontWeight.w500)
                    //               .size(10),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              if (statusButton != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusButton!.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(statusButton!.lable)
                          .size(11)
                          .bold(weight: FontWeight.w500)
                          .color(statusButton?.textColor ?? Colors.black),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title!.firstUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (property.properyType.toString().toLowerCase() == "rent") ...[
                          Text(
                            '₹${rentPrice}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '₹${formatAmount(int.parse(property.price!))}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            height: 12,
                            width: 2,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "${property.sqft} Sq.ft",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff494949),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (property.city != "")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/Home/__location.png",
                              width: 15,
                              fit: BoxFit.cover,
                              height: 15,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                property.address?.trim() ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xffa2a2a2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Posted By ${property.customerRole == 1 ? 'Owner' : property.customerRole == 2 ? 'Agent' : property.customerRole == 3 ? 'Builder' : 'Housepecker'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xffa2a2a2),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
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
  }
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;
  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
