import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/ticket_form_sheet.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const primaryColor = Color(0xFF0284C7);
  static const primaryDark = Color(0xFF0C4A6E);
  static const bgColor = Color(0xFFF4F8FB);

  // Nomor WhatsApp CS (format internasional, tanpa '+' dan tanpa '0' di depan).
  static const String _whatsappNumber = '6288214852525';

  // Email support.
  static const String _supportEmail = 'fullstackflavour@gmail.com';

  // Template pesan yang otomatis terisi saat membuka WhatsApp,
  // supaya laporan pengguna lebih terstruktur dan mudah ditindaklanjuti admin.
  static const String _whatsappTemplate =
      'Halo Admin geo_attend,\n\n'
      'Saya ingin melaporkan kendala pada aplikasi.\n\n'
      'Kendala yang dialami: \n\n'
      'Mohon bantuannya. Terima kasih.';

  Future<void> _openWhatsapp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(_whatsappTemplate)}',
    );
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak dapat dibuka.')),
      );
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    const emailBody =
        'Halo Admin geo_attend,\n\n'
        'Saya ingin melaporkan kendala pada aplikasi.\n\n'
        'Kendala yang dialami: \n\n'
        'Mohon bantuannya. Terima kasih.';

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query:
          'subject=${Uri.encodeComponent('Laporan Kendala Aplikasi geo_attend')}'
          '&body=${Uri.encodeComponent(emailBody)}',
    );
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplikasi email tidak ditemukan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Hubungi Kami',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContactTile(
            icon: FontAwesomeIcons.solidCommentDots,
            iconColor: const Color(0xFF16A34A),
            title: 'Live Chat (WhatsApp)',
            subtitle: 'Respon cepat untuk kendala mendesak.',
            onTap: () => _openWhatsapp(context),
          ),
          const SizedBox(height: 12),
          _ContactTile(
            icon: FontAwesomeIcons.solidEnvelope,
            iconColor: primaryColor,
            title: 'Email Support',
            subtitle: _supportEmail,
            onTap: () => _openEmail(context),
          ),
          const SizedBox(height: 12),
          _ContactTile(
            icon: FontAwesomeIcons.ticket,
            iconColor: const Color(0xFF9333EA),
            title: 'Buat Tiket Bantuan',
            subtitle: 'Untuk masalah yang perlu ditindaklanjuti admin.',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const TicketFormSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ContactUsScreen.primaryDark.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: FaIcon(icon, size: 16, color: iconColor)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
