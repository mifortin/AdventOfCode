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

func Day15(_ File:String, _ Y:Int) throws
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
	
	let XRange = MinX...MaxX
	
	let Pt1 = XRange.reduce(0, { Previous, X in
		Previous + (Lines.contains(where: { return $0.Contains(Int2(X,Y)) && Int2(X,Y) != $0.Beakon } ) ? 1 : 0)
	})
	
	print("Day 15 Part 1: \(Pt1)")
}


func Day15() throws
{
	try Day15("Day15-Sample", 10)
	try Day15("Day15-1", 2000000)
}
