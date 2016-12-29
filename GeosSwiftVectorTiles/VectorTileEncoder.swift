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

public class VectorTileEncoder {
    private var _layers = [String: Layer]()
    private var _layerKeysOrdered = [String]()
    
    let _extent: Int
    let _clipGeometry: Geometry
    let _autoScale: Bool
    
    convenience init() {
        self.init(extent: 4096, clipBuffer: 8, autoScale: true)
    }
    
    convenience init(extent e: Int) {
        self.init(extent: e, clipBuffer: 8, autoScale: true)
    }
    
    public init(extent e: Int, clipBuffer buffer: Int, autoScale auto: Bool) {
        _extent = e
        _autoScale = auto
        let size = auto ? 256 : e
        _clipGeometry = createTileEnvelope(buffer: buffer, size: size)!
    }
    
    public func encode() -> Data {
        //todo:
        return Data()
    }
    
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
