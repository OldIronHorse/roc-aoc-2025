# SPDX-License-Identifier: UPL-1.0
# Copyright (c) 2026 Simon Redding
    
## Generate static websites from markdwon
##
app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.28.1/7brgwR8YUqfeGrkdfF1V4GPPN7DnP7ftqub9KcrTEZtr.tar.zst",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/6.0.0/7j67bdgEMRsua6VnhcYASXRymN5pYgUC9qV4bHFupbf9.tar.zst",
}

import cli.Stdout
import cli.Stderr
import cli.OsStr
import cli.Path
import cli.IOErr
import Day01

main! = |_args| {
    Day01.run!()
}
