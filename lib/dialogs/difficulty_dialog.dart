import 'package:flutter/material.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '选择难度',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _buildDifficultyButton(
            context: context,
            difficulty: '入门',
            description: '非常简单，适合初学者',
            color: Colors.green,
            onTap: () => Navigator.of(context).pop('入门'),
          ),
          const SizedBox(height: 12),
          _buildDifficultyButton(
            context: context,
            difficulty: '简单',
            description: '轻松解决，适合练习',
            color: Colors.blue,
            onTap: () => Navigator.of(context).pop('简单'),
          ),
          const SizedBox(height: 12),
          _buildDifficultyButton(
            context: context,
            difficulty: '中等',
            description: '需要一些技巧和耐心',
            color: Colors.orange,
            onTap: () => Navigator.of(context).pop('中等'),
          ),
          const SizedBox(height: 12),
          _buildDifficultyButton(
            context: context,
            difficulty: '困难',
            description: '挑战你的极限',
            color: Colors.red,
            onTap: () => Navigator.of(context).pop('困难'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '取消',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  Widget _buildDifficultyButton({
    required BuildContext context,
    required String difficulty,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              difficulty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}