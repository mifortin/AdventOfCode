//
//  Day10.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-09.
//

import Foundation

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
	
	var Value = 1
	var Cycles = Array<Int>()
	Cycles.append(0)	// Cycle 0, ignore.
	for inst in parsed
	{
		for _ in 1...inst.0
		{
			Cycles.append(Value)
		}
		
		Value = inst.1(Value);
	}
	
	let KeyCycles = [20,60,100,140,180,220]
	
	var Sums = 0
	
	for K in KeyCycles
	{
		let I = min(K, Cycles.count-1)
		let Strength = Cycles[I] * K
		print("Cycle \(Cycles[I]) Strength: \(Strength)")
		Sums += Strength
	}
	
	//print(Lines)
	//print(parsed)
	//print(Cycles)
	
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
