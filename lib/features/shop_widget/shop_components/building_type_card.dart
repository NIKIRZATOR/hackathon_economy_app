import 'package:flutter/material.dart';
// import 'package:hackathon_economy_app/core/services/audio_manager.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/ui/MainTextButton.dart';
import '../../building_types/model/building_type_model.dart';
import 'building_type_details_dialog.dart';

class BuildingTypeCard extends StatelessWidget {
  const BuildingTypeCard({
    super.key,
    required this.bt,
    this.width = 160,
    required this.screenHeight,
    required this.screenWight,
  });

  final BuildingType bt;
  final double width;
  final double screenHeight;
  final double screenWight;

  void _openDetails(BuildContext context) async {
    final selected = await showDialogWithSound<BuildingType>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BuildingTypeDetailsDialog(
        bt: bt,
        screenHeight: screenHeight,
        screenWight: screenWight,
      ),
    );

    if (selected != null) {
      Navigator.of(context).pop<BuildingType>(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: 260,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
            child: Column(
              children: [
                const Spacer(),
                bt.imageAsset != null
                    ? ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 0.85,
                          child: Image.asset(
                            bt.imageAsset!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Center(child: Icon(Icons.apartment, size: 36)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: SizedBox(
                    height: 2 * 15 * 1.2,
                    child: Center(
                      child: Text(
                        bt.titleBuildingType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  child: MainTextButton(
                    child: Row (      
                      children: [
                        Image.asset(
                            'assets/images/resources/coin.png',
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${bt.cost}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop<BuildingType>(bt);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
