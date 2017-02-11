//
// Created by Willard Kamp on 2/8/17.
// Copyright (c) 2017 William Kamp. All rights reserved.
//

import Foundation

internal var GeosContext: OpaquePointer = {
    return GEOS_init_r()
}()

internal func GPtrOwnerCreate(_ ptr: OpaquePointer) -> GPtrOwner {
    return GPtrOwner(ownedPtr: GeosGeometryPtr(ptr: ptr))
}

internal func GPtrOwnerMakeManaged(_ gOwner: GPtrOwner) -> GPtrOwnerManaged {
    return GPtrOwnerManagedCreate(gOwner.ptr)
}

internal func GPtrOwnerManagedCreate(_ ptr: OpaquePointer) -> GPtrOwnerManaged {
    return GPtrOwnerManaged(ownedPtr: GeosGeometryPtr(ptr: ptr))
}

internal func CSPtrOwnerCreate(_ ptr: OpaquePointer) -> CSPtrOwner {
    return CSPtrOwner(ownedPtr: GeosCoordinateSequencePtr(ptr: ptr))
}

/// container protocol for and 'OpaquePointer' representing a geos geometry or coordinate sequence
internal protocol GeosPtr {
    var ptr: OpaquePointer { get }
}

/// container for and 'OpaquePointer' representing a geos geometry
internal class GeosGeometryPtr: GeosPtr {
    public var ptr: OpaquePointer
    init(ptr: OpaquePointer) {
        self.ptr = ptr
    }
}

/// container for and 'OpaquePointer' representing a geos coordinate sequence
internal class GeosCoordinateSequencePtr: GeosPtr {
    public var ptr: OpaquePointer
    init(ptr: OpaquePointer) {
        self.ptr = ptr
    }
}

/// container for an `GeosGeometryPtr` that your are responsible for destroying
internal class GPtrOwner {
    let ownedPtr: GeosGeometryPtr
    var ptr: OpaquePointer {
        return self.ownedPtr.ptr
    }
    init(ownedPtr: GeosGeometryPtr) {
        self.ownedPtr = ownedPtr
    }
    func destroy() {
        GEOSGeom_destroy_r(GeosContext, ownedPtr.ptr)
    }
}

/// container for an `GeosCoordinateSequencePtr` that your are responsible for destroying
internal class CSPtrOwner {
    let ownedPtr: GeosCoordinateSequencePtr
    var ptr: OpaquePointer {
        return self.ownedPtr.ptr
    }
    init(ownedPtr: GeosCoordinateSequencePtr) {
        self.ownedPtr = ownedPtr
    }
    func destroy() {
        GEOSCoordSeq_destroy_r(GeosContext, seqPtr.ptr)
    }
}


/// container for an `GeosGeometryPtr` that cannot be destroyed
internal class GPtrOwnerManaged : GPtrOwner {
    override func destroy () { }
}
