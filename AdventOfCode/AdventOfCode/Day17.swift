//
//  Day17.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-17.
//

import Foundation
import DequeModule

func Day17(_ File:String, Iterations: Int) throws
{
	let Lines = try ReadFile(File).joined().map({
		if $0 == "<" { return -1 }
		if $0 == ">" { return 1 }
		
		print("ERROR \($0)")
		return 0
	})
	
	//print(Lines.count)
	
	var LineIndex = 0
	let Read = { ()->Int in
		let CurIndex = LineIndex
		LineIndex = (LineIndex + 1) % Lines.count
		return Lines[CurIndex]
	}
	
	let Rocks = [
		[
			0b00111100
		],
		[
			0b00010000,
			0b00111000,
			0b00010000
		],
		[
			0b00001000,
			0b00001000,
			0b00111000
		],
		[
			0b00100000,
			0b00100000,
			0b00100000,
			0b00100000
		],
		[
			0b00110000,
			0b00110000
		]
	]
	
	
	
	let Empty = 0b00000000_00000000
	let Base = 0b11111111_11111111
	
	var PlayField = Deque<Int>()
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
			for Y in 1...7
			{
				if X & (1 << (8-Y)) != 0
				{
					print("#", terminator: "")
				}
				else
				{
					print(".", terminator: "")
				}
			}
			print()
		}
		print()
	}
	
	// The trick is that it HAS to repeat.
	// There are 5 shapes running on the same track (10091 is a prime, so is 5)
	// so it'll repeat each 10091 x 5 times.
	//
	// The first 5 runs will collide with the floor.  Let's ignore that one.
	// The next 5 will enter repeat mode.  To avoid repetition the placement
	// would have to collide with each other all the time - difficult but not
	// impossible.
	
	var Pt1Index = -1
	var CntAtPt1 = 0
	
	var Pt2Index = -1
	var CntAtPt2 = 0
	
	// Then, we have a remainder - we have /10091, but 1000000000000 is not a
	// multiple of this value.
	var Pt3Index = -1
	var CntAtPt3 = 0
	
	var LastCnt = 0
	
	// Cache stride, and then note the distance + I + Playfield count
	var Repeat = Dictionary<Int,(Int,Int,Int)>()
	
	for I in 0..<Iterations
	{
		if I % (Lines.count * Rocks.count) == 0 && I != 0 && Pt3Index == -1
		{
			let Cur = (I, PlayField.count, PlayField.count-LastCnt)
			
			if let F = Repeat[LineIndex]
			{
				if F.2 == Cur.2
				{
					// Extend execution until we have capture everything...
					Pt1Index = F.0
					Pt2Index = Cur.0
					Pt3Index = Iterations % (Cur.0 - F.0) + I - F.0
					
					CntAtPt1 = F.1
					CntAtPt2 = Cur.1
				}
				else
				{
					print("#")
					Repeat[LineIndex] = Cur
				}
			}
			else
			{
				print(">", terminator: "")
				Repeat[LineIndex] = Cur
			}
			
			//print(I, PlayField.count, PlayField.count-LastCnt, LineIndex)
			LastCnt = PlayField.count
		}
		
		if I == Pt3Index { CntAtPt3 = PlayField.count; break }
		
		var CurRock = Rocks[I % Rocks.count]
		var CurY = 0
		
		AddEmptyLines(3)
		//ShowPlayField()
		AddEmptyLines(CurRock.count)
		
		let WriteRock = {
			(DoShow:Bool) in
			var OY = CurY
			for L in CurRock
			{
				if (DoShow)
				{
					PlayField[OY] = PlayField[OY] | L
				}
				else
				{
					PlayField[OY] = PlayField[OY] & ~L
				}
				OY += 1
			}
		}
		
		while (true)
		{
			let TryPlace = {
				(Dx:Int, Dy:Int) -> Bool in
				
				// We could have a stencil / shadow that moves to avoid the loops.
				var RC = CurRock
				if (Dx > 0)
				{
					RC = CurRock.map( { $0 >> 1 } )
					
					for R in RC
					{
						if 0 != (R & 0x1) { return false }
					}
				}
				if (Dx < 0)
				{
					RC = CurRock.map( { $0 << 1 })
					
					for R in RC
					{
						let Compare = 1 << 8
						let Remaining = Compare & R
						if 0 != (Remaining) {return false}
					}
				}
				
				let NY = CurY + Dy
				
				var OY = NY
				for L in RC
				{
					if L & PlayField[OY] != 0 { return false }
					
					OY += 1
				}
				return true
			}
			
			let Dir = Read()
			if (Dir == 0)
			{
				print("ERROR")
			}
			if (!TryPlace(0,0))
			{
				print("ERROR!")
			}
			
			if (TryPlace(Dir, 0))
			{
				if Dir > 0	{ CurRock = CurRock.map({$0 >> 1}) }
				if Dir < 0  { CurRock = CurRock.map({ $0 << 1})}
				
				//WriteRock(true)
				//ShowPlayField()
				//WriteRock(false)
			}
			
			if (TryPlace(0, 1))
			{
				CurY += 1
				
				//WriteRock(true)
				//ShowPlayField()
				//WriteRock(false)
			}
			else
			{
				break
			}
		}
		
		WriteRock(true)
		
		while PlayField[0] == 0
		{
			_ = PlayField.popFirst()
		}
	}
	
	//ShowPlayField()
	
	print()
	print( "\(File) @ \(Iterations) / \(Lines.count)= ")
	
	if (CntAtPt3 == 0)
	{
		// Iterations ended prior to pattern
		print(" \t \(PlayField.count-1)")
	}
	else
	{
		let Rep = Iterations / (Pt2Index - Pt1Index)
		print( "\t \(Pt1Index), \(Pt2Index), \(Pt3Index)")
		print( "\t \(CntAtPt1), \(CntAtPt2), \(CntAtPt3)")
		print( "\t \(Rep) -> \(Pt1Index + Rep*(Pt2Index-Pt1Index) + Pt3Index-Pt2Index) -> \(CntAtPt1 + Rep * (CntAtPt2-CntAtPt1) + CntAtPt3 - CntAtPt2 - 1)")
	}
}

func Day17() throws
{
	
	try Day17("Day17-Sample", Iterations: 2022)
	try Day17("Day17-1", Iterations: 2022) // 3159 was perfect...
	
	try Day17("Day17-Sample", Iterations: 1000000000000)
	try Day17("Day17-1", Iterations: 1000000000000)
}
