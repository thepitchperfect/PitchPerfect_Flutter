import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../models/club_model.dart';
import '/statistics/screens/team_detail.dart';

class ClubDetailPage extends StatefulWidget {
  final Club club;
  final String leagueId;
  final String leagueName;

  const ClubDetailPage({
    super.key,
    required this.club,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> with TickerProviderStateMixin {
  late bool isPicked;
  bool isLoading = true;
  
  String? managerName;
  String? stadiumName;
  String? stadiumCapacity;
  String? historySummary;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    isPicked = widget.club.isLeaguePick;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    fetchDetailedInfo();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> fetchDetailedInfo() async {
    final request = context.read<CookieRequest>();
    // URL set to 127.0.0.1 (ensure this matches your environment: 10.0.2.2 for Android emulator)
    final String url = 'http://127.0.0.1:8000/directory/club/${widget.club.id}/';
    
    try {
      final response = await request.get(url);
      if (mounted) {
        setState(() {
          managerName = response['manager_name'];
          stadiumName = response['stadium_name'];
          stadiumCapacity = response['stadium_capacity_str'];
          historySummary = response['history_summary'];
          
          if (response['is_league_pick'] != null) {
            isPicked = response['is_league_pick'];
            widget.club.isLeaguePick = isPicked; 
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> togglePick() async {
    final request = context.read<CookieRequest>();
    final String clubIdToSend = isPicked ? 'NONE' : widget.club.id;
    const String url = 'http://127.0.0.1:8000/directory/set-league-pick/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({ 
          'club_id': clubIdToSend, 
          'league_id': widget.leagueId 
        }),
      );

      if (response['status'] == 'set' || response['status'] == 'cleared') {
        setState(() {
          isPicked = !isPicked;
          widget.club.isLeaguePick = isPicked;
        });
        
        if (isPicked) {
          _showLockedInDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pick removed"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.grey[800],
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response['message']}")));
      }
    } catch (e) {
      print("Toggle Pick Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action failed: ${e.toString()}")));
    }
  }

  void _showLockedInDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Color(0xFFF97316), size: 64),
                const SizedBox(height: 16),
                Text("LOCKED IN!", style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  "${widget.club.name} is your champion.",
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
              onPressed: () => Navigator.pop(context, true), // Return true to signal refresh
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HERO SECTION
            SizedBox(
              height: 360,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -150,
                    child: Opacity(
                      opacity: 0.05,
                      child: widget.club.logoUrl != null
                          ? Image.network(widget.club.logoUrl!, width: 500)
                          : const SizedBox(),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Hero(
                        tag: 'club_logo_${widget.club.id}',
                        child: Container(
                          width: 130,
                          height: 130,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              )
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: widget.club.logoUrl != null
                              ? Image.network(widget.club.logoUrl!)
                              : const Icon(Icons.shield),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.club.name.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.leagueName.toUpperCase(),
                          style: GoogleFonts.tektur(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. BENTO GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? _buildShimmerLoading()
                  : Column(
                      children: [
                        // --- LINKED TO STATISTICS PAGE ---
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamDetailPage(clubId: widget.club.id),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bar_chart, color: Color(0xFFF97316)),
                                const SizedBox(width: 8),
                                Text(
                                  "VIEW SEASON STATISTICS", 
                                  style: GoogleFonts.tektur(fontWeight: FontWeight.bold, color: Colors.white)
                                ),
                              ],
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(child: _buildInfoCard("MANAGER", managerName ?? "N/A", Icons.person, true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInfoCard("FOUNDED", "${widget.club.foundedYear ?? 'N/A'}", Icons.history, false)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStadiumRow(),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0,5))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("CLUB INTEL", style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                              const SizedBox(height: 12),
                              Text(
                                widget.club.description ?? "No description available.",
                                style: const TextStyle(height: 1.6, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: isPicked ? [
                   BoxShadow(color: const Color(0xFF10B981).withOpacity(0.5), blurRadius: 20)
                ] : [
                   BoxShadow(color: const Color(0xFFF97316).withOpacity(0.3 + (_pulseController.value * 0.1)), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: child,
            );
          },
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: togglePick,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPicked ? const Color(0xFF10B981) : const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isPicked ? Icons.check : Icons.touch_app, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    isPicked ? "SELECTED CHAMPION" : "LOCK IN PICK",
                    style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 12),
          Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, bool primary) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: primary ? null : Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0,5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: primary ? Colors.white54 : const Color(0xFFF97316), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.tektur(fontSize: 10, fontWeight: FontWeight.bold, color: primary ? Colors.white38 : Colors.grey[400])),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary ? Colors.white : const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStadiumRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0,5))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.stadium, color: Color(0xFF1E293B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HOME GROUND", style: GoogleFonts.tektur(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                Text(stadiumName ?? "N/A", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}