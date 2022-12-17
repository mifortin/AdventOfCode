//
//  Day17.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-17.
//

import Foundation
import DequeModule

func Day17(_ File:String, Iterations:Int, Width:Int) throws
{
	let Lines = try ReadFile(File).joined().map( {
		if $0 == ">" { return 1 }
		if $0 == "<" { return -1 }
		print("BAD INPUT \($0)")
		return 0
	})
	
	let MaxHeight = Iterations * 3		// Good enough estimate
	
	let Rocks:[[[Int]]] = [
		[	"####"	],
		
		[	".#.",
			"###",
			".#."	],
		
		[	"..#",
			"..#",
			"###"	],
		
		[	"#","#","#","#" ],
		
		[	"##", "##"	]
	].map( { $0.map( { $0.map( { $0 == "#" ? 1 : 0} ) } ) } )
	
	let EmptyRow = Array(repeating: 0, count: Width)
	var Level = Array(repeating: EmptyRow, count: MaxHeight)
	
	var StartRow = Level.count
	let StartColumn = 2
	var CurInput = 0
	
	let Intersects = {
		(R:[[Int]], L:Int, B:Int) -> Bool in
		
		for Y in 0..<R.count
		{
			for X in 0..<R[0].count
			{
				if Level[B-Y][L+X] != 0
				{
					if R[R.count - Y - 1][X] != 0
					{
						return true;
					}
				}
			}
		}
		
		return false
	}
	
	for I in 0..<Iterations
	{
		let R = Rocks[I % Rocks.count]
		
		var Height = StartRow-4	// From bottom
		var Left = StartColumn	// From left
		
		let DebugDisplay = {
			if (false)
			{
				for Y in 0..<R.count
				{
					for X in 0..<R[0].count
					{
						if R[R.count - Y - 1][X] != 0
						{
							if Level[Height-Y][Left+X] == 0
							{
								Level[Height-Y][Left+X] = I + 1
							}
							else
							{
								print("COPY ERROR")
							}
						}
					}
				}
				
				print()
				print("== \(I) ==")
				for X in Level[(Height-R.count+1)...]
				{
					print(X.map( { $0 == 0 ? "." : String($0 % 10) } ) .joined())
					
				}
				for Y in 0..<R.count
				{
					for X in 0..<R[0].count
					{
						if R[R.count - Y - 1][X] != 0
						{
							if Level[Height-Y][Left+X] == I + 1
							{
								Level[Height-Y][Left+X] = 0
							}
							else
							{
								print("COPY ERROR")
							}
						}
					}
				}
			}
		}
		DebugDisplay();
		
		while(true)
		{
			let NextOp = Lines[CurInput % Lines.count]
			CurInput += 1
			
			if (Left + NextOp >= 0 && Left + NextOp + R[0].count <= Width)
			{
				if !Intersects(R, Left+NextOp, Height)
				{
					Left += NextOp
					DebugDisplay()
				}
			}
			
			if Height + 1 == Level.count
			{
				break
			}
			if !Intersects(R, Left, Height+1)
			{
				Height += 1
				DebugDisplay()
			}
			else
			{
				break
			}
		}
		
		for Y in 0..<R.count
		{
			for X in 0..<R[0].count
			{
				if R[R.count - Y - 1][X] != 0
				{
					if Level[Height-Y][Left+X] == 0
					{
						Level[Height-Y][Left+X] = I + 1
					}
					else
					{
						print("COPY ERROR")
					}
				}
			}
		}
		
		StartRow = min(StartRow, Height - R.count + 1)
	}
	
	print(Level.count - StartRow)
}

func Day17() throws
{
	
	try Day17("Day17-Sample", Iterations:2022, Width:7)
	//try Day17("Day17-Test")
	try Day17("Day17-1", Iterations: 2022, Width: 7) // 3159 too high
}
