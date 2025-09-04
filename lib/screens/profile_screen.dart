import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 应用功能选项
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.settings,
                    iconColor: Colors.blue,
                    title: '设置',
                    onTap: () {
                      // TODO: 打开设置页面
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.menu_book,
                    iconColor: Colors.green,
                    title: '规则',
                    onTap: () {
                      // TODO: 打开规则页面
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.info,
                    iconColor: Colors.orange,
                    title: '关于游戏',
                    onTap: () {
                      // TODO: 打开关于游戏页面
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 支持开发者
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMenuItem(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title: '打赏作者',
                onTap: () {
                  // TODO: 实现打赏功能
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 70,
      endIndent: 20,
      color: Color(0xFFF0F0F0),
    );
  }

}