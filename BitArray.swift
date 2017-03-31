//
//  BitArray.swift
//  BuildBloomFilteriOS
//
//  Created by Tim Palade on 3/14/17.
//  Copyright © 2017 Tim Palade. All rights reserved.
//

import Foundation

final class BitArray: NSObject, NSCoding {
    
    //Array of bits manipulation
    private var array: [UInt64] = []
    
    init(count:Int) {
        super.init()
        self.array = self.buildArray(count: count)
    }
    
    public func valueOfBit(at index:Int) -> Bool{
        return self.valueOfBit(in: self.array, at: index)
    }
    
    public func setValueOfBit(value:Bool, at index: Int){
        self.setValueOfBit(in: &self.array, at: index, value: value)
    }
    
    public func count() -> Int{
        return self.array.count * intSize - 1
    }
    
    //Archieve/Unarchive
    
    func archived() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    class func unarchived(fromData data: Data) -> BitArray? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? BitArray
    }
    
    //NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.array, forKey:"internalBitArray")
    }
    
    init?(coder aDecoder: NSCoder) {
        super.init()
        let array:[UInt64] = aDecoder.decodeObject(forKey:"internalBitArray") as? [UInt64] ?? []
        self.array = array
    }
    
    
    //Private API
    
    private func valueOfBit(in array:[UInt64], at index:Int) -> Bool{
        checkIndexBound(index: index, lowerBound: 0, upperBound: array.count * intSize - 1)
        let (_arrayIndex, _bitIndex) = bitIndex(at:index)
        let bit = array[_arrayIndex]
        return valueOf(bit: bit, atIndex: _bitIndex)
    }
    
    private func setValueOfBit(in array: inout[UInt64], at index:Int, value: Bool){
        checkIndexBound(index: index, lowerBound: 0, upperBound: array.count * intSize - 1)
        let (_arrayIndex, _bitIndex) = bitIndex(at:index)
        let bit = array[_arrayIndex]
        let newBit = setValueFor(bit: bit, value: value, atIndex: _bitIndex)
        array[_arrayIndex] = newBit
    }
    
    //Constants
    private let intSize = MemoryLayout<UInt64>.size * 8
    
    //bit masks
    
    func invertedIndex(index:Int) -> Int{
        return intSize - 1 - index
    }
    
    func mask(index:Int) -> UInt64 {
        checkIndexBound(index: index, lowerBound: 0, upperBound: intSize - 1)
        return 1 << UInt64(invertedIndex(index: index))
    }
    
    func negative(index:Int) -> UInt64 {
        checkIndexBound(index: index, lowerBound: 0, upperBound: intSize - 1)
        return ~(1 << UInt64(invertedIndex(index: index)))
    }
    
    //return (arrayIndex for UInt64 containing the bit ,bitIndex inside the UInt64)
    private func bitIndex(at index:Int) -> (Int,Int){
        return(index / intSize, index % intSize)
    }
    
    private func buildArray(count:Int) -> [UInt64] {
        //words contain intSize bits each
        let numWords = count/intSize + 1
        return Array.init(repeating: UInt64(0), count: numWords)
    }
    
    //Bit manipulation
    private func valueOf(bit: UInt64, atIndex index:Int) -> Bool {
        checkIndexBound(index: index, lowerBound: 0, upperBound: intSize - 1)
        return (bit & mask(index: index) != 0)
    }
    
    private func setValueFor(bit: UInt64, value: Bool,atIndex index: Int) -> UInt64{
        checkIndexBound(index: index, lowerBound: 0, upperBound: intSize - 1)
        if value {
            return (bit | mask(index: index))
        }
        return bit & negative(index: index)
    }
    
    //Util
    private func checkIndexBound(index:Int, lowerBound:Int, upperBound:Int){
        if(index < lowerBound || index > upperBound)
        {
            NSException.init(name: NSExceptionName(rawValue: "BitArray Exception"), reason: "index out of bounds", userInfo: nil).raise()
        }
    }
}
