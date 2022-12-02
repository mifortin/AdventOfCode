//
//  Day1.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-01.
//

import Foundation

func Day1(_ StarBundle:Bundle) throws
{
	let Path = StarBundle.path(forResource: "Day1-1", ofType: "txt")
	if let ValidPath = Path
	{
		let Content = try?String(contentsOfFile: ValidPath);
		let EachLine = Content?.split(separator: "\n", omittingEmptySubsequences: false)
		
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
	else
	{
		throw StarHuntErrors.BadFile;
	}
}
