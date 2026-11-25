import parser.Parser
import cli.File
import cli.Path
import cli.Stdout

Day01 := {}.{
    run! = || {
        zeros = File.open_reader!("day01.txt")?
            .lines()
            .collect!()
            .map_try(|l| l? |> (turn_cmd).parse_str())?
            .map(Turn.from_cmd)
            .fold({ dial: 50, zeros: 0 }, count_zeros).zeros
        _ = Stdout.line!("Day 01, part 1: ${zeros.to_str()}")
        Ok({})
    }
}

Dial : I64
Turn := [Right(I64), Left(I64)].{
    from_cmd : TurnCmd -> Turn
    from_cmd = |cmd|
        match cmd {
            { dir: Right, n } => Right(n.to_i64_wrap())
            { dir: Left, n } => Left(n.to_i64_wrap())
        }
}

rotate : Dial, Turn -> Dial
rotate = |dial, turn|
    match turn {
        Right(n) =>
            (dial + n)
                .mod_by(100)
        Left(n) =>
            (dial - n)
                .mod_by(100)
    }

Direction : [Left, Right]
TurnCmd : { dir: Direction, n: U64 }

direction : Parser(Parser.Utf8.Bytes, Direction, _)
direction =
    Parser.one_of([
        Parser.const(Left).skip(Parser.Utf8.string("L")),
        Parser.const(Right).skip(Parser.Utf8.string("R")),
    ])

turn_cmd : Parser(Parser.Utf8.Bytes, TurnCmd, _)
turn_cmd =
    Parser.const(|dir| |n| { dir, n })
        .keep(direction)
        .keep(Parser.Utf8.digits({}))

#count_zeros : { dial: Dial, zeros: U64 }, Turn
count_zeros = |{ dial, zeros }, turn| {
    new_dial = dial |> rotate(turn)
    { dial: new_dial, zeros: if new_dial == 0 (zeros + 1) else zeros }
}

expect 5 |> rotate(Right(10)) == 15
expect 20 |> rotate(Left(11)) == 9
expect 5 |> rotate(Left(10)) == 95
expect 95 |> rotate(Right(11)) == 6

expect [Right(10)].fold({ dial: 5, zeros: 0 }, count_zeros).zeros == 0
expect [
    Left(68),
    Left(30),
    Right(48),
    Left(5),
    Right(60),
    Left(55),
    Left(1),
    Left(99),
    Right(14),
    Left(82),
].fold({ dial: 50, zeros: 0 }, count_zeros).zeros == 3

expect (direction).parse_str("L") == Ok(Left)
expect (direction).parse_str("R") == Ok(Right)
expect (direction).parse_str("x").is_err()

expect (turn_cmd).parse_str("L68") == Ok({ dir: Left, n: 68 })
