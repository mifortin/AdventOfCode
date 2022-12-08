//
//  Day8.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-07.
//

import Foundation


func Day8() throws
{
	let Lines = try ReadFile("Day8-1").filter({ $0 != "" })
	
	var Visible = Lines.map {
		$0.map { _ in
			return 0
		}
	}
	
	var Scenic = Lines.map {
		$0.map { _ in
			return 1
		}
	}
	
	let Height = Lines.map {
		$0.map( {
			return Int(String($0))!
		})
	}
	
	let width = Lines.count-1
	let height = Lines[0].count-1
	
	let Directions = [(0,-1), (-1,0), (0,1), (1,0)]
	for x in 0...width
	{
		for y in 0...height
		{
			let CurHeight = Height[x][y];
			for d in Directions
			{
				var dx = x
				var dy = y
				var scene = 0
				while true {
					dx += d.0
					dy += d.1
					
					if dx >= 0 && dy >= 0 && dx <= width && dy <= height
					{
						scene += 1
						
						if Height[dx][dy] >= CurHeight
						{
							break
						}
					}
					
					if (dx <= 0 || dy <= 0 || dx >= width || dy >= height)
					{
						Visible[x][y] = 1
						break
					}
				}
				
				Scenic[x][y] *= scene
			}
		}
	}
	
	//print(Height)
	//print(Visible)
	//print(Scenic)
	
	let Sum = Visible.reduce(0, { $0 + $1.reduce(0,+) })
	print("Day 8, Pt 1> \(Sum)")
	
	let Max = Scenic.reduce(0, {max($0, $1.reduce(0, max))})
	print("Day 8, pt2 > \(Max)")
}

