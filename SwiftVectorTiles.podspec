Pod::Spec.new do |s|

  s.name         = "SwiftVectorTiles"
  s.version      = "0.1.4"
  s.summary      = "A Swift Mapbox vector tile encoder"

  s.description  = <<-DESC
A Swift encoder for vector tiles according to the Mapbox Vector Tile Spec: https://github.com/mapbox/vector-tile-spec
DESC

  s.homepage     = "https://github.com/manimaul/GeosSwiftVectorTiles"
  s.license      = { :type => "BSD", :file => "LICENSE.md" }
  s.author       = { "Will Kamp" => "will@madrona.io" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/manimaul/SwiftVectorTiles.git", :tag => s.version.to_s}
  s.subspec 'Core' do |cs|
      cs.source_files = 'SwiftVectorTiles/**/*.{swift,h}'
      cs.dependency "geos"
      cs.dependency 'ProtocolBuffers-Swift'
    end

   s.default_subspec = 'Core'


end
