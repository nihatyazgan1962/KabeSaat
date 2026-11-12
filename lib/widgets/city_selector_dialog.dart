import 'package:flutter/material.dart';
import '../data/turkey_locations.dart';
import '../models/prayer_times_model.dart';
import '../services/prayer_calculator.dart';

class CitySelectorDialog extends StatefulWidget {
  final CityLocation currentCity;
  final Function(CityLocation) onCitySelected;

  const CitySelectorDialog({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
  });

  @override
  State<CitySelectorDialog> createState() => _CitySelectorDialogState();
}

class _CitySelectorDialogState extends State<CitySelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProvinceData? _selectedProvince;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchQuery.isNotEmpty
        ? TurkeyLocations.search(_searchQuery)
        : <CityLocation>[];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (_selectedProvince != null && _searchQuery.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
                      onPressed: () {
                        setState(() {
                          _selectedProvince = null;
                        });
                      },
                    )
                  else
                    const Icon(Icons.location_city, color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'ARAMA SONUÇLARI'
                        : (_selectedProvince != null
                            ? '${_selectedProvince!.name.toUpperCase()} İLÇELERİ'
                            : '81 İL VE TÜM İLÇELER'),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B2232),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'İl veya ilçe ara (Örn: Kadıköy, Alanya, Çankaya...)',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Content Area
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(searchResults)
                : (_selectedProvince != null
                    ? _buildDistrictList(_selectedProvince!)
                    : _buildProvinceList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<CityLocation> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Aradığınız il veya ilçe bulunamadı.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
      itemBuilder: (context, index) {
        final loc = results[index];
        final isSelected = loc.name == widget.currentCity.name;
        final distKm = PrayerCalculator.distanceToKaabaKm(loc.latitude, loc.longitude).toInt();

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : null,
          leading: Icon(
            Icons.location_on,
            color: isSelected ? const Color(0xFFFFD700) : Colors.white38,
          ),
          title: Text(
            loc.name,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Kıble: ${loc.qiblaAngle.toStringAsFixed(1)}° • Kâbe Mesafe: $distKm km',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
              : const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          onTap: () {
            widget.onCitySelected(loc);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildProvinceList() {
    return ListView(
      children: [
        // Holy Cities Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'MÜBAREK BELDELER',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...TurkeyLocations.holyCities.map((loc) {
          final isSelected = loc.name == widget.currentCity.name;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: const Icon(Icons.mosque, color: Color(0xFFFFD700), size: 20),
            title: Text(
              loc.name,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Kıble: ${loc.qiblaAngle.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
                : null,
            onTap: () {
              widget.onCitySelected(loc);
              Navigator.pop(context);
            },
          );
        }),

        const Divider(color: Colors.white12, height: 20),

        // 81 Provinces Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            'TÜRKİYE İLLERİ (81 İL)',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...TurkeyLocations.provinces.map((prov) {
          final isSelected = widget.currentCity.name.startsWith(prov.name);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1E2638),
              child: Text(
                prov.name.substring(0, 1),
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              prov.name,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${prov.districts.length} İlçe • Kıble: ${prov.qiblaAngle.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('İlçeler', style: TextStyle(color: Colors.white38, fontSize: 11)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Color(0xFFFFD700), size: 18),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedProvince = prov;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildDistrictList(ProvinceData prov) {
    return ListView(
      children: [
        // Option 1: Entire City / Center
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          tileColor: const Color(0xFFD4AF37).withOpacity(0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.apartment, color: Color(0xFFFFD700)),
          title: Text(
            '${prov.name} (Merkez / Genel)',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Kıble: ${prov.qiblaAngle.toStringAsFixed(1)}° • Enlem: ${prov.latitude}°',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          onTap: () {
            widget.onCitySelected(
              CityLocation(
                name: prov.name,
                latitude: prov.latitude,
                longitude: prov.longitude,
                qiblaAngle: prov.qiblaAngle,
              ),
            );
            Navigator.pop(context);
          },
        ),

        const Divider(color: Colors.white12, height: 16),

        // List of all districts in this province
        ...prov.districts.map((d) {
          final isSelected = widget.currentCity.name == d.name;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Icon(
              Icons.location_on_outlined,
              color: isSelected ? const Color(0xFFFFD700) : Colors.white38,
            ),
            title: Text(
              d.name,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
                : null,
            onTap: () {
              widget.onCitySelected(d);
              Navigator.pop(context);
            },
          );
        }),
      ],
    );
  }
}
