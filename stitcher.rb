def highestLevel(width, height)
	max = [width, height].max
	return Math.log2(max).ceil()
end

def download(url, outname)
	system("wget -P /tmp -q #{url}/zoom.xml")
	xml = File.read("/tmp/zoom.xml")
	system("rm /tmp/zoom.xml")

	overlap = Integer(/Overlap="([0-9]+)"/.match(xml)[1])
	width = Integer(/Width="([0-9]+)"/.match(xml)[1])
	height = Integer(/Height="([0-9]+)"/.match(xml)[1])
	tilesize = Integer(/TileSize="([0-9]+)"/.match(xml)[1])

	level = highestLevel(width, height)
	x = (width / tilesize).ceil
	y = (height / tilesize).ceil

	puts "Downloading image of size #{width}x#{height} at level #{level}, #{x}x#{y} tiles"

	for xindex in (0..x) do
		puts "Downloading row #{xindex} of #{x}"
		system("wget -P /tmp -q #{url}/zoom_files/#{level}/#{xindex}_{0..#{y}}.png")
		puts "Shaving overlap..."
		system("mogrify -shave #{overlap}x#{overlap} /tmp/#{xindex}_{0..#{y}}.png")
		puts "Stitching row #{xindex} of #{x}"
		system("convert -append /tmp/#{xindex}_{0..#{y}}.png /tmp/row-#{xindex}.png")
		system("rm /tmp/#{xindex}_*.png")
	end
	puts "Stitching rows..."
	system("convert +append /tmp/row-{0..#{x}}.png #{outname}.png")
	system("rm /tmp/row-*.png")
end

def fromPage(url, outname)
	system("wget -O /tmp/page.html -q #{url}")
	html = File.read("/tmp/page.html")
	datapath = /data-xml="\/([^"]+)\/zoom.xml"/.match(html)[1]
	baseurl = "https://hne-rs.s3.amazonaws.com/filestore/#{datapath}"
	puts "Downloading from #{baseurl}"
	download(baseurl, outname)
	system("rm /tmp/page.html")
end

fromPage(ARGV[0], ARGV[1])

#https://hne-rs.s3.amazonaws.com/filestore/zoom/1/9/8/0/5/2_54171b8ade64cd2/zoom_198052/zoom.xml
#https://hne-rs.s3.amazonaws.com/filestore/zoom/1/8/4/7/5/6_96ed85fa60c0a45/zoom_184756/zoom_files/10/0_0.png
#https://www.historicnewengland.org/explore/collections-access/gusn/