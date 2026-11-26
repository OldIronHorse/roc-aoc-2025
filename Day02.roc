import parser.Parser
import cli.File
import cli.Path
import cli.Stdout
import Assert

Day02 := {}.{
    run! = || {
        total = (ranges).parse_str(File.open_reader!("day02.txt")?.read_line!()?)?
            .join_map(|{ max, min }| invalid_ids_in(min, max))
            .sum()
        Stdout.line!("Day 02, part 1: ${total.to_str()}")
    }
}

is_invalid_id : U64 -> Bool
is_invalid_id = |id| {
    cs = id.to_str()
        .to_utf8()
    { before, others } = cs.split_at(cs.len() / 2)
    before == others
}

invalid_ids_in : U64, U64 -> List(U64)
invalid_ids_in = |min, max|
    (min..=max).iter()
        .keep_if(is_invalid_id)
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

expect Assert.equal(True, is_invalid_id(11))
expect Assert.equal(False,is_invalid_id(111))
expect Assert.equal(True, is_invalid_id(123123))

expect Assert.equal([11, 22], invalid_ids_in(11, 22))

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
            .join_map(|{ max, min }| invalid_ids_in(min, max))
            .sum()
    )
}
