//
//  Day11.swift
//  AdventOfCode
//
//  Created by Michael Fortin on 2022-12-10.
//

import Foundation

struct Day11Game
{
	let Name:Int64
	let Items:Array<Int64>
	let Op:((Int64)->Int64)
	let Test:((Int64)->Bool)
	let Pass:Int64
	let Fail:Int64
	let Inspect:Int64
}


func Day11BuildGame( _ Input : ArraySlice<Substring>) -> [Day11Game]
{
	if (Input.count == 0)
	{
		return []
	}
	else
	{
		let DestMonkey = { (S:Substring) -> Int64 in
			let ThrowToMonkey = /throw to monkey (?<Monkey>([0-9])+)/
			let RE = S.matches(of: ThrowToMonkey)
			if RE.count == 1
			{
				return Int64(String(RE[0].Monkey))!
			}
			print("Bad input \(S)")
			return 0
		};
		
		let NameOfMonkey = { (S:Substring) -> Int64 in
			let NameEx = /Monkey (?<Monkey>([0-9])+)/
			let RE = S.matches(of: NameEx)
			if RE.count == 1
			{
				return Int64(String(RE[0].Monkey))!
			}
			print("Bad input \(S)")
			return 0
		};
		
		let GetItems = { (S:Substring) -> [Int64] in
			let ItemId = /(?<Item>[0-9]+)/
			let RE = S.matches(of: ItemId)
			return RE.map( {Int64(String($0.Item))!} )
		}
		
		let GetOp = { (S:Substring) -> (Int64) -> Int64 in
			let OpEx = /new \= (?<A>(.*)) (?<OP>[\+\*]) (?<B>(.*))/
			let RE = S.matches(of: OpEx)
			if RE.count == 1
			{
				let RA = String(RE[0].A)
				let RB = String(RE[0].B)
				let ROP = String(RE[0].OP)
				return {
					let V1 = (RA == "old") ? $0 : Int64(RA)!
					let V2 = (RB == "old") ? $0 : Int64(RB)!
					let Op = ROP
					
					if (Op == "+")
					{
						//print(" > \(V1+V2) -- \(RA)=\(V1) \(Op) \(RB)=\(V2)")
						return V1+V2
					}
					if (Op == "*")
					{
						//print(" > \(V1*V2) -- \(RA)=\(V1) \(Op) \(RB)=\(V2)")
						return V1*V2
					}
					print("Error with: \(RA)=\(V1) \(Op) \(RB)=\(V2)")
					return V1
				}
			}
			print("Bad Input \(S)")
			return { return $0 }
		}
		
		let GetTest = { (S:Substring) -> (Int64) -> Bool in
			let TestEx = /divisible by (?<Divisor>[0-9]+)/
			let RE = S.matches(of: TestEx)
			if RE.count == 1
			{
				let Divisor = Int64(String(RE[0].Divisor))!
				return {
					let Result = ($0 % Divisor) == 0
					//print( "  -- \($0) / \(Divisor) is Divisible \(Result)")
					return Result
				}
			}
			print("Bad Input \(S)")
			return { return $0 == 0 }
		}
		
		let I = Input.startIndex
		
		let New = [
			Day11Game(
				   Name: NameOfMonkey(Input[I]),
				   Items: GetItems(Input[I+1]),
				   Op: GetOp(Input[I+2]),
				   Test: GetTest(Input[I+3]),
				   Pass: DestMonkey(Input[I+4]),
				   Fail: DestMonkey(Input[I+5]),
				   Inspect: 0
				   )
		   ]
		let Next = Day11BuildGame(Input[(I+6)...])
			
		return New + Next
	}
}


func Day11PassItems(_ Game:[Day11Game], Targets:ArraySlice<Int64>, Items:ArraySlice<Int64>) -> [Day11Game]
{
	if (Targets.count == 0)
	{
		return Game
	}
	
	let I = Targets.startIndex
	let UpdatedGame = Game.map( {
		if $0.Name == Targets[I]
		{
			return Day11Game(
				Name: $0.Name,
				Items: $0.Items + [Items[I]],
				Op: $0.Op,
				Test: $0.Test,
				Pass: $0.Pass,
				Fail: $0.Fail,
				Inspect: $0.Inspect
			)
		}
		return $0
	})
	
	return Day11PassItems(UpdatedGame, Targets:Targets[(I+1)...], Items: Items[(I+1)...])
}


func Day11Round(_ Game:[Day11Game], WorryReduce:Int64, Divisor:Int64, Monkey:Int=0) -> [Day11Game]
{
	if Monkey >= Game.count
	{
		return Game
	}
	else
	{
		let C = Game[Monkey]
		//print("MONKEY \(Monkey) \(C.Items)")
		let UpdatedWorry = C.Items.map(C.Op)
		let ReducedWorry = UpdatedWorry.map( { return ($0 / WorryReduce) % Divisor })
		let PassFail = ReducedWorry.map(C.Test)
		let Targets = PassFail.map({ return $0 ? C.Pass : C.Fail })
		
		let ClearedGame = Game.map( {
			if ($0.Name == Monkey)
			{
				return Day11Game(
					Name: $0.Name,
					Items: [],
					Op: $0.Op,
					Test: $0.Test,
					Pass: $0.Pass,
					Fail: $0.Fail,
					Inspect: $0.Inspect + Int64($0.Items.count))
			}
			return $0
		})
		
		let UpdatedGame = Day11PassItems(ClearedGame, Targets: ArraySlice(Targets), Items:ArraySlice(ReducedWorry))

		
		return Day11Round(UpdatedGame, WorryReduce: WorryReduce, Divisor: Divisor, Monkey:Monkey+1)
	}
}


func Simulate(Game:[Day11Game], Prefix:String, Iterations:Int, WorryDiv:Int64, Divisor:Int64)
{
	let Game = (0, Game)
	
	print(Game)
	let Rounds = Array.init(repeating: Game, count: Iterations)
	let Total = Rounds.reduce(Game, { (PartialResult:(Int,[Day11Game]), Next:(Int,[Day11Game])) -> (Int, [Day11Game]) in
		if (PartialResult.0 % 1000 == 0)
		{
			print()
			print("ROUND \(PartialResult.0)")
			for  R in PartialResult.1
			{
				print(" > Monkey \(R.Name) has \(R.Items) inspected \(R.Inspect)")
			}
			print()
		}
		return (PartialResult.0+1, Day11Round(PartialResult.1,WorryReduce:WorryDiv,Divisor:Divisor))
	})
	
	print("ROUND \(Total.0)")
	for  R in Total.1
	{
		print(" > Monkey \(R.Name) has \(R.Items) inspected \(R.Inspect)")
	}
	
	let OrderedTotal = Total.1.sorted(by: {return $0.Inspect > $1.Inspect } )
	print("\(Prefix)> \(OrderedTotal[0].Inspect * OrderedTotal[1].Inspect)")
}


func Day11() throws
{
	let Lines = try ReadFile("Day11-1").filter({ $0 != "" })
	
	let Divisor:Int64 = Lines.filter( {$0.contains("divisible by")} )
		.reduce(1,{
			let TestEx = /divisible by (?<Divisor>[0-9]+)/
			if let Found = $1.firstMatch(of: TestEx) {
				return $0 * Int64(String(Found.Divisor))!
			}
			return $0
		})
	
	let Game = Day11BuildGame(ArraySlice(Lines))
	Simulate(Game: Game, Prefix: "Day11 pt 1", Iterations: 20, WorryDiv: 3, Divisor: Divisor*3)
	Simulate(Game: Game, Prefix: "Day11 pt 2", Iterations: 10000, WorryDiv: 1, Divisor: Divisor)
}
