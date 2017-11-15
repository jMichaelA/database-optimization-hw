-- 1
CREATE INDEX ON public.pitching (teamid);
CREATE INDEX ON public.pitching (yearid);
CREATE INDEX ON public.teams (teamid);
CREATE INDEX ON public.teams (yearid);


-- 3
CREATE INDEX ON public.appearances (masterid);

-- 5
SELECT
    C.yearID as year,
    name as teamName,
    C.lgID as league,
    D.cnt as totalBatters,
    C.cnt as aboveAverageBatters
FROM
    (
    -- B
    SELECT 
        count(masterID) as cnt, A.yearID, A.teamID, A.lgID
    FROM
        (select 
        masterID,
            teamID,
            yearID,
            lgID,
            sum(AB),
            sum(H),
            sum(H) / NULLIF(sum(AB), 0) as avg
    FROM
        batting
    GROUP BY teamID , yearID , lgID , masterID
    ) B, 
    (
    -- A
    select 
        teamID,
            yearID,
            lgID,
            sum(AB),
            sum(H),
            sum(H) / NULLIF(sum(AB), 0) as avg
    FROM
        batting
    WHERE ab is not null
    GROUP BY teamID , yearID , lgID
    ) A
    WHERE
        A.avg >= B.avg AND A.teamID = B.teamID
            AND A.yearID = B.yearID
            AND A.lgID = B.lgID
    GROUP BY a.teamID , a.yearID , a.lgID
    ) C,
    (
    -- D
    SELECT 
        count(masterID) as cnt, yearID, teamID, lgID
    FROM
        batting
    WHERE ab is not null
    GROUP BY yearID , teamID , lgID
    ) D, 
    teams
-- original
WHERE
    C.cnt / NULLIF(D.cnt, 0) >= 0.75
        AND C.yearID = D.yearID
        AND C.teamID = D.teamID
        AND C.lgID = D.lgID
        AND teams.yearID = C.yearID
        AND teams.lgID = C.lgID
        AND teams.teamID = C.teamID
;