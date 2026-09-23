import 'package:flutter/material.dart';
import 'package:qr_app/controller/my_controller.dart';

class TimelineController extends MyController {
  final PageController pageController = PageController();
  int selectedIndex = 0;

  final List<TimelineItem> items = [
    TimelineItem(
      period: '2013 - 14',
      role: 'UI / UX Designer of xyz Company',
      description:
          'To achieve this, it would be necessary to have uniform grammar, pronunciation and more common words...',
    ),
    TimelineItem(
      period: '2014 - 16',
      role: 'Frontend Developer of abc Company',
      description:
          'If several languages coalesce, the grammar of the resulting language is more simple and regular...',
    ),
    TimelineItem(
      period: '2016 - 18',
      role: 'Backend Developer of xyz Company',
      description:
          'The new common language will be more simple and regular than the existing European languages...',
    ),
    TimelineItem(
      period: '2018 - 19',
      role: 'Full stack Developer of abc Company',
      description:
          'Their separate existence is a myth. Europe uses the same vocabulary. The languages only differ in grammar...',
    ),
  ];

  final List<TimelineEvent> timelineEvents = [
    TimelineEvent(
      date: '07 Nov',
      title: 'Ordered',
      description:
          'New common language will be more simple and regular than the existing.',
    ),
    TimelineEvent(
      date: '09 Nov',
      title: 'Packed',
      description:
          'To achieve this, it would be necessary to have uniform grammar.',
    ),
    TimelineEvent(
      date: '10 Nov',
      title: 'Shipped',
      description:
          'It will be as simple as Occidental in fact, it will be Occidental.',
    ),
    TimelineEvent(
      date: '11 Nov',
      title: 'Delivered',
      description:
          'To an English person, it will seem like simplified English.',
    ),
  ];

  void onNavTap(int index) {
    selectedIndex = index;

    update();
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    selectedIndex = index;
    update();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class TimelineEvent {
  final String date;
  final String title;
  final String description;

  TimelineEvent({
    required this.date,
    required this.title,
    required this.description,
  });
}

class TimelineItem {
  final String period;
  final String role;
  final String description;

  TimelineItem({
    required this.period,
    required this.role,
    required this.description,
  });
}
