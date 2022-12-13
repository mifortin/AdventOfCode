//
//  Day13.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-12.
//

import Foundation


enum Day13Result
{
	case Further
	case Right
	case OutOfOrder
	case Error
}


indirect enum Day13Data
{
	case Numb(Int)
	case List([Day13Data])
	case Nul
	case Error(Character)
}


extension Day13Data : CustomStringConvertible
{
	var description: String
	{
		var Ret = ""
		switch(self)
		{
			
		case .Numb(let N):
			Ret += "\(N)"
		case .List(let L):
			Ret += "["
			for E in L {
				Ret += " \(E) "
			}
			Ret += "]"
		case .Nul:
			Ret += " NULL "
		case .Error(let C):
			Ret += " ERROR \(C) "
		}
		
		return Ret
	}
}


func Day13Parse(_ A:Substring) -> (Substring, Day13Data)
{
	// Corner case...
	if A.count == 0 { return ( A, Day13Data.Nul ) }
	
	let I = A.startIndex
	let FirstChar = A[I]
	
	if (FirstChar == "[")
	{
		var L:Array<Day13Data> = []
		
		var B = A[A.index(I, offsetBy: 1)...]
		while (B[B.startIndex] != "]")
		{
			let R = Day13Parse(B)
			
			B = R.0
			L.append(R.1)
			
			if (B[B.startIndex] == ",")
			{
				B = B[B.index(B.startIndex, offsetBy: 1)...]
			}
		}
		
		// Remove the trailing ]
		B = B[B.index(B.startIndex, offsetBy: 1)...]
		
		return (B, Day13Data.List(L))
	}
	
	if (FirstChar.isNumber)
	{
		let Zero = Int(Character("0").asciiValue!)
		var Number = Int(FirstChar.asciiValue!) - Zero
		
		var B = A[A.index(I, offsetBy: 1)...]
		while (B[B.startIndex].isNumber)
		{
			let BI = B.startIndex
			Number = Number * 10 + (Int(B[BI].asciiValue!) - Zero)
			
			B = B[B.index(BI, offsetBy: 1)...]
		}
		
		return (B, Day13Data.Numb(Number))
	}
	
	// Shouldn't happen
	return (A[A.index(I, offsetBy: 1)...], Day13Data.Error(FirstChar))
}

var D13Indent = 0

func Day13Compare(_ A:Day13Data, _ B:Day13Data) -> Day13Result
{
	let Indent = String.init(repeating: "  ", count: D13Indent)
	print ("\(Indent) - Compare \(A) vs \(B)")
	switch (A)
	{
	case .Numb(let ANumb):
		switch(B)
		{
		case .Numb(let BNumb):
			if (ANumb == BNumb){ return Day13Result.Further}
			if (ANumb < BNumb)
			{
				print("\(Indent)   - Left side is smaller, so inputs are in the right order")
				return Day13Result.Right
			}
			print("\(Indent)   - Right side is smaller, so inputs are NOT in the right order")
			return Day13Result.OutOfOrder
			
		case .List(_):
			let A2 = Day13Data.List([A])
			print("\(Indent)   - Mixed types; convert left to \(A2) and retry comparison")
			return Day13Compare(A2, B)
			
		default:
			print("\(Indent)   ERROR")
			return Day13Result.Error
		}
	
	case .List(let LA):
		switch(B)
		{
		case .Numb(_):
			let B2 = Day13Data.List([B])
			print("\(Indent)   - Mixed types; convert right to \(B2) and retry comparison")
			return Day13Compare(A, B2)
			
		case .List(let LB):
			D13Indent += 1
			
			let MinSize = min(LA.count, LB.count)
			for I in 0..<MinSize
			{
				let R = Day13Compare(LA[I], LB[I])
				
				if R != .Further
				{
					D13Indent -= 1
					return R;
				}
			}
			
			D13Indent -= 1
			
			if LA.count == LB.count
			{
				return Day13Result.Further
			}
			if LA.count < LB.count
			{
				print("\(Indent)   - Left side ran out of items, so inputs are in the right order")
				return Day13Result.Right
			}
			print("\(Indent)   - Right side ran out of items, so inputs are NOT in the right order")
			
			return Day13Result.OutOfOrder
			
		default:
			print("\(Indent)  ERROR")
			return Day13Result.Error
		}
	
	default:
		print("\(Indent)   ERROR")
		return Day13Result.Error
	}
}


func Day13() throws
{
	let Lines = try ReadFile("Day13-1")
	var Cnt = 1
	var Day1Cnt = 0
	try Lines.For3 { A, B, _ in
		let ADat = Day13Parse(A).1
		let BDat = Day13Parse(B).1
		print ("== Pair \(Cnt) ==")
		print()
		
		let Res = Day13Compare(ADat, BDat)
		if Res == .Right
		{
			Day1Cnt += Cnt
		}
		
		Cnt += 1
	}
	
	let Key1 = Day13Data.List([Day13Data.List([Day13Data.Numb(2)])]);
	let Key2 = Day13Data.List([Day13Data.List([Day13Data.Numb(6)])]);
	var Packets = Lines.filter( {$0 != ""}).map( {Day13Parse($0).1})
	Packets.append(Key1)
	Packets.append(Key2)
	Packets.sort(by: { return Day13Compare($0, $1) == .Right })
	
	let I1 = Packets.firstIndex(where: { return Day13Compare($0, Key1) != .Right })! + 1
	let I2 = Packets.firstIndex(where: { return Day13Compare($0, Key2) != .Right})! + 1
	
	for P in Packets
	{
		print(P)
	}
	
	
	print ("Day 1 Sum of Indices: \(Day1Cnt)")
	print ("Day 2 \(I1) x \(I2) = \(I1 * I2)")
}
