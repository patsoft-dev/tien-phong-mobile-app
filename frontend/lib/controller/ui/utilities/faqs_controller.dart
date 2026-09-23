import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:qr_app/controller/my_controller.dart';

class FaqsController extends MyController {
  final List<InfoCardItem> cards = [
    InfoCardItem(
      icon: RemixIcons.question_line,
      title: 'General Questions',
      onTap: () {},
    ),
    InfoCardItem(
      icon: RemixIcons.price_tag_3_line,
      title: 'Privacy Policy',
      onTap: () {},
    ),
    InfoCardItem(
      icon: Icons.support_agent,
      title: 'Help & Support',
      onTap: () {},
    ),
    InfoCardItem(icon: Icons.article, title: 'Pricing & Plans', onTap: () {}),
  ];
  final List faqs = [
    {
      'number': '01',
      'question': 'What is Lorem Ipsum?',
      'answer':
          'New common language will be more simple and regular than the existing European languages. It will be as simple as occidental.',
    },
    {
      'number': '02',
      'question': 'Where does it come from?',
      'answer':
          'Everyone realizes why a new common language would be desirable one could refuse to pay expensive translators.',
    },
    {
      'number': '03',
      'question': 'Where can I get some?',
      'answer':
          'If several languages coalesce, the grammar of the resulting language is more simple and regular than that of the individual languages.',
    },
    {
      'number': '04',
      'question': 'Why do we use it?',
      'answer':
          'Their separate existence is a myth. For science, music, sport, etc, Europe uses the same vocabulary.',
    },
    {
      'number': '05',
      'question': 'Where can I get some?',
      'answer':
          'To an English person, it will seem like simplified English, as a skeptical Cambridge friend of mine told me what Occidental',
    },
    {
      'number': '06',
      'question': 'Where can I get some?',
      'answer':
          'If several languages coalesce, the grammar of the resulting language is more simple and regular than that of the individual languages.',
    },
  ];
}

class InfoCardItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  InfoCardItem({required this.icon, required this.title, required this.onTap});
}
