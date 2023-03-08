ffmpeg -i src/lineup/hori.jpg  -filter:v "crop='min(iw, ih)':'min(iw, ih)':'(iw/2)-min(iw, ih)/2':'(ih/2)-min(iw, ih)/2'" -y resized_hori.jpg

ffmpeg -i src/lineup/vert.jpg  -filter_complex "crop='min(iw, ih)':'min(iw, ih)':'(iw/2
)-min(iw, ih)/2':'(ih/2)-min(iw, ih)/2',scale=w=200:h=200:force_original_aspect_ratio=increase" -y resized_verti.jpg

ffmpeg -i src/lineup/vert.jpg  -vf "crop='min(iw, ih)':'min(iw, ih)':'(iw/2
)-min(iw, ih)/2':'(ih/2)-min(iw, ih)/2',scale=w=200:h=200:force_original_aspect_ratio=increase" -y resized_verti.jpg