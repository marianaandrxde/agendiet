import 'package:agendiet/views/meta_view.dart';
import 'package:flutter/material.dart';
import 'package:agendiet/views/update_weight_view.dart';

class UserProfileView extends StatelessWidget {
  final String userName;
  final int userId;

  const UserProfileView({super.key, required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade400,
                child: Text(
                  userName.isNotEmpty ? userName[0] : '',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: <Widget>[
                  _buildQuadrant(
                    context, 'Atualize seu peso', Icons.accessibility,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateWeightScreen(userId: userId),
                        ),
                      );
                    },
                  ),
                  _buildQuadrant(
                    context, 'Visualize seu progresso', Icons.show_chart,
                    onTap: () {
                      print('Visualizar progresso');
                    },
                  ),
                  _buildQuadrant(
                    context, 'Estabeleça suas metas', Icons.flag,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EstabelecerMetaView(userId: userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuadrant(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap ?? () {}, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}