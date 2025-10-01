import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => StatisticsModel(prefs)),
        ChangeNotifierProvider(create: (_) => ProfileModel(prefs)),
        ChangeNotifierProvider(create: (_) => TimerModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return MaterialApp(
          navigatorKey: TimerModel.navigatorKey,
          title: 'Timer App',
          theme: ThemeData.dark(),
          home: HomeScreen(),
          builder: (context, child) {
            return Stack(
              children: [
                Scaffold(
                  body: child,
                  backgroundColor: themeModel.backgroundColor,
                ),
                if (Provider.of<TimerModel>(context).secondsRemaining > 0 || Provider.of<TimerModel>(context).isMinimized)
                  Positioned(
                    top: 16,
                    left: MediaQuery.of(context).size.width / 2 - 100,
                    child: SizedBox(
                      width: 200,
                      child: MinimizedTimer(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final now = DateTime.now();
    final formattedDate = "${now.weekdayName}, ${now.day} ${now.monthName} ${now.year}";

    return Container(
      decoration: themeModel.backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: themeModel.backgroundImage!,
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(color: themeModel.backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.home, size: 40),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, size: 40),
                    onSelected: (String value) {
                      if (value == 'customize') {
                        _showCustomizeDialog(context);
                      } else if (value == 'statistics') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StatisticsScreen()),
                        );
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'customize',
                        child: Text('Customize'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'statistics',
                        child: Text('Statistics'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('My Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  formattedDate,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 200),
                    ElevatedButton(
                      onPressed: () {
                        final timerModel = Provider.of<TimerModel>(context, listen: false);
                        if (timerModel.secondsRemaining > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimerRunningScreen(
                                hours: timerModel.initialSeconds ~/ 3600,
                                minutes: (timerModel.initialSeconds % 3600) ~/ 60,
                                seconds: timerModel.initialSeconds % 60,
                                category: timerModel.category,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TimerSettingScreen()),
                          );
                        }
                      },
                      child: Text('Timer', style: TextStyle(fontSize: 28)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customize Background', style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Red', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.red[900],
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundColor(Colors.red[900]!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Blue', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.blue[900],
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundColor(Colors.blue[900]!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Green', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.green[900],
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundColor(Colors.green[900]!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Black', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.black,
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundColor(Colors.black);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Coding Background', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/CodingBackground.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundImage(AssetImage('assets/CodingBackground.png'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lofi Background', style: TextStyle(fontSize: 18)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/lofi1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Provider.of<ThemeModel>(context, listen: false).setBackgroundImage(AssetImage('assets/lofi1.png'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to get weekday and month names
extension DateTimeExtension on DateTime {
  String get weekdayName {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String get monthName {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }
}

class TimerSettingScreen extends StatefulWidget {
  const TimerSettingScreen({super.key});

  @override
  State<TimerSettingScreen> createState() => _TimerSettingScreenState();
}

class _TimerSettingScreenState extends State<TimerSettingScreen> {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  String selectedCategory = 'Coding'; // Default category

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      body: Container(
        decoration: themeModel.backgroundImage != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: themeModel.backgroundImage!,
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(color: themeModel.backgroundColor),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.home, size: 40),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<int>(
                          value: hours,
                          items: List.generate(24, (index) => index)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(), style: TextStyle(color: Colors.white, fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              hours = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                        ),
                        Text(' hours ', style: TextStyle(color: Colors.white, fontSize: 18)),
                        DropdownButton<int>(
                          value: minutes,
                          items: List.generate(60, (index) => index)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(), style: TextStyle(color: Colors.white, fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              minutes = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                        ),
                        Text(' min ', style: TextStyle(color: Colors.white, fontSize: 18)),
                        DropdownButton<int>(
                          value: seconds,
                          items: List.generate(60, (index) => index)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(), style: TextStyle(color: Colors.white, fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              seconds = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                        ),
                        Text(' sec ', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Choose a category: ', style: TextStyle(color: Colors.white, fontSize: 18)),
                        DropdownButton<String>(
                          value: selectedCategory,
                          items: <String>['Coding', 'Exercise', 'Reading', 'Writing', 'Studying', 'Assignments']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: Colors.white, fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          dropdownColor: Colors.grey[850],
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(20),
                          ),
                          child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            final timerModel = Provider.of<TimerModel>(context, listen: false);
                            timerModel.startTimer(hours, minutes, seconds, selectedCategory, context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimerRunningScreen(
                                  hours: hours,
                                  minutes: minutes,
                                  seconds: seconds,
                                  category: selectedCategory,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(20),
                          ),
                          child: Text('Start', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statisticsModel = Provider.of<StatisticsModel>(context);

    // Calculate total seconds across all categories
    final totalSeconds = statisticsModel.getTotalSeconds('Coding') +
        statisticsModel.getTotalSeconds('Exercise') +
        statisticsModel.getTotalSeconds('Reading') +
        statisticsModel.getTotalSeconds('Writing') +
        statisticsModel.getTotalSeconds('Studying') +
        statisticsModel.getTotalSeconds('Assignments');
    final totalHours = totalSeconds ~/ 3600;
    final remainingSeconds = totalSeconds % 3600;
    final totalMinutes = remainingSeconds ~/ 60;
    final remainingSecondsDisplay = remainingSeconds % 60;

    // Find the maximum value for dynamic scaling
    final maxSeconds = [
      statisticsModel.getTotalSeconds('Coding'),
      statisticsModel.getTotalSeconds('Exercise'),
      statisticsModel.getTotalSeconds('Reading'),
      statisticsModel.getTotalSeconds('Writing'),
      statisticsModel.getTotalSeconds('Studying'),
      statisticsModel.getTotalSeconds('Assignments'),
    ].reduce((a, b) => a > b ? a : b);
    final dynamicMaxY = maxSeconds > 0 ? (maxSeconds + 3600) ~/ 3600 * 3600 : 10000;

    return Container(
      decoration: Provider.of<ThemeModel>(context).backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: Provider.of<ThemeModel>(context).backgroundImage!,
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(color: Provider.of<ThemeModel>(context).backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.home, size: 40),
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount Achieved',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      totalSeconds > 0
                          ? '$totalHours hour${totalHours != 1 ? 's' : ''} $totalMinutes minute${totalMinutes != 1 ? 's' : ''} $remainingSecondsDisplay second${remainingSecondsDisplay != 1 ? 's' : ''}'
                          : '0 seconds',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Category Totals (in seconds):',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('Coding: ${statisticsModel.getTotalSeconds('Coding')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Exercise: ${statisticsModel.getTotalSeconds('Exercise')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Reading: ${statisticsModel.getTotalSeconds('Reading')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Writing: ${statisticsModel.getTotalSeconds('Writing')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Studying: ${statisticsModel.getTotalSeconds('Studying')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('Assignments: ${statisticsModel.getTotalSeconds('Assignments')} seconds', style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.grey[850]!,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItem: (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                final categories = ['Coding', 'Exercise', 'Reading', 'Writing', 'Studying', 'Assignments'];
                                final value = rod.toY.round();
                                return BarTooltipItem(
                                  '${categories[groupIndex]}: $value seconds',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: dynamicMaxY.toDouble(),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Coding').toDouble(),
                                  color: Colors.blue,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Exercise').toDouble(),
                                  color: Colors.green,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Reading').toDouble(),
                                  color: Colors.red,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Writing').toDouble(),
                                  color: Colors.orange,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Studying').toDouble(),
                                  color: Colors.purple,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 5,
                              barRods: [
                                BarChartRodData(
                                  toY: statisticsModel.getTotalSeconds('Assignments').toDouble(),
                                  color: Colors.teal,
                                  width: 20,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: dynamicMaxY.toDouble(),
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  final style = TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  String text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = 'Coding';
                                      break;
                                    case 1:
                                      text = 'Exercise';
                                      break;
                                    case 2:
                                      text = 'Reading';
                                      break;
                                    case 3:
                                      text = 'Writing';
                                      break;
                                    case 4:
                                      text = 'Studying';
                                      break;
                                    case 5:
                                      text = 'Assignments';
                                      break;
                                    default:
                                      text = '';
                                      break;
                                  }
                                  final isEven = value.toInt() % 2 == 0;
                                  return Transform.translate(
                                    offset: Offset(0, isEven ? 0 : 10),
                                    child: SideTitleWidget(
                                      meta: meta,
                                      space: 4,
                                      child: Text(text, style: style, textAlign: TextAlign.center),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  final style = TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text('${value ~/ 3600}h', style: style),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Ensures full coverage
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

class TimeData {
  final String category;
  final int seconds;

  TimeData(this.category, this.seconds);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileModel = Provider.of<ProfileModel>(context);

    return Container(
      decoration: Provider.of<ThemeModel>(context).backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: Provider.of<ThemeModel>(context).backgroundImage!,
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(color: Provider.of<ThemeModel>(context).backgroundColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.home, size: 40),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(profileModel.profileImage),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue, size: 30),
                          onPressed: () => _showImageSelectionDialog(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Username: ',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: TextEditingController(text: profileModel.name)
                              ..addListener(() {
                                profileModel.name = TextEditingController(text: profileModel.name).text;
                              }),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        profileModel.bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default1.jpg'),
                ),
                title: Text('Default 1'),
                onTap: () {
                  Provider.of<ProfileModel>(context, listen: false).profileImage = 'assets/default1.jpg';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default2.jpg'),
                ),
                title: Text('Default 2'),
                onTap: () {
                  Provider.of<ProfileModel>(context, listen: false).profileImage = 'assets/default2.jpg';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default3.jpg'),
                ),
                title: Text('Default 3'),
                onTap: () {
                  Provider.of<ProfileModel>(context, listen: false).profileImage = 'assets/default3.jpg';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class TimerRunningScreen extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final String category;

  const TimerRunningScreen({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerModel>(
      builder: (context, timerModel, child) {
        final themeModel = Provider.of<ThemeModel>(context);

        return Container(
          decoration: themeModel.backgroundImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: themeModel.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(color: themeModel.backgroundColor),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                timerModel.minimize();
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.home, size: 40),
                          onPressed: () {
                            timerModel.minimize();
                            Navigator.popUntil(context, ModalRoute.withName('/'));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.minimize, size: 40, color: Colors.white),
                          onPressed: timerModel.isMinimized ? null : timerModel.minimize,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CustomPaint(
                              painter: CircleProgressPainter(progress: timerModel.secondsRemaining / timerModel.initialSeconds),
                              child: Center(
                                child: Text(
                                  '${(timerModel.secondsRemaining ~/ 3600).toString().padLeft(2, '0')}:${((timerModel.secondsRemaining % 3600) ~/ 60).toString().padLeft(2, '0')}:${(timerModel.secondsRemaining % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(fontSize: 44, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  timerModel.cancelTimer();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                ),
                                child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: timerModel.isRunning ? timerModel.pauseTimer : timerModel.resumeTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                ),
                                child: Text(timerModel.isRunning ? 'Pause' : 'Resume', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MinimizedTimer extends StatelessWidget {
  const MinimizedTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);
    return GestureDetector(
      onTap: () {
        timerModel.maximize(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${timerModel.secondsRemaining ~/ 3600}:${(timerModel.secondsRemaining % 3600) ~/ 60}:${timerModel.secondsRemaining % 60}',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Text(
              timerModel.category,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: timerModel.cancelTimer,
            ),
          ],
        ),
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 5.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Progress circle
    final progressPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        -2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ThemeModel with ChangeNotifier {
  Color _backgroundColor = Colors.blue[900]!;
  ImageProvider? _backgroundImage;

  Color get backgroundColor => _backgroundColor;
  ImageProvider? get backgroundImage => _backgroundImage;

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    _backgroundImage = null;
    notifyListeners();
  }

  void setBackgroundImage(ImageProvider? image) {
    _backgroundImage = image;
    _backgroundColor = image != null ? Colors.transparent : Colors.blue[900]!;
    notifyListeners();
  }
}

class StatisticsModel with ChangeNotifier {
  final Map<String, int> _categoryTotals = {
    'Coding': 0,
    'Exercise': 0,
    'Reading': 0,
    'Writing': 0,
    'Studying': 0,
    'Assignments': 0,
  };
  final SharedPreferences _prefs;

  StatisticsModel(this._prefs) {
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    final prefs = _prefs;
    _categoryTotals['Coding'] = prefs.getInt('coding_total') ?? 0;
    _categoryTotals['Exercise'] = prefs.getInt('exercise_total') ?? 0;
    _categoryTotals['Reading'] = prefs.getInt('reading_total') ?? 0;
    _categoryTotals['Writing'] = prefs.getInt('writing_total') ?? 0;
    _categoryTotals['Studying'] = prefs.getInt('studying_total') ?? 0;
    _categoryTotals['Assignments'] = prefs.getInt('assignments_total') ?? 0;
    notifyListeners();
  }

  Future<void> _saveTotals() async {
    final prefs = _prefs;
    await prefs.setInt('coding_total', _categoryTotals['Coding'] ?? 0);
    await prefs.setInt('exercise_total', _categoryTotals['Exercise'] ?? 0);
    await prefs.setInt('reading_total', _categoryTotals['Reading'] ?? 0);
    await prefs.setInt('writing_total', _categoryTotals['Writing'] ?? 0);
    await prefs.setInt('studying_total', _categoryTotals['Studying'] ?? 0);
    await prefs.setInt('assignments_total', _categoryTotals['Assignments'] ?? 0);
  }

  void addTime(String category, int seconds) {
    if (_categoryTotals.containsKey(category)) {
      _categoryTotals[category] = (_categoryTotals[category] ?? 0) + seconds;
      _saveTotals();
      notifyListeners();
    }
  }

  int getTotalSeconds(String category) {
    return _categoryTotals[category] ?? 0;
  }
}

class ProfileModel with ChangeNotifier {
  String _name = 'User Name';
  String _bio = 'Tell us about yourself!';
  String _profileImage = 'assets/profile_image.jpg';
  final SharedPreferences _prefs;

  ProfileModel(this._prefs) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = _prefs;
    _name = prefs.getString('profile_name') ?? 'User Name';
    _bio = prefs.getString('profile_bio') ?? 'Tell us about yourself!';
    _profileImage = prefs.getString('profile_image') ?? 'assets/profile_image.jpg';
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = _prefs;
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_bio', _bio);
    await prefs.setString('profile_image', _profileImage);
  }

  String get name => _name;
  String get bio => _bio;
  String get profileImage => _profileImage;

  set name(String value) {
    _name = value;
    _saveProfile();
    notifyListeners();
  }

  set bio(String value) {
    _bio = value;
    _saveProfile();
    notifyListeners();
  }

  set profileImage(String value) {
    _profileImage = value;
    _saveProfile();
    notifyListeners();
  }
}

class TimerModel with ChangeNotifier {
  int _secondsRemaining = 0;
  int _initialSeconds = 0;
  String _category = '';
  bool _isRunning = false;
  bool _isMinimized = false;
  Timer? _timer;
  late StatisticsModel _statisticsModel;

  TimerModel();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int get secondsRemaining => _secondsRemaining;
  int get initialSeconds => _initialSeconds;
  String get category => _category;
  bool get isRunning => _isRunning;
  bool get isMinimized => _isMinimized;

  void startTimer(int hours, int minutes, int seconds, String category, BuildContext context) {
    _initialSeconds = hours * 3600 + minutes * 60 + seconds;
    _secondsRemaining = _initialSeconds;
    _category = category;
    _isRunning = true;
    _isMinimized = false;
    _statisticsModel = Provider.of<StatisticsModel>(context, listen: false);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning && _secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else if (_secondsRemaining <= 0) {
        timer.cancel();
        _isRunning = false;
        _statisticsModel.addTime(_category, _initialSeconds);
        _showCompletionDialog(context);
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (!_isRunning && _secondsRemaining > 0) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          timer.cancel();
          _isRunning = false;
          _statisticsModel.addTime(_category, _initialSeconds);
          _showCompletionDialog(TimerModel.navigatorKey.currentContext!);
        }
      });
      notifyListeners();
    }
  }

  void cancelTimer() {
    _isRunning = false;
    _isMinimized = false;
    _timer?.cancel();
    _secondsRemaining = 0;
    notifyListeners();
  }

  void stopTimer() {
    cancelTimer();
  }

  void minimize() {
    if (_isRunning && !_isMinimized) {
      _isMinimized = true;
      notifyListeners();
    }
  }

  void maximize(BuildContext context) {
    if (_isMinimized) {
      _isMinimized = false;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TimerRunningScreen(
          hours: _initialSeconds ~/ 3600,
          minutes: (_initialSeconds % 3600) ~/ 60,
          seconds: _initialSeconds % 60,
          category: _category,
        )),
      );
      notifyListeners();
    }
  }

  void _showCompletionDialog(BuildContext context) {
    final durationText = formatDuration(_initialSeconds ~/ 3600, (_initialSeconds % 3600) ~/ 60, _initialSeconds % 60);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Congratulations!', style: TextStyle(color: Colors.white, fontSize: 20)),
        content: Text(
          'You have successfully completed $durationText of $category!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.green, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String formatDuration(int hours, int minutes, int seconds) {
    List<String> parts = [];
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    if (seconds > 0) parts.add('$seconds second${seconds > 1 ? 's' : ''}');
    if (parts.isEmpty) return '0 seconds';
    return parts.join(' ');
  }
}