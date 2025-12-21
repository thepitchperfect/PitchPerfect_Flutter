import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/club_model.dart';
import '../screens/club_detail_page.dart';

class ClubCard extends StatefulWidget {
  final Club club;
  final String leagueId;
  final String leagueName;

  const ClubCard({
    super.key,
    required this.club,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailPage(
                    club: widget.club,
                    leagueId: widget.leagueId,
                    leagueName: widget.leagueName,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'club_logo_${widget.club.id}',
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: widget.club.logoUrl != null
                            ? Image.network(
                                widget.club.logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.grey, size: 40),
                              )
                            : const Icon(Icons.shield, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  Text(
                    widget.club.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tektur(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.club.foundedYear?.toString() ?? 'N/A',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}