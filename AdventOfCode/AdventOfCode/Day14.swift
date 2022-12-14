//
//  Day14.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-13.
//

import Foundation

func Day14Sim(Coords:[[SIMD2<Int>]], FloorVariant:Bool) -> Int
{
	let Min = Coords.reduce( SIMD2<Int>(Int.max,Int.max),
	{ return $0.ComponentMin(
		$1.reduce(SIMD2<Int>(Int.max,Int.max),
			{return $0.ComponentMin( $1)}
		))
	}).ComponentMin(SIMD2<Int>(500,0)) &- SIMD2<Int>(500,0)
	
	let Max = Coords.reduce( SIMD2<Int>(Int.min,Int.min),
	{ return $0.ComponentMax(
		$1.reduce(SIMD2<Int>(Int.min,Int.min),
			{return $0.ComponentMax( $1)}
		))
	}) &+ SIMD2<Int>(500,2)
	
	let Size = Max &- Min
	
	var Grid = Array.init(repeating: Array.init(repeating: ".", count: Size.x+1), count: Size.y+1)
	
	if (FloorVariant)
	{
		Grid[Grid.count-1] = Array.init(repeating: "=", count: Size.x+1)
	}
	
	for CGroup in Coords
	{
		for I in 1..<CGroup.count
		{
			var Start = CGroup[I-1] &- Min
			let End = CGroup[I] &- Min
			
			Grid[Start.y][Start.x] = "#"
			
			while (Start != End)
			{
				var Delta = End &- Start
				Delta.clamp(lowerBound: SIMD2<Int>(-1,-1), upperBound: SIMD2<Int>(1,1))
				Start &+= Delta
				
				Grid[Start.y][Start.x] = "#"
			}
		}
	}
	
	let Options = [SIMD2<Int>(0,1), SIMD2<Int>(-1,1), SIMD2<Int>(1,1)]
	
	var Pt1 = 0
	var SandSource = SIMD2<Int>(500,0) &- Min
	for I in 1...
	{
		var Start = SandSource
		
		var Found = Start
		repeat {
			Start = Found
			for O in Options
			{
				let Test = Start &+ O
				
				if Grid[Test.y][Test.x] == "."
				{
					Found = Test
					break
				}
			}
		} while Found != Start && (Found.y < Size.y-1 || FloorVariant)
		
		if (Found.y == Size.y-1 && !FloorVariant)
		{
			Pt1 = I-1
			break
		}
		
		Grid[Start.y][Start.x] = "o"
		
		if (!FloorVariant || I % 1000 == 0 || Found == SandSource)
		{
			print("Iteration \(I)")
			for G in Grid
			{
				print(G.joined())
			}
			print()
		}
		
		if Found == SandSource
		{
		   Pt1 = I
		   break
		}
	}
	
	return Pt1
}

func Day14() throws
{
	let Lines = try ReadFile("Day14-1").filter({ $0 != "" })
	let Coords = Lines.map {
		let CoordX = /(?<X>([0-9]+)),(?<Y>([0-9]+))/
		let CoordM = $0.matches(of: CoordX)
		return CoordM.map( { return SIMD2<Int>(Int.From($0.X)!, Int.From($0.Y)!) } )
	}
	
	let Pt1 = Day14Sim(Coords: Coords, FloorVariant: false)
	let Pt2 = Day14Sim(Coords: Coords, FloorVariant: true)
	
	print("Day 14 Pt1: \(Pt1)")
	print("Day 14 Pt2: \(Pt2)")
}
