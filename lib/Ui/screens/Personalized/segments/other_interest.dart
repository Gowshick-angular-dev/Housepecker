part of '../personalized_property_screen.dart';

class OtherInterests extends StatefulWidget {
  final PersonalizedVisitType type;
  final Function(
          RangeValues priceRange, String location, List<int> propertyType)
      onInteraction;
  const OtherInterests(
      {super.key, required this.onInteraction, required this.type});

  @override
  State<OtherInterests> createState() => _OtherInterestsState();
}

class _OtherInterestsState extends State<OtherInterests> {
  String selectedLocation = "";
  final TextEditingController _controller = TextEditingController();
  late final min = personalizedInterestSettings.priceRange.first ?? 0.0;
  late final max = personalizedInterestSettings.priceRange.last ?? 1.0;
  RangeValues _priceRangeValues = const RangeValues(0, 100);
  RangeValues _selectedRangeValues = const RangeValues(0, 50);

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();
  List<int> selectedPropertyType = [1, 2];
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        selectedPropertyType = personalizedInterestSettings.propertyType;

        if (personalizedInterestSettings.city.isNotEmpty) {
          _controller.text = personalizedInterestSettings.city.firstUpperCase();
          selectedLocation = personalizedInterestSettings.city;
        }

        widget.onInteraction
            .call(_selectedRangeValues, selectedLocation, selectedPropertyType);
        setState(() {});
        FetchSystemSettingsState state =
            context.read<FetchSystemSettingsCubit>().state;
        if (state is FetchSystemSettingsSuccess) {
          var settingsData = state.settings['data'];
          var minPrice = double.parse(settingsData['min_price']);
          var maxPrice = double.parse(settingsData['max_price']);
          _priceRangeValues = RangeValues(minPrice, maxPrice);
          if (min != 0.0 && max != 0.0) {
            _selectedRangeValues = RangeValues(min, max);
          } else {
            _selectedRangeValues = RangeValues(minPrice, maxPrice / 4);
          }
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xfff6faff),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select The City".translate(context))
                          .color(context.color.textColorDark)
                          .size(17)
                          .centerAlign(),
                      Text("You Want To See".translate(context))
                          .color(context.color.textColorDark)
                          .size(17),
                      Text("Property For".translate(context))
                          .color(context.color.textColorDark)
                          .size(17),

                    ],
                  ),
                ),
                if (isFirstTime)
                  GestureDetector(
                      onTap: () {
                        HelperUtils.killPreviousPages(
                            context, Routes.main, {"from": "login"});
                      },
                      child: Chip(
                          label: Text("skip".translate(context))
                              .color(context.color.buttonColor))),
                // const Chip(label: Text("Skip")),

              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                buildCitySearchTextField(context),
                const SizedBox(
                  height: 10,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text("selectedLocation".translate(context))
                            .color(context.color.textColorDark.withOpacity(0.6)),
                        Expanded(child: Text(selectedLocation))
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Text("Choose The Property".translate(context))
                    .color(context.color.textColorDark)
                    .size(17),
                Text("Type You Are Interested In".translate(context))
                    .color(context.color.textColorDark)
                    .size(17),

                const SizedBox(
                  height: 20,
                ),
                PropertyTypeSelector(
                  onInteraction: (List<int> values) {
                    selectedPropertyType = values;

                    widget.onInteraction
                        .call(_selectedRangeValues, selectedLocation, values);

                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                Text("Choose The Budget For The".translate(context))
                    .color(context.color.textColorDark)
                    .size(17),
                Text("Property You're Interested In.".translate(context))
                    .color(context.color.textColorDark)
                    .size(17),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text("minLbl".translate(context)),
                          Text(_selectedRangeValues.start
                              .toInt()
                              .toString()
                              .priceFormate()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: RangeSlider(
                        // labels: RangeLabels(_priceRangeValues.start.toString(), _priceRangeValues.end.toString()),
                        activeColor: context.color.tertiaryColor,
                        values: _selectedRangeValues,
                        onChanged: (RangeValues value) {
                          _selectedRangeValues = value;
                          widget.onInteraction.call(_selectedRangeValues,
                              selectedLocation, selectedPropertyType);
                          setState(() {});
                        },
                        min: _priceRangeValues.start,
                        max: _priceRangeValues.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text("maxLbl".translate(context)),
                          Text(_selectedRangeValues.end
                              .toInt()
                              .toString()
                              .priceFormate()),
                        ],
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
  }

  Widget buildCitySearchTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: TypeAheadField(
        debounceDuration: const Duration(milliseconds: 500),
        loadingBuilder: (context) {
          return Center(child: UiUtils.progress());
        },
        minCharsForSuggestions: 2,
        textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Color(0xffa0a0a0),
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
              hintText: "searchCity".translate(context),
                contentPadding : EdgeInsets.only(left: 15,top: 3,bottom: 3),
              fillColor: Color(0xfff5f5f5),
              suffixIcon: GestureDetector(
                  onTap: () {
                    _controller.text = "";
                  },
                  child: Icon(
                    Icons.close,
                    color: Color(0xff6b6b6b),
                  )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Color(0xffdfdfdf)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: context.color.tertiaryColor),
              ),
            )),
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: context.color.secondaryColor.withOpacity(1),
        ),
        itemBuilder: (context, GooglePlaceModel itemData) {
          List<String> address = [
            itemData.city,
            // itemData.state,
            // itemData.country
          ];

          return ListTile(
            title: Text(address.join(",").toString()),
          );
        },
        onSuggestionSelected: (GooglePlaceModel suggestion) {
          List<String> addressList = [
            suggestion.city,
            // suggestion.state,
            // suggestion.country
          ];
          String address = addressList.join(",");
          _controller.text = address;
          selectedLocation = address;
          widget.onInteraction.call(
              _selectedRangeValues, selectedLocation, selectedPropertyType);

          setState(() {});
        },
        suggestionsCallback: (pattern) async {
          return await googlePlaceRepository.serchCities(pattern);
        },
      ),
    );
  }
}

class PropertyTypeSelector extends StatefulWidget {
  final Function(List<int> values) onInteraction;
  const PropertyTypeSelector({
    super.key,
    required this.onInteraction,
  });

  @override
  State<PropertyTypeSelector> createState() => _PropertyTypeSelectorState();
}

class _PropertyTypeSelectorState extends State<PropertyTypeSelector> {
  List<int> selectedPropertyType = [1, 2];
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        if (personalizedInterestSettings.propertyType.isNotEmpty) {
          selectedPropertyType = personalizedInterestSettings.propertyType;
        }

        widget.onInteraction.call(selectedPropertyType);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAddAll([1, 2]);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: StadiumBorder(
                side: BorderSide(color: selectedPropertyType.containesAll([1, 2])
                    ? Color(0xffffa920)
                    : Color(0xffd9d9d9))),
            label: Text("all".translate(context),style: TextStyle(
              color: Color(0xff333333),
              fontSize: 13,
            ),),
            backgroundColor: selectedPropertyType.containesAll([1, 2])
                ? Color(0xfffffbf3)
                : Color(0xfff2f2f2),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(0);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: StadiumBorder(
                side: BorderSide(color: selectedPropertyType.isSingleElementAndIs(0)
                    ? Color(0xffffa920)
                    : Color(0xffd9d9d9))),
            label: Text("sell".translate(context),style: TextStyle(
              color: Color(0xff333333),
              fontSize: 13,
            ),),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(0)
                ? Color(0xfffffbf3)
                : Color(0xfff2f2f2),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
            onTap: () {
              selectedPropertyType.clearAndAdd(1);
              widget.onInteraction.call(selectedPropertyType);
              setState(() {});
            },
            child: Chip(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: StadiumBorder(
                  side: BorderSide(color: selectedPropertyType.isSingleElementAndIs(1)
                      ? Color(0xffffa920)
                      : Color(0xffd9d9d9))),
              label: Text("rent".translate(context),style: TextStyle(
                color: Color(0xff333333),
                fontSize: 13,
              ),),
              backgroundColor: selectedPropertyType.isSingleElementAndIs(1)
                  ? Color(0xfffffbf3)
                  : Color(0xfff2f2f2),
            )),
      ],
    );
  }
}
