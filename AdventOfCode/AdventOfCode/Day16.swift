//
//  Day16.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-15.
//

import Foundation

struct Day16Dat
{
	let Flow:Int
	let Tunnels:[String]
}

struct Day16Tracker : CustomStringConvertible
{
	var description: String {
		return "== \(TimeElapsed) == \(CurValve) == \(Actions.joined()) == \(Opened.joined(separator: ",")) == \(PressurePerTime) == \(TotalPressure)"
	}
	
	let CurValve:String		// Our Location
	let TimeElapsed:Int
	let Opened:Set<String>
	let PressurePerTime:Int
	let TotalPressure:Int
	let Actions:Array<String>
	
	func GenKey() -> String
	{
		return "\(CurValve)\(Opened.joined())\(TimeElapsed)"
	}
}

func Day16(_ File:String) throws
{
	let Lines = try ReadFile(File).filter({ $0 != "" }).map( {
		let ValveRex = /(?<Valve>[A-Z]{2})/
		let FlowRex = /(?<Flow>[0-9]+)/
		
		let Valves = $0.matches(of: ValveRex)
		let Flow = $0.matches(of: FlowRex)
		
		return Day16Dat(Flow: Int.From(Flow[0].Flow)!, Tunnels: Valves.map({ String($0.Valve)}))
	})
	
	var Graph = Dictionary<String, Day16Dat>()
	for L in Lines
	{
		Graph[L.Tunnels[0]]
			= Day16Dat(Flow: L.Flow, Tunnels: Array(L.Tunnels[1...]))
	}
	
	let Flows = (Lines.map { $0.Flow }).sorted(by: >).filter( {$0 != 0} )
	var SumFlows = [Int]()
	for I in 0..<Flows.count
	{
		SumFlows.append( Flows[...I].reduce(0, +))
	}
	
	var MaxSpan = 0
	
	for L in Graph
	{
		var SSearch = [(L.key,0)]
		var SCache = Dictionary<String, Int>()
		while (SSearch.count > 0)
		{
			let Cur = SSearch.popLast()!
			
			if SCache[Cur.0] == nil || SCache[Cur.0]! > Cur.1
			{
				SCache[Cur.0] = Cur.1
				
				if let G = Graph[Cur.0]
				{
					for T in G.Tunnels
					{
						SSearch.insert((T, Cur.1+1), at: 0)
					}
				}
			}
		}
		let Span = SCache.values.max()!
		MaxSpan = max(Span, MaxSpan)
	}
	
	print("-- Span: \(MaxSpan) - Flows: \(SumFlows)")
	
	var Cache = Dictionary<String, Int>()
	var Actions = [Day16Tracker(CurValve: "AA", TimeElapsed: 0, Opened: [], PressurePerTime: 0, TotalPressure: 0, Actions: [])]
	
	let AddAction = {
		(ToAdd:Day16Tracker) in
		let CacheKey = ToAdd.GenKey()
		if ToAdd.TimeElapsed > MaxSpan && ToAdd.PressurePerTime < SumFlows[ToAdd.TimeElapsed / MaxSpan - 1]
		{
			//print("SLOW \(Cur)")
		}
		else if  Cache[CacheKey] == nil || Cache[CacheKey]! < ToAdd.TotalPressure
		{
			Cache[CacheKey] = ToAdd.TotalPressure	// We've been here!!!
			Actions.insert(ToAdd, at: 0)
		}
	}
	
	var FoundTime = 0
	var Elements = 0
	while Actions.count != 0
	{
		let Cur = Actions.popLast()!
		
		if Cur.TimeElapsed >= 30
		{
			Actions.append(Cur)
			break
		}
		
		if Cur.TimeElapsed > FoundTime
		{
			FoundTime += 1
			print("Minute \(FoundTime) @ \(Elements)")
			Elements = 0
		}
		Elements += 1
		
		// If we are worse than the cache...

		//print(Cur)
		
		// If we opened every valve, just do nothing...
		if Cur.Opened.count != Graph.count
		{
			let Tunnels = Graph[Cur.CurValve]!
			
			if Tunnels.Flow > 0 && !Cur.Opened.contains(Cur.CurValve)
			{
				AddAction(Day16Tracker(CurValve: Cur.CurValve,
									   TimeElapsed: Cur.TimeElapsed+1,
									   Opened: Set(Cur.Opened + [Cur.CurValve]),
									   PressurePerTime: Cur.PressurePerTime + Tunnels.Flow,
									   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure,
									   Actions: Cur.Actions + ["O\(Cur.CurValve)"]))
			}
			
			for T in Tunnels.Tunnels
			{
				AddAction(Day16Tracker(CurValve: T,
									   TimeElapsed: Cur.TimeElapsed+1,
									   Opened: Cur.Opened,
									   PressurePerTime: Cur.PressurePerTime,
									   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure,
									   Actions: Cur.Actions + ["M\(T)"]))
			}
		}
		else
		{
			AddAction(Day16Tracker(CurValve: Cur.CurValve,
								   TimeElapsed: Cur.TimeElapsed+1,
								   Opened: Cur.Opened,
								   PressurePerTime: Cur.PressurePerTime,
								   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure,
								   Actions: Cur.Actions + ["I\(Cur.CurValve)"]))
		}
	}
	
	print()
	var Max = 0
	for C in Actions{
		//print(C, C.GenKey())
		Max = max(C.TotalPressure, Max)
	}
	print("Pt 1: \(Max)")
}

func Day16() throws
{
	try Day16("Day16-Sample")
	try Day16("Day16-1")
}
