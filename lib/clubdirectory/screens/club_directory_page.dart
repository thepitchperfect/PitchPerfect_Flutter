import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/club_model.dart';
import '../widgets/club_card.dart';
import '/profile/screens/login.dart'; 
import 'club_detail_page.dart';

class ClubDirectoryPage extends StatefulWidget {
  const ClubDirectoryPage({super.key});

  @override
  State<ClubDirectoryPage> createState() => _ClubDirectoryPageState();
}

class _ClubDirectoryPageState extends State<ClubDirectoryPage> with TickerProviderStateMixin {
  late Future<void> _dataFuture;
  
  List<League> _leagues = [];
  Map<String, dynamic> _userPicks = {};
  
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }

  String? selectedLeagueId;
  String searchQuery = "";
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = fetchData(request);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _dataFuture = fetchData(request);
    });
  }

  Future<void> fetchData(CookieRequest request) async {
    // NOTE: Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/iOS
    final response = await request.get('$_baseUrl/directory/json/');
    
    if (response != null) {
      if (response['leagues'] != null) {
        List<League> loadedLeagues = [];
        for (var d in response['leagues']) {
          if (d != null) {
            loadedLeagues.add(League.fromJson(d));
          }
        }
        _leagues = loadedLeagues;
      }
      
      if (response['picks'] != null) {
        _userPicks = response['picks'];
      } else {
        _userPicks = {};
      }
    }
  }

  void _onLeagueSelected(League? league) {
    setState(() {
      if (selectedLeagueId == league?.id) {
        selectedLeagueId = null;
        _mapController.move(const LatLng(48.5, 10.0), 4.0);
      } else {
        selectedLeagueId = league?.id;
        if (league != null) {
          _mapController.move(LatLng(league.latitude, league.longitude), 6.0);
        }
      }
    });
  }

  void _navigateToDetail(BuildContext context, Club club, String leagueId, String leagueName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailPage(
          club: club,
          leagueId: leagueId,
          leagueName: leagueName,
        ),
      ),
    ).then((shouldRefresh) {
      // If we return true from Detail Page (or just always refresh to be safe)
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFFF97316),
        child: FutureBuilder(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (_leagues.isEmpty) {
              return const Center(child: Text("No leagues found."));
            }

            final filteredDisplayData = _getFilteredData();

            return Column(
              children: [
                if (!isSearchVisible) _buildRegionFilter(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      if (!isSearchVisible)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildMapWidget(_leagues),
                                const SizedBox(height: 24),
                                _buildChampionsSection(request), 
                              ],
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Text(
                                searchQuery.isEmpty ? "BROWSE CLUBS" : "SEARCH RESULTS",
                                style: GoogleFonts.tektur(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
                            ],
                          ),
                        ),
                      ),

                      if (filteredDisplayData.isEmpty)
                         SliverToBoxAdapter(
                           child: Padding(
                             padding: const EdgeInsets.all(32.0),
                             child: Center(child: Text("No clubs found.", style: GoogleFonts.lato(color: Colors.grey))),
                           ),
                         ),

                      ...filteredDisplayData.map((entry) {
                        final league = entry.key;
                        final clubs = entry.value;

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _LeagueHeaderDelegate(
                                title: league.name.toUpperCase(), 
                                region: league.region.toUpperCase()
                              ),
                            ),
                            
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    // Use GestureDetector to wrap the card properly
                                    return GestureDetector(
                                        onTap: () => _navigateToDetail(context, clubs[index], league.id, league.name),
                                        // Pass the club data, but disable internal navigation in ClubCard if needed
                                        // For now, assuming ClubCard handles display
                                        child: AbsorbPointer(
                                          absorbing: true, // We handle tap here in the Grid
                                          child: ClubCard(
                                            club: clubs[index],
                                            leagueId: league.id,
                                            leagueName: league.name,
                                          ),
                                        )
                                    );
                                  },
                                  childCount: clubs.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
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

  Widget _buildChampionsSection(CookieRequest request) {
    bool isLoggedIn = request.loggedIn;
    
    Widget picksGrid = GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _leagues.length > 6 ? 6 : _leagues.length,
      itemBuilder: (context, index) {
        final league = _leagues[index];
        final pickData = _userPicks[league.id]; 
        return _buildChampionSlot(league, pickData);
      },
    );

    return Column(
      children: [
        Text(
          "MY LEAGUE PICKS",
          style: GoogleFonts.tektur(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        
        Stack(
          children: [
            isLoggedIn 
              ? picksGrid 
              : ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Opacity(opacity: 0.6, child: AbsorbPointer(child: picksGrid)),
                ),
            
            if (!isLoggedIn)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Log in to set picks",
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const LoginPage())
                            ).then((_) => _refreshData()); // Refresh on return
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Log In"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChampionSlot(League league, Map<String, dynamic>? pickData) {
    bool hasPick = pickData != null;

    // FIX: Tapping this filters the view to that league so user can pick
    return GestureDetector(
      onTap: () {
        _onLeagueSelected(league); // Filter the list
        // Optionally scroll down if you want, but filtering is clearer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Showing clubs for ${league.name}"))
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasPick 
              ? Border.all(color: const Color(0xFFF97316), width: 1.5)
              : Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          boxShadow: hasPick 
              ? [BoxShadow(color: const Color(0xFFF97316).withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasPick) ...[
                    Expanded(
                      child: pickData['logoUrl'] != null 
                          ? Image.network(pickData['logoUrl'], fit: BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(Icons.shield))
                          : const Icon(Icons.shield, size: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pickData['clubName'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                  ] else ...[
                    Icon(Icons.add_circle_outline, color: Colors.grey[300], size: 32),
                    const SizedBox(height: 4),
                    Text(
                      "SELECT PICK",
                      style: GoogleFonts.tektur(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  league.name.substring(0, 3).toUpperCase(),
                  style: GoogleFonts.tektur(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---

  List<MapEntry<League, List<Club>>> _getFilteredData() {
    final filteredDisplayData = <MapEntry<League, List<Club>>>[];
    for (var league in _leagues) {
      if (selectedLeagueId != null && league.id != selectedLeagueId) continue;
      final matchingClubs = league.clubs.where((club) {
        return club.name.toLowerCase().contains(searchQuery);
      }).toList();
      if (matchingClubs.isNotEmpty) {
        filteredDisplayData.add(MapEntry(league, matchingClubs));
      }
    }
    return filteredDisplayData;
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      title: isSearchVisible
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.lato(color: const Color(0xFF1E293B), fontSize: 18),
              decoration: InputDecoration(
                hintText: "Search clubs...",
                hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            )
          : Text(
              "CLUB DIRECTORY",
              style: GoogleFonts.orbitron(
                color: const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(isSearchVisible ? Icons.close : Icons.search, color: const Color(0xFF1E293B)),
          onPressed: () {
            setState(() {
              if (isSearchVisible) {
                _searchController.clear();
                searchQuery = "";
              }
              isSearchVisible = !isSearchVisible;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0),
      ),
    );
  }

  Widget _buildRegionFilter() {
    return Container(
      height: 70,
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _leagues.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedLeagueId == null;
            return _buildFilterChip(
              label: "All Regions",
              isSelected: isSelected,
              onTap: () => _onLeagueSelected(null),
            );
          }
          final league = _leagues[index - 1];
          final isSelected = selectedLeagueId == league.id;
          return _buildFilterChip(
            label: league.name,
            isSelected: isSelected,
            onTap: () => _onLeagueSelected(league),
          );
        },
      ),
    );
  }

  Widget _buildMapWidget(List<League> allLeagues) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(48.5, 10.0),
                initialZoom: 4.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  userAgentPackageName: 'com.pitchperfect.app',
                ),
                MarkerLayer(
                  markers: allLeagues.map((league) {
                    final isSelected = selectedLeagueId == league.id;
                    if (selectedLeagueId != null && !isSelected) return const Marker(point: LatLng(0,0), child: SizedBox());
                    return Marker(
                      point: LatLng(league.latitude, league.longitude),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _onLeagueSelected(league),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF97316) : const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          child: Icon(Icons.location_on, color: Colors.white, size: isSelected ? 24 : 20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 14, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    Text(
                      selectedLeagueId != null ? "REGION FOCUSED" : "WORLD VIEW",
                      style: GoogleFonts.tektur(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lato(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeagueHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String region;

  _LeagueHeaderDelegate({required this.title, required this.region});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 50,
      color: const Color(0xFFF8FAFC), 
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
           Container(
             width: 4, height: 16, 
             decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(2))
           ),
           const SizedBox(width: 8),
           Text(
             title, 
             style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))
           ),
           const Spacer(),
           Text(region, style: GoogleFonts.tektur(fontSize: 10, color: Colors.grey[400])),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50.0;
  @override
  double get minExtent => 50.0;
  @override
  bool shouldRebuild(covariant _LeagueHeaderDelegate oldDelegate) => oldDelegate.title != title;
}