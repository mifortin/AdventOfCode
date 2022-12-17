//
//  Day16.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-15.
//

import Foundation
import DequeModule
import OrderedCollections

struct Day16Dat
{
	let Flow:Int
	let Tunnels:[String]
}

struct Day16DatInt
{
	let Flow:Int
	let Tunnels:[Int8]
}

struct Day16Key : Hashable
{
	let CurValve:Int8
	let EValve:Int8
	let TimeElapsed:Int8
	let Opened:Int64
}

struct Day16Tracker : CustomStringConvertible
{
	var description: String {
		return "== \(TimeElapsed) == \(CurValve) == \(Opened) == \(PressurePerTime) == \(TotalPressure)"
	}
	
	let CurValve:Int8		// Our Locations
	let EValve:Int8
	let TimeElapsed:Int8
	let Opened:Int64
	let ClosedCnt:Int
	let PressurePerTime:Int
	let TotalPressure:Int
	
	func GenKey() -> Day16Key
	{
		if (ClosedCnt == 0) { return Day16Key(CurValve: 0, EValve: 0, TimeElapsed: TimeElapsed, Opened: Opened) }
		return Day16Key(CurValve: min(CurValve, EValve), EValve: max(CurValve,EValve), TimeElapsed: TimeElapsed, Opened: Opened)
	}
}

func Day16(_ File:String, _ TotalTime:Int, _ Players:Int) throws
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
	
	var String2Int = Dictionary<String,Int8>()
	var String2IntC:Int8 = 0
	for G in Graph
	{
		String2Int[G.key] = String2IntC
		String2IntC += 1
	}
	
	var IGraph = Dictionary<Int8, Day16DatInt>()
	for G in Graph
	{
		IGraph[String2Int[G.key]!] = Day16DatInt(Flow: G.value.Flow, Tunnels: G.value.Tunnels.map({ String2Int[$0]!}))
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
		
		if (Players != 1 && L.key == "AA")
		{
			MaxSpan = Span
			break
		}
	}
	
	//print("-- Span: \(MaxSpan) - Flows: \(SumFlows)")
	
	var FoundTime = 0
	var Elements = 0
	
	print(String(repeating: ".", count: TotalTime) )
	var Cache = Dictionary<Day16Key, Int>()
	var Actions:Deque = [Day16Tracker(CurValve: String2Int["AA"]!, EValve: String2Int["AA"]!, TimeElapsed: 0, Opened: 0, ClosedCnt: Graph.count, PressurePerTime: 0, TotalPressure: 0)]
	
	let AddAction = {
		(ToAdd:Day16Tracker) in
		let CacheKey = ToAdd.GenKey()
		
		if ToAdd.TimeElapsed > FoundTime
		{
			FoundTime += 1
			//print("Minute \(FoundTime) @ \(Elements)")
			print("=", terminator: "")
			Elements = 0
			
			// Reset - we changed minute. (performance noticably degrades as it gets full)
			Cache = Dictionary<Day16Key, Int>()
		}
		
		let FlowInd = min(Int(ToAdd.TimeElapsed) / MaxSpan - 1, SumFlows.count-1)
		if ToAdd.TimeElapsed > MaxSpan && ToAdd.PressurePerTime < SumFlows[FlowInd]
		{
			//print("SLOW \(Cur)")
		}
		else if  Cache[CacheKey] == nil || Cache[CacheKey]! < ToAdd.TotalPressure
		{
			Cache[CacheKey] = ToAdd.TotalPressure	// We've been here!!!
			Actions.insert(ToAdd, at: 0)
		}
	}
	
	// Elephant is an direction...  Don't feel like making code generic
	let AddEAction = {
		(ToAdd:Day16Tracker) in
		
		if Players == 1
		{
			AddAction(ToAdd)
		}
		else
		{
			if ToAdd.ClosedCnt != 0
			{
				let Tunnels = IGraph[ToAdd.EValve]!
				
				let ValveIndex = ToAdd.EValve
				if Tunnels.Flow > 0 && (ToAdd.Opened & (1 << ValveIndex)) == 0
				{
					AddAction(Day16Tracker(CurValve: ToAdd.CurValve,
											EValve: ToAdd.EValve,
											TimeElapsed: ToAdd.TimeElapsed,
											Opened: ToAdd.Opened | (1 << ValveIndex),
											ClosedCnt: ToAdd.ClosedCnt - 1,
											PressurePerTime: ToAdd.PressurePerTime + Tunnels.Flow,
											TotalPressure: ToAdd.TotalPressure))
				}
				
				for T in Tunnels.Tunnels
				{
					AddAction(Day16Tracker(CurValve: ToAdd.CurValve,
											EValve: T,
											TimeElapsed: ToAdd.TimeElapsed,
											Opened: ToAdd.Opened,
											ClosedCnt: ToAdd.ClosedCnt,
											PressurePerTime: ToAdd.PressurePerTime,
											TotalPressure: ToAdd.TotalPressure))
				}
			}
			else
			{
				AddAction(ToAdd)
			}
		}
	}
	
	while Actions.count != 0
	{
		let Cur = Actions.popLast()!
		
		if Cur.TimeElapsed >= TotalTime
		{
			Actions.append(Cur)
			break
		}
		
		Elements += 1
		
		// If we are worse than the cache...

		//print(Cur)
		
		// If we opened every valve, just do nothing...
		if Cur.ClosedCnt != 0
		{
			let Tunnels = IGraph[Cur.CurValve]!
			
			let ValveIndex = Cur.CurValve
			if Tunnels.Flow > 0 && (Cur.Opened & (1 << ValveIndex)) == 0
			{
				AddEAction(Day16Tracker(CurValve: Cur.CurValve,
									   EValve: Cur.EValve,
									   TimeElapsed: Cur.TimeElapsed+1,
									   Opened: Cur.Opened | (1 << ValveIndex),
									   ClosedCnt: Cur.ClosedCnt - 1,
									   PressurePerTime: Cur.PressurePerTime + Tunnels.Flow,
									   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure))
			}
			
			for T in Tunnels.Tunnels
			{
				AddEAction(Day16Tracker(CurValve: T,
									   EValve: Cur.EValve,
									   TimeElapsed: Cur.TimeElapsed+1,
									   Opened: Cur.Opened,
									   ClosedCnt: Cur.ClosedCnt,
									   PressurePerTime: Cur.PressurePerTime,
									   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure))
			}
		}
		else
		{
			AddAction(Day16Tracker(CurValve: Cur.CurValve,
								   EValve: Cur.EValve,
								   TimeElapsed: Cur.TimeElapsed+1,
								   Opened: Cur.Opened,
								   ClosedCnt: Cur.ClosedCnt,
								   PressurePerTime: Cur.PressurePerTime,
								   TotalPressure: Cur.PressurePerTime + Cur.TotalPressure))
		}
	}
	
	print()
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
	try Day16("Day16-Sample", 30, 1)
	try Day16("Day16-1", 30, 1)
	
	try Day16("Day16-Sample", 26, 2)
	try Day16("Day16-1", 26, 2)
}
