require 'json'

def highestLevel(width, height)
	max = [width, height].max
	return Math.log2(max).ceil()
end

def downloadTiles(baseurl, width, height, tilesize, overlap, imgformat, outname)
	x = (width / tilesize).ceil
	y = (height / tilesize).ceil
	level = highestLevel(width, height)

	puts "Downloading image at level #{level}, #{x}x#{y} tiles"

	for xindex in (0..x) do
		puts "Downloading row #{xindex} of #{x}"
		system("wget -U 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36' -P /tmp -q #{baseurl}/#{level}/#{xindex}_{0..#{y}}.#{imgformat}")
		puts "Shaving overlap..."
		system("mogrify -shave #{overlap}x#{overlap} /tmp/#{xindex}_{0..#{y}}.#{imgformat}")
		puts "Stitching row #{xindex} of #{x}"
		system("convert -append /tmp/#{xindex}_{0..#{y}}.#{imgformat} /tmp/row-#{xindex}.png")
		system("rm /tmp/#{xindex}_*.#{imgformat}")
	end
	puts "Stitching rows..."
	system("convert +append /tmp/row-{0..#{x}}.png #{outname}.png")
	system("rm /tmp/row-*.png")
end

def downloadHNE(url, outname)
	system("wget -P /tmp -q #{url}/zoom.xml")
	xml = File.read("/tmp/zoom.xml")
	system("rm /tmp/zoom.xml")

	overlap = Integer(/Overlap="([0-9]+)"/.match(xml)[1])
	width = Integer(/Width="([0-9]+)"/.match(xml)[1])
	height = Integer(/Height="([0-9]+)"/.match(xml)[1])
	tilesize = Integer(/TileSize="([0-9]+)"/.match(xml)[1])

	downloadTiles("#{url}/zoom_files", width, height, tilesize, overlap, "png", outname)
end

def downloadSI(idsid, outname)
	system("wget -U 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36' -O /tmp/page.html -q 'https://ids.si.edu/ids/dynamic?id=#{idsid}&iiif=false'")
	page = File.read("/tmp/page.html")
	system("rm /tmp/page.html")

	rawjson = /idsDynamic\(([^\)]*)\)/.match(page)[1]
	rawjson.gsub!(/(['"])?([a-zA-Z0-9_]+)(['"])?:/, '"\2":')
	json = JSON.parse(rawjson)
	tilesize = 512
	overlap = 1
	baseurl = "https://ids.si.edu/ids/viewTile/#{json["tilePath"]}"
	downloadTiles(baseurl, json["imageWidth"], json["imageHeight"], tilesize, overlap, "jpg", outname)
end

def fromPageHNE(url, outname)
	system("wget -O /tmp/page.html -q #{url}")
	html = File.read("/tmp/page.html")
	datapath = /data-xml="\/([^"]+)\/zoom.xml"/.match(html)[1]
	baseurl = "https://hne-rs.s3.amazonaws.com/filestore/#{datapath}"
	puts "Downloading from #{baseurl}"
	downloadHNE(baseurl, outname)
	system("rm /tmp/page.html")
end

def fromPageSI(url, outname)
	system("wget -O /tmp/page.html -q #{url}")
	html = File.read("/tmp/page.html")
	idsid = /data-idsid="([^"]+)"/.match(html)[1]
	puts "Downloading UAN #{idsid}"
	downloadSI(idsid, outname)
end

url = ARGV[0]

if /si\.edu/.match?(url)
	fromPageSI(url, ARGV[1])
elsif /historicnewengland\.org/
	fromPageHNE(url, ARGV[1])
else
	puts "Unsupported URL"