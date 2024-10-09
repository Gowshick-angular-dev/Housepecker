import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../utils/ui_utils.dart';



class ServiceCategoryList extends StatefulWidget {
  const ServiceCategoryList({super.key});

  @override
  State<ServiceCategoryList> createState() => _ServiceCategoryListState();
}

class _ServiceCategoryListState extends State<ServiceCategoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.getTranslatedLabel(
          context,
          "articles",
        ),
      ),
    );
  }
}
