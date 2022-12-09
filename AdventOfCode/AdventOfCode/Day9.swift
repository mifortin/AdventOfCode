//
//  Day9.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-08.
//

import Foundation

enum Day9Errors : Error
{
	case BadInput
}

func Day9() throws
{
	let Lines = try ReadFile("Day9-1").filter({ $0 != "" })
	
	let Actions = Lines.map({
		let parse = /(?<Direction>[UDLR]) (?<Amount>(\d+))/
		
		if let match = $0.wholeMatch(of: parse)
		{
			return (match.Direction, Int(String(match.Amount))!)
		}
		return ("E",0)
	})
	
	let StartPosition = SIMD2<Int>(1000,1000)
	var Tail = Array.init(repeating: StartPosition, count: 11)
	
	let Deltas = [
		"U":SIMD2<Int>(0,1),
		"D":SIMD2<Int>(0,-1),
		"L":SIMD2<Int>(-1,0),
		"R":SIMD2<Int>(1,0),
		"E":SIMD2<Int>(0,0)
	]
	
	let GoToAdjacent = [
		SIMD2<Int>(-1,0), SIMD2<Int>(1,0), SIMD2<Int>(0,1), SIMD2<Int>(0,-1),
		SIMD2<Int>(-1,-1), SIMD2<Int>(1,1), SIMD2<Int>(-1,1), SIMD2<Int>(1,-1)
	]
	
	let Primes = SIMD2<Int>(9679,9601)
	
	var Visited = Array.init(repeating: Set<Int>(), count:Tail.count);
	for i in 0..<Tail.count
	{
		Visited[i].insert(Primes.Dot(Tail[i]))
	}
	
	for Action in Actions
	{
		if (Action.0 == "E")
		{
			throw Day9Errors.BadInput;
		}
		
		print(Action)
		for _ in 1...Action.1
		{
			Tail[0] &+= Deltas[String(Action.0)]!
			Visited[0].insert( Primes.Dot(Tail[0]));
			
			for i in 1..<Tail.count
			{
				let p = i-1
				if abs(Tail[i].x - Tail[p].x) > 1
					|| abs(Tail[i].y - Tail[p].y) > 1
				{
					var TempTail = SIMD2<Int>(0,0)
					var MinDistance = Int.max
					for Delta in GoToAdjacent {
						let Temp = Tail[i] &+ Delta
						let md = Temp.DistanceSq(Tail[p])
						if (md < MinDistance)
						{
							MinDistance = md;
							TempTail = Temp
						}
					}
				
					Tail[i] = TempTail
					Visited[i].insert( Primes.Dot(Tail[i]));
				}
			}
			
			//print(" > \(Position) \(Tail)")
			
			/*let grid = 10
			let p1 = Array.init(repeating: ".", count: grid)
			var p2 = Array.init(repeating: p1, count: grid)
			
			var cnt = 0
			for T in Tail
			{
				let x = T.x - 1000
				let y = T.y - 1000
				
				if x >= 0 && y>=0 && x<grid && y<grid
				{
					if (p2[y][x] == ".")
					{
						p2[y][x] = cnt == 10 ? "A" : String(cnt)
					}
				}
				
				cnt += 1
			}
			
			print()
			for p in p2 {
				print(p.joined(separator: " "))
			}*/
		}
	}
	
	//print(Actions)
	for i in 0..<Tail.count
	{
		print("Day 9; Link \(i), visited \(Visited[i].count), currently at \(Tail[i]) ")
	}
}
