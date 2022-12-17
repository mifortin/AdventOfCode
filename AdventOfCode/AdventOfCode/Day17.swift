//
//  Day17.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-17.
//

import Foundation
import DequeModule

func Day17(_ File:String) throws
{
	let Lines = try ReadFile(File)[0]
	
	print(Lines.count)
	
	var LineIndex = 0
	let Read = { ()->Character in
		let CurIndex = LineIndex
		LineIndex = (LineIndex + 1) % Lines.count
		return Lines[Lines.index(Lines.startIndex, offsetBy: CurIndex)]
	}
	
	let ReadOffset = {
		() -> Int in
		let L = Read()
		return L == "<" ? -1 : (L == ">" ? 1 : 0)
	}
	
	let Rocks = [
		[
			"===="
		],
		[
			".+.",
			"+++",
			".+."
		],
		[
			"..*",
			"..*",
			"***"
		],
		[
			"|",
			"|",
			"|",
			"|"
		],
		[
			"XX",
			"XX"
		]
	]
	
	let Empty = Array(repeating: Character("."), count: 7)
	let Base = Array(repeating: Character("-"), count: 7)
	
	var PlayField = Deque<Array<Character> >()
	PlayField.append(Base)
	let AddEmptyLines = {
		(NumLines:Int) in
		for _ in 1...NumLines
		{
			PlayField.insert(Empty, at: 0)
		}
	}
	
	let ShowPlayField = {
		for X in PlayField
		{
			print("|\(String(X))|")
		}
		print()
	}
	
	for I in 0..<2022
	{
		let CurRock = Rocks[I % Rocks.count]
		var CurX = 2
		var CurY = 0
		
		AddEmptyLines(3)
		//ShowPlayField()
		AddEmptyLines(CurRock.count)
		
		let WriteRock = {
			(DoShow:Bool) in
			var OX = CurX
			var OY = CurY
			for L in CurRock
			{
				OX = CurX
				for C in L
				{
					if C != "."
					{
						if (PlayField[OY][OX] != ".")
						{
							print("ERROR!")
						}
						PlayField[OY][OX] = DoShow ? C : "."
					}
					OX += 1
				}
				OY += 1
			}
		}
		
		let ShowState = {
			WriteRock(true)
			ShowPlayField()
			WriteRock(false)
		}
		
		while (true)
		{
			let TryPlace = {
				(Dx:Int, Dy:Int) -> Bool in
				
				let NX = min(max(CurX + Dx, 0),7 - CurRock[0].count)
				if NX != CurX + Dx
				{
					return false
				}
				let NY = CurY + Dy
				
				var OX = NX
				var OY = NY
				for L in CurRock
				{
					OX = NX
					for C in L
					{
						if C != "." && PlayField[OY][OX] != "."
						{
							return false
						}
						OX += 1
					}
					OY += 1
				}
				return true
			}
			
			let Dir = ReadOffset()
			if (Dir == 0)
			{
				print("ERROR")
			}
			//print(Dir)
			if (TryPlace(Dir, 0))
			{
				CurX += Dir
				//ShowState()
			}
			
			if (TryPlace(0, 1))
			{
				CurY += 1
				//ShowState()
			}
			else
			{
				break
			}
		}
		
		WriteRock(true)
		
		while PlayField[0] == Empty
		{
			_ = PlayField.popFirst()
		}
	}
	
	ShowPlayField()
	
	print()
	print (PlayField.count-1)
}

func Day17() throws
{
	//try Day17("Day17-Sample")
	try Day17("Day17-1") // 3159 too high
}
