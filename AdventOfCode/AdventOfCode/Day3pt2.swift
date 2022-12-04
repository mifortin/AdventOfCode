//
//  Day3.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-02.
//

import Foundation

func Day3Pt2() throws
{
	let EachLine = try ReadFile("Day3-1")
	
	var Sum = 0
	try EachLine.For3(
	{
		let Set1 = Set($0)
		let Set2 = Set($1)
		let Set3 = Set($2)
		
		print (Set1)
		print (Set2)
		print (Set3)
		
		let Intersect1 = Set1.intersection(Set2)
		let Intersect2 = Intersect1.intersection(Set3)
		
		if (Intersect2.count != 1)
		{
			throw Day3Errors.BadInput
		}
		
		for Badge in Intersect2
		{
			print("   > ", Badge, try Day3Char2Score(Badge))
			Sum += try Day3Char2Score(Badge)
		}
	})
	
	print (Sum)
}
