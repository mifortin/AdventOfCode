//
//  Day1.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-01.
//

import Foundation

func Day1() throws
{
	let EachLine = try?ReadFile("Day1-1")
	
	var TotalCalories = 0;

	var CaloryCounter = Array<Int>();
	if let ValidInput = EachLine {
		for Line in ValidInput
		{
			if Line.isEmpty
			{
				CaloryCounter.append(TotalCalories);
				TotalCalories = 0
			}
			else
			{
				let CaloryItem = Int(Line)
				if let ValidCalory = CaloryItem
				{
					TotalCalories += ValidCalory
				}
			}
		}
		CaloryCounter.append(TotalCalories);
		let Ordered = CaloryCounter.sorted(by: { $0 > $1});
		print(Ordered[0] + Ordered[1] + Ordered[2])
	}
}
