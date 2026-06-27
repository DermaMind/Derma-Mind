import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double rating;
  final int reviews;
  final double price;
  final String category;
  final Color cardColor;
  final Color iconColor;
  final IconData icon;
  final String description;
  final List<String> suitableFor;
  final List<String> ingredients;
  final String? imageUrl;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.category,
    required this.cardColor,
    required this.iconColor,
    required this.icon,
    required this.description,
    required this.suitableFor,
    required this.ingredients,
    this.imageUrl,
    this.isFavorite = false,
  });
}

// ── Dummy catalogue ────────────────────────────────────────────────────────────

final List<ProductModel> dummyProducts = [
  ProductModel(
    id: '1',
    name: 'CeraVe Moisturizing Cream',
    brand: 'CeraVe',
    rating: 4.8,
    reviews: 2341,
    price: 285,
    category: 'Moisturizer',
    cardColor: const Color(0xFFEFF6FF),
    iconColor: const Color(0xFF3B82F6),
    icon: Icons.water_drop_outlined,
    description:
        'A rich, non-greasy moisturizing cream with three essential ceramides '
        'and hyaluronic acid. Helps restore and maintain the skin\'s natural '
        'barrier. Suitable for dry to very dry skin. Fragrance-free and '
        'non-comedogenic.',
    suitableFor: ['Dry', 'Normal', 'Sensitive'],
    ingredients: ['Ceramides (1, 3, 6-II)', 'Hyaluronic Acid', 'Niacinamide', 'Petrolatum'],
  ),
  ProductModel(
    id: '2',
    name: 'La Roche-Posay SPF 50+',
    brand: 'La Roche-Posay',
    rating: 4.9,
    reviews: 1876,
    price: 420,
    category: 'Sunscreen',
    cardColor: const Color(0xFFFFFBEB),
    iconColor: const Color(0xFFF59E0B),
    icon: Icons.wb_sunny_outlined,
    description:
        'Ultra-light fluid sunscreen with SPF 50+ and PPD 42. Invisible finish '
        'on all skin tones. Non-greasy, water-resistant formula suitable for '
        'sensitive and acne-prone skin. Tested under dermatological supervision.',
    suitableFor: ['Oily', 'Combination', 'Sensitive', 'Acne-prone'],
    ingredients: ['Mexoryl SX', 'Mexoryl XL', 'Titanium Dioxide', 'Glycerin'],
  ),
  ProductModel(
    id: '3',
    name: 'Cetaphil Gentle Cleanser',
    brand: 'Cetaphil',
    rating: 4.7,
    reviews: 3102,
    price: 195,
    category: 'Cleanser',
    cardColor: const Color(0xFFF0FDF4),
    iconColor: const Color(0xFF10B981),
    icon: Icons.bubble_chart_outlined,
    description:
        'A gentle, soap-free face and body cleanser that removes dirt, makeup, '
        'and impurities without stripping the skin\'s natural oils. pH-balanced '
        'formula keeps skin soft and hydrated. Recommended by dermatologists '
        'worldwide for sensitive skin.',
    suitableFor: ['All skin types', 'Sensitive', 'Dry'],
    ingredients: ['Glycerin', 'Panthenol', 'Niacinamide', 'Allantoin'],
  ),
  ProductModel(
    id: '4',
    name: 'The Ordinary Niacinamide 10%',
    brand: 'The Ordinary',
    rating: 4.6,
    reviews: 5489,
    price: 160,
    category: 'Serum',
    cardColor: const Color(0xFFF5F3FF),
    iconColor: const Color(0xFF8B5CF6),
    icon: Icons.science_outlined,
    description:
        'A high-strength vitamin and mineral blemish formula. 10% Niacinamide '
        'reduces the appearance of skin blemishes and congestion. 1% Zinc '
        'helps balance visible sebum activity. Suitable for all skin types '
        'especially oily and acne-prone skin.',
    suitableFor: ['Oily', 'Combination', 'Acne-prone'],
    ingredients: ['Niacinamide 10%', 'Zinc PCA 1%', 'Hyaluronic Acid', 'Pentylene Glycol'],
  ),
  ProductModel(
    id: '5',
    name: 'Bioderma Sensibio Toner',
    brand: 'Bioderma',
    rating: 4.5,
    reviews: 987,
    price: 310,
    category: 'Toner',
    cardColor: const Color(0xFFFFF1F2),
    iconColor: const Color(0xFFEC4899),
    icon: Icons.opacity_outlined,
    description:
        'A soothing micellar toner that gently removes impurities and calms '
        'reactive skin. Enriched with cucumber extract and patented biological '
        'complex to reinforce skin tolerance. Alcohol-free, fragrance-free, '
        'and hypoallergenic.',
    suitableFor: ['Sensitive', 'Reactive', 'Dry'],
    ingredients: ['Cucumber Extract', 'Mannose', 'Glycerin', 'Fructooligosaccharides'],
  ),
  ProductModel(
    id: '6',
    name: 'Eucerin Sun Fluid SPF 50',
    brand: 'Eucerin',
    rating: 4.7,
    reviews: 1234,
    price: 375,
    category: 'Sunscreen',
    cardColor: const Color(0xFFFFFBEB),
    iconColor: const Color(0xFFF97316),
    icon: Icons.wb_sunny_outlined,
    description:
        'A lightweight sun fluid with advanced UVA/UVB protection and '
        'Anti-Oxidant Complex. Oil-free formula reduces pigmentation spots '
        'over time. Suitable for normal to combination skin with a dry, '
        'non-sticky finish. Dermatologically tested.',
    suitableFor: ['Normal', 'Combination', 'Pigmented'],
    ingredients: ['Tinosorb S', 'Uvinul A Plus', 'Vitamin E', 'Glycerin'],
  ),
];
