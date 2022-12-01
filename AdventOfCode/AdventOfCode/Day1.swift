//
//  Day1.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-01.
//

import Foundation

func Day1(_ StarBundle:Bundle) throws
{
	print("Let's a-read a-file!")
	
	let Path = StarBundle.path(forResource: "Day1-1", ofType: "txt")
	if let ValidPath = Path
	{
		let Content = try?String(contentsOfFile: ValidPath);
		let EachLine = Content?.split(separator: "\n", omittingEmptySubsequences: false)
		
		var MaxCalories = 0;
		var TotalCalories = 0;
		
		if let ValidInput = EachLine {
			for Line in ValidInput
			{
				if Line.isEmpty
				{
					MaxCalories = max(MaxCalories, TotalCalories)
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
			MaxCalories = max(MaxCalories, TotalCalories)
			print(MaxCalories)
		}
	}
	else
	{
		throw StarHuntErrors.BadFile;
	}
}
