import parser.Parser
import cli.File
import cli.Path
import cli.Stdout
import Assert

Day01 := {}.{
    run! = || {
        turns = File.open_reader!("day01.txt")?
            .lines()
            .collect!()
            .map_try(|l| l? |> (turn_cmd).parse_str())?
            .map(Turn.from_cmd)
        zero_hits = turns
            .fold({ dial: 50, zeros: 0 }, count_zeros).zeros
        _ = Stdout.line!("Day 01, part 1: ${zero_hits.to_str()}")
        zero_passes = turns
            .fold({ dial: 50, zeros: 0 }, rotate_track_zeros).zeros
        _ = Stdout.line!("Day 01, part 2: ${zero_passes.to_str()}")

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

rotate_track_zeros : { dial: Dial, zeros: I64 }, Turn -> { dial: Dial, zeros: I64 }
rotate_track_zeros = |{ dial, zeros}, turn|
    match turn {
        Right(n) => {
            d = dial + n
            {
                dial: d.mod_by(100),
                zeros: zeros + d.div_by(100)
            }
        }
        Left(n) => {
            d = dial - n
            {
                dial: d.mod_by(100),
                zeros: zeros + d.div_by(100).abs() + if d.is_zero() or (d.is_negative() and dial.is_positive()) 1 else 0,
            }
        }
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

expect { dial: 0, zeros: 0 } |> rotate_track_zeros(Right(0)) == { dial: 0, zeros: 0 }
expect { dial: 0, zeros: 1 } |> rotate_track_zeros(Left(10)) == { dial: 90, zeros: 1 }
expect { dial: 5, zeros: 0 } |> rotate_track_zeros(Right(10)) == { dial: 15, zeros: 0 }
expect { dial: 95, zeros: 0 } |> rotate_track_zeros(Right(11)) == { dial: 6, zeros: 1 }
expect { dial: 95, zeros: 0 } |> rotate_track_zeros(Right(120)) == { dial: 15, zeros: 2 }
expect { dial: 20, zeros: 0 } |> rotate_track_zeros(Left(11)) == { dial: 9, zeros: 0 }
expect { dial: 20, zeros: 0 } |> rotate_track_zeros(Left(41)) == { dial: 79, zeros: 1 }
expect Assert.equal({ dial: 79, zeros: 2 }, { dial: 20, zeros: 0 } |> rotate_track_zeros(Left(141)))
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
].fold({ dial: 50, zeros: 0 }, rotate_track_zeros).zeros == 6
