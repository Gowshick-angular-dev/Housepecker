import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../data/cubits/category/fetch_category_cubit.dart';
import '../../../../data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
import '../../../../data/cubits/subscription/get_subsctiption_package_limits_cubit.dart';
import '../../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../../data/helper/widgets.dart';
import '../../../../data/model/category.dart';
import '../../../../data/model/system_settings_model.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/responsiveSize.dart';
import '../../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/blurred_dialoge_box.dart';
import 'loanAdForm.dart';

class SelectAdType extends StatefulWidget {
  final List? cat;
  const SelectAdType({super.key, this.cat});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const SelectAdType();
      },
    );
  }

  @override
  State<SelectAdType> createState() => _SelectAdTypeState();
}

class _SelectAdTypeState extends State<SelectAdType> {

  int? selectedIndex;
  var selectedCategory;
  bool isLimitFetched = false;
  bool isDialogeShown = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          title: UiUtils.getTranslatedLabel(
            context,
            "Post Advertisement",
          ),
          actions: const [
            Text("1/2",style: TextStyle(color: Colors.white)),
            SizedBox(
              width: 14,
            ),
          ],
          showBackButton: true),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              disabledColor: Colors.grey,
              onTapDisabledButton: () {
                HelperUtils.showSnackBarMessage(
                    context, "pleaseSelectCategory".translate(context),
                    isFloating: true);
              },
              disabled: selectedCategory == null,
              onPressed: () {
                if (selectedCategory != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanAdForm(cat: selectedCategory, isEdit: false, id: null)),
                  );
                }
              },
              height: 40.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "continue")),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 20.0, end: 20, top: 20),
              child:
              Text(UiUtils.getTranslatedLabel(context, "typeOfProperty"))
                  .color(context.color.textColorDark),
            ),
            GridView.builder(
              itemCount: widget.cat!.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  crossAxisCount: 3),
              itemBuilder: (context, index) {
                return buildTypeCard(
                    index, context, widget.cat![index]);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildTypeCard(int index, BuildContext context, category) {
    return GestureDetector(
      onTap: () {
        selectedCategory = category;
        selectedIndex = index;
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
            color: (selectedIndex == index) ? Color(0xffeef6ff) : Color(0xfff9f9f9),
            borderRadius: BorderRadius.circular(10),
            // boxShadow: (selectedIndex == index)
            //     ? [
            //         BoxShadow(
            //             offset: const Offset(1, 2),
            //             blurRadius: 5,
            //             color: context.color.tertiaryColor)
            //       ]
            //     : null,
            border:  Border.all(color: (selectedIndex == index) ? Color(0xff88bcfc) : Color(0xffe0e0e0), width: 1.5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.house,
            //   color: selectedIndex == index
            //       ? context.color.secondaryColor
            //       : context.color.teritoryColor,
            // ),
            SizedBox(
              height: 28.rh(context),
              width: 28.rw(context),
              child: UiUtils.imageType(category['image']!,
                  color: selectedIndex == index
                      ? context.color.secondaryColor
                      : (Constant.adaptThemeColorSvg
                      ? context.color.tertiaryColor
                      : null)),
            ),

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                category['name']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                ),
              ).color(selectedIndex == index
                  ? Color(0xff3c3c3c)
                  : Color(0xff3c3c3c)),
            )
          ],
        ),
      ),
    );
  }
}
