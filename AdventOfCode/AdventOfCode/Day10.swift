//
//  Day10.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-09.
//

import Foundation


func D10ComputeCycles (Current : Int, Parsed : ArraySlice<(Int, (Int) -> Int)>) -> ArraySlice<Int>
{
	if (Parsed.count == 0)
	{
		return ArraySlice<Int>()
	}
	else
	{
		let Start = Parsed.startIndex
		let Value = Parsed[Start]
		let Next = Value.1(Current)
		return Array.init(repeating: Current, count: Value.0) + D10ComputeCycles(Current: Next, Parsed: Parsed[(Start+1)...])
	}
};

func Day10() throws
{
	let Lines = try ReadFile("Day10-1").filter({ $0 != "" })
	
	let parsed = Lines.map {
		let noop = /noop/
		let addx = /addx (?<number>(-?[0-9]+))/
		
		if let _ = $0.wholeMatch(of: noop)
		{
			print("noop")
			return (1,{ (_ v:Int)->Int in return v })
		}
		
		if let x = $0.wholeMatch(of: addx)
		{
			let toAdd = Int(String(x.number))!
			print("addx \(toAdd)")
			return (2,{ print("\($0) + \(toAdd)"); return $0 + toAdd })
		}
		
		return (1000,{ (_ v:Int)->Int in return -10000 })
	}
	
	let Cycles = [1] + D10ComputeCycles(Current: 1, Parsed: ArraySlice(parsed))
	
	let KeyCycles = [20,60,100,140,180,220]
	
	let Sums = KeyCycles.reduce(1, {(Previous:Int, KeyIndex:Int) -> Int in
		let I = min(KeyIndex, Cycles.count-1)
		let Strength = Cycles[I] * KeyIndex
		print("Cycle \(Cycles[I]) Strength: \(Strength)")
		return Previous + Strength
	})
	
	var Display = Array<String>()
	var J = 1
	while J < Cycles.count
	{
		var CurSegment = ""
		for ind in 1...40
		{
			let Offset = Cycles[J]
			if ind >= Offset && ind <= Offset + 2
			{
				CurSegment += "#"
			}
			else
			{
				CurSegment += "."
			}
			
			print (" > \(Offset) -> \(CurSegment)")
			
			J += 1
			if J == Cycles.count
			{ break; }
		}
		Display.append(CurSegment)
	}
	
	print()
	print("Day 9  Pt1> \(Sums)")
	print()
	
	for D in Display
	{
		print(D)
	}
}
