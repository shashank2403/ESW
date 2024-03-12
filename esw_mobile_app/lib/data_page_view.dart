import 'dart:developer';

import 'package:flutter/material.dart';

class DataPageView extends StatefulWidget {
  const DataPageView({
    super.key,
  });

  @override
  State<DataPageView> createState() => _DataPageViewState();
}

class _DataPageViewState extends State<DataPageView> {
  PageController pageController = PageController(initialPage: 0);

  int currentPage = 0;

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
        SizedBox(
          height: 100.0,
          child: PageView(
            controller: pageController,
            onPageChanged: (pageIndex) {
              currentPage = pageIndex;
              setState(() {});
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 100,
                  color: Colors.brown,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 100,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
