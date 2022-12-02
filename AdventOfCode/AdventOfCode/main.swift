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
	try Day2();
} catch {
	print(error);
}
