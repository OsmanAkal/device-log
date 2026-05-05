import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_bar_provider.dart';

class FilterBar extends StatelessWidget {
final List<String> statusOptions;
 const FilterBar({
    super.key,
    required this.statusOptions,
  });
  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterProvider>();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          TextField(
            onChanged: filter.setSearch,
            decoration: InputDecoration(
              hintText: "Ara...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [

              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: filter.status,
                  decoration: InputDecoration( 
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder( 
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, 
                    ), 
                  ),
                  items: statusOptions
                    .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text( e[0].toUpperCase() + e.substring(1),),
                    ))
                    .toList(),
                  onChanged: (val) => filter.setStatus(val!),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: filter.sort,
                       decoration: InputDecoration( 
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder( 
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, 
                    ), 
                  ),
                  items: const [
                    DropdownMenuItem(value: "new", child: Text("En Yeni")),
                    DropdownMenuItem(value: "old", child: Text("En Eski")),
                  ],
                  onChanged: (val) => filter.setSort(val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}