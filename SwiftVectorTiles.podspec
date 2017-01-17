Pod::Spec.new do |s|

  s.name         = "SwiftVectorTiles"
  s.version      = "0.1.2"
  s.summary      = "A Swift Mapbox vector tile encoder"

  s.description  = <<-DESC
A Swift encoder for vector tiles according to the Mapbox Vector Tile Spec: https://github.com/mapbox/vector-tile-spec
DESC

  s.homepage     = "https://github.com/manimaul/GeosSwiftVectorTiles"
  s.license      = { :type => "BSD", :file => "LICENSE.md" }
  s.author       = { "Will Kamp" => "will@madrona.io" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/manimaul/GeosSwiftVectorTiles.git", :tag => s.version.to_s}

  s.dependency 'gdal-mm', '0.1.0'
  s.dependency 'ProtocolBuffers-Swift'

end
