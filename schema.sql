BEGIN TRANSACTION;

CREATE EXTENSION btree_gist;
CREATE EXTENSION pgcrypto;

CREATE TYPE hfp_message_with_metadata AS (
    message_id uuid,
    received_at timestamptz,
    qos smallint,
    topic text,
    message jsonb
);

CREATE TABLE raw_hfp_messages (
    array_id uuid PRIMARY KEY,
    received_at_range tstzrange NOT NULL,
    unique_vehicle_id text NOT NULL,
    messages hfp_message_with_metadata ARRAY NOT NULL,
    EXCLUDE USING GIST (unique_vehicle_id WITH =, received_at_range WITH &&)
);

CREATE INDEX received_at_range_idx ON raw_hfp_messages USING GIST (received_at_range);
CREATE INDEX unique_vehicle_id_idx ON raw_hfp_messages (unique_vehicle_id);



SELECT (
    gen_random_uuid(),
    '2017-03-20T10:28:14.003092+0200',
    1,
    '/hfp/journey/train/0090_06330/3002P/1/Lentoasema/08:21/EOL/5/60;24/19/74/31',
    '{"VP":{"desi":"P","dir":"1","oper":90,"veh":6330,"tst":"2017-03-20T08:28:13Z","tsi":1489998493,"spd":0.76,"hdg":266,"lat":60.173766,"long":24.940978,"acc":0.75,"dl":1236,"odo":null,"drst":null,"oday":"2017-03-20","jrn":8648,"line":636,"start":"08:21"}}'
) :: hfp_message_with_metadata;

INSERT INTO raw_hfp_messages (
    array_id,
    received_at_range,
    unique_vehicle_id,
    messages
) VALUES (
    gen_random_uuid(),
    tstzrange(
        '2017-03-20T10:00+0200',
        '2017-03-20T11:00+0200',
        '(]'
    ),
    '0090_06330',
    ARRAY[(
        gen_random_uuid(),
        '2017-03-20T10:28:14.003092+0200',
        1,
        '/hfp/journey/train/0090_06330/3002P/1/Lentoasema/08:21/EOL/5/60;24/19/74/31',
        '{"VP":{"desi":"P","dir":"1","oper":90,"veh":6330,"tst":"2017-03-20T08:28:13Z","tsi":1489998493,"spd":0.76,"hdg":266,"lat":60.173766,"long":24.940978,"acc":0.75,"dl":1236,"odo":null,"drst":null,"oday":"2017-03-20","jrn":8648,"line":636,"start":"08:21"}}'
    ) :: hfp_message_with_metadata]
);

SELECT * FROM raw_hfp_messages;

END TRANSACTION;
