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
	//try?Day1();
	//try Day2();
	//try Day3();
	//try Day3Pt2();
	//try Day4()
	try Day5()
} catch {
	print(error);
}
