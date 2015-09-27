//
//  Bond+ReactiveCocoa.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

//
//// MARK: - ReactiveCocoa + SwiftBonds
//
//private class RetainingDynamicArray<T>: DynamicArray<T> {
//    override init(_ v: Array<T>) {
//        super.init(v)
//    }
//    var retainedObjects: [AnyObject] = []
//    func retain(object: AnyObject) {
//        retainedObjects.append(object)
//    }
//}
//
//func toBondDynamicArray<T, P: PropertyType where P.Value == [T]>(property: P) -> DynamicArray<T> {
//    let dyn = RetainingDynamicArray<T>(property.value)
//    dyn.retain(Box(property))
//    property.producer.start(next: { [weak dyn] value in
//        dyn?.value = value
//    })
//    return dyn
//}
//
//func toBondDynamic<T, P: PropertyType where P.Value == T>(property: P) -> Dynamic<T> {
//    let dyn = InternalDynamic<T>(property.value)
//    dyn.retain(Box(property))
//    property.producer.start(next: { [weak dyn] value in
//        dyn?.value = value
//    })
//    return dyn
//}
//
///// Output Dynamic retains input property
//func toBondDynamic<T, P: MutablePropertyType where P.Value == T>(property: P) -> Dynamic<T> {
//    var updatingFromSelf = false
//    let reverseBond = Bond<T>() { [weak property] v in
//        if !updatingFromSelf {
//            property?.value = v
//        }
//    }
//    let dyn = InternalDynamic<T>(property.value)
//    dyn.retain(Box(property))
//    dyn.retain(reverseBond)
//    property.producer.start(next: { [weak dyn] value in
//        updatingFromSelf = true
//        dyn?.value = value
//        updatingFromSelf = false
//    })
//    reverseBond.bind(dyn, fire: false, strongly: false)
//    return dyn
//}
//
///// Output PropertyOf which retains source dynamic
//func fromBondDynamic<T, D: Dynamical where D.DynamicType == T>(d: D) -> PropertyOf<T> {
//    return fromBondDynamic(d.designatedDynamic)
//}
//
///// Output PropertyOf which retains source dynamic
//func fromBondDynamic<T>(dynamic: Dynamic<T>) -> PropertyOf<T> {
//    let (signal, sink) = Signal<T, ReactiveCocoa.NoError>.pipe()
//    let bond = Bond<T>() { value in
//        sendNext(sink, value)
//    }
//    bond.bind(dynamic, fire: false, strongly: true)
//    return PropertyOf(dynamic.value) {
//        return signal |> map { v in
//            let retainedBond = bond // Force retain bond
//            return v
//        }
//    }
//}
//
//// MARK: Bindings
//
//extension UITextField : Bondable, Dynamical {
//}
//extension UITextView : Dynamical {
//}
//
//// Two way bind
//
//func <->> <T, P: MutablePropertyType where P.Value == T>(left: P, right: Dynamic<T>) {
//    toBondDynamic(left) <->> right
//}
//
//func <->> <D: Dynamical, P: MutablePropertyType where D.DynamicType == P.Value>(left: P, right: D) {
//    toBondDynamic(left) <->> right.designatedDynamic
//}
//
//// Bind and fire
//
//func ->> <P: PropertyType, T where P.Value == T>(left: P, right: Bond<T>) {
//    toBondDynamic(left) ->> right
//}
//
//func ->> <T: PropertyType, U: Bondable where T.Value == U.BondType>(left: T, right: U) {
//    toBondDynamic(left) ->> right.designatedBond
//}
//
//// Bind only
//
//func ->| <P: PropertyType, T where P.Value == T>(left: P, right: Bond<T>) {
//    toBondDynamic(left) ->| right
//}
//
//func ->| <T: PropertyType, U: Bondable where T.Value == U.BondType>(left: T, right: U) {
//    toBondDynamic(left) ->| right.designatedBond
//}
//
