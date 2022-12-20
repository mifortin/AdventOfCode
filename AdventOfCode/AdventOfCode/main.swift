//
//  main.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-01.
//

import Foundation

enum StarHuntErrors : Error {
	case BadBundle
	case BadFile
	case MissingFile(String)
}

let CurrentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath);
let StarBundleURL = URL(fileURLWithPath: "StarHunt.bundle", relativeTo: CurrentDirectory);
let StarBundle = Bundle(url: StarBundleURL);

extension Sequence
{
	func For3(_ Callback:(Element, Element, Element) throws->Void, Skip:Int=0) throws
	{
		var Iterator = makeIterator()
		
		while let A = Iterator.next() {
			if let B = Iterator.next() {
				if let C = Iterator.next() {
					try Callback(A,B,C)
				}
			}
			
			if (Skip > 0)
			{
				for _ in 1...Skip {
					let _ = Iterator.next()
				}
			}
		}
	}
}

extension SIMD2<Int>
{
	init(_ X:Substring, _ Y:Substring)
	{
		self.init(Int.From(X)!, Int.From(Y)!)
	}
	
	func Dot( _ Other:SIMD2<Int>) -> Int
	{
		return Other.x * x + Other.y * y
	}
	
	func Manhattan( _ Other:SIMD2<Int>) -> Int
	{
		return abs(Other.x - x) + abs(Other.y - y)
	}
	
	func DistanceSq( _ Other:SIMD2<Int>) -> Int
	{
		return (Other.x - x) * (Other.x - x) + (Other.y - y) * (Other.y - y)
	}
	
	func ComponentMin(_ Other:SIMD2<Int>) -> SIMD2<Int>
	{
		return SIMD2<Int>(Swift.min(x, Other.x), Swift.min(y,Other.y))
	}
	
	func ComponentMax(_ Other:SIMD2<Int>) -> SIMD2<Int>
	{
		return SIMD2<Int>(Swift.max(x, Other.x), Swift.max(y,Other.y))
	}
}

typealias Int2 = SIMD2<Int>

extension Int
{
	static func From( _ X:Substring) -> Int?
	{
		return Int(String(X))
	}
}

func ReadFile(_ FileName:String) throws -> Array<Substring>
{
	if let ValidBundle = StarBundle
	{
		let Path = ValidBundle.path(forResource: FileName, ofType: "txt")
		if let ValidPath = Path
		{
			let Content = try?String(contentsOfFile: ValidPath);
			let EachLine = Content?.split(separator: "\n", omittingEmptySubsequences: false)
			if let ValidEachLine = EachLine
			{
				return ValidEachLine
			}
			else
			{
				return []
			}
		}
		
		throw StarHuntErrors.MissingFile(FileName);
	}
	throw StarHuntErrors.BadBundle;
}


do {
	try Day19()
} catch {
	print(error);
}
