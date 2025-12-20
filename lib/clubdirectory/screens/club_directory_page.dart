import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/club_model.dart';
import '../widgets/club_card.dart';

class ClubDirectoryPage extends StatefulWidget {
  const ClubDirectoryPage({super.key});

  @override
  State<ClubDirectoryPage> createState() => _ClubDirectoryPageState();
}

class _ClubDirectoryPageState extends State<ClubDirectoryPage> with TickerProviderStateMixin {
  Future<List<League>>? _leaguesFuture;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  String? selectedLeagueId;
  String searchQuery = "";
  bool isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<League>> fetchLeagues(CookieRequest request) async {
    // NOTE: Ensure this matches your Django environment (10.0.2.2 or 127.0.0.1)
    final response = await request.get('http://127.0.0.1:8000/directory/json/');
    List<League> listLeagues = [];
    if (response['leagues'] != null) {
      for (var d in response['leagues']) {
        listLeagues.add(League.fromJson(d));
      }
    }
    return listLeagues;
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    _leaguesFuture ??= fetchLeagues(request);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
      ),
      body: FutureBuilder<List<League>>(
        future: _leaguesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No leagues found."));
          }

          final allLeagues = snapshot.data!;
          final filteredDisplayData = <MapEntry<League, List<Club>>>[];
          
          for (var league in allLeagues) {
            if (selectedLeagueId != null && league.id != selectedLeagueId) continue;
            final matchingClubs = league.clubs.where((club) {
              return club.name.toLowerCase().contains(searchQuery);
            }).toList();
            if (matchingClubs.isNotEmpty) {
              filteredDisplayData.add(MapEntry(league, matchingClubs));
            }
          }

          return Column(
            children: [
              if (!isSearchVisible)
                Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: allLeagues.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedLeagueId == null;
                        return _buildFilterChip(
                          label: "All Regions",
                          isSelected: isSelected,
                          onTap: () => _onLeagueSelected(null),
                        );
                      }
                      final league = allLeagues[index - 1];
                      final isSelected = selectedLeagueId == league.id;
                      return _buildFilterChip(
                        label: league.name,
                        isSelected: isSelected,
                        onTap: () => _onLeagueSelected(league),
                      );
                    },
                  ),
                ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (!isSearchVisible)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildMapWidget(allLeagues),
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
                                crossAxisCount: 2, // 2 Cards per row
                                childAspectRatio: 0.8, // Slightly taller for safety
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return ClubCard(
                                    club: clubs[index],
                                    leagueId: league.id,
                                    leagueName: league.name,
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