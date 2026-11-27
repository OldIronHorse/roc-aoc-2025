import parser.Parser
import cli.File
import cli.Path
import cli.Stdout
import Assert

Day02 := {}.{
    run! = || {
        rs = (ranges).parse_str(File.open_reader!("day02.txt")?.read_line!()?)?
        total = rs.join_map(|{ max, min }| invalid_ids_in(min, max, is_valid_id))
            .sum()
        _ = Stdout.line!("Day 02, part 1: ${total.to_str()}")
        total2 = rs.join_map(|{ max, min }| invalid_ids_in(min, max, is_valid_id2))
            .sum()
        _ = Stdout.line!("Day 02, part 2: ${total2.to_str()}")
        Ok({})
    }
}

is_valid_id : U64 -> Bool
is_valid_id = |id| {
    cs = id.to_str()
        .to_utf8()
    { before, others } = cs.split_at(cs.len() / 2)
    before != others
}

is_valid_id2 : U64 -> Bool
is_valid_id2 = |id| {
    cs = id.to_str()
        .to_utf8()

    do = |chunk, rest|
        if chunk.repeat(cs.len() / chunk.len()).join() == cs
            False
        else if chunk.len() >= rest.len()
            True
        else
            match rest {
                [c, .. as rest1] => do(chunk.append(c), rest1)
                [] =>  True
            }

    match cs {
        [_] => True
        [c, .. as rest] => do([c], rest)
        [] => False
    }
}

invalid_ids_in : U64, U64, (U64 -> Bool) -> List(U64)
invalid_ids_in = |min, max, validator|
    (min..=max).iter()
        .drop_if(validator)
        |> List.from_iter()

IdRange : { min: U64, max: U64 }

range : Parser(Parser.Utf8.Bytes, IdRange, _)
range =
    Parser.const(|min| |max| { min, max })
        .keep(Parser.Utf8.digits({}))
        .skip(Parser.Utf8.codeunit('-'))
        .keep(Parser.Utf8.digits({}))

ranges : Parser(Parser.Utf8.Bytes, List(IdRange), _)
ranges = range.sep_by(Parser.Utf8.codeunit(','))

# tests

expect Assert.equal(False, is_valid_id(11))
expect Assert.equal(True, is_valid_id(111))
expect Assert.equal(False, is_valid_id(123123))

expect Assert.equal([11, 22], invalid_ids_in(11, 22, is_valid_id))

expect Assert.equal({ min: 11, max: 22 }, (range).parse_str("11-22")?)
expect Assert.equal(
    [
        { min: 11, max: 22 },
        { min: 99, max: 115},
    ],
    (ranges).parse_str("11-22,99-115")?
)

expect {
    rs = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
    Assert.equal(
        1227775554,
        (ranges).parse_str(rs)?
            .join_map(|{ max, min }| invalid_ids_in(min, max, is_valid_id))
            .sum()
    )
}

expect Assert.equal(True, is_valid_id2(1))
expect Assert.equal(True, is_valid_id2(123412))
expect Assert.equal(False, is_valid_id2(11))
expect Assert.equal(False, is_valid_id2(111))
expect Assert.equal(False, is_valid_id2(121212))

expect {
    rs = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
    Assert.equal(
        4174379265,
        (ranges).parse_str(rs)?
            .join_map(|{ max, min }| invalid_ids_in(min, max, is_valid_id2))
            .sum()
    )
}
