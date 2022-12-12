//
//  Day12.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-11.
//

import Foundation


func Day12() throws
{
	let Lines = try ReadFile("Day12-1").filter({ $0 != "" })
	
	let StartKey = -14
	let EndKey = -28
	
	let Heights = Lines.map( {
		$0.map( {
			return Int($0.asciiValue!) - Int(Character("a").asciiValue!)
		})
	} )
	let Height = Heights.count
	let Width = Heights[0].count
	
	
	let DistanceTo = { (StartX:Int , StartY:Int) -> Int in
		
		let Unexplored = 9999999999
		var Distance = Heights.map( {
			$0.map( { (Int) in return Unexplored } )
		})
		
		// Distance travelled is 0.  Start height is huge so we can move anywhere
		var Explore = [(StartX, StartY, 0, 0)]
		
		var Found = Explore[0]
		
		while let Current = Explore.popLast()
		{
			let CurHeight = Heights[Current.1][Current.0]
			let Adjusted = (CurHeight == StartKey) ? 0 : CurHeight
			
			if CurHeight == EndKey && Current.3 >= 24
			{
				Distance[Current.1][Current.0] = Current.2
				Found = Current
				break
			}
			
			if Distance[Current.1][Current.0] != Unexplored
			{
				continue
			}
			
			if (Current.3 + 1 >= Adjusted && Adjusted != EndKey)
				|| (Current.3 == 25 && Adjusted == EndKey)
			{
				Distance[Current.1][Current.0] = Current.2
				
				if (Current.0 >= 1)
				{
					Explore.insert((Current.0 - 1, Current.1, Current.2+1, Adjusted), at: 0)
				}
				
				if (Current.1 >= 1)
				{
					Explore.insert((Current.0, Current.1 - 1, Current.2+1, Adjusted), at: 0)
				}
				
				if (Current.0 < Width - 1)
				{
					Explore.insert((Current.0 + 1, Current.1, Current.2+1, Adjusted), at: 0)
				}
				
				if (Current.1 < Height - 1)
				{
					Explore.insert((Current.0, Current.1 + 1, Current.2+1, Adjusted), at: 0)
				}
			}
		}
		
		return Found.2
	}
	
	let Pt1StartY = Heights.firstIndex(where: {return $0.contains(StartKey)})!
	let Pt1StartX = Heights[Pt1StartY].firstIndex(where: { return $0 == StartKey })!
	
	let Day1Distance = DistanceTo(Pt1StartX, Pt1StartY)
	
	print()
	
	var MinDistance = Day1Distance
	for X in 0..<Width
	{
		for Y in 0..<Height
		{
			if Heights[Y][X] == 0
			{
				let NewDist = DistanceTo(X,Y)
				
				if NewDist != 0 {
					MinDistance = min(MinDistance, NewDist)
				}
			}
		}
	}
	
	print(" Day 12 pt 1: \(Day1Distance)")
	print(" Day 12 pt 2: \(MinDistance)")
}
