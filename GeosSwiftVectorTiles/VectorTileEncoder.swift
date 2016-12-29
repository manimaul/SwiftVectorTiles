//
//  VectorTileEncoder.swift
//  GeosSwiftVectorTiles
//
//  Created by William Kamp on 12/28/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import Foundation

private class Feature {
    let _geometry: Geometry
    let _tags: [Int]
    
    init(geometry: Geometry, tags: [Int]) {
        self._geometry = geometry
        self._tags = tags
    }
    
}

private class Layer {
    var _features = [Feature]()
    
    var _keys = [String: Int]()
    var _keysKeysOrdered = [String]()
    
    var _values = [AnyHashable: Int]()
    var _valuesKeysOrdered = [AnyHashable]()
    
    func key(key k: String) -> Int {
        guard let i = _keys[k] else {
            _keys[k] = _keys.count
            _keysKeysOrdered.append(k)
            return _keys.count
        }
        return i
    }
    
    func keys() -> [String] {
        return _keysKeysOrdered
    }
    
    func value(object obj: AnyHashable) -> Int {
        guard let i = _values[obj] else {
            _values[obj] = _values.count
            _valuesKeysOrdered.append(obj)
            return _values.count
        }
        return i
    }
    
    func values() -> [AnyHashable] {
        return _valuesKeysOrdered
    }
}

private func createTileEnvelope(buffer b: Int, size s: Int) -> Geometry? {
    let _start = (Double) (0 - b)
    let _end = (Double) (s + b)
    let _coords = [Coordinate(x: _start, y: _end),
                  Coordinate(x: _end,    y:_end),
                  Coordinate(x: _end,    y:_start),
                  Coordinate(x: _start,  y:_start),
                  Coordinate(x: _start,  y: _end)]
    return LineString(points: _coords)
}

/**
 * Encodes geometries into Mapbox Vector tiles.
 */
public class VectorTileEncoder {
    private var _layers = [String: Layer]()
    private var _layerKeysOrdered = [String]()
    
    let _extent: Int
    let _clipGeometry: Geometry
    let _autoScale: Bool

    /// Create a 'VectorTileEncoder' with the default extent of 4096 and clip buffer of 8.
    convenience init() {
        self.init(extent: 4096, clipBuffer: 8, autoScale: true)
    }

    /// Create a 'VectorTileEncoder' with the given extent and a clip buffer of 8.
    convenience init(extent e: Int) {
        self.init(extent: e, clipBuffer: 8, autoScale: true)
    }

    /// Create a {@link VectorTileEncoder} with the given extent value.
    ///
    /// The extent value control how detailed the coordinates are encoded in the
    /// vector tile. 4096 is a good default, 256 can be used to reduce density.
    ///
    /// The clip buffer value control how large the clipping area is outside of
    /// the tile for geometries. 0 means that the clipping is done at the tile
    /// border. 8 is a good default.
    ///
    /// - parameter extent: a int with extent value. 4096 is a good value.
    /// - parameter clipBuffer: a int with clip buffer size for geometries. 8 is a good value.
    /// - parameter autoScale: when true, the encoder expects coordinates in the 0..255 range and will scale them
    ///                        automatically to the 0..extent-1 range before encoding. when false, the encoder expects
    ///                        coordinates in the 0..extent-1 range.
    public init(extent e: Int, clipBuffer buffer: Int, autoScale auto: Bool) {
        _extent = e
        _autoScale = auto
        let size = auto ? 256 : e
        _clipGeometry = createTileEnvelope(buffer: buffer, size: size)!
    }

    /// - returns: 'Data' with the vector tile
    public func encode() -> Data {
        // todo:
        return Data()
    }

    /// Add a feature with layer name (typically feature type name), some attributes and a Geometry. The Geometry must
    /// be in "pixel" space 0,0 lower left and 256,256 upper right.
    ///
    /// For optimization, geometries will be clipped, geometries will simplified and features with geometries outside
    /// of the tile will be skipped.
    ///
    /// - parameter layerName:
    /// - parameter attributes:
    /// - parameter geometry:
    public func addFeature(layerName name: String, attributes attrs: [String: AnyHashable], geometry geo: Geometry?) {
        
        // split up MultiPolygon and GeometryCollection (without subclasses)
        if let collection = geo as? GeometryCollection<Geometry> {
            splitAndAddFeatures(layerName: name, attributes: attrs, geometry: collection)
        }
        
        // skip small Polygon/LineString.
        if let polygon = geo as? Polygon {
            if (polygon.area() < 1.0) {
                return
            }
        }
        
        if let line = geo as? LineString {
            if (line.length() < 1.0) {
                return
            }
        }
        
        // clip geometry
        if let point = geo as? Waypoint {
            if !(clipCovers(geometry: point)) {
                return
            }
        } else {
            if let clippedGeo = createdClippedGeometry(geometry: geo) {
                
                // if clipping result in MultiPolygon, then split once more
                if let collection = clippedGeo as? GeometryCollection<Geometry> {
                    splitAndAddFeatures(layerName: name, attributes: attrs, geometry: collection)
                    return
                }
                
                // no need to add empty geometry
                if clippedGeo.empty() {
                    return
                }
                
                var layer = _layers[name]
                if layer == nil {
                    layer = Layer()
                    _layers[name] = layer
                    _layerKeysOrdered.append(name)
                }
                
                var tags = [Int]()
                for (key, val) in attrs {
                    tags.append(layer!.key(key: key))
                    tags.append(layer!.value(object: val))
                }
                let feature = Feature(geometry: clippedGeo, tags: tags)
                layer!._features.append(feature)
                
            }
        }
    
    }
    
    private func createdClippedGeometry(geometry g: Geometry?) -> Geometry? {
        guard let geo = g else {
            return nil
        }
        
        let intersect = _clipGeometry.intersection(geo)
        if intersect.empty() && geo.intersects(_clipGeometry) {
            guard let wkt = geo.WKT else {
                return nil
            }
            if let originalViaWkt = Geometry.create(wkt) {
                return _clipGeometry.intersection(originalViaWkt)
            } else {
                return nil
            }
            
        }
        return intersect
    }

    /// A short circuit clip to the tile extent (tile boundary + buffer) for points to improve performance. This method
    /// can be overridden to change clipping behavior. See also 'clipGeometry(Geometry)'.
    ///
    /// see https://github.com/ElectronicChartCentre/java-vector-tile/issues/13
    private func clipCovers(geometry geo: Geometry) -> Bool {
        return _clipGeometry.covers(geo);
    }


    private func splitAndAddFeatures(layerName name: String, attributes attrs: [String: AnyHashable], geometry geo: GeometryCollection<Geometry>?) {
        if let items = geo?.geometries.makeIterator() {
            while let item = items.next() {
                addFeature(layerName: name, attributes: attrs, geometry: item)
            }
        }
    }
    
    
}
