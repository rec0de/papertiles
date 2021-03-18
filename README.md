# Paper Tiles

*Tileable background images for a less boring web.*  

This is the backing repository behind [rec0de.net/var/papertiles](https://rec0de.net/var/papertiles/). To view and download backgrounds, please head over there.

## Contributing

If you'd like to help add more backgrounds, you can browse a wallpaper archive of your choice (all currently available backgrounds are from the [Historic New England archive](https://www.historicnewengland.org/explore/collections-access/wallpaper/) and the [Smithsonian Institution](https://si.edu)), find something you like, and crop / edit it to tile seamlessly.  
Please make sure the wallpaper pattern is in the public domain with reasonable certainty.  
To submit a new image, just open an issue or a pull request here. Please include:

- The tileable image, where the largest dimension is, if possible, at least 1080px, preferrably in a lossless format such as png
- A link to the source of the original wallpaper
- How you'd like to be credited

## Image resolutions and formats

This repository contains only one version of each image in the png format. Images are scaled such that the largest dimension is 1080px. The jpg images available from the website (small: 540px, large: 1080px) are generated from these png images using [guetzli](https://github.com/google/guetzli/) at the default quality of 95.

Much higher resolution pngs (typically >4000x4000 px) are available on request for most images.

## The Wallpaper Downloader

I wrote a ruby script to automatically download max-resolution wallpaper images from both the Historic New England and the Smithsonian archive. Maybe you'll find that useful, so I included it in this repo. It requires `wget` and `imagemagick` to be installed and probably only runs on Linux without modification.

Usage: `ruby stitcher.rb [url] [target file]`  
The url should be of the item page, e.g. `https://www.historicnewengland.org/explore/collections-access/gusn/178306/`. The `.png` suffix will be appended to the target file name.
