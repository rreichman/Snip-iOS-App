from shutil import copyfile
import os
import sys

filenamesToPicSizes = {}
filenamesToPicSizes["iTunesArtwork.png"] = 512
filenamesToPicSizes["iTunesArtwork@2x.png"] = 1024
filenamesToPicSizes["Icon-60.png"] = 60
filenamesToPicSizes["Icon-60@2x.png"] = 120
filenamesToPicSizes["Icon-60@3x.png"] = 180
filenamesToPicSizes["Icon-76.png"] = 76
filenamesToPicSizes["Icon-76@2x.png"] = 152
filenamesToPicSizes["Icon-83.5.png"] = 83.5
filenamesToPicSizes["Icon-83.5@2x.png"] = 167
filenamesToPicSizes["Icon-Small-20.png"] = 20
filenamesToPicSizes["Icon-Small-40.png"] = 40
filenamesToPicSizes["Icon-Small-40@2x.png"] = 80
filenamesToPicSizes["Icon-Small-40@3x.png"] = 120
filenamesToPicSizes["Icon-Small.png"] = 29
filenamesToPicSizes["Icon-Small@2x.png"] = 58
filenamesToPicSizes["Icon-Small@3x.png"] = 87

iconFolder = "AppIcon"
if not os.path.exists(iconFolder):
	os.makedirs(iconFolder)

for filename in filenamesToPicSizes.keys():
	currentSize = filenamesToPicSizes[filename]
	copyfile(sys.argv[1],iconFolder + "//" + filename)
	imageResizeLine = "mogrify -resize " + str(currentSize) + "x" + str(currentSize) + " " + iconFolder + "//" + filename
	os.system(imageResizeLine)