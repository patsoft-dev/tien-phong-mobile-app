import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_app/controller/my_controller.dart';

class PricingController extends MyController {
  final List<PricingCard> cards = [
    PricingCard(
      icon: FontAwesomeIcons.cube,
      title: 'Starter',
      subtitle: 'Neque quis est',
      price: '19',
      features: [
        'Free Live Support',
        'Unlimited User',
        'No Time Tracking',
        'Free Setup',
      ],
    ),
    PricingCard(
      icon: FontAwesomeIcons.trophy,
      title: 'Professional',
      subtitle: 'Quis autem iure',
      price: '29',
      features: [
        'Free Live Support',
        'Unlimited User',
        'No Time Tracking',
        'Free Setup',
      ],
    ),
    PricingCard(
      icon: FontAwesomeIcons.shieldHalved,
      title: 'Enterprise',
      subtitle: 'Sed neque unde',
      price: '39',
      features: [
        'Free Live Support',
        'Unlimited User',
        'No Time Tracking',
        'Free Setup',
      ],
    ),
    PricingCard(
      icon: FontAwesomeIcons.headset,
      title: 'Unlimited',
      subtitle: 'Itaque earum rerum',
      price: '49',
      features: [
        'Free Live Support',
        'Unlimited User',
        'No Time Tracking',
        'Free Setup',
      ],
    ),
  ];
}

class PricingCard {
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;

  PricingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
  });
}
