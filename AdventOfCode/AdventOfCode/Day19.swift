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

struct Day19State
{
	var Time:Int
	var Built:[(Int, Int)]		// Robot + Ore cnt
}


func Day19(_ Data:[Day19Data], MinGeodeStart:Int) -> Int
{
	var State = Deque<Day19State>()
	
	let InitState = Day19State(Time: 0, Built:
								[(1,0), (0,0), (0,0), (0,0)])
	State.append(InitState)
	
	// Consider - if there are more bots than what can be built...
	var MaxBots:Dictionary<Int,Int> = [
		0:0, 1:0, 2:0, 3:99999
	]
	
	for D in Data {
		MaxBots[D.Dep1.Material] = max(MaxBots[D.Dep1.Material]!, D.Dep1.Cost)
		if D.Dep2.Cost != 0 {
			MaxBots[D.Dep2.Material] = max(MaxBots[D.Dep2.Material]!, D.Dep2.Cost)
		}
	}
	
	var MinGeode = MinGeodeStart
	
	var InfGeode = 0
	for I in 1...24
	{
		InfGeode += I
	}
	
	// Maximum ore that we can use.  Except for geode which is infinite.
	
	
	//var Seen = Set<Int>()
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
			//Seen = Set<Int>()
			if Cur.Time != 0 {
				InfGeode -= (24 - Cur.Time)
			}
			MaxTime += 1
			print(" \(Cur.Time)/\(State.count)/\(MinGeode)/\(InfGeode)", terminator: "")
		}
		
		var Updated = Cur
		Updated.Built = Cur.Built.map( { ($0.0, $0.0 + $0.1) } )
		Updated.Time += 1
		
		if Updated.Built[3 /* geode */ ].1 + InfGeode < MinGeode
		{
			continue
		}
		//Seen.insert(Cur.Key())
		
		for D in Data
		{
			if Cur.Built[D.Dep1.Material].1 < D.Dep1.Cost {
				continue
			}
			if D.Dep2.Cost != 0 {
				if Cur.Built[D.Dep2.Material].1 < D.Dep2.Cost {
					continue
				}
			}
			
			if Cur.Built[D.Robot].0 > MaxBots[D.Robot]!
			{
				continue
			}
			
			var BotCost = Updated
			BotCost.Built[D.Robot].0 += 1
			BotCost.Built[D.Dep1.Material].1 -= D.Dep1.Cost
			if D.Dep2.Cost != 0 {
				BotCost.Built[D.Dep2.Material].1 -= D.Dep2.Cost
			}
			
			//if Seen.contains(BotCost.Key())
			//{
			//	print("$", terminator: "")
			//	continue
			//}
			
			State.append(BotCost)
			
			if D.Robot == 3 /* geode */
			{
				//print()
				//print(" \(D)")
				//print("  \(Cur)")
				//print("  \(BotCost)")
				//print()
				let PotentialMin = (24-BotCost.Time) * BotCost.Built[3 /* geode */].0 + BotCost.Built[3 /* geode */].1
				//print(PotentialMin, BotCost)
				MinGeode = max(MinGeode, PotentialMin)
			}
		}
		
		//if !Seen.contains(Updated.Key())
		//{
			State.append(Updated)
		//}
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
	var MinGeode = 0
	var Score = 0
	var Id = 1
	for D in Data
	{
		let C = Day19(D, MinGeodeStart: MinGeode)
		if (C < MinGeode)
		{
			MinGeode = C
			Score = MinGeode * Id
		}
		print (Id, C)
		Id += 1
	}
	print(Score)
}


func Day19() throws
{
	try Day19("Day19-Sample")
	try Day19("Day18-1")
}

