//
//  Day5.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-04.
//

import Foundation

func Day5() throws
{
	let Lines = try ReadFile("Day5-1")
	
	let Crates = Lines.filter { $0.contains("[") }
	let Moves = Lines.filter( { $0.contains("move") } )
	
	var Stacks9000 = Array<Array<Character> >()
	var Stacks9001 = Array<Array<Character> >()
	
	for Crate in Crates.reversed()
	{
		var index = 0
		try Crate.For3({
			
			if ($0 == "[")
			{
				print(index, $0, $1, $2)
				
				if (index >= Stacks9000.count)
				{
					Stacks9000.append(Array<Character>())
				}
				Stacks9000[index].append($1)
			}
			index += 1;
			
		}, Skip: 1)
	}
	
	Stacks9001 = Stacks9000;
	print(Stacks9000)
	
	for Move in Moves
	{
		let parts = Move.components(separatedBy: " ")
		
		let Count = Int(parts[1])!
		let From = Int(parts[3])! - 1
		let Dest = Int(parts[5])! - 1
		
		for _ in 1...Count {
			let Moving = Stacks9000[From].popLast()!
			Stacks9000[Dest].append(Moving)
		}
		
		let LastIndex = Stacks9001[Dest].endIndex
		for _ in 1...Count {
			let Moving = Stacks9001[From].popLast()!
			Stacks9001[Dest].insert(Moving, at: LastIndex)
		}
	}
	
	print(Stacks9000)
	print(Stacks9001)
	
	var Final = ""
	for X in Stacks9000 {
		Final.append(X.last!)
	}
	print()
	print(Final)
	print()
	
	Final = ""
	for X in Stacks9001 {
		Final.append(X.last!)
	}
	print()
	print(Final)
	print()
}
