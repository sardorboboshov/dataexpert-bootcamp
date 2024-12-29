CREATE TABLE host_activity_reduced (
    month DATE,
    host TEXT,
    hit_array REAL[],
    unique_visitors REAL[],
    PRIMARY KEY (host, month)
);