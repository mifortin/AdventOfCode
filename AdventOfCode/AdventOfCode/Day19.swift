//
//  Day19.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-18.
//

import Foundation
import DequeModule

struct Day19Dep
{
	let Cost:Int
	let Material:Int
}

struct Day19Data
{
	let Robot:Int
	let Dep1:Day19Dep
	let Dep2:Day19Dep
}

struct Day19Built : Hashable
{
	var Robots:Int
	var Mined:Int
}

struct Day19State : Hashable
{
	var Time:Int
	var Built:[Day19Built]		// Robot + Ore cnt
}


func Day19(_ Data:[Day19Data], MinGeodeStart:Int) -> Int
{
	var State = Deque<Day19State>()
	
	let InitState = Day19State(Time: 0, Built:
								[Day19Built(Robots:1, Mined:0),
								 Day19Built(Robots:0, Mined:0),
								 Day19Built(Robots:0, Mined:0),
								 Day19Built(Robots:0, Mined:0)])
	State.append(InitState)
	
	// Consider - if there are more bots than what can be built...
	var MaxBots = [
		0, 0, 0, 99999
	]
	
	for D in Data {
		MaxBots[D.Dep1.Material] = max(MaxBots[D.Dep1.Material], D.Dep1.Cost)
		if D.Dep2.Cost != 0 {
			MaxBots[D.Dep2.Material] = max(MaxBots[D.Dep2.Material], D.Dep2.Cost)
		}
	}
	
	var MinGeode = MinGeodeStart
	
	var InfGeode = 0
	
	var Seen = Set<Day19State>()
	var MaxTime = 0
	while let Cur = State.popFirst()
	{
		if Cur.Time == 25
		{
			State.append(Cur)
			break
		}
		
		if Cur.Time == MaxTime
		{
			Seen = Set<Day19State>()
			InfGeode = 0
			for I in MaxTime...24
			{
				InfGeode += 25 - I
			}
			MaxTime += 1
			print(" \(Cur.Time)/\(State.count)/\(MinGeode)/\(InfGeode)", terminator: "")
		}
		
		var Updated = Cur
		Updated.Built = Cur.Built.map( { Day19Built(Robots:$0.Robots, Mined:$0.Robots + $0.Mined) } )
		Updated.Time += 1
		
		if Updated.Built[3 /* geode */ ].Mined + InfGeode < MinGeode
		{
			continue
		}
		Seen.insert(Cur)
		
		var Built = 0
		for D in Data
		{
			if Cur.Time == 24 { continue }	// We're at the end...
			if Cur.Time == 23 && D.Robot < 3 { continue }	// Not useful to build anything else
			if Cur.Time == 22 && D.Robot < 2 { continue }
			
			if Cur.Built[D.Dep1.Material].Mined < D.Dep1.Cost {
				if Cur.Built[D.Dep1.Material].Robots == 0 { Built += 1}
				continue
			}
			if D.Dep2.Cost != 0 {
				if Cur.Built[D.Dep2.Material].Mined < D.Dep2.Cost {
					if Cur.Built[D.Dep2.Material].Robots == 0 { Built += 1}
					continue
				}
			}
			Built += 1
			
			if Cur.Built[D.Robot].Robots > MaxBots[D.Robot]
			{
				continue
			}
			
			if Cur.Built[D.Robot].Mined > MaxBots[D.Robot] * (25-Cur.Time)
			{
				continue
			}
			
			var BotCost = Updated
			BotCost.Built[D.Robot].Robots += 1
			BotCost.Built[D.Dep1.Material].Mined -= D.Dep1.Cost
			if D.Dep2.Cost != 0 {
				BotCost.Built[D.Dep2.Material].Mined -= D.Dep2.Cost
			}
			
			if Seen.contains(BotCost)
			{
			//	print("$", terminator: "")
				continue
			}
			
			State.append(BotCost)
			
			if D.Robot == 3 /* geode */
			{
				//print()
				//print(" \(D)")
				//print("  \(Cur)")
				//print("  \(BotCost)")
				//print()
				let PotentialMin = (24-BotCost.Time) * BotCost.Built[3 /* geode */].Robots + BotCost.Built[3 /* geode */].Mined
				//print(PotentialMin, BotCost)
				MinGeode = max(MinGeode, PotentialMin)
			}
		}
		
		if !Seen.contains(Updated)
		{
			if Built != Data.count
			{
				State.append(Updated)
			}
		}
		//else
		//{
		//	print("$", terminator: "")
		//}
	}
	
	print(MinGeode)
	
	return MinGeode
}


func Day19(_ File:String) throws
{
	let Data = try ReadFile(File).filter({ $0 != "" }).map( {
		let OneEx = /(?<type>([a-z]+)) robot costs (?<cost>([0-9]+)) (?<resource>([a-z]+))\./
		let TwoEx = /(?<type>([a-z]+)) robot costs (?<cost1>([0-9]+)) (?<resource1>([a-z]+)) and (?<cost2>([0-9]+)) (?<resource2>([a-z]+))\./
		
		let OneM = $0.matches(of: OneEx)
		let TwoM = $0.matches(of: TwoEx)
		
		let s2i:Dictionary<Substring, Int> =
		[Substring("ore"):0, Substring("clay"):1, Substring("obsidian"):2, Substring("geode"):3]
		
		var Result = [Day19Data]()
		for One in OneM
		{
			Result.append(Day19Data(
				Robot: s2i[One.type]!,
				Dep1: Day19Dep(Cost: Int.From(One.cost)!, Material: s2i[One.resource]!),
				Dep2: Day19Dep(Cost: 0, Material: -1)))
		}
		for Two in TwoM
		{
			Result.append(Day19Data(
				Robot: s2i[Two.type]!,
				Dep1: Day19Dep(Cost: Int.From(Two.cost1)!, Material: s2i[Two.resource1]!),
				Dep2: Day19Dep(Cost: Int.From(Two.cost2)!, Material: s2i[Two.resource2]!)))
		}
		return Result
	} )
	
	// For each blueprint...
	var Score = 0
	var Id = 1
	for D in Data
	{
		let C = Day19(D, MinGeodeStart: 0)
		
		Score += C * Id
		print (Id, C)
		Id += 1
	}
	print(Score)
}


func Day19() throws
{
	try Day19("Day19-Sample")
	try Day19("Day19-1")
}

