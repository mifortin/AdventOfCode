//
//  Day15.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-14.
//

import Foundation

struct Day15Beacon : CustomStringConvertible
{
	var description: String
	{
		return "Sensor: \(Sensor.x),\(Sensor.y); Beakon: \(Beakon.x),\(Beakon.y); Distance: \(Dist);"
	}
	
	let Sensor:Int2
	let Beakon:Int2
	let Dist:Int
	
	func Contains(_ Other:Int2) -> Bool
	{
		return Sensor.Manhattan(Other) <= Dist
	}
}

enum Day15Item
{
	case Beacon
	case InRange (Day15Beacon)
	case Sensor
	case OutOfRange
	case Error
}

class Day15QuadTree
{
	var Children = Array<Day15QuadTree?>(repeating: nil, count: 4)
	var Values = Array<Day15Beacon>()
	
	let Min:Int2
	let Max:Int2
	let MidPt:Int2
	
	var Depth = 0
	
	init(_ iMin:Int2, _ iMax:Int2)
	{
		Min = iMin
		Max = iMax
		MidPt = (Min &+ Max) / 2
	}
	
	func GetChild(_ Quadrant:Int) -> Day15QuadTree
	{
		if let Child = Children[Quadrant]
		{
			return Child
		}
		
		var NMin:Int2 = Min
		var NMax:Int2 = Max
		
		if (Quadrant == 0 || Quadrant == 2)		// Left
		{
			NMax.x = MidPt.x
		}
		else		// Right
		{
			NMin.x = MidPt.x + 1
		}
		if (Quadrant == 0 || Quadrant == 1)		// Top
		{
			NMax.y = MidPt.y
		}
		else
		{
			NMin.y = MidPt.y+1
		}
		
		let newChild = Day15QuadTree(NMin, NMax)
		newChild.Depth = Depth + 1
		Children[Quadrant] = newChild
		return newChild
	}
	
	func AddBeacon(_ Beacon:Day15Beacon)
	{
		if Depth >= 10 || Min.Manhattan(Max) < 2
		{
			Values.append( Beacon )
			return
		}
		else
		{
			let Left = Beacon.Sensor.x - Beacon.Dist <= MidPt.x
			let Right = Beacon.Sensor.x + Beacon.Dist > MidPt.x
			
			let Up = Beacon.Sensor.y - Beacon.Dist <= MidPt.y
			let Down = Beacon.Sensor.y + Beacon.Dist > MidPt.y
			
			if Left && Up
			{
				GetChild(0).AddBeacon(Beacon)
			}
			
			if Right && Up
			{
				GetChild(1).AddBeacon(Beacon)
			}
			
			if Down && Left
			{
				GetChild(2).AddBeacon(Beacon)
			}
			
			if Down && Right
			{
				GetChild(3).AddBeacon(Beacon)
			}
		}
	}
	
	
	func ContainsPt( _ Pos:Int2) -> Bool
	{
		return Pos.x >= Min.x && Pos.y >= Min.y
				&& Pos.x <= Max.x && Pos.y <= Max.y
	}
	
	
	func Find(_ Pos:Int2) -> Day15Item
	{
		if Values.count > 0
		{
			for V in Values
			{
				if V.Sensor == Pos { return Day15Item.Sensor}
				if V.Beakon == Pos { return Day15Item.Beacon}
				if V.Contains(Pos) { return Day15Item.InRange(V) }
			}
			
			return Day15Item.OutOfRange
		}
		else
		{
			for C in Children
			{
				if let VC = C
				{
					if VC.ContainsPt(Pos)
					{
						return VC.Find(Pos)
					}
				}
			}
		}
		
		return Day15Item.OutOfRange
	}
}

func Day15(_ File:String, _ Start:Int2, _ End:Int2) throws
{
	let Lines = try ReadFile(File).filter({ $0 != "" }).map( {
		let Rex = /\=(?<C>((\-)?[0-9]+))/
		let Matches = $0.matches(of: Rex)
		let Sense = Int2(Matches[0].C, Matches[1].C)
		let Beak = Int2(Matches[2].C, Matches[3].C)
		let Dist = Sense.Manhattan(Beak)
		return Day15Beacon(Sensor: Sense, Beakon: Beak, Dist: Dist)
	});
	
	let MinX = Lines.reduce(Int.max, { min($0, min($1.Sensor.x, $1.Beakon.x) - $1.Dist) })
	let MaxX = Lines.reduce(Int.min, { max($0, max($1.Sensor.x, $1.Beakon.x) + $1.Dist) })
	
	let S = (Start.x == End.x) ? Int2(MinX, Start.y) : Start
	let E = (Start.x == End.x) ? Int2(MaxX, End.y) : End
	
	let Tree = Day15QuadTree(S, E)
	for L in Lines
	{
		Tree.AddBeacon(L)
	}
	
	var Counter = 0
	var FoundOutOfRange = Int2(-100,-100)
	for Y in S.y...E.y
	{
		var X = S.x
		while (X <= E.x)
		{
			let Found = Tree.Find(Int2(X,Y))
			switch(Found)
			{
			case .Beacon:
				// Nothing
				Counter += 0
			case .InRange(let FB):
				
				let Remaining = FB.Dist - abs(Y - FB.Sensor.y)
				let NewX = Remaining + FB.Sensor.x
				
				Counter += NewX - X + 1
				
				if FB.Beakon.y == S.y && FB.Beakon.x >= X
				{
					Counter -= 1
				}
				
				X = NewX
				
			case .Sensor:
				// Nothing
				Counter += 0
			case .OutOfRange:
				FoundOutOfRange = Int2(X,Y)
			case .Error:
				print("ERROR!!!")
			}
			X += 1
		}
	}
	
	let Freq = 4000000 * FoundOutOfRange.x + FoundOutOfRange.y
	print()
	print("Processing file \(File) Range \(S) -> \(E)")
	print(" - Day 15 Part1 for \(File): \(Counter)")
	print(" - Day 15 Part2 for \(File): \(FoundOutOfRange) = \(Freq)")
//	let Pt1 = XRange.reduce(0, { Previous, X in
//		Previous + (Lines.contains(where: { return $0.Contains(Int2(X,Y)) && Int2(X,Y) != $0.Beakon } ) ? 1 : 0)
//	})
	
//	print("Day 15 Part 1: \(Pt1)")
}


func Day15() throws
{
	try Day15("Day15-Sample", Int2(0,10), Int2(0,10))
	try Day15("Day15-1", Int2(0, 2000000), Int2(0, 2000000))
	
	try Day15("Day15-Sample", Int2(0,0), Int2(20,20))
	try Day15("Day15-1", Int2(0, 0), Int2(4000000, 4000000         ))
}
