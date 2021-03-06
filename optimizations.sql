-- 1
CREATE INDEX ON public.pitching (teamid);
CREATE INDEX ON public.pitching (yearid);
CREATE INDEX ON public.teams (teamid);
CREATE INDEX ON public.teams (yearid);


-- 2
CREATE INDEX schoolp ON public.schoolsplayers (schoolid);


-- 3
CREATE INDEX ON public.appearances (masterid);


-- 4
SELECT name, t.yearid, w
	FROM teams t
	
JOIN (
     SELECT 
         max(w), yearid
         from teams 
         group by w, yearid
    ) as y 
        ON t.yearid = y.yearid  
        AND t.w = y.max
        ORDER BY yearid ASC

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


-- 6
CREATE INDEX byear ON public.batting (yearid); 	 
CREATE INDEX battingID ON public.batting (teamid); 


-- 7 
I attempted to add these indices, but none of them made any difference. 

CREATE INDEX teamid ON public.salaries (teamid);  	//nothing                   
CREATE INDEX yearid ON public.salaries (yearid); 	//nothing                     
CREATE INDEX lgid ON public.salaries (lgid);		//nothing        			  
CREATE INDEX salary ON public.salaries (salary);	//nothing                     

CREATE INDEX tteamid ON public.teams (teamid); 	        //nothing                   
CREATE INDEX tyearid ON public.teams (yearid);	        //nothing                     
CREATE INDEX tlgid ON public.teams (lgid);		//nothing
CREATE INDEX tname ON public.teams (name);		//nothing                     

Also I deleted a line in the last WHERE statement that did not change the end results, but also did not reduce the cost. 
WHERE
    A.yearID = B.yearID + 1
        AND (A.S * 2) <= (B.S)
        AND A.teamID = B.teamID
        AND A.lgID = B.lgID
        AND teams.yearID = A.yearID
--      AND teams.lgID = A.lgID    ********Removed********
        AND teams.teamID = A.teamID 	

