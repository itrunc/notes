WITH split(word, str) AS (
    -- alternatively put your query here
    -- SELECT '', category||',' FROM categories
    SELECT '', 'A,B,C,D'||','
    UNION ALL SELECT
    substr(str, 0, instr(str, ',')),
    substr(str, instr(str, ',')+1)
    FROM split WHERE str!=''
) SELECT word FROM split WHERE word!='';
