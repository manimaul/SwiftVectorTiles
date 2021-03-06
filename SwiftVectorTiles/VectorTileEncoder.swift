//
//  VectorTileEncoder.swift
//  GeosSwiftVectorTiles
//
//  Created by William Kamp on 12/28/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import Foundation

private class Feature {
    let _geometry: MadGeometry
    let _tags: [Int]

    init(geometry: MadGeometry, tags: [Int]) {
        self._geometry = geometry
        self._tags = tags
    }
}

private class Layer {
    var _features = [Feature]()

    var _keys = [String: Int]()
    var _keysKeysOrdered = [String]()

    var _values = [Attribute: Int]()
    var _valuesKeysOrdered = [Attribute]()

    func key(key k: String) -> Int {
        guard let i = _keys[k] else {
            let index = _keys.count
            _keys[k] = index
            _keysKeysOrdered.append(k)
            return index
        }
        return i
    }

    func keys() -> [String] {
        return _keysKeysOrdered
    }

    func value(object obj: Attribute) -> Int {
        guard let i = _values[obj] else {
            let index = _values.count
            _values[obj] = index
            _valuesKeysOrdered.append(obj)
            return index
        }
        return i
    }

    func values() -> [Attribute] {
        return _valuesKeysOrdered
    }
}

private func createTileEnvelope(buffer b: Int, size s: Int) -> MadPolygon {
    let start = (Double) (0 - b)
    let end = (Double) (s + b)
    let wkt = "POLYGON (( \(start) \(end), \(end) \(end), \(end) \(start), \(start) \(start), \(start) \(end) ))"
    let geometry = MadGeometryFactory.geometryFromWellKnownText(wkt)
    return geometry as! MadPolygon
}

private func toIntArray(intArray arr: [Int]) -> [UInt32] {
    var ints = [UInt32]()
    for i in arr {
        ints.append(UInt32(i))
    }
    return ints
}

private func toGeomType(geometry g: MadGeometry) -> VectorTile.Tile.GeomType {
    switch g.geometryType {
        case .point, .multiPoint:
            return VectorTile.Tile.GeomType.point
        case .lineString, .multiLineString, .linearRing:
             return VectorTile.Tile.GeomType.linestring
        case .polygon, .multiPolygon:
             return VectorTile.Tile.GeomType.polygon
        default:
            return VectorTile.Tile.GeomType.unknown
    }
}

/// https://developers.google.com/protocol-buffers/docs/encoding#types
private func zigZagEncode(number n: Int) -> Int {
    return (n << 1) ^ (n >> 31)
}

private func commandAndLength(command c: Command, repeated r: Int) -> Int {
    return r << 3 | c.rawValue
}


/**
 * Encodes geometries into Mapbox Vector tiles.
 */
public class VectorTileEncoder {
    private var _layers = [String: Layer]()
    private var _layerKeysOrdered = [String]()

    let _extent: Int
    let _clipGeometry: MadPolygon
    let _autoScale: Bool
    var _x = 0
    var _y = 0

    /// Create a 'VectorTileEncoder' with the default extent of 4096 and clip buffer of 8.
    public convenience init() {
        self.init(extent: 4096, clipBuffer: 8, autoScale: true)
    }

    /// Create a 'VectorTileEncoder' with the given extent and a clip buffer of 8.
    public convenience init(extent e: Int) {
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
        _clipGeometry = createTileEnvelope(buffer: buffer, size: size)
    }

    /// - returns: 'Data' with the vector tile
    public func encode() -> Data {
        let tileBuilder = VectorTile.Tile.Builder()
        var tileLayers = Array<VectorTile.Tile.Layer>()
        for layerName in _layerKeysOrdered {
            let layer = _layers[layerName]!

            let tileLayerBuilder = VectorTile.Tile.Layer.Builder()
            tileLayerBuilder.version = 2
            tileLayerBuilder.name = layerName
            tileLayerBuilder.keys = layer.keys()

            var values = Array<VectorTile.Tile.Value>()
            for attributeValue in layer.values() {
                let tileValueBuilder = VectorTile.Tile.Value.Builder()
                switch attributeValue {
                case let .attInt(aInt):
                    tileValueBuilder.setIntValue(aInt)
                case let .attFloat(aFloat):
                    tileValueBuilder.setFloatValue(aFloat)
                case let .attDouble(aDouble):
                    tileValueBuilder.setDoubleValue(aDouble)
                case let .attString(aString):
                    tileValueBuilder.setStringValue(aString)
                }
                do {
                    let tv = try tileValueBuilder.build()
                    values.append(tv)
                } catch {
                    NSLog("could not build tile value")
                }
            }
            tileLayerBuilder.values = values
            tileLayerBuilder.setExtent(UInt32(_extent))

            var features = Array<VectorTile.Tile.Feature>()
            for feature in layer._features {
                let geo = feature._geometry
                let featureBuilder = VectorTile.Tile.Feature.Builder()
                featureBuilder.setTags(toIntArray(intArray: feature._tags))
                featureBuilder.setType(toGeomType(geometry: geo))
                featureBuilder.setGeometry(commands(geometry: geo))
                do {
                    let f = try featureBuilder.build()
                    features.append(f)
                } catch {
                    NSLog("could not build feature")
                }
            }

            tileLayerBuilder.setFeatures(features)
            do {
                let tl = try tileLayerBuilder.build()
                tileLayers.append(tl)
            } catch {}

        }

        tileBuilder.setLayers(tileLayers)
        do {
            let t = try tileBuilder.build()
            return t.data()
        } catch {
            fatalError("could not build tile")
        }
    }

    public func addFeature(layerName name: String, attributes attrs: [String: Attribute]?, geometry wkb: Data) {
        guard let geo = MadGeometryFactory.geometryFromWellKnownBinary(wkb) else {
            NSLog("could not create geometry")
            return
        }
        addFeature(layerName: name, attributes: attrs, geometry: geo)
    }

    public func addFeature(layerName name: String, attributes attrs: [String: Attribute]?, geometry wkt: String) {
        guard let geo = MadGeometryFactory.geometryFromWellKnownText(wkt) else {
            NSLog("could not create geometry")
            return
        }
        addFeature(layerName: name, attributes: attrs, geometry: geo)
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
    public func addFeature(layerName name: String, attributes attrs: [String: Attribute]?, geometry geom: MadGeometry?) {
        guard let geo = geom else {
            return
        }

        if let mmg = geo as? MadMultiGeometry {
            splitAndAddFeatures(layerName: name, attributes: attrs, geometry: mmg.geometries)
            return
        }

        if let mgc = geo as? MadGeometryCollection {
            splitAndAddFeatures(layerName: name, attributes: attrs, geometry: mgc.geometries)
            return
        }

        // skip small Polygon/LineString.
        if let polygon = geo as? MadPolygon {
            if (polygon.area < 1.0) {
                return
            }
        }

        if let line = geo as? MadLineString {
            if (line.length < 1.0) {
                return
            }
        }

        // clip geometry
        if let point = geo as? MadPoint {
            if !(clipCovers(geometry: point)) {
                return
            }
        } else {
            if let clippedGeo = createdClippedGeometry(geometry: geo) {

                // if clipping result in MultiPolygon, then split once more
                if let mmg = geo as? MadMultiGeometry {
                    splitAndAddFeatures(layerName: name, attributes: attrs, geometry: mmg.geometries)
                    return
                }

                // if clipping result in GeometryCollection, then split once more
                if let mgc = geo as? MadGeometryCollection {
                    splitAndAddFeatures(layerName: name, attributes: attrs, geometry: mgc.geometries)
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
                if let attributes = attrs {
                    for (key, val) in attributes {
                        tags.append(layer!.key(key: key))
                        tags.append(layer!.value(object: val))
                    }
                }
                let feature = Feature(geometry: clippedGeo, tags: tags)
                layer!._features.append(feature)

            }
        }

    }

    private func commands(coordinates cs: [GeoCoordinate], closePathAtEnd closedEnd: Bool, isMultiPoint mp: Bool) -> [UInt32] {
        let count = Int(cs.count)

        if count == 0 {
            fatalError("empty geometry")
        }

        var r = [Int]()
        var lineToIndex = 0
        var lineToLength = 0
        let scale = _autoScale ? (Double(_extent) / 256.0) : 1.0

        var i = 0
        let first = cs[0]
        for c in cs {
            if i == 0 {
                r.append(commandAndLength(command: .moveTo, repeated: mp ? count: 1))
            }

            let x = Int(round(c.0 * scale))
            let y = Int(round(c.1 * scale))

            // prevent point equal to the previous
            if i > 0 && x == _x && y == _y {
                lineToLength -= 1
                continue
            }

            // prevent double closing
            if closedEnd && (cs.count > 1) && (i == (count - 1)) && first == c {
                lineToLength -= 1
                continue
            }

            // delta, then zigzag
            r.append(zigZagEncode(number: x - _x))
            r.append(zigZagEncode(number: y - _y))

            _x = x
            _y = y

            if (i == 0) && (count > 1) && !mp {
                // can length be too long?
                lineToIndex = r.count
                lineToLength = count - 1
                r.append(commandAndLength(command: .lineTo, repeated: lineToLength))

            }
            i += 1
        }

        // update LineTo length
        if lineToIndex > 0 {
            if lineToLength == 0 {
                r.remove(at: lineToIndex)
            } else {
                // update LineTo with new length
                r[lineToIndex] = commandAndLength(command: .lineTo, repeated: lineToLength)
            }
        }

        if closedEnd {
            r.append(commandAndLength(command: .closePath, repeated: 1))
        }

        return toIntArray(intArray: r)
    }

    private func commands(coordinates cs: [GeoCoordinate], closePathAtEnd closedEnd: Bool) -> [UInt32] {
        return commands(coordinates: cs, closePathAtEnd: closedEnd, isMultiPoint: false)
    }

    private func commands(geometry geo: MadGeometry) -> [UInt32] {

        _x = 0
        _y = 0

        if let polygon = geo as? MadPolygon {
            var result = [UInt32]()

            // According to the vector tile specification, the exterior ring of a polygon
            // must be in clockwise order, while the interior ring in counter-clockwise order.
            // In the tile coordinate system, Y axis is positive down.
            //
            // However, in geMadaphic coordinate system, Y axis is positive up.
            // Therefore, we must reverse the coordinates.
            // So, the code below will make sure that exterior ring is in counter-clockwise order
            // and interior ring in clockwise order.
            var exteriorRing = polygon.exteriorRing!
            if !exteriorRing.isCounterClockWise {
                exteriorRing = exteriorRing.reverse()!
            }
            result.append(contentsOf: commands(coordinates: exteriorRing.coordinates, closePathAtEnd: true))

            for interiorRing in polygon.interiorRings {
                var ir :MadLinearRing? = interiorRing
                if !(interiorRing.isCounterClockWise) {
                    ir = interiorRing.reverse()
                }
                result.append(contentsOf: commands(coordinates: ir!.coordinates, closePathAtEnd: true))
            }

            return result
        }

        if let mls = geo as? MadMultiLineString {
            var result = [UInt32]()
            for iGeo in mls {
                result.append(contentsOf: commands(coordinates: iGeo.coordinates, closePathAtEnd: false))
            }
            return result
        }
        let isMp = geo is MadMultiPoint
        return commands(coordinates: geo.coordinates, closePathAtEnd: shouldClosePath(geometry: geo), isMultiPoint: isMp)
    }

    private func shouldClosePath(geometry: MadGeometry) -> Bool {
        return (geometry is MadPolygon) || (geometry is MadLinearRing)
    }

    private func createdClippedGeometry(geometry g: MadGeometry?) -> MadGeometry? {
        guard let geo = g,
              let clipped = _clipGeometry.intersection(other: geo) else {
            // could not intersect. original geometry will be used instead.
            return g
        }

        // some times a intersection is returned as an empty geometry.
        // going via wkt fixes the problem.
        if clipped.isEmpty && geo.intersects(other: _clipGeometry) {
            if let wkt = geo.wkt,
               let wktGeo = MadGeometryFactory.geometryFromWellKnownText(wkt),
               let clippedWktGeo = _clipGeometry.intersection(other: wktGeo) {
                return clippedWktGeo
            } else {
                return g
            }
        }

        return clipped
    }

    /// A short circuit clip to the tile extent (tile boundary + buffer) for points to improve performance. This method
    /// can be overridden to change clipping behavior. See also 'clipGeometry(Geometry)'.
    ///
    /// see https://github.com/ElectronicChartCentre/java-vector-tile/issues/13
    private func clipCovers(geometry geo: MadGeometry) -> Bool {
        return _clipGeometry.covers(other: geo);
    }

    private func splitAndAddFeatures(layerName name: String, attributes attrs: [String: Attribute]?, geometry geo: [MadGeometry]) {

        for each in geo {
            addFeature(layerName: name, attributes: attrs, geometry: each)
        }
    }

}
