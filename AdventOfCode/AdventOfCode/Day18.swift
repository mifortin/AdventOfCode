//
//  Day18.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-18.
//

import Foundation
import DequeModule


struct Day18C : Hashable
{
	let X:Int8
	let Y:Int8
	let Z:Int8
	
	static func +(lhs:Day18C, rhs:Day18C) ->Day18C
	{
		return Day18C(X: lhs.X+rhs.X, Y: lhs.Y+rhs.Y, Z: lhs.Z+rhs.Z)
	}
}

func min(_ l:Day18C, _ r:Day18C) -> Day18C
{
	return Day18C(X: min(l.X, r.X), Y: min(l.Y, r.Y), Z: min(l.Z, r.Z))
}

func max(_  l:Day18C, _ r:Day18C) -> Day18C
{
	return Day18C(X: max(l.X, r.X), Y: max(l.Y, r.Y), Z: max(l.Z, r.Z))
}


func Day18(_ File:String) throws
{
	let Coords = try ReadFile(File).filter({ $0 != "" }).map({
		let REX = /(?<Numb>[0-9]+)/
		let F = $0.matches(of:REX)
		let AsInt = (Int.From(F[0].Numb)!, Int.From(F[1].Numb)!, Int.From(F[2].Numb)!)
		
		return (Int8(AsInt.0), Int8(AsInt.1), Int8(AsInt.2))
	})
	
	var Cubes = Set<Day18C>()
	for C in Coords
	{
		Cubes.insert(Day18C(X: C.0, Y: C.1, Z: C.2))
	}
	
	let Faces:[Day18C] = [
		Day18C(X: 1, Y: 0, Z: 0),
		Day18C(X: -1, Y: 0, Z: 0),
		Day18C(X: 0, Y: 1, Z: 0),
		Day18C(X: 0, Y: -1, Z: 0),
		Day18C(X: 0, Y: 0, Z: 1),
		Day18C(X: 0, Y: 0, Z: -1)
	]
	
	var Cnt = 0
	for C in Cubes
	{
		for F in Faces
		{
			let O = C + F
			if !Cubes.contains(O)
			{
				Cnt += 1
			}
		}
	}
	
	print("\(File) Day 18 Pt1: \(Cnt)")
	
	var Lower = Day18C(X:127, Y:127, Z:127)
	var Upper = Day18C(X:-128, Y:-128, Z:-128)
	for C in Cubes
	{
		Lower = min(Lower, C)
		Upper = max(Upper, C)
	}
	Lower = Lower + Day18C(X: -1, Y: -1, Z: -1)
	Upper = Upper + Day18C(X: 1, Y: 1, Z: 1)
	
	var Exterior = Set<Day18C>()
	var Actions = Deque([Lower])
	Exterior.insert(Lower)
	while let A = Actions.popFirst()
	{
		for F in Faces
		{
			let NewInd = F + A
			
			if (NewInd.X >= Lower.X && NewInd.X <= Upper.X
				&& NewInd.Y >= Lower.Y && NewInd.Y <= Upper.Y
				&& NewInd.Z >= Lower.Z && NewInd.Z <= Upper.Z
				&& !Exterior.contains(NewInd)
				&& !Cubes.contains(NewInd))
			{
				Exterior.insert(NewInd)
				Actions.append(NewInd)
			}
		}
	}
	
	var Cnt2 = 0
	for C in Cubes
	{
		for F in Faces
		{
			let O = C + F
			if !Cubes.contains(O) && Exterior.contains(O)
			{
				Cnt2 += 1
			}
		}
	}
	
	print("\(File) Day 18 Pt2: \(Cnt2)")
}

func Day18() throws
{
	try Day18("Day18-Sample")
	try Day18("Day18-1")
}
