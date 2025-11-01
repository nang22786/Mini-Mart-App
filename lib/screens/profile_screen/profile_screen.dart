import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_event.dart';
import 'package:mini_mart/bloc/auth/auth_state.dart';
import 'package:mini_mart/bloc/user/user_bloc.dart';
import 'package:mini_mart/bloc/user/user_event.dart';
import 'package:mini_mart/bloc/user/user_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/user/user_model.dart';
import 'package:mini_mart/screens/profile_screen/advertising_owner_screen/advertising_owner_screen.dart';
import 'package:mini_mart/screens/profile_screen/category_owner_screen/category_owner_screen.dart';
import 'package:mini_mart/screens/login_screen/login_screen.dart';
import 'package:mini_mart/screens/notification_screen/notification_screen.dart';
import 'package:mini_mart/screens/profile_screen/order_owner_screen/order_owner_screen.dart';
import 'package:mini_mart/screens/profile_screen/product_owner_screen/product_owner_screen.dart';
import 'package:mini_mart/screens/profile_screen/update_screen.dart';
import 'package:mini_mart/styles/fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedLanguage = 'English (EN)';
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final userId = StorageService.getUserId();
    if (userId != null) {
      context.read<UserBloc>().add(GetUserInfoEvent(userId: userId));
    }
  }

  // Check if user is admin or owner
  bool _isAdminOrOwner(UserModel? user) {
    if (user == null) return false;
    final role = user.role.toLowerCase();
    return role == 'admin' || role == 'owner';
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English (EN)'),
              const Divider(height: 1),
              _buildLanguageOption('Khmer (KH)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: kantumruyPro,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: kantumruyPro,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontFamily: kantumruyPro),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: kantumruyPro,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: Text(
              'Log out',
              style: TextStyle(
                color: const Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    bool isSelected = selectedLanguage == language;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: kantumruyPro,
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(
    String? profileImageUrl,
    String userName,
    UserModel? user,
  ) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: profileImageUrl != null && profileImageUrl.isNotEmpty
                ? Image.network(
                    ApiConfig.baseUrl + profileImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF6C5CE7),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(userName);
                    },
                  )
                : _buildDefaultAvatar(userName),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(user: user),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User data not loaded. Please try again.',
                      style: TextStyle(fontFamily: kantumruyPro),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String userName) {
    return Container(
      color: const Color(0xFF6C5CE7),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.message,
                          style: TextStyle(fontFamily: kantumruyPro),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is UserUpdated) {
              _loadUserInfo();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: kantumruyPro,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            if (userState is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            String userName = 'Guest User';
            String userEmail = '';
            String? profileImageUrl;
            UserModel? currentUser;

            if (userState is UserLoaded) {
              userName = userState.user.name;
              userEmail = userState.user.email;
              profileImageUrl = userState.user.image;
              currentUser = userState.user;
            } else if (userState is UserUpdated) {
              userName = userState.user.name;
              userEmail = userState.user.email;
              profileImageUrl = userState.user.image;
              currentUser = userState.user;
            } else {
              userEmail = StorageService.getUserEmail() ?? '';
              if (userEmail.isNotEmpty) {
                userName = userEmail.split('@')[0];
              }
            }

            final isAdmin = _isAdminOrOwner(currentUser);

            return Column(
              children: [
                const SizedBox(height: 20),
                // Profile Picture and Name
                _buildProfileImage(profileImageUrl, userName, currentUser),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: kantumruyPro,
                  ),
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: kantumruyPro,
                    ),
                  ),
                ],
                // Admin Role Badge
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB3022).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDB3022),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 16,
                          color: const Color(0xFFDB3022),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentUser?.role.toUpperCase() ?? 'ADMIN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDB3022),
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Admin Management Section
                      if (isAdmin) ...[
                        _buildSectionHeader('Management'),
                        const SizedBox(height: 12),
                        // AdvertisingOwnerScreen
                        _buildMenuItem(
                          icon: Icons.category_outlined,
                          title: 'Category',
                          iconColor: const Color(0xFFDB3022),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategoryOwnerScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.add_box_outlined,
                          title: 'Product',
                          iconColor: const Color(0xFFDB3022),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProductOwnerScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.campaign,
                          title: 'Advertising',
                          iconColor: const Color(0xFFDB3022),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdvertisingOwnerScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'All Orders',
                          iconColor: const Color(0xFFDB3022),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderOwnerScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notification',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),
                      // const SizedBox(height: 12),
                      // _buildMenuItem(
                      //   icon: Icons.language,
                      //   title: selectedLanguage,
                      //   trailing: const Icon(
                      //     Icons.keyboard_arrow_down,
                      //     size: 20,
                      //   ),
                      //   onTap: _showLanguageBottomSheet,
                      // ),
                      // const SizedBox(height: 12),
                      // _buildMenuItem(
                      //   icon: Icons.visibility_outlined,
                      //   title: 'Dark mode',
                      //   trailing: Switch(
                      //     value: isDarkMode,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         isDarkMode = value;
                      //       });
                      //     },
                      //     activeColor: const Color(0xFF6C5CE7),
                      //   ),
                      //   onTap: null,
                      // ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy policy',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Log out',
                        titleColor: const Color(0xFFE91E63),
                        iconColor: const Color(0xFFE91E63),
                        onTap: _showLogoutDialog,
                      ),
                      if (isAdmin) ...[const SizedBox(height: 100)],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontFamily: kantumruyPro,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor ?? Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                  fontFamily: kantumruyPro,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
