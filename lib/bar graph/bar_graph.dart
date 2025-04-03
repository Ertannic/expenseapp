import 'package:expenseapp/bar%20graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // initialize upon build

  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    // we need to scroll to the latest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // initialuze bar data - user our monthly summary to create a list of bars
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

  // calculate max for upper limit of graph
  double calcualteMax() {
    // initially, set it at 500, but adjust if spending is past this amont
    double max = 500;

    // get the month with the highest amount
    widget.monthlySummary.sort();

    // increase the upper limit by a bit
    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return 500;
    }
    return max;
  }

  // scroll controller to make sure it scroll to the end / latest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    // initialize upon build
    initializeBarData();

    // bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calcualteMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: getBottomTitles,
                  ),
                ),
              ),
              barGroups: List.generate(
                widget.monthlySummary.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: widget.monthlySummary[index],
                      color: Colors.grey.shade800,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calcualteMax(),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

// Подписи для оси X
Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  const List<String> months = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D'
  ];

  String text = (value.toInt() >= 0 && value.toInt() < months.length)
      ? months[value.toInt()]
      : '';

  return Padding(
    padding: const EdgeInsets.only(top: 8.0), // Немного отступа
    child: Text(text, style: textStyle),
  );
}
