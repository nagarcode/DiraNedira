import 'package:dira_nedira/investments/investment.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingsChart extends StatelessWidget {
  final List<Investment> investments;

  static show(BuildContext context, List<Investment> investments) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => SpendingsChart(
            investments: investments,
          ),
        ));
  }

  const SpendingsChart({@required this.investments});
  @override
  Widget build(BuildContext context) {
    final sections = _initSectionsData();
    final data = PieChartData(
      borderData: FlBorderData(border: Border.all()),
      sections: sections,
      centerSpaceRadius: 20,
    );
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        body: Center(
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Card(
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        data,
                      ),
                    ),
                  ),
                  // Column(
                  //   mainAxisSize: MainAxisSize.max,
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: _indicators(),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _initSectionsData() {
    final Map<Color, List<Investment>> colorsToInvestments =
        _initColorsToInvestments();
    final sectionsList = <PieChartSectionData>[];
    final sectionsMap = Investment.colors;
    sectionsMap.forEach((key, value) {
      final investmentList = colorsToInvestments[key];
      int amount = 0;
      for (var investment in investmentList) {
        amount += investment.amount;
      }
      sectionsList.add(PieChartSectionData(
          radius: 140,
          titleStyle: TextStyle(fontSize: 15),
          color: key,
          title: value + '\n₪$amount',
          showTitle: investmentList.isNotEmpty,
          value: investmentList.length.toDouble()));
    });
    sectionsList.forEach((element) {});
    return sectionsList;
  }

  Map<Color, List<Investment>> _initColorsToInvestments() {
    final Map<Color, List<Investment>> colorsToInvestments = {};
    Investment.colors.keys.forEach((color) {
      colorsToInvestments[color] = [];
    });
    for (var investment in investments) {
      colorsToInvestments[investment.color()].add(investment);
    }
    return colorsToInvestments;
  }

  // _indicators() {
  //   return [
  //     Investment.colors.forEach((color, name) {
  //       Indicator(
  //         color: Color(0xfff8b250),
  //         text: 'Second',
  //         isSquare: true,
  //       );
  //     })
  //   ];
  // }
}
