import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/string_extenstion.dart';
import '../../../../utils/ui_utils.dart';
import '../../proprties/property_details.dart';
import '../../widgets/like_button_widget.dart';
import '../../widgets/promoted_widget.dart';

class PropertyCardBig extends StatelessWidget {
  final PropertyModel property;
  final bool? isFirst;
  final bool? showEndPadding;
  final Function(FavoriteType type)? onLikeChange;
  const PropertyCardBig(
      {super.key,
      this.onLikeChange,
      required this.property,
      this.isFirst,
      this.showEndPadding});

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.price!
        // .priceFormate( disabled: Constant.isNumberWithSuffix == false,)
        // .toString()
        // .formatAmount(prefix: true)
    );
    if (property.rentduration != "" && property.rentduration != null) {
      rentPrice = ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: (isFirst ?? false) ? 0 : 5.0,
        end: (showEndPadding ?? true) ? 5.0 : 0,
      ),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property?.slugId ?? "");
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: context.color.secondaryColor,
              border: Border.all(
                  width: 1,
                  color: Color(0xffe0e0e0)
              )
          ),
          height: 240,
          width: 250,
          child: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft:Radius.circular(15),
                        ),
                        child: UiUtils.getImage(
                          property.titleImage!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          blurHash: property.titleimagehash,
                        ),
                      ),
                      PositionedDirectional(
                        end: 10,
                        top: 10,
                        child: Container(
                          width: 30,
                          height: 30,
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
                          child: LikeButtonWidget(
                            property: property,
                            onLikeChanged: (type) {
                              onLikeChange?.call(type);
                            },
                          ),
                        ),
                      ),

                      // PositionedDirectional(
                      //   start: 10,
                      //   bottom: 10,
                      //   child: Container(
                      //     height: 24,
                      //     clipBehavior: Clip.antiAlias,
                      //     decoration: BoxDecoration(
                      //       color: context.color.secondaryColor.withOpacity(
                      //         0.7,
                      //       ),
                      //       borderRadius: BorderRadius.circular(
                      //         4,
                      //       ),
                      //     ),
                      //     child: BackdropFilter(
                      //       filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                      //       child: Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 8.0),
                      //         child: Center(
                      //           child: Text(
                      //             property.properyType!
                      //                 .toLowerCase()
                      //                 .translate(context),
                      //           )
                      //               .color(
                      //                 context.color.textColorDark,
                      //               )
                      //               .bold()
                      //               .size(context.font.smaller),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left:10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 8,),
                          Text(
                            property.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 6,),
                          if (property.city != "") ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset("assets/Home/__location.png",width:15,fit: BoxFit.cover,height: 15,),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(property.city!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xffa2a2a2),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w400
                                      ),),
                                  )
                                ],
                              ),
                            )
                          ],
                          // Row(
                          //   children: [
                          //     UiUtils.imageType(property.category!.image!,
                          //         width: 18,
                          //         height: 18,
                          //         color: Constant.adaptThemeColorSvg
                          //             ? context.color.tertiaryColor
                          //             : null),
                          //     const SizedBox(
                          //       width: 5,
                          //     ),
                          //     Text(property.category?.category ?? "")
                          //         .size(
                          //           context.font.small,
                          //         )
                          //         .bold(
                          //           weight: FontWeight.w400,
                          //         )
                          //         .color(
                          //           context.color.textLightColor,
                          //         )
                          //   ],
                          // ),
                          if (property.properyType.toString().toLowerCase() ==
                              "rent") ...[
                            Text(rentPrice == null? "" : rentPrice,  maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500
                              ),),
                          ] else ...[
                            Text(property.price!
                                // .priceFormate(disabled:Constant.isNumberWithSuffix == false,)
                              .formatAmount(prefix: true)
                              ,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xff333333),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500
                              ),)
                          ],
                          SizedBox(height: 6,),
                          Text("Ready To Move",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xffa2a2a2),
                                fontSize: 11,
                                fontWeight: FontWeight.w400
                            ),
                          ),

                        ],
                      ),
                    ),
                  )
                ],
              ),

              // PositionedDirectional(
              //   start: 10,
              //   top: 10,
              //   child: Row(
              //     children: [
              //       Visibility(
              //           visible: property.promoted ?? false,
              //           child: const PromotedCard(type: PromoteCardType.text)),
              //       // const SizedBox(
              //       //   width: 2,
              //       // ),
              //       // Container(
              //       //   height: 24,
              //       //   decoration: BoxDecoration(
              //       //       color: context.color.secondaryColor.withOpacity(0.9),
              //       //       borderRadius: BorderRadius.circular(4)),
              //       //   child: Padding(
              //       //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //       //     child: Center(
              //       //       child: Text(
              //       //         UiUtils.getTranslatedLabel(context, "sell"),
              //       //       )
              //       //           .color(
              //       //             context.color.textColorDark,
              //       //           )
              //       //           .bold()
              //       //           .size(context.font.smaller),
              //       //     ),
              //       //   ),
              //       // )
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
