import cli.File
import cli.Stdout
import parser.Parser
import Assert

Day03 := {}.{
    run! = || {
        battery_banks : List(List(U64))
        battery_banks = File.open_reader!("day03.txt")?
            .lines()
            .collect!()
            .map_try(|line| (battery_bank).parse_str(line?))?
        total1 = battery_banks.map(max_joltage_from).sum()
        _ = Stdout.line!("Day 03, part 1, total: ${total1.to_str()}")
        Ok({})
    }
}

max_joltage_from = |batteries| {
    b1 = batteries.drop_last(1).max().ok_or(0)
    b1_index = batteries.find_first_index(|b| b == b1).ok_or(0)
    { before: _, others } = batteries.split_at(b1_index + 1)
    b2 = others.max().ok_or(0)
    (b1 * 10) + b2
}

battery = Parser.Utf8.digit({})
battery_bank = Parser.one_or_more(battery)

expect Assert.equal(98, max_joltage_from([9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1]))
expect Assert.equal(89, max_joltage_from([8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 9]))
expect Assert.equal(78, max_joltage_from([2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8]))
expect Assert.equal(92, max_joltage_from([8, 1, 8, 1, 8, 1, 9, 1, 1 ,2, 1, 1]))

expect Assert.equal(5, (battery).parse_str("5")?)
expect Assert.equal([9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1], (battery_bank).parse_str("987654321111")?)
