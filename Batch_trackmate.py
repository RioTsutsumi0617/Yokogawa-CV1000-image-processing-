import os
import sys
from ij import IJ
from java.io import File
from fiji.plugin.trackmate import Model, Settings, TrackMate, Logger
from fiji.plugin.trackmate.detection import LogDetectorFactory
from fiji.plugin.trackmate.tracking.jaqaman import SparseLAPTrackerFactory
from fiji.plugin.trackmate.io import TmXmlWriter, CSVExporter

reload(sys)
sys.setdefaultencoding('utf-8')

# New cropped input folders
input_folders = [
    "",
    "",
    ""
]

# Output folders remain the same
output_folders = {
	"tagBFP": "/tagBFP",
    "Distal": "/Distal",
    "Proximal":"/Proximal"
}

# Ensure output folders exist
for folder in output_folders.values():
    if not os.path.exists(folder):
        os.makedirs(folder)

# Channel settings
channel_configs = {
    "tagBFP": {"TARGET_CHANNEL": 1, "THRESHOLD": 2200000.0},
    "Distal": {"TARGET_CHANNEL": 2, "THRESHOLD": 400000.0},
    "Proximal": {"TARGET_CHANNEL": 3, "THRESHOLD": 400000.0}
}

# Process each image in composite_cropped folders
for folder in input_folders:
    for filename in os.listdir(folder):
        if filename.endswith(".tif"):
            path = os.path.join(folder, filename)
            imp = IJ.openImage(path)

            if imp is None:
                print("Failed to open", filename)
                continue

            for mode in ["tagBFP", "Distal", "Proximal"]:
                config = channel_configs[mode]
                output_dir = output_folders[mode]

                model = Model()
                model.setLogger(Logger.IJ_LOGGER)

                settings = Settings(imp)
                settings.detectorFactory = LogDetectorFactory()
                settings.detectorSettings = {
                    'DO_SUBPIXEL_LOCALIZATION': True,
                    'RADIUS': 6.0,
                    'TARGET_CHANNEL': config["TARGET_CHANNEL"],
                    'THRESHOLD': config["THRESHOLD"],
                    'DO_MEDIAN_FILTERING': False
                }

                settings.trackerFactory = SparseLAPTrackerFactory()
                settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
                settings.trackerSettings['LINKING_MAX_DISTANCE'] = 63.333333333333336
                settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = 10.0
                settings.trackerSettings['ALLOW_GAP_CLOSING'] = True
                settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = False
                settings.trackerSettings['ALLOW_TRACK_MERGING'] = False
                settings.trackerSettings['SPLITTING_MAX_DISTANCE'] = 15.0
                settings.trackerSettings['MERGING_MAX_DISTANCE'] = 15.0
                settings.trackerSettings['ALTERNATIVE_LINKING_COST_FACTOR'] = 1.05
                settings.trackerSettings['BLOCKING_VALUE'] = float("inf")
                settings.trackerSettings['CUTOFF_PERCENTILE'] = 0.9
                settings.trackerSettings['MAX_FRAME_GAP'] = 3

                settings.addAllAnalyzers()

                trackmate = TrackMate(model, settings)

                if not trackmate.checkInput():
                    print("TrackMate input error for", filename, "mode:", mode, "-", trackmate.getErrorMessage())
                    continue

                if not trackmate.process():
                    print("TrackMate failed on", filename, "mode:", mode)
                    continue

                base = filename.replace(".tif", "")
                xml_path = os.path.join(output_dir, base + "_tracking.xml")
                all_spots_csv = os.path.join(output_dir, base + "_all_spots.csv")
                filtered_spots_csv = os.path.join(output_dir, base + "_spots.csv")

                writer = TmXmlWriter(File(xml_path), Logger.IJ_LOGGER)
                writer.appendModel(model)
                writer.appendSettings(settings)
                writer.writeToFile()

                CSVExporter.exportSpots(all_spots_csv, model, False)
                CSVExporter.exportSpots(filtered_spots_csv, model, True)

                print("Processed", filename, "mode:", mode)

            imp.close()

print("TrackMate batch analysis complete.")
