Feature: Restore metadata from another host without s3

  Background:
    Given default configuration
    And a working s3
    And a working zookeeper on zookeeper01
    And a working clickhouse on clickhouse01
    And a working clickhouse on clickhouse02

  Scenario: Restore metadata from another host without s3
    Given we have executed queries on clickhouse01
    """
    CREATE DATABASE test_db;
    CREATE TABLE test_db.table_01 (
        EventDate DateTime,
        CounterID UInt32,
        UserID UInt32
    )
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/shard_01/test_db.table_01', '{replica}')
    PARTITION BY toYYYYMM(EventDate)
    ORDER BY (CounterID, EventDate, intHash32(UserID))
    SAMPLE BY intHash32(UserID);
    INSERT INTO test_db.table_01 SELECT now(), number, rand() FROM system.numbers LIMIT 10
    """
    When we restore clickhouse schema from clickhouse01 to clickhouse02
    Then clickhouse01 has same schema as clickhouse02
