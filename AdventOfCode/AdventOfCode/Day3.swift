//
//  Day3.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-02.
//

import Foundation

enum Day3Errors : Error
{
	case OddLines
	case DiffLens
	case BadInput
}

func Day3Char2Score(_ C:Character) throws -> Int
{
	if (C >= "a" && C <= "z")
	{
		return Int(C.asciiValue! - "a".first!.asciiValue!) + 1
	}
	else if (C >= "A" && C <= "Z")
	{
		return Int(C.asciiValue! - "A".first!.asciiValue!) + 27
	}
	
	throw Day3Errors.BadInput
}

func Day3Score(_ A: ArraySlice<Character>, _ B: ArraySlice<Character>) throws ->Int
{
	if (A.count == 0 || B.count == 0)
	{
		return 0
	}
	
	let NextA = A.index(A.startIndex, offsetBy: 1)
	let NextB = B.index(B.startIndex, offsetBy: 1)
	
	if (A.first! == B.first!)
	{
		let Score = try Day3Char2Score(A.first!)
		print (" >", A.first!, Score)
		return Score + (try Day3Score(A[NextA...], B[NextB...]))
	}
	else if (A.first! < B.first!)
	{
		return (try Day3Score(A[NextA...], B));
	}
	else
	{
		return (try Day3Score(A, B[NextB...]));
	}
}

func Day3() throws
{
	let EachLine = try?ReadFile("Day3-1")
	
	var Sum = 0
	if let ValidLines = EachLine
	{
		for Line in ValidLines
		{
			let Length = Line.count;
			
			if (Length == 0)
			{
				continue
			}
			
			if (Length % 2) != 0
			{
				throw Day3Errors.OddLines
			}
			
			let Half = Line.index(Line.startIndex, offsetBy: Length/2)
			
			let FirstHalf = Line[..<Half]
			let SecondHalf = Line[Half...]
			
			if (FirstHalf.count != SecondHalf.count)
			{
				throw Day3Errors.DiffLens
			}
			
			let SortedFirst = FirstHalf.sorted();
			let SortedSecond = SecondHalf.sorted();
			
			let SetFirst = Set(SortedFirst)
			let SetSecond = Set(SortedSecond)
			
			print(Line)
			print(SetFirst)
			print(SetSecond)
			
			let Intersect = SetFirst.intersection(SetSecond)
			
			if (Intersect.count != 1)
			{
				throw Day3Errors.BadInput
			}
			
			for Item in Intersect
			{
				print(" >", Item, try Day3Char2Score(Item))
				Sum += try Day3Char2Score(Item)
			}
			//let Score = try Day3Score(ArraySlice(SortedFirst), ArraySlice(SortedSecond))
			//print (Score)
		}
	}
	
	print (Sum)
}
