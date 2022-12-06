//
//  Day6.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-05.
//

import Foundation

extension Substring
{
	func Day6UniqueIndex(_ numUnique:Int) -> Int
	{
		if count < numUnique
		{
			return -1;
		}
		
		for i in 0...(count-numUnique) {
			let StartIndex = index(startIndex, offsetBy: i)
			let EndIndex = index(StartIndex, offsetBy: numUnique)
			let Substring = self[StartIndex..<EndIndex]
			
			let Subset = Set(Substring)
			if (Subset.count == numUnique)
			{
				return i+numUnique
			}
		}
		return -1
	}
}

func Day6() throws
{
	let Lines = try ReadFile("Day6-1")
	
	for Line in Lines {
		print("pt1> ", Line.Day6UniqueIndex(4), "     pt2> ", Line.Day6UniqueIndex(14))
	}
}
