#! python3
# upload-perf
# Copyright 2019 David Adam <zanchey@ucc.gu.uwa.edu.au>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

import sys, os, sqlite3

if __name__ == "__main__":
    db = sqlite3.connect('fishperf.sqlite3')

    hostname = os.uname().nodename
    this_sha = sys.argv[1]
    previous_sha = sys.argv[2]

    current_test = ""
    k, v, u = "", "", ""

    # Example input:
    # external_cmds.fish
    #   rusage self:
    #       user time: 140 ms
    #        sys time: 312 ms
    #        max rss: 6292 kb
    #        signals: 0

    for line in sys.stdin.readlines():
        # Non-indented lines start each test name
        if not line[0] == " ":
            current_test = line[:-1]
        elif line.rstrip()[-1] == ":":
            # Drop the "rusage self:" line
            pass
        else:
            l = line.strip()
            k, out = l.split(":")
            out = out.strip()
            if " " in out:
                v, u = out.split(" ")
            else:
                v, u = out, ""
            db.execute("""INSERT INTO fishperf (
                    hostname,
                    this_sha,
                    previous_sha,
                    testname,
                    key,
                    value,
                    unit
                ) VALUES (?, ?, ?, ?, ?, ?, ?)""",
                (hostname, this_sha, previous_sha, current_test, k, v, u))
    
    db.commit()
