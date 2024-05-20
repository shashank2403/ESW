import 'package:esw_mobile_app/graphs.dart';
import 'package:esw_mobile_app/utils.dart';
import 'package:flutter/material.dart';
import "package:esw_mobile_app/constants.dart";

class DataPageView extends StatefulWidget {
  const DataPageView({
    super.key,
    required this.rawData,
  });

  final String rawData;
  @override
  State<DataPageView> createState() => _DataPageViewState();
}

class _DataPageViewState extends State<DataPageView> {
  PageController pageController = PageController(initialPage: 0);

  int currentPage = 0;
  late List<Map<String, String>> data;
  late Map<String, List<double>> featureSeries;

  @override
  void initState() {
    super.initState();
    data = getDataFromRaw(widget.rawData);
    featureSeries = getSeries(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (currentPage != 0) {
                    setState(() {
                      currentPage = 0;
                      pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentPage == 0 ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Latest",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (currentPage != 1) {
                    setState(() {
                      currentPage = 1;
                      pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentPage == 1 ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Plot",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 700,
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (pageIndex) {
              currentPage = pageIndex;
              setState(() {});
            },
            children: [
              SingleChildScrollView(child: getLatestDisplay(data)),
              SingleChildScrollView(
                child: Column(
                  children: [
                    for (var entry in dataPlots)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SizedBox(
                          width: 500,
                          height: 300,
                          child: LineChartWidget(
                            displayData: featureSeries[entry]!,
                            dataTitle: entry,
                            dataUnit: dataUnits[entry] ?? "",
                            timeData: featureSeries["Time"]!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
