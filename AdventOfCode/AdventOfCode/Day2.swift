//
//  Day2.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-02.
//

import Foundation

enum RockAction
{
	case Rock
	case Paper
	case Scissors
	case Nil
}

typealias RockPaperScissor = (RockAction, RockAction)

func RockPaperTransform(_ Src:Substring) -> RockPaperScissor
{
	let Theirs = ["A":RockAction.Rock,"B":RockAction.Paper, "C":RockAction.Scissors]
	let Mine = ["X":RockAction.Rock,"Y":RockAction.Paper, "Z":RockAction.Scissors]
	
	let Parts = Src.split(separator: " ")
	if (Parts.count == 2) {
		let TheirPlay = Parts[0];
		let MyPlay = Parts[1];
		
		let TheirAction = Theirs[String(TheirPlay)] ?? RockAction.Nil;
		let MyAction = Mine[String(MyPlay)] ?? RockAction.Nil;
		
		return RockPaperScissor(TheirAction, MyAction)
	}
	
	return RockPaperScissor(RockAction.Nil, RockAction.Nil)
}

func Score(player:RockAction, other:RockAction) -> Int
{
	if (player == RockAction.Nil || other == RockAction.Nil)
	{
		return 0
	}
	
	let ActionScore = [RockAction.Rock:1, RockAction.Paper:2, RockAction.Scissors:3]
	let WinSets = [RockAction.Rock:RockAction.Scissors,
				   RockAction.Scissors:RockAction.Paper,
				   RockAction.Paper:RockAction.Rock]
	
	let BaseScore = ActionScore[player] ?? 0;
	
	let TieScore = (player == other) ? 3 : 0;
	
	let WinScore = (WinSets[player] ?? RockAction.Nil) == other ? 6 : 0;
	
	return BaseScore + TieScore + WinScore;
}

func Day2() throws
{
	let EachLine = try?ReadFile("Day2-1")
	
	if let ValidLines = EachLine
	{
		let Actions = ValidLines.map{ RockPaperTransform($0) }
		
		let SumScores = Actions.reduce(0, { $0 + Score(player:$1.1, other:$1.0)});
		
		print(SumScores)
	}
}
