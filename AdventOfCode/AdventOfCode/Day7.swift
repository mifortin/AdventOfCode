//
//  Day7.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-06.
//

import Foundation

var Day7Indent = 0

class Day7File : Hashable, Equatable, CustomStringConvertible {
	static func == (lhs: Day7File, rhs: Day7File) -> Bool {
		return lhs.Name == rhs.Name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(Name)
	}
	
	public var description: String
	{
		let S = String(repeating: " ", count: Day7Indent*2)
		return "\(S)\(Name) \(Size)\n"
	}
	
	var Name:Substring = ""
	var Size:Int = 0
}

class Day7Dir : Hashable, Equatable, CustomStringConvertible {
	static func == (lhs: Day7Dir, rhs: Day7Dir) -> Bool {
		return lhs.Name == rhs.Name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(Name)
	}
	
	public var description: String
	{
		var Out = ""
		
		let S = String(repeating: " ", count: Day7Indent*2)
		
		Out += "\(S)\(Name) \(Size)\n"
		Day7Indent+=1
		
		for Sub in SubDir
		{
			Out += Sub.description
		}
		
		for File in Files
		{
			Out += File.description
		}
		
		Day7Indent-=1
		return Out
	}
	
	var Name:Substring = ""
	var SubDir:Set<Day7Dir> = []
	var Files:Set<Day7File> = []
	var Size:Int = 0
}


enum Day7Error : Error
{
	case BadInput(Substring)
}

func Day7() throws
{
	let Lines = try ReadFile("Day7-1")
	
	let NonEmpty = Lines.filter { return $0 != "" }
	
	var CurDir = Day7Dir()
	CurDir.Name = "/"
	
	var DirParse = [CurDir]
	
	var AllDirs = [CurDir]
	
	for Line in NonEmpty {
		let CmdCd = /\$ cd (?<path>.*)/
		let CmdLs = /\$ ls/
		let CmdDir = /dir (?<name>.*)/
		let CmdFile = /(?<length>\d+) (?<name>.*)/
		
		if let Match = Line.wholeMatch(of: CmdCd)
		{
			if Match.path == "/" {
				
			}
			else if Match.path == ".." {
				_ = DirParse.popLast()
				CurDir = DirParse.last!
			}
			else {
				let newDir = Day7Dir()
				newDir.Name = Match.path
				if !CurDir.SubDir.contains(newDir)
				{
					CurDir.SubDir.insert(newDir)
					AllDirs.append(newDir)
				}
				CurDir = CurDir.SubDir.first(where: { return $0.Name == Match.path })!
				DirParse.append(CurDir)
			}
		}
		else if let _ = Line.wholeMatch(of: CmdLs)
		{
			// Unused - do nothing
		}
		else if let Match = Line.wholeMatch(of: CmdFile)
		{
			let NewFile = Day7File()
			NewFile.Name = Match.name
			NewFile.Size = Int(Match.length)!
			
			if !CurDir.Files.contains(NewFile)
			{
				CurDir.Files.insert(NewFile)
				
				for Dirs in DirParse {
					Dirs.Size += NewFile.Size
				}
			}
		}
		else if let Match = Line.wholeMatch(of: CmdDir)
		{
			let newDir = Day7Dir()
			newDir.Name = Match.name
			if !CurDir.SubDir.contains(newDir)
			{
				CurDir.SubDir.insert(newDir)
				AllDirs.append(newDir)
			}
		}
		else
		{
			throw Day7Error.BadInput(Line)
		}
	}
	
	print(DirParse[0])
	
	let TotalSpace = 70000000
	let ForUpdate = 30000000
	let UsedSpace = DirParse[0].Size
	let FreeSpace = TotalSpace - UsedSpace
	let NeededSpace = ForUpdate - FreeSpace
	
	print ("Need \(NeededSpace)")
	
	print()
	
	var Sum = 0
	for Dir in AllDirs
	{
		if Dir.Size <= 100000
		{
			Sum += Dir.Size
		}
	}
	print("Pt1> \(Sum)")
	
	var SmallestDir = TotalSpace
	for Dir in AllDirs
	{
		if Dir.Size >= NeededSpace && SmallestDir > Dir.Size
		{
			SmallestDir = Dir.Size
		}
	}
	print("Pt2> \(SmallestDir)")
}
