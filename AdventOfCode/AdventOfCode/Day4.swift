//
//  Day4.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-04.
//

import Foundation

func Day4ParseRange(_ S:Substring) -> ClosedRange<Int>
{
	let Parts = S.split(separator: "-")
	
	return Int(Parts.first!)! ... Int(Parts.last!)!
}

func Day4Parse(_ S:Substring) -> (ClosedRange<Int>, ClosedRange<Int>)
{
	let Parts = S.split(separator: ",")
	
	return (Day4ParseRange(Parts.first!), Day4ParseRange(Parts.last!))
}

func Day4() throws
{
	let EachLine = try ReadFile("Day4-1")
	var FullyContains=0
	var Overlaps=0
	
	for Line in EachLine
	{
		if (Line == "") {continue}
		
		print(Line)
		
		let ParsedLine = Day4Parse(Line)
		
		print(" >", ParsedLine)
		
		if (ParsedLine.0.contains(ParsedLine.1)
			|| ParsedLine.1.contains(ParsedLine.0))
 		{
			print(" > contains")
			FullyContains+=1
		}
		
		if (ParsedLine.0.overlaps(ParsedLine.1)
			|| ParsedLine.1.overlaps(ParsedLine.0))
		{
			print(" > overlaps")
			Overlaps+=1
		}
	}
	
	print()
	print("Fully Contains: ", FullyContains)
	print("Overlaps: ", Overlaps)
	print()
}
