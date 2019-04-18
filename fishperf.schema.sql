-- fishperf.schema.sql
-- Copyright 2019 David Adam <zanchey@ucc.gu.uwa.edu.au>
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.

CREATE TABLE fishperf (
    hostname,
    timestamp DEFAULT CURRENT_TIMESTAMP,
    this_sha,
    previous_sha,
    testname,
    key,
    value,
    unit
);